#!/bin/sh
# pie-check.sh — Mechanical verifier that a design doc or brief follows strict P -> I -> E order (POSIX sh)
# Usage: pie-check.sh <doc-file>
set -eu

if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage: pie-check.sh <design-doc-or-brief.md>

Verifies:
  1. Purpose section/line exists BEFORE Interactions and Elements
  2. Interactions / Contract / Oracle section exists BEFORE Elements / Implementation
  3. Elements / Implementation / Agents section exists AFTER Purpose and Interactions
  4. Explicit Oracle or Verification criteria present
  5. Explicit Non-Goals / Scope boundary present (warns if absent)
EOF
    [ $# -eq 1 ] && exit 0 || exit 2
fi

DOC="$1"
[ -f "$DOC" ] || { echo "FAIL: file not found: $DOC" >&2; exit 1; }

line_of() {
    grep -Ein "$1" "$DOC" | head -n 1 | cut -d: -f1
}

P_LINE=$(line_of '^(#+[[:space:]]*(P[[:space:]—:-]|Purpose)|PURPOSE:|GOAL LINE:)')
I_LINE=$(line_of '^(#+[[:space:]]*(I[[:space:]—:-]|Interactions?|Contracts?)|CONTRACT:|INTERACTIONS?:)')
E_LINE=$(line_of '^(#+[[:space:]]*(E[[:space:]—:-]|Elements?|Implementation)|ELEMENTS?:|FILES[[:space:]:]|AGENTS[[:space:]:])')

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

[ -n "$P_LINE" ] && pass "Purpose defined at line $P_LINE" || fail "missing Purpose / GOAL LINE section"
[ -n "$I_LINE" ] && pass "Interactions/Contract defined at line $I_LINE" || fail "missing Interactions / CONTRACT section"
[ -n "$E_LINE" ] && pass "Elements/Files defined at line $E_LINE" || fail "missing Elements / FILES section"

if [ -n "$P_LINE" ] && [ -n "$I_LINE" ]; then
    if [ "$P_LINE" -lt "$I_LINE" ]; then
        pass "order P ($P_LINE) < I ($I_LINE)"
    else
        fail "PIE order violated: Purpose (L$P_LINE) must precede Interactions/Contract (L$I_LINE)"
    fi
fi

if [ -n "$I_LINE" ] && [ -n "$E_LINE" ]; then
    if [ "$I_LINE" -lt "$E_LINE" ]; then
        pass "order I ($I_LINE) < E ($E_LINE)"
    else
        fail "PIE order violated: Interactions/Contract (L$I_LINE) must precede Elements (L$E_LINE)"
    fi
fi

if grep -Eiq '(oracle|negative control|mutant|verif|expect:)' "$DOC"; then
    pass "oracle / verification criteria present"
else
    fail "missing oracle / verification criteria in Interactions"
fi

if grep -Eiq '(non-goal|not-purpose|not-scope|out of scope|anything else is)' "$DOC"; then
    pass "scope boundary / non-goals stated"
else
    printf 'WARN: consider adding explicit Non-Goals / NOT-PURPOSE to prevent scope creep\n' >&2
fi

if [ "$FAILS" -gt 0 ]; then
    printf 'PIE-CHECK RESULT: FAIL (%d error(s))\n' "$FAILS" >&2
    exit 1
fi
printf 'PIE-CHECK RESULT: PASS (%s)\n' "$DOC"
exit 0
