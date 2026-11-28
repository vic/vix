#!/bin/sh
# jj-land-linear.sh — Flock-serialized linear lane landing with SHA restore check & cleanup (POSIX sh)
# Usage:
#   jj-land-linear.sh --repo <main-repo> --ws <ws-path> --name <ws-name> --msg "<commit msg>"
#                     [--manifest <clean.sha256>] [--keep-ws]
set -eu

REPO=""
WS=""
NAME=""
MSG=""
MANIFEST=""
KEEP_WS=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: jj-land-linear.sh --repo <main-repo> --ws <ws-path> --name <ws-name> --msg "<msg>" [--manifest <clean.sha256>] [--keep-ws]

Steps (serialized under flock on <main-repo>/.jj/land.lock):
  1. Verify main repo has zero divergent() / conflicts() and clean @
  2. Snapshot secondary workspace (`jj -R <ws> st`)
  3. Optional: verify clean-restore SHA-256 manifest in <ws> (blocks live mutants)
  4. Refuse empty diff
  5. Squash `<name>@` into main `@` and commit linearly with --msg
  6. Re-verify zero divergent() / conflicts()
  7. Forget workspace and remove <ws> (unless --keep-ws)
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --ws) WS="$2"; shift 2 ;;
        --name) NAME="$2"; shift 2 ;;
        --msg) MSG="$2"; shift 2 ;;
        --manifest) MANIFEST="$2"; shift 2 ;;
        --keep-ws) KEEP_WS=1; shift ;;
        *) echo "jj-land-linear: unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$REPO" ] || [ -z "$WS" ] || [ -z "$NAME" ] || [ -z "$MSG" ]; then
    echo "jj-land-linear: --repo, --ws, --name, --msg are all required" >&2
    exit 2
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
LOCK="$REPO/.jj/land.lock"

do_land() {
    "$SCRIPT_DIR/jj-gate.sh" --repo "$REPO" --require-clean

    if [ ! -d "$WS" ]; then
        echo "FAIL: workspace path does not exist: $WS" >&2
        exit 1
    fi

    # Snapshot workspace edits first (jj only snapshots inside the ws)
    jj -R "$WS" st >/dev/null

    if [ -n "$MANIFEST" ]; then
        ABS_MAN=$(cd "$(dirname "$MANIFEST")" && pwd)/$(basename "$MANIFEST")
        if ! (cd "$WS" && sha256sum -c "$ABS_MAN" >/dev/null 2>&1); then
            echo "FAIL: clean-restore SHA-256 mismatch in $WS (possible live mutant)" >&2
            (cd "$WS" && sha256sum -c "$ABS_MAN" 2>&1 | grep -v ': OK$') >&2 || true
            exit 1
        fi
        echo "PASS: clean-restore SHA-256 verified"
    fi

    DIFF=$(jj -R "$REPO" diff -r "${NAME}@" --name-only 2>/dev/null || true)
    if [ -z "$DIFF" ]; then
        echo "FAIL: workspace ${NAME}@ has empty diff — nothing to land" >&2
        exit 1
    fi

    jj -R "$REPO" squash --from "${NAME}@" --into @
    jj -R "$REPO" commit -m "$MSG"

    "$SCRIPT_DIR/jj-gate.sh" --repo "$REPO"

    if [ "$KEEP_WS" -eq 0 ]; then
        jj -R "$REPO" workspace forget "$NAME"
        rm -rf "$WS"
        echo "PASS: workspace $NAME forgotten and removed"
    fi

    LANDED=$(jj -R "$REPO" log --no-graph -r '@-' -T 'change_id.short() ++ " " ++ commit_id.short()')
    echo "LANDED LINEAR: $LANDED — $MSG"
}

if command -v flock >/dev/null 2>&1; then
    (
        flock -w 30 9 || { echo "FAIL: could not acquire jj land lock ($LOCK)" >&2; exit 1; }
        do_land
    ) 9>"$LOCK"
else
    do_land
fi
