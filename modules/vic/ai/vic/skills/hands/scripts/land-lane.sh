#!/bin/sh
# land-lane.sh — Serialized candidate-commit landing gate for HANDS (POSIX sh, project-agnostic)
# Usage:
#   land-lane.sh --repo <main> --ws <ws-path> --name <lane> --msg "<commit msg>"
#                --gate-cmd "<cmd run inside ws>" --pass-regex "<nonzero pass regex>"
#                [--manifest <clean.sha256>]
set -eu

REPO=""
WS=""
NAME=""
MSG=""
GATE_CMD=""
PASS_RE=""
MANIFEST=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: land-lane.sh --repo <main> --ws <ws-path> --name <lane> --msg "<msg>" \
                    --gate-cmd "<cmd>" --pass-regex "<regex>" [--manifest <clean.sha256>]

Enforces:
  1. Flock serialization (one jj writer per repo)
  2. Clean main @ and zero divergent()/conflicts()
  3. Clean-restore SHA-256 verification on --ws (if --manifest given)
  4. Runs --gate-cmd inside --ws on candidate code; requires BOTH exit 0 AND --pass-regex match (armed non-zero pass check)
  5. Linear squash + commit onto main, re-verifies zero divergence, forgets & removes workspace
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --ws) WS="$2"; shift 2 ;;
        --name) NAME="$2"; shift 2 ;;
        --msg) MSG="$2"; shift 2 ;;
        --gate-cmd) GATE_CMD="$2"; shift 2 ;;
        --pass-regex) PASS_RE="$2"; shift 2 ;;
        --manifest) MANIFEST="$2"; shift 2 ;;
        *) echo "land-lane: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$REPO" ] && [ -n "$WS" ] && [ -n "$NAME" ] && [ -n "$MSG" ] && [ -n "$GATE_CMD" ] && [ -n "$PASS_RE" ] || {
    echo "land-lane: missing required arguments (see --help)" >&2; exit 2
}

LOCK="$REPO/.jj/land.lock"

run_land() {
    BAD=$(jj -R "$REPO" log --no-graph -r 'divergent() | conflicts()' -T 'commit_id.short() ++ "\n"' 2>/dev/null || true)
    [ -z "$BAD" ] || { echo "FAIL: divergent()/conflicts() non-empty" >&2; exit 1; }

    MAIN_DIRTY=$(jj -R "$REPO" diff --name-only 2>/dev/null || true)
    [ -z "$MAIN_DIRTY" ] || { echo "FAIL: main working copy is dirty; stop-gate triggered" >&2; exit 1; }

    [ -d "$WS" ] || { echo "FAIL: workspace missing: $WS" >&2; exit 1; }
    jj -R "$WS" st >/dev/null

    if [ -n "$MANIFEST" ]; then
        ABS_MAN=$(cd "$(dirname "$MANIFEST")" && pwd)/$(basename "$MANIFEST")
        (cd "$WS" && sha256sum -c "$ABS_MAN" >/dev/null 2>&1) || {
            echo "FAIL: clean-restore SHA-256 mismatch in $WS (possible live mutant)" >&2
            exit 1
        }
    fi

    OUT=$(mktemp)
    trap 'rm -f "$OUT"' EXIT
    if ! (cd "$WS" && sh -c "$GATE_CMD") >"$OUT" 2>&1; then
        echo "FAIL: candidate gate command failed:" >&2
        tail -n 30 "$OUT" >&2
        exit 1
    fi
    if ! grep -Eq "$PASS_RE" "$OUT"; then
        echo "FAIL: gate exited 0 but armed pass-marker regex did not match ($PASS_RE) — unarmed green refused:" >&2
        tail -n 20 "$OUT" >&2
        exit 1
    fi
    rm -f "$OUT"
    trap - EXIT

    jj -R "$WS" st >/dev/null
    jj -R "$REPO" squash --from "${NAME}@" --into @
    jj -R "$REPO" commit -m "$MSG"

    BAD2=$(jj -R "$REPO" log --no-graph -r 'divergent() | conflicts()' -T 'commit_id.short() ++ "\n"' 2>/dev/null || true)
    [ -z "$BAD2" ] || { echo "FAIL: post-land divergence detected" >&2; exit 1; }

    jj -R "$REPO" workspace forget "$NAME"
    rm -rf "$WS"

    LANDED=$(jj -R "$REPO" log --no-graph -r '@-' -T 'change_id.short() ++ " " ++ commit_id.short()')
    echo "LAND-DONE: $LANDED — $MSG"
}

if command -v flock >/dev/null 2>&1; then
    (
        flock -w 30 9 || { echo "FAIL: lock timeout ($LOCK)" >&2; exit 1; }
        run_land
    ) 9>"$LOCK"
else
    run_land
fi
