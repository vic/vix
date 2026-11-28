#!/bin/sh
# solo-gate.sh — Fast pre-timing & pre-commit self-check for solo direct delivery (POSIX sh)
# Usage: solo-gate.sh [--repo <dir>] [--check-quiet] [--max-load 1.5]
set -eu

REPO="."
CHECK_QUIET=0
MAX_LOAD="1.5"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: solo-gate.sh [--repo <dir>] [--check-quiet] [--max-load 1.5]

Checks:
  1. Optional --check-quiet: verifies 1-min system loadavg <= --max-load before wall-clock timing
  2. Verifies jj divergent()/conflicts() empty
  3. Prints diff --stat and flags banned tokens (TODO, FIXME, abort(, panic(, DEBUG_PROBE) in changed code
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --check-quiet) CHECK_QUIET=1; shift ;;
        --max-load) MAX_LOAD="$2"; shift 2 ;;
        *) echo "solo-gate: unknown arg: $1" >&2; exit 2 ;;
    esac
done

FAILS=0
fail() { printf 'FAIL: %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS: %s\n' "$1"; }

if [ "$CHECK_QUIET" -eq 1 ] && [ -r /proc/loadavg ]; then
    LOAD1=$(awk '{print $1}' /proc/loadavg)
    if awk -v l="$LOAD1" -v m="$MAX_LOAD" 'BEGIN { exit (l <= m ? 0 : 1) }'; then
        pass "quiet host confirmed (1m load=$LOAD1 <= $MAX_LOAD)"
    else
        fail "host NOT quiet for timing (1m load=$LOAD1 > $MAX_LOAD)"
    fi
fi

if [ -d "$REPO/.jj" ]; then
    BAD=$(jj -R "$REPO" log --no-graph -r 'divergent() | conflicts()' -T 'commit_id.short() ++ "\n"' 2>/dev/null || true)
    [ -z "$BAD" ] && pass "jj divergent()/conflicts() empty" || fail "jj divergent()/conflicts() non-empty"
    CHANGED=$(jj -R "$REPO" diff --name-only 2>/dev/null || true)
    jj -R "$REPO" diff --stat 2>/dev/null || true
else
    CHANGED=$(git -C "$REPO" diff --name-only 2>/dev/null || true)
fi

OLD_IFS="$IFS"
IFS='
'
for f in $CHANGED; do
    [ -z "$f" ] && continue
    [ ! -f "$REPO/$f" ] && continue
    case "$f" in *.md|*.txt|*.tsv|*.json|*.log) continue ;; esac
    if grep -En '(TODO|FIXME|XXX|DEBUG_PROBE|\babort[[:space:]]*\(|\bpanic[[:space:]]*\()' "$REPO/$f" >/dev/null 2>&1; then
        fail "banned token/trace residue in $f"
    fi
done
IFS="$OLD_IFS"

[ "$FAILS" -eq 0 ] && { echo "SOLO-GATE: PASS"; exit 0; }
echo "SOLO-GATE: FAIL ($FAILS error(s))" >&2
exit 1
