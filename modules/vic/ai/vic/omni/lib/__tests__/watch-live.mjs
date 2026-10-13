// T3 oracle: fs.watch ingests one changed .jsonl file + broadcasts $-tagged events.
import { mkdtempSync, mkdirSync, writeFileSync, appendFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import assert from 'node:assert';
import { Store } from '../store.js';
import { startWatcher } from '../watch.js';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const root = mkdtempSync(join(tmpdir(), 'omni-watch-'));
const store = new Store(join(root, 't.db'));
const projDir = join(root, '-x');
mkdirSync(projDir, { recursive: true });
const file = join(projDir, 's.jsonl');
const got = [];
const handle = startWatcher({ ROOT: root, store, broadcast: (m) => got.push(m), debounceMs: 60 });

const line = (uuid, out) => JSON.stringify({ type: 'assistant', uuid, sessionId: 'S1', timestamp: '2026-06-16T10:00:00.000Z',
  message: { role: 'assistant', model: 'claude-opus-4-8', content: 'hi', usage: { input_tokens: 0, output_tokens: out } } });

try {
  await sleep(150);                       // let recursive watch settle
  writeFileSync(file, line('a', 100) + '\n');
  await sleep(350);
  const evs = got.filter((m) => m.type === 'event');
  assert.ok(evs.length >= 1, 'got >=1 broadcast event');
  assert.ok(evs.some((m) => m.ev.usd > 0), 'event carries usd>0');
  // exact: opus 100 out tokens = 100*25/1e6 = 0.0025
  assert.ok(evs.some((m) => Math.abs(m.ev.usd - 0.0025) < 1e-9), 'usd exact');
  const after1 = got.length;

  // append a 2nd jsonl line -> another event
  appendFileSync(file, line('b', 50) + '\n');
  await sleep(350);
  assert.ok(got.length > after1, 'append fired another event');
  const after2 = got.length;

  // non-jsonl change -> no ingest, no broadcast
  writeFileSync(join(projDir, 'note.txt'), 'not a transcript');
  await sleep(250);
  assert.strictEqual(got.length, after2, 'non-jsonl change ignored');

  console.log('OK');
} finally {
  handle.stop();
  rmSync(root, { recursive: true, force: true });
}
process.exit(0);
