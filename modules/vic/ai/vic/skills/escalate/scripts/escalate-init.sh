#!/bin/sh
# escalate-init.sh — Scaffold a cold-resumable # ESCALATE artifact with live VCS state (POSIX sh)
# Usage: escalate-init.sh --repo <dir> --slug <short-slug> --question "<one-line question>" [--ticket <id>]
set -eu

REPO="."
SLUG=""
QUESTION=""
TICKET="none"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: escalate-init.sh --repo <dir> --slug <slug> --question "<one-line question>" [--ticket <id>]

Creates <repo>/vic/notes/escalate-<slug>.md pre-populated with UTC timestamp and current VCS revision.
EOF
            exit 0
            ;;
        --repo) REPO="$2"; shift 2 ;;
        --slug) SLUG="$2"; shift 2 ;;
        --question) QUESTION="$2"; shift 2 ;;
        --ticket) TICKET="$2"; shift 2 ;;
        *) echo "escalate-init: unknown arg: $1" >&2; exit 2 ;;
    esac
done

[ -n "$SLUG" ] && [ -n "$QUESTION" ] || { echo "escalate-init: --slug and --question required" >&2; exit 2; }

TS=$(date -u +%Y-%m-%dT%H:%MZ)
REV="unknown"
if [ -d "$REPO/.jj" ]; then
    REV=$(jj -R "$REPO" log --no-graph -r '@' -T 'change_id.short() ++ " " ++ commit_id.short()' 2>/dev/null || echo "jj-unknown")
elif [ -d "$REPO/.git" ] || [ -f "$REPO/.git" ]; then
    REV=$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "git-unknown")
fi

OUT_DIR="$REPO/vic/notes"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/escalate-${SLUG}.md"

cat > "$OUT" <<EOF
# ESCALATE: $QUESTION

- **DATE:** $TS
- **TICKET:** $TICKET
- **REPO / REV:** $REPO @ $REV
- **BLOCKED ON:** <exact command + verbatim error output>

## TRIED
1. Try 1 (<model>/<effort>): <approach> -> FAILED: <cmd + verbatim output>
2. Try 2 (<model>/<effort>): <approach> -> FAILED: <cmd + verbatim output>

## RULED OUT (DO NOT RE-WALK)
- <dead path + falsification receipt>

## SPEC ANCHORS CHECKED
- <file:line> "<quote>" — insufficient because <gap>

## NEEDED
- <derivation | owner ruling A/B/C with recommendation | architecture fix>

## COLD-RESUME STATE
- Minrepro (<1s): <path + exact cmd>
- Probe artifacts: <paths>
EOF

echo "CREATED ESCALATION ARTIFACT: $OUT"
