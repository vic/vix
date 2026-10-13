// T2 oracle: waste() taxonomy + eventCost + burnPunchcard.
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import assert from 'node:assert';
import { Store } from '../store.js';
import { waste, eventCost, burnPunchcard } from '../query.js';

const root = mkdtempSync(join(tmpdir(), 'omni-waste-'));
try {
  let uid = 0;
  const ev = (store, session, model, out, n, extra = {}) => {
    for (let i = 0; i < n; i++) {
      store.event({
        uuid: 'e' + (uid++), session, project: '/p', ts: '2026-06-16T10:00:00.000Z',
        etype: 'assistant', role: 'assistant', model,
        usage: { in: extra.in || 0, out, cache_r: extra.cr || 0, cache_w: 0 },
        n_tools: 0, n_errors: extra.errs || 0, agent: null, data: null,
      });
    }
  };

  // ---- (a) main corpus: 1 over-routed tiny opus session + 4 normal opus + 1 haiku ----
  const dbA = join(root, 'a.db');
  const A = new Store(dbA);
  ev(A, 'OPUS_TINY', 'claude-opus-4-8', 20, 50);      // perEv 20 — over-routed
  for (let k = 0; k < 4; k++) ev(A, 'OPUS_N' + k, 'claude-opus-4-8', 2000, 5); // perEv 2000 — normal
  ev(A, 'HAIKU1', 'claude-haiku-4-5', 20, 50);        // cheap — never W1
  const wa = waste(A);

  const w1 = wa.items.filter((x) => x.reason === 'W1');
  assert.strictEqual(w1.length, 1, 'exactly one W1');
  assert.strictEqual(w1[0].id, 'OPUS_TINY', 'W1 on the tiny opus session');
  // usd_lost ≈ opusUsd − sonnetUsd for 1000 out tokens = 0.025 − 0.015 = 0.01
  assert.ok(Math.abs(w1[0].usd_lost - 0.01) < 1e-6, 'W1 usd_lost ≈ 0.01, got ' + w1[0].usd_lost);
  assert.ok(wa.by_reason.W1 > 0, 'by_reason.W1 > 0');
  assert.ok(wa.total_lost_usd >= w1[0].usd_lost, 'total >= W1');
  A.close();

  // ---- (b) negative control: all-haiku corpus -> no W1 ----
  const dbB = join(root, 'b.db');
  const B = new Store(dbB);
  ev(B, 'H1', 'claude-haiku-4-5', 500, 6);
  ev(B, 'H2', 'claude-haiku-4-5', 400, 4);
  const wb = waste(B);
  assert.strictEqual(wb.by_reason.W1, 0, 'all-haiku -> by_reason.W1 === 0');
  assert.strictEqual(wb.items.filter((x) => x.reason === 'W1').length, 0, 'no W1 items');

  // ---- punchcard sanity: one populated cell (Tue=2, 10:00 UTC) with usd>0 ----
  const pc = burnPunchcard(B);
  assert.ok(pc.length >= 1, 'punchcard has cells');
  const cell = pc.find((c) => c.dow === 2 && c.hour === 10);
  assert.ok(cell && cell.usd > 0 && cell.events > 0, 'Tue 10:00 cell populated');
  B.close();

  // ---- (c) eventCost exact ----
  assert.strictEqual(eventCost({ model: 'opus', in: 1000, out: 2000 }), 0.055, 'eventCost opus');
  assert.strictEqual(eventCost({ model: 'claude-haiku-4-5', in: 1000, out: 1000 }), 0.006, 'eventCost haiku');

  console.log('OK');
} finally {
  rmSync(root, { recursive: true, force: true });
}
