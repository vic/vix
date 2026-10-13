// learn-mine.test.mjs — self-test for learn-mine.js
// Uses an in-memory node:sqlite db seeded with fixture rows.
import { DatabaseSync } from 'node:sqlite';
import { mineLessons } from './learn-mine.js';

// ---- Minimal Store shim (mirrors Store.all / Store.get) ----------------
function makeStore(db) {
  return {
    db,
    all(sql, ...args) { return db.prepare(sql).all(...args); },
    get(sql, ...args) { return db.prepare(sql).get(...args); },
  };
}

// ---- Seed an in-memory db ----------------------------------------------
const db = new DatabaseSync(':memory:');

db.exec(`
  CREATE TABLE event(
    uuid TEXT PRIMARY KEY, session TEXT, project TEXT, ts TEXT,
    etype TEXT, role TEXT, model TEXT,
    in_tok INTEGER, out_tok INTEGER, cache_r INTEGER, cache_w INTEGER,
    skill TEXT, n_tools INTEGER, n_errors INTEGER, agent TEXT, data TEXT);
`);

const ins = db.prepare(`
  INSERT INTO event
    (uuid,session,project,ts,etype,role,model,in_tok,out_tok,cache_r,cache_w,
     skill,n_tools,n_errors,agent,data)
  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
`);

// Helper
const ev = (uuid, session, project, model, skill, n_errors, data, out_tok = 100, in_tok = 50) =>
  ins.run(uuid, session, project, '2025-01-01T00:00:00Z', 'assistant', 'assistant',
    model, in_tok, out_tok, 0, 0, skill, 0, n_errors, null, data);

// M2 fixtures — same error signature across TWO sessions
ev('e1', 'ses-A', 'proj-alpha', 'claude-3-5', null, 1,
  'Tool call failed: ENOENT no such file or directory \'/tmp/build/out.js\'');
ev('e2', 'ses-B', 'proj-alpha', 'claude-3-5', null, 1,
  'Tool call failed: ENOENT no such file or directory \'/home/vic/other/file.js\'');
// Single-session error — should NOT appear
ev('e3', 'ses-C', 'proj-beta', 'claude-3-opus', null, 1,
  'Error: connection refused localhost:5432');

// M3 fixtures — two distinct (skill, model) combos, each with ≥2 runs
// skill='coding', model='claude-3-5', sessions: ses-D and ses-E
ev('e4', 'ses-D', 'proj-alpha', 'claude-3-5', 'coding', 0, null, 200, 80);
ev('e5', 'ses-E', 'proj-alpha', 'claude-3-5', 'coding', 1, null, 180, 90);
// skill='research', model='claude-3-opus', sessions: ses-F and ses-G
ev('e6', 'ses-F', 'proj-beta', 'claude-3-opus', 'research', 0, null, 300, 120);
ev('e7', 'ses-G', 'proj-beta', 'claude-3-opus', 'research', 0, null, 320, 110);

// M4 fixtures — error→fix pairs across TWO sessions sharing the same error signature
// Use a helper that sets n_tools explicitly
const insEv = db.prepare(`
  INSERT INTO event
    (uuid,session,project,ts,etype,role,model,in_tok,out_tok,cache_r,cache_w,
     skill,n_tools,n_errors,agent,data)
  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
`);
// s1: error at ts=100, recovery at ts=200
// column order: uuid,session,project,ts,etype,role,model,in_tok,out_tok,cache_r,cache_w,skill,n_tools,n_errors,agent,data
insEv.run('f1','s1','proj-fix','100','assistant','assistant','claude-3-5',50,100,0,0,null,0,1,null,
  "Error: ENOENT cannot open '/tmp/x' no such file or directory");
insEv.run('f2','s1','proj-fix','200','assistant','assistant','claude-3-5',50,100,0,0,null,2,0,null,
  "Created the missing /tmp/x file, the build passes now.");
// s2: same ENOENT error class at ts=300, recovery at ts=400
insEv.run('f3','s2','proj-fix','300','assistant','assistant','claude-3-5',50,100,0,0,null,0,1,null,
  "Error: ENOENT cannot open '/tmp/y' no such file or directory");
insEv.run('f4','s2','proj-fix','400','assistant','assistant','claude-3-5',50,100,0,0,null,1,0,null,
  "Made the directory, works.");

// ---- Run ---------------------------------------------------------------
const s = makeStore(db);
const lessons = mineLessons(s);

// ---- Assertions --------------------------------------------------------
let failures = 0;
function assert(cond, msg) {
  if (!cond) { console.error('FAIL:', msg); failures++; }
}

assert(Array.isArray(lessons), 'result must be array');

// Every item has required shape
for (const l of lessons) {
  assert(typeof l.type === 'string', `type must be string: ${JSON.stringify(l)}`);
  assert(typeof l.signature === 'string', `signature must be string: ${l.type}`);
  assert(typeof l.scope === 'string', `scope must be string: ${l.type}`);
  assert(l.confidence === 'observed', `confidence must be 'observed': ${l.type}`);
  assert(l.source === 'rule', `source must be 'rule': ${l.type}`);
  assert(l.evidence && typeof l.evidence.occurrences === 'number',
    `evidence.occurrences missing: ${l.type}`);
}

const errorSigs = lessons.filter((l) => l.type === 'error_signature');
const skillEff  = lessons.filter((l) => l.type === 'skill_efficacy');
const errorFix  = lessons.filter((l) => l.type === 'error_fix');

// M2: at least 1 error_signature spanning ≥2 sessions (ENOENT across ses-A and ses-B)
assert(errorSigs.length >= 1, 'expected ≥1 error_signature');
const enoent = errorSigs.find((l) => l.signature.includes('enoent'));
assert(enoent != null, 'expected an enoent error_signature');
assert(enoent.evidence.sessions.length >= 2, 'enoent must span ≥2 sessions');

// Single-session error must NOT appear
const refused = errorSigs.find((l) => l.signature.includes('refused'));
assert(refused == null, 'single-session error must be filtered out');

// M3: at least 2 skill_efficacy entries
assert(skillEff.length >= 2, `expected ≥2 skill_efficacy, got ${skillEff.length}`);
const coding = skillEff.find((l) => l.signature.includes('coding'));
const research = skillEff.find((l) => l.signature.includes('research'));
assert(coding != null, 'expected coding skill_efficacy');
assert(research != null, 'expected research skill_efficacy');
assert(coding.evidence.occurrences >= 2, 'coding runs must be ≥2');

// M4: at least 1 error_fix lesson
assert(errorFix.length >= 1, `expected ≥1 error_fix, got ${errorFix.length}`);

// The two ENOENT sessions s1+s2 normalize to the same sig → one combined lesson
const enoentFix = errorFix.find((l) => l.signature.includes('enoent'));
assert(enoentFix != null, 'expected an enoent error_fix lesson');
assert(enoentFix.resolution.length > 0, 'error_fix must have non-empty resolution');
assert(enoentFix.evidence.occurrences >= 2,
  `error_fix occurrences must be ≥2, got ${enoentFix.evidence.occurrences}`);
assert(enoentFix.evidence.sessions.includes('s1'), 'error_fix must include session s1');
assert(enoentFix.evidence.sessions.includes('s2'), 'error_fix must include session s2');

// M2+M3 still intact (regression guard)
assert(errorSigs.length >= 1, 'M2 error_signature must still appear');
assert(skillEff.length >= 2, 'M3 skill_efficacy must still appear');

// ---- Report ------------------------------------------------------------
console.log(`\nMineLessons → ${lessons.length} lessons`);
console.log(`  error_signature: ${errorSigs.length}`);
console.log(`  skill_efficacy:  ${skillEff.length}`);
console.log(`  error_fix:       ${errorFix.length}`);

if (errorSigs.length > 0) {
  const sample = errorSigs[0];
  console.log('\nSample error_signature:');
  console.log('  sig     :', sample.signature);
  console.log('  trigger :', sample.trigger);
  console.log('  scope   :', sample.scope);
  console.log('  sessions:', sample.evidence.sessions.length);
  console.log('  occur   :', sample.evidence.occurrences);
}
if (skillEff.length > 0) {
  const sample = skillEff[0];
  console.log('\nSample skill_efficacy:');
  console.log('  sig        :', sample.signature);
  console.log('  resolution :', sample.resolution);
  console.log('  occurrences:', sample.evidence.occurrences);
}
if (errorFix.length > 0) {
  const sample = errorFix[0];
  console.log('\nSample error_fix:');
  console.log('  sig        :', sample.signature);
  console.log('  trigger    :', sample.trigger);
  console.log('  resolution :', sample.resolution.slice(0, 80));
  console.log('  sessions   :', sample.evidence.sessions);
  console.log('  occurrences:', sample.evidence.occurrences);
}

if (failures > 0) {
  console.error(`\n${failures} assertion(s) FAILED`);
  process.exit(1);
}
console.log('\nALL-PASS');
