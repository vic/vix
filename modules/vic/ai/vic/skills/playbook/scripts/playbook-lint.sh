#!/bin/sh
# playbook-lint.sh — Validate frozen playbooks against anti-rot and budget rules (POSIX sh)
# Usage: playbook-lint.sh <playbook.md> [--max-lines 60]
set -eu

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage: playbook-lint.sh <playbook.md> [--max-lines 60]

Checks:
  1. Line count <= --max-lines (default 60)
  2. Required sections: WHEN, STEPS, ORACLE, TRAPS, DONE
  3. Zero memorized line-number instructions ("line 42", "lines 10-30")
  4. Zero unfilled <PLACEHOLDER> tokens
EOF
    [ $# -ge 1 ] && exit 0 || exit 2
fi

PB="$1"; shift
MAX_LINES=60
while [ $# -gt 0 ]; do
    case "$1" in
        --max-lines) MAX_LINES="$2"; shift 2 ;;
        *) echo "playbook-lint: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -f "$PB" ] || { echo "FAIL: file not found: $PB" >&2; exit 1; }

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

LINES=$(wc -l < "$PB" | tr -d ' ')
[ "$LINES" -le "$MAX_LINES" ] && pass "lines $LINES <= $MAX_LINES" || fail "lines $LINES > $MAX_LINES"

for sec in WHEN STEPS ORACLE TRAPS DONE; do
    grep -Eq "^##[[:space:]]+${sec}" "$PB" && pass "section: $sec" || fail "missing section: ## $sec"
done

if grep -Eni '\b(at|on|edit|check)[[:space:]]+lines?[[:space:]]+[0-9]+' "$PB" >/dev/null 2>&1; then
    fail "hardcoded line number found (anchor by symbol/text instead)"
else
    pass "no memorized line-number anchors"
fi

if grep -En '<[A-Z][A-Z0-9_-]+>' "$PB" >/dev/null 2>&1; then
    fail "unfilled <PLACEHOLDER> found"
else
    pass "no unfilled placeholders"
fi

[ "$FAILS" -eq 0 ] && { echo "PLAYBOOK-LINT: PASS ($PB)"; exit 0; }
echo "PLAYBOOK-LINT: FAIL ($FAILS error(s))" >&2
exit 1
