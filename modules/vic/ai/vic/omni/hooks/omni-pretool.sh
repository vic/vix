#!/usr/bin/env bash
# omni-pretool.sh — PreToolUse hook for Claude Code.
# FAIL-OPEN: any internal error → allow.
# CONTRACT: exit 0 always; print one JSON object to stdout.

set -euo pipefail

ALLOW_JSON='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'

_allow() {
    printf '%s\n' "$ALLOW_JSON"
    exit 0
}

_allow_with_context() {
    # $1 = reason string (no double-quotes inside)
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","additionalContext":"%s"}}\n' "$1"
    exit 0
}

# Read all stdin up-front (blocking; Claude always sends the full JSON before hook reads).
INPUT=""
if read -r -t 5 -d '' INPUT 2>/dev/null || true; then
    :
fi
# Fallback: read line-by-line if the above captured nothing (some shells / configs differ).
if [ -z "$INPUT" ]; then
    while IFS= read -r LINE 2>/dev/null; do
        INPUT="${INPUT}${LINE}"$'\n'
    done || true
fi

# ── STEP 2: KILL SWITCH ────────────────────────────────────────────────────────
if [ "${OMNI_HOOK:-}" = "off" ]; then
    _allow
fi

# ── STEP 3: PREFILTER — deny cache ────────────────────────────────────────────
DENY_KEYS="${OMNI_DENY_KEYS:-$HOME/.claude/.omni/deny-keys.txt}"
if [ ! -f "$DENY_KEYS" ] || [ ! -s "$DENY_KEYS" ]; then
    # Missing or empty → nothing can be denied → instant allow, no node.
    _allow
fi

# ── STEP 4: CIRCUIT BREAKER ───────────────────────────────────────────────────
STATE_FILE="${OMNI_HOOK_STATE:-$HOME/.claude/.omni/hook.state}"
NOW=$(date +%s)
WINDOW_START=$(( NOW - 60 ))
DENY_COUNT=0

if [ -f "$STATE_FILE" ]; then
    while IFS= read -r TS; do
        [ -z "$TS" ] && continue
        if [ "$TS" -gt "$WINDOW_START" ] 2>/dev/null; then
            DENY_COUNT=$(( DENY_COUNT + 1 ))
        fi
    done < "$STATE_FILE"
fi

if [ "$DENY_COUNT" -gt 3 ]; then
    # Too many denies in last 60s → force allow (warn-only mode).
    _allow
fi

# ── STEP 5: ENGINE ────────────────────────────────────────────────────────────
CMD="${OMNI_CHECK_CMD:-"node $HOME/.claude/omni/omni.js check --hook"}"

# Run engine under 200ms timeout; capture stdout and exit code.
ENGINE_OUT=""
ENGINE_EXIT=0
ENGINE_OUT=$(printf '%s' "$INPUT" | timeout 0.2 bash -c "$CMD" 2>/dev/null) || ENGINE_EXIT=$?

# FAIL-OPEN conditions: timeout/non-zero/empty/not JSON-looking.
if [ "$ENGINE_EXIT" -ne 0 ] || [ -z "$ENGINE_OUT" ]; then
    _allow
fi

# Quick sanity: must look like JSON (starts with '{').
TRIMMED_OUT="${ENGINE_OUT#"${ENGINE_OUT%%[! ]*}"}"   # ltrim spaces
case "$TRIMMED_OUT" in
    '{'*) ;;          # looks like JSON — proceed
    *)    _allow ;;   # not JSON-looking — fail open
esac

# Detect deny verdict using grep (no hard jq dep).
if printf '%s' "$ENGINE_OUT" | grep -q '"permissionDecision":"deny"'; then
    # OMNI_HOOK=warn → downgrade deny to allow with context.
    if [ "${OMNI_HOOK:-}" = "warn" ]; then
        # Extract reason if present (best-effort with sed, no jq required).
        REASON=$(printf '%s' "$ENGINE_OUT" \
            | sed -n 's/.*"permissionDecisionReason":"\([^"]*\)".*/\1/p' \
            | head -1)
        REASON="${REASON:-omni-pretool would have denied this}"
        _allow_with_context "$REASON"
    fi

    # Record deny timestamp for circuit breaker.
    mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null || true
    printf '%s\n' "$NOW" >> "$STATE_FILE" 2>/dev/null || true

    printf '%s\n' "$ENGINE_OUT"
    exit 0
fi

# Allow (or any other verdict) → pass through.
printf '%s\n' "$ENGINE_OUT"
exit 0
