// T4 oracle: SSE snapshot replay from ring + /api/waste route.
import { mkdtempSync, mkdirSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { get } from 'node:http';
import assert from 'node:assert';
import { main, broadcast } from '../serve.js';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const root = mkdtempSync(join(tmpdir(), 'omni-serve-'));
mkdirSync(join(root, 'r'), { recursive: true });
const PORT = 7791;
const { server } = await main({ DB: join(root, 's.db'), ROOT: join(root, 'r'), argv: [String(PORT)] });

try {
  // a live event recorded into the ring BEFORE the client connects
  broadcast({ type: 'event', ev: { uuid: 'X', model: 'opus', in: 1000, out: 2000, cache_r: 0, cache_w: 0, usd: 0.055, tools: [] } });

  // connect an SSE client; it must immediately receive a snapshot containing that event
  const buf = await new Promise((resolve) => {
    let acc = '';
    const req = get({ host: '127.0.0.1', port: PORT, path: '/api/stream' }, (res) => {
      res.setEncoding('utf8');
      res.on('data', (c) => { acc += c; });
    });
    setTimeout(() => { req.destroy(); resolve(acc); }, 250);
  });
  assert.ok(buf.includes('event: snapshot'), 'snapshot event sent on connect');
  assert.ok(buf.includes('"usd":0.055'), 'snapshot replays ring event');

  // /api/waste route returns the taxonomy shape
  const w = await (await fetch(`http://127.0.0.1:${PORT}/api/waste`)).json();
  assert.ok('total_lost_usd' in w, 'waste has total_lost_usd');
  assert.ok(w.by_reason && 'W1' in w.by_reason, 'waste has by_reason.W1');

  // /api/punchcard route returns an array
  const pc = await (await fetch(`http://127.0.0.1:${PORT}/api/punchcard`)).json();
  assert.ok(Array.isArray(pc), 'punchcard is array');

  console.log('OK');
} finally {
  server.close();
  rmSync(root, { recursive: true, force: true });
}
process.exit(0);
