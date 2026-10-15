import { randomBytes } from 'node:crypto';
import { WebSocket } from 'ws';
import { MAX_PLAYERS, PROTOCOL, parseInput, type Admission } from '../shared/protocol.ts';

type Player = { id: number; socket: WebSocket | null; token: string; admission: Admission; lastSeq: number; lastSeen: number; windowAt: number; count: number };
type Room = { code: string; host: WebSocket; players: Map<number, Player>; createdAt: number };
type Binding = { room: Room; player?: Player };
const token = () => randomBytes(24).toString('hex');
const code = () => Array.from(randomBytes(6), n => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[n % 32]).join('');
export function send(socket: WebSocket | null, value: unknown) {
  if (socket?.readyState === WebSocket.OPEN) socket.send(JSON.stringify(value));
}

export class Rooms {
  readonly rooms = new Map<string, Room>();
  private readonly bindings = new Map<WebSocket, Binding>();
  constructor(private readonly now = Date.now) {}
  has(room: string) { return this.rooms.has(room); }
  handle(socket: WebSocket, packet: Record<string, unknown>) {
    const binding = this.bindings.get(socket);
    if (!binding) {
      if (packet.version !== PROTOCOL) return send(socket, { type: 'error', code: 'version', message: 'Reload the controller: incompatible protocol.' });
      if (packet.type === 'create') {
        if (this.rooms.size >= 32) return send(socket, { type: 'error', code: 'busy', message: 'Relay is full.' });
        let roomCode = code();
        while (this.rooms.has(roomCode)) roomCode = code();
        const room: Room = { code: roomCode, host: socket, players: new Map(), createdAt: this.now() };
        this.rooms.set(roomCode, room); this.bindings.set(socket, { room });
        return send(socket, { type: 'created', room: roomCode, maxPlayers: MAX_PLAYERS, version: PROTOCOL });
      }
      if (packet.type === 'join') return this.join(socket, packet);
      return send(socket, { type: 'error', code: 'join_first', message: 'Create or join a room first.' });
    }
    const { room, player } = binding;
    if (packet.type === 'ping') return send(socket, { type: 'pong', nonce: packet.nonce });
    if (player) {
      if (player.admission !== 'admitted') return;
      if (packet.type === 'command' && ['pause','pin','drop','tool','replay'].includes(String(packet.command))) {
        const now = this.now();
        if (now - player.windowAt >= 1000) { player.windowAt = now; player.count = 0; }
        if (++player.count > 90) return;
        send(room.host, {type:'command',playerId:player.id,command:packet.command}); return;
      }
      if (packet.type !== 'input') return;
      const input = parseInput(packet);
      if (!input || input.seq <= player.lastSeq) return;
      const now = this.now();
      if (now - player.windowAt >= 1000) { player.windowAt = now; player.count = 0; }
      if (++player.count > 90) return;
      player.lastSeq = input.seq; player.lastSeen = now;
      return send(room.host, { ...input, playerId: player.id });
    }
    if (packet.type === 'admit') {
      const target = room.players.get(Number(packet.playerId));
      if (!target || !target.socket) return;
      target.admission = 'admitted';
      send(target.socket, { type: 'admitted', playerId: target.id });
      this.roster(room);
    } else if (packet.type === 'reject') {
      const target = room.players.get(Number(packet.playerId));
      if (target) {
        send(target.socket, { type: 'ended', message: 'The host removed this player.' });
        if (target.socket) { this.bindings.delete(target.socket); target.socket.close(); }
        room.players.delete(target.id); this.roster(room);
      }
    } else if (packet.type === 'frame_ack') {
      const target = room.players.get(Number(packet.playerId));
      if (!target || !Number.isSafeInteger(packet.seq) || Number(packet.seq) > target.lastSeq ||
          !['rendered', 'simulated'].includes(String(packet.phase))) return;
      // Position is useful to integration tests; no controller supplies authoritative world state.
      send(target.socket, { type: 'frame_ack', seq: packet.seq, phase: packet.phase, position: packet.position });
    } else if (packet.type === 'private') {
      if (typeof packet.text === 'string' && packet.text.length <= 300)
        send(room.players.get(Number(packet.playerId))?.socket ?? null, { type: 'private', text: packet.text, clue: typeof packet.clue === 'string' ? packet.clue.slice(0, 300) : undefined });
    } else if (packet.type === 'mode') {
      if (typeof packet.title === 'string' && packet.title.length <= 40 &&
          typeof packet.actionLabel === 'string' && packet.actionLabel.length <= 30)
        send(room.players.get(Number(packet.playerId))?.socket ?? null, {
          type: 'mode', title: packet.title, actionLabel: packet.actionLabel,
          hint: typeof packet.hint === 'string' ? packet.hint.slice(0, 120) : '',
        });
    }
  }
  private join(socket: WebSocket, packet: Record<string, unknown>) {
    const room = this.rooms.get(String(packet.room).trim().toUpperCase());
    if (!room) return send(socket, { type: 'error', code: 'room_missing', message: 'Room not found. Check the code on the TV.' });
    if (typeof packet.token === 'string') {
      const existing = [...room.players.values()].find(p => p.token === packet.token);
      if (existing) {
        if (existing.socket) { this.bindings.delete(existing.socket); existing.socket.close(4001, 'Reconnected elsewhere'); }
        existing.socket = socket; existing.lastSeq = -1; existing.lastSeen = this.now();
        this.bindings.set(socket, { room, player: existing });
        send(socket, { type: 'joined', room: room.code, playerId: existing.id, token: existing.token, admission: existing.admission });
        // Reset authoritative input before a new connection begins its sequence.
        send(room.host, { type: 'reset_input', playerId: existing.id });
        this.roster(room); return;
      }
    }
    if (room.players.size >= MAX_PLAYERS) return send(socket, { type: 'error', code: 'full', message: 'Both probe slots are reserved. The host can remove a disconnected player.' });
    const id = [1, 2].find(n => !room.players.has(n))!;
    const player: Player = { id, socket, token: token(), admission: 'pending', lastSeq: -1, lastSeen: this.now(), windowAt: this.now(), count: 0 };
    room.players.set(id, player); this.bindings.set(socket, { room, player });
    send(socket, { type: 'joined', room: room.code, playerId: id, token: player.token, admission: 'pending' });
    this.roster(room);
  }
  private roster(room: Room) {
    send(room.host, { type: 'roster', players: [...room.players.values()].map(p => ({ id: p.id, connected: !!p.socket, admission: p.admission })) });
  }
  disconnect(socket: WebSocket) {
    const binding = this.bindings.get(socket);
    if (!binding) return;
    this.bindings.delete(socket);
    const { room, player } = binding;
    if (player) {
      if (player.socket !== socket) return;
      player.socket = null;
      send(room.host, { type: 'reset_input', playerId: player.id });
      this.roster(room);
    } else {
      this.rooms.delete(room.code);
      for (const p of room.players.values()) {
        send(p.socket, { type: 'ended', message: 'The TV host closed. Join its new room to try again.' });
        if (p.socket) { this.bindings.delete(p.socket); p.socket.close(1000, 'Host closed'); }
      }
    }
  }
  close() {
    for (const socket of [...this.bindings.keys()]) { this.disconnect(socket); socket.close(); }
  }
}
