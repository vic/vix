// check.test.mjs — oracle tests for lib/check.js
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import os from 'node:os';

import { Store } from './store.js';
import { check, emitHookJSON, normalizeAction, writeDenyKeyCache } from './check.js';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function mktemp() {
  return mkdtempSync(join(os.tmpdir(), 'omni-check-'));
}

function seedLesson(s, key, data, project = null) {
  const ts = new Date().toISOString();
  s.db.prepare(
    `INSERT INTO node(id, kind, label, project, ts, data)
     VALUES(?, 'lesson', ?, ?, ?, ?)`,
  ).run(key, key, project, ts, JSON.stringify(data));
}

// ---------------------------------------------------------------------------
// A. ALLOW default: no lessons → decision 'allow'
// ---------------------------------------------------------------------------
{
  const dir = mktemp();
  const s = new Store(join(dir, 'db.sqlite'));

  const v = check(s, { tool_name: 'Bash', command: 'echo hello world foo', scope: 'omni' });
  assert.equal(v.decision, 'allow', 'A: expected allow with no lessons');

  s.close();
  rmSync(dir, { recursive: true });
  console.log('A. ALLOW default: PASS');
}

// ---------------------------------------------------------------------------
// B. DENY: blessed lesson + matching action → deny
// ---------------------------------------------------------------------------
{
  const dir = mktemp();
  const s = new Store(join(dir, 'db.sqlite'));

  seedLesson(s, 'lesson:deny-test', {
    type: 'dead_end',
    trigger: 'terraform apply prod cluster',
    resolution: 'never run terraform apply on prod directly',
    scope: 'omni',
    confidence: 'agent_confirmed',
    enforce: true,
    evidence: { occurrences: 3, sessions: ['s1', 's2'], projects: ['omni'], models: [] },
  }, 'omni');

  const v = check(s, { tool_name: 'Bash', command: 'terraform apply prod cluster', scope: 'omni' });
  assert.equal(v.decision, 'deny', 'B: expected deny');
  assert.equal(v.match, 'exact', 'B: expected exact match');

  s.close();
  rmSync(dir, { recursive: true });
  console.log('B. DENY exact: PASS');
}

// ---------------------------------------------------------------------------
// C. NOT-DENY (enforce=false): same lesson but enforce=false → warn not deny
// ---------------------------------------------------------------------------
{
  const dir = mktemp();
  const s = new Store(join(dir, 'db.sqlite'));

  seedLesson(s, 'lesson:no-enforce', {
    type: 'dead_end',
    trigger: 'terraform apply prod cluster',
    resolution: 'never run terraform apply on prod directly',
    scope: 'omni',
    confidence: 'agent_confirmed',
    enforce: false,   // <-- NOT enforced
    evidence: { occurrences: 3, sessions: ['s1', 's2'], projects: ['omni'], models: [] },
  }, 'omni');

  const v = check(s, { tool_name: 'Bash', command: 'terraform apply prod cluster', scope: 'omni' });
  assert.notEqual(v.decision, 'deny', 'C: must not deny when enforce=false');
  assert.equal(v.decision, 'warn', 'C: expected warn (token overlap) when enforce=false');

  s.close();
  rmSync(dir, { recursive: true });
  console.log('C. NOT-DENY (enforce=false): PASS');
}

// ---------------------------------------------------------------------------
// D. SPECIFICITY FLOOR: trigger='rm', action='rm' → NOT deny (floor fails)
// ---------------------------------------------------------------------------
{
  const dir = mktemp();
  const s = new Store(join(dir, 'db.sqlite'));

  seedLesson(s, 'lesson:floor-test', {
    type: 'dead_end',
    trigger: 'rm',
    resolution: 'do not rm',
    scope: 'omni',
    confidence: 'agent_confirmed',
    enforce: true,
    evidence: { occurrences: 3, sessions: ['s1', 's2'], projects: ['omni'], models: [] },
  }, 'omni');

  const v = check(s, { tool_name: 'Bash', command: 'rm', scope: 'omni' });
  assert.notEqual(v.decision, 'deny', 'D: must not deny short/generic action (floor)');

  s.close();
  rmSync(dir, { recursive: true });
  console.log('D. SPECIFICITY FLOOR: PASS');
}

// ---------------------------------------------------------------------------
// E. SCOPE: lesson scope='projA' → check scope='projB' → not deny
// ---------------------------------------------------------------------------
{
  const dir = mktemp();
  const s = new Store(join(dir, 'db.sqlite'));

  seedLesson(s, 'lesson:scope-test', {
    type: 'dead_end',
    trigger: 'terraform apply prod cluster',
    resolution: 'never run terraform apply on prod directly',
    scope: 'projA',   // belongs to projA
    confidence: 'agent_confirmed',
    enforce: true,
    evidence: { occurrences: 3, sessions: ['s1', 's2'], projects: ['projA'], models: [] },
  }, 'projA');

  const v = check(s, { tool_name: 'Bash', command: 'terraform apply prod cluster', scope: 'projB' });
  assert.notEqual(v.decision, 'deny', 'E: cross-project lesson must not deny');
  // also must not warn from a foreign-scoped lesson
  assert.equal(v.decision, 'allow', 'E: expected allow for cross-project scope');

  s.close();
  rmSync(dir, { recursive: true });
  console.log('E. SCOPE: PASS');
}

// ---------------------------------------------------------------------------
// F. FAIL-OPEN: check(null, {...}) → decision 'allow'
// ---------------------------------------------------------------------------
{
  const v = check(null, { tool_name: 'Bash', command: 'some command', scope: 'omni' });
  assert.equal(v.decision, 'allow', 'F: fail-open on internal error');

  console.log('F. FAIL-OPEN: PASS');
}

// ---------------------------------------------------------------------------
// G. emitHookJSON deny → permissionDecision==='deny'
// ---------------------------------------------------------------------------
{
  const verdict = {
    decision: 'deny',
    reason: 'never do this',
    lesson_ref: 'lesson:x',
    match: 'exact',
    enforce: true,
    confidence: 'agent_confirmed',
  };
  const hook = emitHookJSON(verdict);
  assert.equal(
    hook.hookSpecificOutput.permissionDecision,
    'deny',
    'G: deny verdict must emit permissionDecision=deny',
  );
  assert.ok(
    hook.hookSpecificOutput.permissionDecisionReason.startsWith('omni (learned):'),
    'G: deny reason must start with omni (learned):',
  );

  console.log('G. emitHookJSON deny: PASS');
}

console.log('ALL-PASS');
