#!/bin/sh
# dispatch-lint.sh — Validate Agent tier description + dispatch brief completeness (POSIX sh)
# Usage: dispatch-lint.sh --desc "<model>/<effort>: <task>" [--model <model>] [--brief <file>]
set -eu

DESC=""
MODEL=""
BRIEF=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: dispatch-lint.sh --desc "<model>/<effort>: <3-5 words>" [--model <model>] [--brief <brief.md>]

Checks:
  1. Description matches agent-tier-gate.sh regex: ^(haiku|sonnet|opus|fable)/(low|med|medium|high|xhigh|max):
  2. Optional --model matches description prefix
  3. Optional --brief checks for oracle/negative control, <=10m cap, zero placeholders, no Skill tool call
EOF
            exit 0
            ;;
        --desc) DESC="$2"; shift 2 ;;
        --model) MODEL="$2"; shift 2 ;;
        --brief) BRIEF="$2"; shift 2 ;;
        *) echo "dispatch-lint: unknown arg: $1" >&2; exit 2 ;;
    esac
done

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

if [ -n "$DESC" ]; then
    if printf '%s' "$DESC" | grep -Eq '^(haiku|sonnet|opus|fable)/(low|med|medium|high|xhigh|max):[[:space:]]+[^[:space:]]'; then
        pass "description matches agent-tier-gate prefix"
        PREFIX=$(printf '%s' "$DESC" | cut -d/ -f1)
        if [ -n "$MODEL" ]; then
            [ "$MODEL" = "$PREFIX" ] && pass "explicit model '$MODEL' matches prefix '$PREFIX'" || fail "model '$MODEL' != prefix '$PREFIX'"
        fi
    else
        fail "description violates agent-tier-gate format: '$DESC'"
    fi
fi

if [ -n "$BRIEF" ]; then
    [ -f "$BRIEF" ] || { fail "brief file not found: $BRIEF"; exit 1; }
    grep -Eiq '(oracle|red|mutant|negative control|expect)' "$BRIEF" && pass "brief contains oracle/negative control" || fail "brief missing oracle/negative control"
    grep -Eiq '(5[- ]min|10[- ]min|5 minute|10 minute)' "$BRIEF" && pass "brief contains 5/10-min time cap" || fail "brief missing 5/10-min time cap"
    grep -En '<[A-Z][A-Z0-9_-]+>' "$BRIEF" >/dev/null 2>&1 && fail "brief has unfilled <PLACEHOLDER> tokens" || pass "no unfilled placeholders"
    grep -Eiq '(invoke skill|call skill tool)' "$BRIEF" && fail "brief asks worker to call external Skill tool (inline laws instead)" || pass "no external Skill tool requirement"
fi

[ "$FAILS" -eq 0 ] && { echo "DISPATCH-LINT: PASS"; exit 0; }
echo "DISPATCH-LINT: FAIL ($FAILS error(s))" >&2
exit 1
