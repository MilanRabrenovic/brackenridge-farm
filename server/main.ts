import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { networkInterfaces } from 'node:os';
import dgram from 'node:dgram';
import { WebSocketServer } from 'ws';
import QRCode from 'qrcode';
import { MAX_PACKET_BYTES, parsePacket } from '../shared/protocol.ts';
import { Rooms } from './rooms.ts';

const DISCOVERY_PORT = 41234;

function startDiscovery(relayUrl: string) {
  const socket = dgram.createSocket('udp4');
  let timer: NodeJS.Timeout | undefined;
  socket.on('error', error => console.warn(`Relay discovery disabled: ${error.message}`));
  socket.bind(0, '0.0.0.0', () => {
    socket.setBroadcast(true);
    const payload = Buffer.from(JSON.stringify({ type: 'farm_relay', version: 1, url: relayUrl }));
    const announce = () => {
      for (const address of ['255.255.255.255', '127.0.0.1']) {
        socket.send(payload, DISCOVERY_PORT, address, error => {
          if (error) console.warn(`Relay discovery announcement failed: ${error.message}`);
        });
      }
    };
    announce();
    timer = setInterval(announce, 1500);
  });
  return () => {
    if (timer) clearInterval(timer);
    socket.close();
  };
}

const root = resolve(fileURLToPath(new URL('..', import.meta.url)));
const mime: Record<string, string> = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json', '.wasm': 'application/wasm', '.pck': 'application/octet-stream', '.png': 'image/png', '.svg': 'image/svg+xml' };
export function createRelay(options: { publicOrigin?: string; controllerOrigin?: string } = {}) {
  const rooms = new Rooms();
  const server = http.createServer(async (req, res) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Referrer-Policy', 'no-referrer');
    const url = new URL(req.url ?? '/', 'http://localhost');
    if (process.env.FARM_HTTP_DIAGNOSTICS === '1' && url.pathname.startsWith('/host/')) {
      res.once('finish', () => console.info(`[host-load] ${req.method} ${url.pathname} ${res.statusCode}`));
    }
    if (!['GET', 'HEAD'].includes(req.method ?? '')) { res.writeHead(405); res.end(); return; }
    if (url.pathname === '/health') { res.setHeader('Content-Type', 'application/json'); res.end(JSON.stringify({ ok: true, protocol: 1, rooms: rooms.rooms.size })); return; }
    if (url.pathname === '/qr') {
      const room = url.searchParams.get('room') ?? '';
      if (!rooms.has(room)) { res.writeHead(404); res.end('Room not found'); return; }
      const origin = options.controllerOrigin || options.publicOrigin || `http://${req.headers.host}`;
      const png = await QRCode.toBuffer(`${origin}/?room=${room}`, { type: 'png', margin: 1, width: 360 });
      res.setHeader('Content-Type', 'image/png'); res.setHeader('Cache-Control', 'no-store');
      res.end(req.method === 'HEAD' ? undefined : png); return;
    }
    // Explicit roots; no arbitrary filesystem exposure through this LAN service.
    const web = url.pathname.startsWith('/host/');
    const base = resolve(root, web ? 'build/web' : 'build/controller');
    let relative: string;
    try { relative = decodeURIComponent(web ? url.pathname.slice(6) : url.pathname.slice(1)); }
    catch { res.writeHead(400); res.end(); return; }
    const file = resolve(base, relative || 'index.html');
    if (!file.startsWith(base + sep)) { res.writeHead(403); res.end(); return; }
    try {
      const body = await readFile(file);
      res.setHeader('Content-Type', mime[extname(file)] || 'application/octet-stream');
      res.setHeader('Cache-Control', 'no-store');
      res.end(req.method === 'HEAD' ? undefined : body);
    } catch { res.writeHead(404); res.end(web ? 'Godot web export is not built. Run npm run export:web.' : 'Not found. Run npm run build:controller.'); }
  });
  const wss = new WebSocketServer({ noServer: true, maxPayload: MAX_PACKET_BYTES });
  server.on('upgrade', (req, socket, head) => {
    if (req.url !== '/ws' || (options.publicOrigin && req.headers.origin && req.headers.origin !== options.publicOrigin)) { socket.destroy(); return; }
    wss.handleUpgrade(req, socket, head, ws => wss.emit('connection', ws, req));
  });
  wss.on('connection', ws => {
    let alive = true, count = 0, windowAt = Date.now();
    const registration = setTimeout(() => ws.close(4000, 'Registration timeout'), 15000);
    const heartbeat = setInterval(() => { if (!alive) return ws.terminate(); alive = false; ws.ping(); }, 10000);
    ws.on('pong', () => { alive = true; });
    ws.on('message', raw => {
      if (Date.now() - windowAt >= 1000) { count = 0; windowAt = Date.now(); }
      if (++count > 150) return ws.close(4008, 'Rate limit');
      const packet = parsePacket(raw.toString());
      if (!packet) return ws.close(1008, 'Invalid packet');
      if (packet.type === 'create' || packet.type === 'join') clearTimeout(registration);
      rooms.handle(ws, packet);
    });
    ws.on('error', () => ws.terminate());
    ws.on('close', () => { clearTimeout(registration); clearInterval(heartbeat); rooms.disconnect(ws); });
  });
  return { server, rooms, close: async () => {
    rooms.close(); for (const client of wss.clients) client.terminate();
    await new Promise<void>(r => wss.close(() => r()));
    await new Promise<void>(r => server.close(() => r()));
  } };
}
if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const port = Number(process.env.PORT || 8787);
  const ips = Object.values(networkInterfaces()).flat().filter(i => i?.family === 'IPv4' && !i.internal).map(i => i!.address);
  const publicOrigin = process.env.PUBLIC_ORIGIN || `http://${ips[0] || '127.0.0.1'}:${port}`;
  const relay = createRelay({ publicOrigin: process.env.PUBLIC_ORIGIN, controllerOrigin: publicOrigin });
  relay.server.listen(port, '0.0.0.0', () => {
    console.log(`Brackenridge Farm\nControllers: ${publicOrigin}/\nBrowser host: ${publicOrigin}/host/\nNative host relay: ${publicOrigin.replace(/^http/, 'ws')}/ws\nLocal LAN development only; use HTTPS/WSS for any public deployment.`);
  });
  const stopDiscovery = startDiscovery(publicOrigin.replace(/^http/, 'ws') + '/ws');
  const shutDown = () => { stopDiscovery(); void relay.close().then(() => process.exit(0)); };
  process.once('SIGINT', shutDown);
  process.once('SIGTERM', shutDown);
}
