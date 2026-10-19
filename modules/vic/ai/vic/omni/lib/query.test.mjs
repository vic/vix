// Oracle tests for lib/query.js — FIX 1/2/3 (FORGE, ISOLATION, T2-REACHABLE).
// Run: OMNI_DB=/tmp/omni_fix.db node lib/query.test.mjs
// (Expects a copy of omni.db at OMNI_DB, or creates a fresh in-memory-like db.)
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { Store } from './store.js';
import * as Q from './query.js';

const DB = process.env.OMNI_DB || ':memory:';
let PASS = 0;
function ok(name) { PASS++; console.log(`ok ${PASS} - ${name}`); }

const s = new Store(DB);

function lessonId(scope, type, sig) {
  return 'lesson:' + createHash('sha1')
    .update(scope + '\x1f' + type + '\x1f' + sig)
    .digest('hex');
}

function insertLesson(store, scope, type, sig, evidence) {
  const id = lessonId(scope, type, sig);
  const data = JSON.stringify({ type, signature: sig, scope, evidence, resolution: 'test', confidence: 'observed', source: 'miner' });
  store.db.prepare(`INSERT INTO node(id,kind,label,project,ts,data) VALUES(?,?,?,?,?,?)
    ON CONFLICT(id) DO UPDATE SET data=excluded.data`)
    .run(id, 'lesson', sig.slice(0, 120), scope === 'GLOBAL' ? null : scope, new Date().toISOString(), data);
  return id;
}

// ── FORGE TEST ───────────────────────────────────────────────────────────────
// Call Q.learn 3x with the same new signature (no session param in schema now).
// The resulting node's evidence.occurrences must stay 1 (seeded default, no
// increment per call) and tier must be T0 (no promotion from repeat calls).
{
  const sig = 'forge-test-sig-' + Date.now();
  const base = { type: 'error_fix', signature: sig, scope: 'GLOBAL', resolution: 'r', write: 'dry' };

  Q.learn(s, base);
  Q.learn(s, base);
  const r3 = Q.learn(s, base);

  // Read the node back
  const id = lessonId('GLOBAL', 'error_fix', sig);
  const row = s.get('SELECT data FROM node WHERE id=?', id);
  assert.ok(row, 'FORGE: node exists after learn');
  const stored = JSON.parse(row.data);
  assert.equal(stored.evidence.occurrences, 1, 'FORGE: occurrences stays 1 (no increment per call)');
  assert.equal(r3.tier, 'T0', 'FORGE: tier is T0 (repeat calls do not promote)');
  ok('FORGE — repeat learn() calls do not increment occurrences or promote');
}

// ── RECALL-ISOLATION TEST ────────────────────────────────────────────────────
// Insert two lesson nodes: one GLOBAL, one scoped to project 'pa'.
// recall(s,{}) → ONLY the GLOBAL one.
// recall(s,{scope:'pa'}) → pa (and global via include_global).
{
  const sigGlobal = 'isolation-global-' + Date.now();
  const sigPa = 'isolation-pa-' + Date.now();
  insertLesson(s, 'GLOBAL', 'error_fix', sigGlobal, { sessions: [], projects: [], occurrences: 1, models: [] });
  insertLesson(s, 'pa', 'error_fix', sigPa, { sessions: [], projects: ['pa'], occurrences: 1, models: [] });

  // No scope → GLOBAL only
  const globalOnly = Q.recall(s, {});
  const gotGlobal = globalOnly.some((r) => r.signature === sigGlobal);
  const gotPa = globalOnly.some((r) => r.signature === sigPa);
  assert.equal(gotGlobal, true, 'ISOLATION: recall({}) includes GLOBAL lesson');
  assert.equal(gotPa, false, 'ISOLATION: recall({}) does NOT include project pa lesson');

  // scope='pa' with include_global (default true) → both
  const paAndGlobal = Q.recall(s, { scope: 'pa' });
  const gotPaScoped = paAndGlobal.some((r) => r.signature === sigPa);
  const gotGlobalScoped = paAndGlobal.some((r) => r.signature === sigGlobal);
  assert.equal(gotPaScoped, true, 'ISOLATION: recall({scope:pa}) includes pa lesson');
  assert.equal(gotGlobalScoped, true, 'ISOLATION: recall({scope:pa}) includes GLOBAL lesson via include_global');

  // scope='pa' with include_global=false → only pa
  const paOnly = Q.recall(s, { scope: 'pa', include_global: false });
  const gotPaOnly = paOnly.some((r) => r.signature === sigPa);
  const gotGlobalExcluded = paOnly.some((r) => r.signature === sigGlobal);
  assert.equal(gotPaOnly, true, 'ISOLATION: recall({scope:pa,include_global:false}) includes pa lesson');
  assert.equal(gotGlobalExcluded, false, 'ISOLATION: recall({scope:pa,include_global:false}) excludes GLOBAL');

  ok('ISOLATION — recall scope filtering has no cross-project leak');
}

// ── T2-REACHABLE TEST ────────────────────────────────────────────────────────
// Seed a lesson node with evidence matching T2 thresholds (occurrences>=5, projects>=2).
// Q.learn with promote_skill → tier 'T2'.
{
  const sig = 't2-reachable-' + Date.now();
  const ev = { occurrences: 5, sessions: ['s1', 's2'], projects: ['a', 'b'], models: [] };
  insertLesson(s, 'GLOBAL', 'skill_efficacy', sig, ev);

  const r = Q.learn(s, {
    type: 'skill_efficacy',
    signature: sig,
    scope: 'GLOBAL',
    promote_skill: 'my-skill',
    write: 'dry',
  });

  assert.equal(r.tier, 'T2', `T2-REACHABLE: tier is T2 (got ${r.tier})`);
  ok('T2-REACHABLE — mined evidence with >=5 occ, >=2 projects yields T2 on promote_skill');
}

// Close the store
s.close();
console.log(`\n# ${PASS} cases passed`);
