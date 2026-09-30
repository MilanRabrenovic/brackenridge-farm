export const PROTOCOL = 1;
export const MAX_PLAYERS = 2; // Committed hackathon slice supports two; four players are deferred.
export const MAX_PACKET_BYTES = 4096;
export const STALE_INPUT_MS = 250;

export type Input = { type: 'input'; seq: number; x: number; y: number; action: boolean };
export type Admission = 'pending' | 'admitted';
export type Phase = 'rendered' | 'simulated';
export function parseInput(value: Record<string, unknown>): Input | null {
  if (value.type !== 'input' || !Number.isSafeInteger(value.seq) || Number(value.seq) < 0 ||
      typeof value.x !== 'number' || !Number.isFinite(value.x) || Math.abs(value.x) > 1 ||
      typeof value.y !== 'number' || !Number.isFinite(value.y) || Math.abs(value.y) > 1 ||
      typeof value.action !== 'boolean') return null;
  const length = Math.hypot(value.x, value.y);
  return { type: 'input', seq: Number(value.seq), x: value.x / Math.max(1, length),
    y: value.y / Math.max(1, length), action: value.action };
}
export function parsePacket(raw: string): Record<string, unknown> | null {
  if (Buffer.byteLength(raw) > MAX_PACKET_BYTES) return null;
  try { const v: unknown = JSON.parse(raw); return v !== null && typeof v === 'object' && !Array.isArray(v) ? v as Record<string, unknown> : null; }
  catch { return null; }
}
