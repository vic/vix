#!/bin/sh
# ws-create.sh — Create a clean isolated jj lane workspace under ${XDG_RUNTIME_DIR:-/tmp}/jj-ws (POSIX sh)
# Usage: ws-create.sh --repo <main-repo> --name <lane-name> [--rev <rev>]
set -eu

REPO="."
NAME=""
REV="@-"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ws-create.sh --repo <main-repo> --name <lane-name> [--rev <rev>]

Creates an isolated jj workspace at ${XDG_RUNTIME_DIR:-/tmp}/jj-ws/<repo>/<lane-name>
after verifying zero divergent()/conflicts() in the main repository.
Prints the absolute workspace path on stdout.
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --name) NAME="$2"; shift 2 ;;
        --rev) REV="$2"; shift 2 ;;
        *) echo "ws-create: unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$NAME" ]; then
    echo "ws-create: --name required" >&2
    exit 2
fi

ROOT=$(jj -R "$REPO" root 2>/dev/null) || { echo "FAIL: not a jj repo: $REPO" >&2; exit 1; }

BAD=$(jj -R "$ROOT" log --no-graph -r 'divergent() | conflicts()' -T 'commit_id.short() ++ "\n"' 2>/dev/null || true)
if [ -n "$BAD" ]; then
    echo "FAIL: refusing to branch workspace from repo with divergent() or conflicts():" >&2
    printf '%s\n' "$BAD" >&2
    exit 1
fi

BASE_DIR="${XDG_RUNTIME_DIR:-/tmp}/jj-ws/$(basename "$ROOT")"
WS_PATH="$BASE_DIR/$NAME"

if [ -e "$WS_PATH" ]; then
    echo "FAIL: workspace path already exists: $WS_PATH (forget & remove or choose a new name)" >&2
    exit 1
fi

mkdir -p "$BASE_DIR"
jj -R "$ROOT" workspace add --name "$NAME" -r "$REV" "$WS_PATH" >/dev/null
printf '%s\n' "$WS_PATH"
