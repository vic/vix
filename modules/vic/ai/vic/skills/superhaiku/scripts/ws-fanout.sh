#!/bin/sh
# ws-fanout.sh — Create/verify-RED/cleanup k isolated jj workspaces for a superhaiku unit (POSIX sh)
# Usage:
#   ws-fanout.sh create  --repo <main> --unit <u1> --k <3> [--rev @-] [--red-cmd "<oracle>"]
#   ws-fanout.sh cleanup --repo <main> --unit <u1> --k <3>
set -eu

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage:
  ws-fanout.sh create  --repo <main> --unit <u1> --k <3> [--rev @-] [--red-cmd "<oracle>"]
  ws-fanout.sh cleanup --repo <main> --unit <u1> --k <3>

create:
  - Verifies zero divergent()/conflicts() in --repo
  - If --red-cmd is given, runs it on --repo FIRST and REFUSES to fan out if it exits 0 (unarmed oracle!)
  - Creates k isolated jj workspaces <unit>a0 .. <unit>a<k-1> under ${XDG_RUNTIME_DIR:-/tmp}/jj-ws/<repo>/
  - Prints created workspace paths (one per line)

cleanup:
  - Abandons any remaining <unit>a<k>@, forgets each workspace, and removes its runtime directory
EOF
    exit 0
fi

SUB="$1"; shift
REPO="."
UNIT=""
K=3
REV="@-"
RED_CMD=""

while [ $# -gt 0 ]; do
    case "$1" in
        --repo) REPO="$2"; shift 2 ;;
        --unit) UNIT="$2"; shift 2 ;;
        --k) K="$2"; shift 2 ;;
        --rev) REV="$2"; shift 2 ;;
        --red-cmd) RED_CMD="$2"; shift 2 ;;
        *) echo "ws-fanout: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$UNIT" ] || { echo "ws-fanout: --unit required" >&2; exit 2; }
ROOT=$(jj -R "$REPO" root 2>/dev/null) || { echo "FAIL: not a jj repo: $REPO" >&2; exit 1; }
BASE_DIR="${XDG_RUNTIME_DIR:-/tmp}/jj-ws/$(basename "$ROOT")"

case "$SUB" in
    create)
        BAD=$(jj -R "$ROOT" log --no-graph -r 'divergent() | conflicts()' -T 'commit_id.short() ++ "\n"' 2>/dev/null || true)
        [ -z "$BAD" ] || { echo "FAIL: divergent()/conflicts() non-empty in $ROOT" >&2; exit 1; }

        if [ -n "$RED_CMD" ]; then
            if (cd "$ROOT" && timeout 60 sh -c "$RED_CMD") >/dev/null 2>&1; then
                echo "FAIL: baseline --red-cmd exited 0 BEFORE any edit (UNARMED ORACLE — fix test before swarming)" >&2
                exit 1
            fi
            echo "PASS: baseline oracle confirmed RED (non-zero exit)" >&2
        fi

        mkdir -p "$BASE_DIR"
        i=0
        while [ "$i" -lt "$K" ]; do
            name="${UNIT}a${i}"
            ws="$BASE_DIR/$name"
            if [ -e "$ws" ]; then
                echo "FAIL: workspace already exists: $ws" >&2
                exit 1
            fi
            jj -R "$ROOT" workspace add --name "$name" -r "$REV" "$ws" >/dev/null
            printf '%s\n' "$ws"
            i=$((i + 1))
        done
        ;;
    cleanup)
        i=0
        while [ "$i" -lt "$K" ]; do
            name="${UNIT}a${i}"
            ws="$BASE_DIR/$name"
            if [ -d "$ws" ]; then
                jj -R "$ws" st >/dev/null 2>&1 || true
            fi
            jj -R "$ROOT" abandon "${name}@" >/dev/null 2>&1 || true
            jj -R "$ROOT" workspace forget "$name" >/dev/null 2>&1 || true
            rm -rf "$ws"
            i=$((i + 1))
        done
        echo "CLEANED UP ${K} workspaces for unit ${UNIT}"
        ;;
    *)
        echo "ws-fanout: unknown subcommand '$SUB'" >&2
        exit 2
        ;;
esac
