#!/bin/sh
# vic-preflight.sh — One-command session-start & pre-edit preflight (POSIX sh, project-agnostic)
# Usage: vic-preflight.sh [--repo <dir>]
set -eu

REPO="."
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: vic-preflight.sh [--repo <dir>]

Runs deterministic session-start orientation and health checks:
  1. Checks jj repo health (divergent(), conflicts(), working copy status, active workspaces)
  2. Shows last 10 commits (names only)
  3. Lists 10 newest ./vic/*.md files by mtime
  4. Checks HANDOFF.md age and line count (<= 25 lines rule)
  5. Reports evidence-gate.conf presence and active evidence tickets
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        *) echo "vic-preflight: unknown arg: $1" >&2; exit 2 ;;
    esac
done

echo "=== 1. VCS HEALTH ($REPO) ==="
if [ -d "$REPO/.jj" ]; then
    DIV=$(jj -R "$REPO" log --no-graph -r 'divergent() | conflicts()' -T 'change_id.short() ++ " " ++ commit_id.short() ++ "\n"' 2>/dev/null || true)
    if [ -n "$DIV" ]; then
        echo "WARN: divergent()/conflicts() NON-EMPTY:"
        printf '%s\n' "$DIV"
    else
        echo "OK: jj divergent()/conflicts() empty"
    fi
    echo "--- jj st ---"
    jj -R "$REPO" st 2>/dev/null || true
    echo "--- workspaces ---"
    jj -R "$REPO" workspace list 2>/dev/null || true
    echo "=== 2. RECENT COMMITS (ancestors(@,10)) ==="
    jj -R "$REPO" log -r 'ancestors(@,10)' --name-only --no-pager 2>/dev/null | head -n 40 || true
else
    echo "WARN: no .jj directory at $REPO (colocate with 'jj git init --colocate')"
fi

echo "=== 3. NEWEST vic/*.md ==="
if [ -d "$REPO/vic" ]; then
    find "$REPO/vic" -maxdepth 3 -type f -name '*.md' -exec stat -c '%Y %n' {} + 2>/dev/null | sort -rn | head -n 10 || true
else
    echo "(no $REPO/vic directory)"
fi

echo "=== 4. HANDOFF CHECK ==="
H="$REPO/vic/HANDOFF.md"
if [ -f "$H" ]; then
    LINES=$(wc -l < "$H" | tr -d ' ')
    MTIME=$(stat -c '%Y' "$H" 2>/dev/null || echo 0)
    NOW=$(date +%s)
    AGE_MIN=$(( (NOW - MTIME) / 60 ))
    echo "HANDOFF: $H (lines=$LINES, age=${AGE_MIN}m)"
    [ "$LINES" -gt 25 ] && echo "WARN: HANDOFF.md exceeds 25-line budget ($LINES lines)"
else
    echo "NOTE: no $H"
fi

echo "=== 5. EVIDENCE GATE ==="
if [ -f "$REPO/vic/evidence-gate.conf" ]; then
    echo "ACTIVE: $REPO/vic/evidence-gate.conf"
    if [ -d "$REPO/vic/evidence" ]; then
        for t in "$REPO/vic/evidence"/*.md; do
            [ -f "$t" ] || continue
            V=$(sed -n 's/^verdict:[[:space:]]*//p' "$t" | head -n 1)
            echo "  ticket: $(basename "$t") verdict=${V:-MISSING}"
        done
    else
        echo "  (no tickets yet in $REPO/vic/evidence/)"
    fi
else
    echo "inactive (no $REPO/vic/evidence-gate.conf)"
fi
