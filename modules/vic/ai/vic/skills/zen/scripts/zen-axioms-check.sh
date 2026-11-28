#!/bin/sh
# zen-axioms-check.sh — Static verifier for Zen Nix axioms & LoC minimalism budget (POSIX sh)
# Usage: zen-axioms-check.sh [--repo <dir>] [--max-total-loc 1500]
set -eu

REPO="."
MAX_LOC=1500

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: zen-axioms-check.sh [--repo <dir>] [--max-total-loc 1500]

Checks Zen hard axioms across tracked .nix files:
  1. Zero `throw` calls in non-test Nix code (use fx.effects.conditions.signal)
  2. Zero `lib.fix` over config (use ned.run cycle)
  3. Zero Python (.py) files in repository
  4. Total Nix LoC <= --max-total-loc (default 1500)
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --max-total-loc) MAX_LOC="$2"; shift 2 ;;
        *) echo "zen-axioms-check: unknown arg: $1" >&2; exit 2 ;;
    esac
done

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

PY_FILES=$(find "$REPO" -maxdepth 4 -type f -name '*.py' -not -path '*/.jj/*' -not -path '*/.git/*' 2>/dev/null || true)
if [ -n "$PY_FILES" ]; then
    fail "forbidden Python file(s) present: $PY_FILES"
else
    pass "zero .py files"
fi

NIX_FILES=$(find "$REPO" -maxdepth 4 -type f -name '*.nix' -not -path '*/.jj/*' -not -path '*/.git/*' -not -name 'flake.nix' | sort)
TOT_LOC=0
for f in $NIX_FILES; do
    L=$(wc -l < "$f" | tr -d ' ')
    TOT_LOC=$((TOT_LOC + L))
    case "$f" in *test*|*Test*) continue ;; esac
    if grep -En '(^|[^[:alnum:]_])throw[[:space:]]' "$f" | grep -v '^[0-9]*:[[:space:]]*#' >/dev/null 2>&1; then
        fail "forbidden 'throw' in $f (use fx.effects.conditions.signal):"
        grep -En '(^|[^[:alnum:]_])throw[[:space:]]' "$f" | grep -v '^[0-9]*:[[:space:]]*#' | head -n 5 >&2
    fi
    if grep -En '\blib\.fix\b' "$f" | grep -v '^[0-9]*:[[:space:]]*#' >/dev/null 2>&1; then
        fail "forbidden 'lib.fix' in $f (use ned.run cycle):"
        grep -En '\blib\.fix\b' "$f" | grep -v '^[0-9]*:[[:space:]]*#' | head -n 5 >&2
    fi
done

if [ "$TOT_LOC" -le "$MAX_LOC" ]; then
    pass "total Nix LoC $TOT_LOC <= $MAX_LOC"
else
    fail "total Nix LoC $TOT_LOC exceeds minimalism budget $MAX_LOC"
fi

[ "$FAILS" -eq 0 ] && { echo "ZEN-AXIOMS-CHECK: PASS ($REPO)"; exit 0; }
echo "ZEN-AXIOMS-CHECK: FAIL ($FAILS issue(s))" >&2
exit 1
