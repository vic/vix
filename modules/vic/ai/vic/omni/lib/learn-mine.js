// learn-mine.js — rule-based lesson mining for omni's learning feature.
// Pure + deterministic. No LLM. No writes to db (caller upserts).

const ERR_RE = /(?:Error|error:|ENOENT|EACCES|cannot |failed|not found|undefined|panic|exception|refused|timed? out)[^\n]{0,120}/i;

// Strip volatile tokens: hex strings ≥7 chars, absolute paths, line:col refs,
// plain numbers, uuid-like sequences. Collapse whitespace. Lowercase.
function normalize(sig) {
  return sig
    .toLowerCase()
    .replace(/\b[0-9a-f]{7,}\b/g, '·')           // hex ids
    .replace(/\/[^\s:,)"']{4,}/g, '·')             // absolute paths
    .replace(/\b\d+:\d+\b/g, '·')                  // line:col
    .replace(/\b\d{4,}\b/g, '·')                   // long numbers
    .replace(/[0-9a-f]{8}-[0-9a-f-]{18,}/g, '·')  // uuids
    .replace(/\s+/g, ' ')
    .trim();
}

// M2 — Recurring error signatures (cross-session aggregate)
function mineErrorSignatures(s) {
  const rows = s.all(
    `SELECT uuid, session, project, model, ts, data
     FROM event
     WHERE etype='assistant' AND n_errors>0`,
  );

  // sig_key -> { norm, representative, sessions:Set, projects:Set, models:Set, occurrences }
  const groups = new Map();

  for (const row of rows) {
    if (!row.data) continue;
    const text = typeof row.data === 'string' ? row.data : JSON.stringify(row.data);
    const match = text.match(ERR_RE);
    if (!match) continue;

    const raw = match[0];
    const norm = normalize(raw);
    if (!norm) continue;

    if (!groups.has(norm)) {
      groups.set(norm, {
        norm,
        representative: raw,
        sessions: new Set(),
        projects: new Set(),
        models: new Set(),
        occurrences: 0,
      });
    }
    const g = groups.get(norm);
    g.sessions.add(row.session);
    if (row.project) g.projects.add(row.project);
    if (row.model) g.models.add(row.model);
    g.occurrences += 1;
  }

  const lessons = [];
  for (const g of groups.values()) {
    if (g.sessions.size < 2) continue; // must span ≥2 distinct sessions

    const projects = [...g.projects];
    const scope = projects.length === 1 ? projects[0] : 'GLOBAL';

    lessons.push({
      type: 'error_signature',
      signature: g.norm,
      trigger: g.representative,
      resolution: '',
      scope,
      confidence: 'observed',
      source: 'rule',
      evidence: {
        sessions: [...g.sessions],
        projects,
        occurrences: g.occurrences,
        models: [...g.models],
      },
    });
  }

  return lessons;
}

// M3 — Skill×Model cost-efficacy router
function mineSkillEfficacy(s) {
  const rows = s.all(
    `SELECT skill, model,
            COUNT(DISTINCT session) AS runs,
            SUM(out_tok) AS out_tok,
            SUM(in_tok) AS in_tok,
            SUM(n_errors) AS errs,
            COUNT(*) AS turns
     FROM event
     WHERE skill IS NOT NULL AND skill != ''
     GROUP BY skill, model`,
  );

  const lessons = [];
  for (const row of rows) {
    if (!row.skill || !row.model) continue;
    if ((row.runs || 0) < 2) continue;

    const runs = row.runs || 0;
    const out_tok = row.out_tok || 0;
    const turns = row.turns || 1;
    const errs = row.errs || 0;

    lessons.push({
      type: 'skill_efficacy',
      signature: `skill:${row.skill} model:${row.model}`,
      trigger: `${row.skill} × ${row.model}`,
      resolution: `${runs} runs · ${out_tok} out_tok (${Math.round(out_tok / turns)}/turn) · ${errs} errs · ${(errs / turns).toFixed(2)} err/turn`,
      scope: 'GLOBAL',
      confidence: 'observed',
      source: 'rule',
      evidence: {
        sessions: [],
        projects: [],
        occurrences: runs,
        models: [row.model],
      },
    });
  }

  return lessons;
}

// M4 — Error → Fix pairs (error turn followed by a clean recovery turn)
// NOTE: In the current schema, n_errors>0 rows are etype='user' and always
// have data=NULL (error text is not persisted in event.data). The etype guard
// is intentionally removed so the query matches the real rows; the null-data
// guard below filters them out gracefully. Fixture rows (etype='assistant'
// with non-null data) continue to work unchanged.
function mineErrorFix(s) {
  // Step 1: get all error turns that have prose data (any etype)
  const errorTurns = s.all(
    `SELECT uuid, session, project, model, ts, data
     FROM event
     WHERE n_errors>0 AND data IS NOT NULL`,
  );

  // Step 2: cache timeline per session (only load once)
  const timelines = new Map();
  function getTimeline(session) {
    if (!timelines.has(session)) {
      const rows = s.all(
        `SELECT ts, n_errors, n_tools, data
         FROM event
         WHERE session=? AND etype IN ('assistant','user') AND data IS NOT NULL
         ORDER BY ts`,
        session,
      );
      timelines.set(session, rows);
    }
    return timelines.get(session);
  }

  // sig_key -> { normSig, trigger, resolution, sessions, projects, models, occurrences }
  const groups = new Map();

  for (const err of errorTurns) {
    const text = typeof err.data === 'string' ? err.data : JSON.stringify(err.data);
    const match = text.match(ERR_RE);
    if (!match) continue;

    const raw = match[0];
    const normSig = normalize(raw);
    if (!normSig) continue;

    // Step 3: find the FIRST recovery turn after this error turn in same session
    const timeline = getTimeline(err.session);
    const recovery = timeline.find(
      (t) => t.ts > err.ts && t.n_errors === 0 && t.n_tools > 0,
    );
    if (!recovery) continue; // unresolved, skip

    // Step 4: trim resolution prose to ~300 chars
    const resText = typeof recovery.data === 'string' ? recovery.data : JSON.stringify(recovery.data);
    const resolution = resText.trim().slice(0, 300);

    // Step 5: group by normalized signature
    if (!groups.has(normSig)) {
      groups.set(normSig, {
        normSig,
        trigger: raw,
        resolution,
        sessions: new Set(),
        projects: new Set(),
        models: new Set(),
        occurrences: 0,
      });
    }
    const g = groups.get(normSig);
    g.sessions.add(err.session);
    if (err.project) g.projects.add(err.project);
    if (err.model) g.models.add(err.model);
    g.occurrences += 1;
  }

  const lessons = [];
  for (const g of groups.values()) {
    const projects = [...g.projects];
    const scope = projects.length === 1 ? projects[0] : 'GLOBAL';

    lessons.push({
      type: 'error_fix',
      signature: g.normSig,
      trigger: g.trigger,
      resolution: g.resolution,
      scope,
      confidence: 'observed',
      source: 'rule',
      evidence: {
        sessions: [...g.sessions],
        projects,
        occurrences: g.occurrences,
        models: [...g.models],
      },
    });
  }

  return lessons;
}

export function mineLessons(s) {
  const lessons = [
    ...mineErrorSignatures(s),
    ...mineSkillEfficacy(s),
    ...mineErrorFix(s),
  ];
  return lessons;
}
