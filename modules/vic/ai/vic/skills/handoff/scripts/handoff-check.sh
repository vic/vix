#!/bin/sh
# handoff-check.sh — Validate <repo>/vic/HANDOFF.md line budget, freshness, and required fields (POSIX sh)
# Usage: handoff-check.sh [--repo <dir>] [--max-lines 25] [--max-age-min 30]
set -eu

REPO="."
MAX_LINES=25
MAX_AGE=30

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: handoff-check.sh [--repo <dir>] [--max-lines 25] [--max-age-min 30]

Validates <repo>/vic/HANDOFF.md:
  - Exists and is non-empty
  - Line count <= --max-lines (default 25)
  - Age <= --max-age-min minutes (default 30)
  - Contains required keys: UPDATED, DOING, NEXT-CMD, THEN, OPEN, FILES, BURN
  - Contains zero unfilled <PLACEHOLDER> tokens
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --max-lines) MAX_LINES="$2"; shift 2 ;;
        --max-age-min) MAX_AGE="$2"; shift 2 ;;
        *) echo "handoff-check: unknown arg: $1" >&2; exit 2 ;;
    esac
done

H="$REPO/vic/HANDOFF.md"
FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

if [ ! -s "$H" ]; then
    fail "missing or empty HANDOFF file: $H"
    exit 1
fi

LINES=$(wc -l < "$H" | tr -d ' ')
if [ "$LINES" -le "$MAX_LINES" ]; then
    pass "line count $LINES <= $MAX_LINES"
else
    fail "line count $LINES exceeds budget $MAX_LINES (move history to state.md)"
fi

MTIME=$(stat -c '%Y' "$H" 2>/dev/null || echo 0)
NOW=$(date +%s)
AGE_MIN=$(( (NOW - MTIME) / 60 ))
if [ "$AGE_MIN" -le "$MAX_AGE" ]; then
    pass "freshness ${AGE_MIN}m <= ${MAX_AGE}m"
else
    fail "HANDOFF is stale (${AGE_MIN}m > ${MAX_AGE}m)"
fi

for key in UPDATED DOING NEXT-CMD THEN OPEN FILES BURN; do
    if grep -Eq "^(${key}|##?[[:space:]]*.*${key})" "$H"; then
        pass "field present: $key"
    else
        fail "missing required field: $key"
    fi
done

if grep -En '<[A-Z][A-Z0-9_-]+>' "$H" >/dev/null 2>&1; then
    fail "unfilled <PLACEHOLDER> token(s) in $H"
else
    pass "no unfilled placeholders"
fi

if [ "$FAILS" -gt 0 ]; then
    printf 'HANDOFF-CHECK RESULT: FAIL (%d error(s))\n' "$FAILS" >&2
    exit 1
fi
printf 'HANDOFF-CHECK RESULT: PASS (%s)\n' "$H"
exit 0
