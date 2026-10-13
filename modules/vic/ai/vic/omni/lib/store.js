// store.js — node:sqlite graph store. Closed enums => invalid graph unstorable.
import { DatabaseSync } from 'node:sqlite';

export const NODE_KINDS = new Set([
  'project', 'session', 'model', 'skill', 'tool', 'concept', 'acronym',
  'file', 'prompt', 'decision', 'dispatch', 'lesson',
]);
export const EDGE_RELS = new Set([
  'in_project', 'used_model', 'used_skill', 'used_tool', 'touched_file',
  'mentions', 'parent', 'has_decision', 'defines_acronym', 'dispatched',
]);

const DDL = `
CREATE TABLE IF NOT EXISTS node(
  id TEXT PRIMARY KEY, kind TEXT NOT NULL, label TEXT, project TEXT, ts TEXT, data TEXT);
CREATE INDEX IF NOT EXISTS node_kind ON node(kind);
CREATE INDEX IF NOT EXISTS node_project ON node(project);
CREATE TABLE IF NOT EXISTS edge(
  src TEXT NOT NULL, dst TEXT NOT NULL, rel TEXT NOT NULL, weight INTEGER DEFAULT 1, data TEXT,
  PRIMARY KEY(src, dst, rel));
CREATE INDEX IF NOT EXISTS edge_src ON edge(src);
CREATE INDEX IF NOT EXISTS edge_dst ON edge(dst);
CREATE INDEX IF NOT EXISTS edge_rel ON edge(rel);
CREATE TABLE IF NOT EXISTS event(
  uuid TEXT PRIMARY KEY, session TEXT, project TEXT, ts TEXT, etype TEXT, role TEXT,
  model TEXT, in_tok INTEGER, out_tok INTEGER, cache_r INTEGER, cache_w INTEGER,
  skill TEXT, n_tools INTEGER, n_errors INTEGER, agent TEXT, data TEXT);
CREATE INDEX IF NOT EXISTS event_session ON event(session);
CREATE INDEX IF NOT EXISTS event_project ON event(project);
CREATE INDEX IF NOT EXISTS event_agent ON event(agent);
CREATE INDEX IF NOT EXISTS event_ts ON event(ts);
CREATE TABLE IF NOT EXISTS ingest_state(
  file TEXT PRIMARY KEY, size INTEGER, mtime INTEGER, lines INTEGER, sig TEXT, pver INTEGER);
`;

export class Store {
  constructor(path) {
    this.db = new DatabaseSync(path);
    this.db.exec('PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL;');
    this.db.exec(DDL);
    // Migration: add n_errors to existing event tables that pre-date this column.
    const hasCols = this.db.prepare('PRAGMA table_info(event)').all();
    if (!hasCols.some((c) => c.name === 'n_errors')) {
      this.db.exec('ALTER TABLE event ADD COLUMN n_errors INTEGER DEFAULT 0');
    }
    // Migration: add pver to existing ingest_state tables that pre-date this column.
    const hasIngestPver = this.db.prepare('PRAGMA table_info(ingest_state)').all();
    if (!hasIngestPver.some((c) => c.name === 'pver')) {
      this.db.exec('ALTER TABLE ingest_state ADD COLUMN pver INTEGER');
    }
    this._node = this.db.prepare(`INSERT INTO node(id,kind,label,project,ts,data) VALUES(?,?,?,?,?,?)
      ON CONFLICT(id) DO UPDATE SET
        label=COALESCE(excluded.label, node.label),
        project=COALESCE(excluded.project, node.project),
        ts=CASE WHEN excluded.ts>node.ts THEN excluded.ts ELSE node.ts END,
        data=COALESCE(excluded.data, node.data)`);
    this._edge = this.db.prepare(`INSERT INTO edge(src,dst,rel,weight,data) VALUES(?,?,?,?,?)
      ON CONFLICT(src,dst,rel) DO UPDATE SET weight=edge.weight+excluded.weight`);
    this._event = this.db.prepare(`INSERT INTO event
      (uuid,session,project,ts,etype,role,model,in_tok,out_tok,cache_r,cache_w,skill,n_tools,n_errors,agent,data)
      VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
      ON CONFLICT(uuid) DO UPDATE SET
        data=excluded.data,
        n_errors=excluded.n_errors,
        n_tools=excluded.n_tools,
        skill=excluded.skill,
        model=excluded.model,
        role=excluded.role`);
    this._getState = this.db.prepare('SELECT * FROM ingest_state WHERE file=?');
    this._setState = this.db.prepare(`INSERT INTO ingest_state(file,size,mtime,lines,sig,pver) VALUES(?,?,?,?,?,?)
      ON CONFLICT(file) DO UPDATE SET size=excluded.size,mtime=excluded.mtime,lines=excluded.lines,sig=excluded.sig,pver=excluded.pver`);
  }

  node(kind, key, label = null, project = null, ts = null, data = null) {
    if (!NODE_KINDS.has(kind)) throw new TypeError('bad node kind: ' + kind);
    const id = kind + ':' + key;
    this._node.run(id, kind, label, project, ts, data == null ? null : JSON.stringify(data));
    return id;
  }
  edge(src, dst, rel, weight = 1, data = null) {
    if (!EDGE_RELS.has(rel)) throw new TypeError('bad edge rel: ' + rel);
    this._edge.run(src, dst, rel, weight, data == null ? null : JSON.stringify(data));
  }
  event(e) {
    const u = e.usage || {};
    const N = (v) => (v == null ? null : v); // undefined|null -> null (bind-safe)
    this._event.run(N(e.uuid), N(e.session), N(e.project), N(e.ts), N(e.etype), N(e.role), N(e.model),
      u.in | 0, u.out | 0, u.cache_r | 0, u.cache_w | 0, N(e.skill), e.n_tools | 0, e.n_errors | 0,
      e.agent ?? null, e.data == null ? null : JSON.stringify(e.data));
  }
  getState(file) { return this._getState.get(file) || null; }
  setState(file, size, mtime, lines, sig, pver) { this._setState.run(file, size, mtime, lines, sig, pver); }

  all(sql, ...a) { return this.db.prepare(sql).all(...a); }
  get(sql, ...a) { return this.db.prepare(sql).get(...a); }
  tx(fn) { this.db.exec('BEGIN'); try { fn(); this.db.exec('COMMIT'); } catch (e) { this.db.exec('ROLLBACK'); throw e; } }
  close() { this.db.close(); }
}
