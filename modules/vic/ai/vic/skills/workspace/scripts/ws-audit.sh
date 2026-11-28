#!/bin/sh
# ws-audit.sh — Cross-check jj workspaces against runtime dirs and flag leaks/drift (POSIX sh)
# Usage: ws-audit.sh [--repo <main-repo>] [--strict]
set -eu

REPO="."
STRICT=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ws-audit.sh [--repo <main-repo>] [--strict]

Reports:
  - All jj workspaces registered in the repository
  - Any leftover directories in ${XDG_RUNTIME_DIR:-/tmp}/jj-ws/<repo>/ not tracked by jj
  - Any divergent() or conflicts() commits
With --strict, exits 1 if any non-default/non-vic workspace or orphan dir exists.
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --strict) STRICT=1; shift ;;
        *) echo "ws-audit: unknown arg: $1" >&2; exit 2 ;;
    esac
done

ROOT=$(jj -R "$REPO" root 2>/dev/null) || { echo "FAIL: not a jj repo: $REPO" >&2; exit 1; }
REPO_NAME=$(basename "$ROOT")
BASE_DIR="${XDG_RUNTIME_DIR:-/tmp}/jj-ws/$REPO_NAME"

ISSUES=0
echo "=== JJ WORKSPACES ($ROOT) ==="
WS_LIST=$(jj -R "$ROOT" workspace list 2>/dev/null)
printf '%s\n' "$WS_LIST"

EXTRA=$(printf '%s\n' "$WS_LIST" | awk -F: '$1 != "default" && $1 != "vic" { print $1 }')
if [ -n "$EXTRA" ]; then
    echo "NOTE: active/leftover lane workspaces: $(printf '%s' "$EXTRA" | tr '\n' ' ')"
    ISSUES=$((ISSUES + 1))
fi

echo "=== RUNTIME DIRS ($BASE_DIR) ==="
if [ -d "$BASE_DIR" ]; then
    for d in "$BASE_DIR"/*; do
        [ -e "$d" ] || continue
        b=$(basename "$d")
        if printf '%s\n' "$WS_LIST" | awk -F: '{print $1}' | grep -Fxq -- "$b"; then
            echo "  TRACKED: $d"
        else
            echo "  ORPHAN DIR (not in jj workspace list): $d"
            ISSUES=$((ISSUES + 1))
        fi
    done
else
    echo "  (none)"
fi

BAD=$(jj -R "$ROOT" log --no-graph -r 'divergent() | conflicts()' -T 'change_id.short() ++ " " ++ commit_id.short() ++ "\n"' 2>/dev/null || true)
if [ -n "$BAD" ]; then
    echo "FAIL: divergent()/conflicts() non-empty:" >&2
    printf '%s\n' "$BAD" >&2
    exit 1
fi

if [ "$STRICT" -eq 1 ] && [ "$ISSUES" -gt 0 ]; then
    echo "WS-AUDIT RESULT: FAIL ($ISSUES active/orphan workspace issue(s))" >&2
    exit 1
fi
echo "WS-AUDIT RESULT: OK (issues=$ISSUES)"
exit 0
