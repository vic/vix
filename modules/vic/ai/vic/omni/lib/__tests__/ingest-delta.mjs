// T1 oracle: ingestFile returns delta projections; fileMeta resolves tagging.
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import assert from 'node:assert';
import { Store } from '../store.js';
import { ingestFile, fileMeta } from '../ingest.js';

const root = mkdtempSync(join(tmpdir(), 'omni-ingest-'));
try {
  const slug = '-tmp-x';
  const projDir = join(root, slug);
  mkdirSync(projDir, { recursive: true });
  const sess = join(projDir, 'sess.jsonl');
  const FP = '/tmp/x/foo.js';
  const l0 = JSON.stringify({ type: 'assistant', uuid: 'u0', sessionId: 'S1', timestamp: '2026-06-16T10:00:00.000Z',
    message: { role: 'assistant', model: 'claude-opus-4-8', content: 'hello world', usage: { input_tokens: 100, output_tokens: 50, cache_read_input_tokens: 7, cache_creation_input_tokens: 3 } } });
  const l1 = JSON.stringify({ type: 'assistant', uuid: 'u1', sessionId: 'S1', timestamp: '2026-06-16T10:00:01.000Z',
    message: { role: 'assistant', model: 'claude-opus-4-8', content: [{ type: 'tool_use', name: 'Edit', id: 't1', input: { file_path: FP } }] } });
  writeFileSync(sess, l0 + '\n' + l1 + '\n');

  const db = join(root, 't.db');
  const store = new Store(db);
  const meta = fileMeta(root, sess);
  const r = ingestFile(store, sess, slug, meta);

  assert.strictEqual(r.skipped, false, 'not skipped');
  assert.strictEqual(r.processed, 2, 'processed 2');
  assert.strictEqual(r.events.length, r.processed, 'events.length === processed');
  assert.strictEqual(r.events[0].in, 100, 'ev0 in tokens');
  assert.strictEqual(r.events[0].out, 50, 'ev0 out tokens');
  assert.strictEqual(r.events[0].cache_r, 7, 'ev0 cache_r');
  assert.strictEqual(r.events[0].cache_w, 3, 'ev0 cache_w');
  assert.ok(r.events[0].text.length <= 200, 'text <=200');
  assert.strictEqual(r.events[1].tools[0].name, 'Edit', 'ev1 tool name');
  assert.strictEqual(r.events[1].tools[0].file, FP, 'ev1 tool file path');

  // idempotent re-ingest -> skipped, empty events
  const r2 = ingestFile(store, sess, slug, meta);
  assert.strictEqual(r2.skipped, true, 're-ingest skipped');
  assert.deepStrictEqual(r2.events, [], 'skipped events empty');

  // fileMeta tagging: top-level + subagent
  const top = fileMeta(root, sess);
  assert.strictEqual(top.slug, slug, 'top slug');
  assert.strictEqual(top.subagent, false, 'top not subagent');
  const subAbs = join(root, slug, 'XUUID', 'subagents', 'agent-Z.jsonl');
  const sub = fileMeta(root, subAbs);
  assert.strictEqual(sub.slug, slug, 'sub slug');
  assert.strictEqual(sub.subagent, true, 'sub is subagent');
  assert.strictEqual(sub.agentId, 'agent-Z', 'sub agentId');
  assert.strictEqual(sub.parent, 'XUUID', 'sub parent');

  store.close();
  console.log('OK');
} finally {
  rmSync(root, { recursive: true, force: true });
}
