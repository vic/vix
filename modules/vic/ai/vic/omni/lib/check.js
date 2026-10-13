// check.js — enforcement verdict engine for omni.
// Consults learned lessons from the Store and decides allow/warn/deny.
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import os from 'node:os';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const STOPWORDS = new Set([
  'error', 'failed', 'fail', 'bash', 'sh', 'npm', 'node', 'git',
  'cannot', 'not', 'found', 'rm', 'cd', 'ls', 'the', 'a', 'to', 'of', 'in',
  '.', '/', '',
]);

const TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

// ---------------------------------------------------------------------------
// 1. normalizeAction
// ---------------------------------------------------------------------------

/**
 * Normalise an action string (command, file path, or any text) into a
 * canonical key and a Set of salient tokens.
 *
 * @param {string} s
 * @returns {{ key: string, tokens: Set<string> }}
 */
export function normalizeAction(s) {
  if (typeof s !== 'string' || s.trim() === '') {
    return { key: '', tokens: new Set() };
  }

  // 1. Lowercase + collapse whitespace
  const lower = s.toLowerCase().replace(/\s+/g, ' ').trim();

  // 2. For a command-like string: reduce to argv0 + salient flags + last operand
  //    Detect "command-like": starts with a word (no spaces in first token)
  const parts = lower.split(' ');
  const argv0 = parts[0];
  const flags = parts.filter((p) => p.startsWith('-'));
  const operands = parts.filter((p) => !p.startsWith('-'));
  const lastOperand = operands.length > 1 ? operands[operands.length - 1] : null;

  const reduced = [argv0, ...flags, ...(lastOperand ? [lastOperand] : [])].join(' ');

  // 3. Tokenize on whitespace / '/' / '='
  const raw = reduced.split(/[\s/=]+/);

  // 4. Drop stopwords and generic denylist
  const tokens = new Set(raw.filter((t) => t.length > 0 && !STOPWORDS.has(t)));

  const key = [...tokens].join(' ');

  return { key, tokens };
}

// ---------------------------------------------------------------------------
// Internal: specificity floor check
// ---------------------------------------------------------------------------

function passesFloor(norm) {
  if (norm.key.length < 12) return false;
  if (norm.tokens.size < 2) return false;
  // Ensure not composed solely of generic tokens (already filtered, but
  // after filtering at least 2 tokens must survive — already checked above)
  return true;
}

// ---------------------------------------------------------------------------
// Internal: lesson freshness (TTL 30 days)
// ---------------------------------------------------------------------------

function isFresh(lesson) {
  const now = Date.now();

  let maxTs = 0;

  if (lesson.ts) {
    const t = typeof lesson.ts === 'number' ? lesson.ts : Date.parse(lesson.ts);
    if (!Number.isNaN(t)) maxTs = Math.max(maxTs, t);
  }

  // evidence items carry no individual timestamps in this schema;
  // lesson.ts (the node row ts) is the sole freshness signal.

  if (maxTs === 0) return true; // no ts info — assume fresh (fail-open)
  return now - maxTs <= TTL_MS;
}

// ---------------------------------------------------------------------------
// 2. check
// ---------------------------------------------------------------------------

/**
 * Main verdict function.
 *
 * @param {import('./store.js').Store} s  - Store instance
 * @param {{ tool_name?: string, command?: string, file?: string, scope?: string }} opts
 * @returns {{ decision: 'allow'|'warn'|'deny', reason: string, match: string, lesson_ref: string|null, enforce?: boolean, confidence?: string }}
 */
export function check(s, { tool_name: _tool_name, command, file, scope } = {}) {
  try {
    const action = command ?? file ?? '';
    const norm = normalizeAction(action);
    const floor = passesFloor(norm);

    // Fetch all lessons
    const rows = s.all("SELECT id,project,ts,data FROM node WHERE kind='lesson'");

    let denyVerdict = null;
    let warnVerdict = null;

    for (const row of rows) {
      let parsedData;
      try {
        parsedData = typeof row.data === 'string' ? JSON.parse(row.data) : row.data;
      } catch {
        continue;
      }
      if (!parsedData) continue;

      // Scope predicate: lesson eligible if GLOBAL or same project
      const lessonScope = parsedData.scope;
      if (lessonScope !== 'GLOBAL' && lessonScope !== scope) continue;

      const lessonNorm = normalizeAction(parsedData.trigger ?? parsedData.signature ?? '');

      // --- DENY-ELIGIBLE check ---
      const denyEligible =
        (parsedData.type === 'dead_end' || parsedData.type === 'error_fix') &&
        parsedData.enforce === true &&
        parsedData.confidence === 'agent_confirmed' &&
        (parsedData.evidence?.occurrences ?? 0) >= 3 &&
        floor &&
        isFresh({ ts: row.ts, parsedData }) &&
        norm.key === lessonNorm.key;

      if (denyEligible) {
        denyVerdict = {
          decision: 'deny',
          reason: parsedData.resolution || parsedData.signature || '',
          lesson_ref: row.id,
          match: 'exact',
          enforce: true,
          confidence: parsedData.confidence,
        };
        break; // first deny wins
      }

      // --- WARN: >=2 shared salient tokens ---
      if (!denyVerdict && !warnVerdict) {
        const intersection = [...norm.tokens].filter((t) => lessonNorm.tokens.has(t));
        if (intersection.length >= 2) {
          warnVerdict = {
            decision: 'warn',
            reason: parsedData.resolution || parsedData.signature || '',
            lesson_ref: row.id,
            match: 'overlap',
            enforce: false,
          };
        }
      }
    }

    if (denyVerdict) return denyVerdict;
    if (warnVerdict) return warnVerdict;
    return { decision: 'allow', reason: '', match: 'none', lesson_ref: null };
  } catch {
    return { decision: 'allow', reason: '', match: 'none', lesson_ref: null };
  }
}

// ---------------------------------------------------------------------------
// 3. emitHookJSON
// ---------------------------------------------------------------------------

/**
 * Convert a verdict into the exact Claude Code PreToolUse hook JSON.
 *
 * @param {{ decision: string, reason: string }} verdict
 * @returns {object}
 */
export function emitHookJSON(verdict) {
  if (verdict.decision === 'deny') {
    return {
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: 'omni (learned): ' + verdict.reason,
      },
    };
  }
  if (verdict.decision === 'warn') {
    return {
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'allow',
        additionalContext: 'omni: ' + verdict.reason,
      },
    };
  }
  // allow
  return {
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'allow',
    },
  };
}

// ---------------------------------------------------------------------------
// 4. writeDenyKeyCache
// ---------------------------------------------------------------------------

/**
 * Write normalised deny keys for all enforced lessons to ~/.omni/deny-keys.txt.
 *
 * @param {import('./store.js').Store} s
 * @param {string} [root]
 * @returns {Promise<number>} count of keys written
 */
export async function writeDenyKeyCache(s, root = os.homedir() + '/.claude') {
  try {
    const rows = s.all("SELECT data FROM node WHERE kind='lesson'");
    const keys = [];
    for (const row of rows) {
      let d;
      try {
        d = typeof row.data === 'string' ? JSON.parse(row.data) : row.data;
      } catch {
        continue;
      }
      if (!d || d.enforce !== true) continue;
      const k = normalizeAction(d.trigger ?? d.signature ?? '').key;
      if (k) keys.push(k);
    }
    const dir = join(root, '.omni');
    await mkdir(dir, { recursive: true });
    await writeFile(join(dir, 'deny-keys.txt'), keys.join('\n') + (keys.length ? '\n' : ''));
    return keys.length;
  } catch {
    return 0;
  }
}
