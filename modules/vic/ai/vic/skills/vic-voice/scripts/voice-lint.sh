#!/bin/sh
# voice-lint.sh — Mechanical anti-AI-slop & vic-voice draft linter (POSIX sh)
# Usage: voice-lint.sh [--chat] <draft-file>
set -eu

CHAT=0
FILE=""
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: voice-lint.sh [--chat] <draft-file>

Checks human-facing prose (skipping fenced code blocks) for vic-voice violations:
  - Banned AI tics ("Great question", "I'd be happy to", "Certainly", "delve", "It's worth noting", "In summary")
  - Banned sales adjectives ("revolutionary", "next-generation", "powerful", "unleash", "unlock", "game-changing", "seamless", "robust", "leverage")
  - Fake prose test-counter summaries ("100/150 success", "42/42 passed" outside fenced command logs)
  - Talking about "being honest" instead of just being honest
  - Wall-of-text length (> 45 lines of prose outside code fences)
  - With --chat: flags markdown headings
EOF
            exit 0
            ;;
        --chat) CHAT=1; shift ;;
        *) FILE="$1"; shift ;;
    esac
done

[ -n "$FILE" ] && [ -f "$FILE" ] || { echo "voice-lint: draft file required" >&2; exit 2; }

awk -v chat="$CHAT" '
BEGIN {
    in_code = 0; fails = 0; prose_lines = 0
    tics = "(great question|i'\''d be happy to|certainly|it'\''s worth noting|in summary|let me know if you need|feel free to ask)"
    sales = "(revolutionary|next-generation|powerful|unleash|unlock|game-changing|seamless|robust|leverage|comprehensive|delve)"
    honest_meta = "(to be honest|being honest|honestly speaking|full honesty)"
}
/^```/ { in_code = !in_code; next }
in_code { next }
{
    if ($0 ~ /[^[:space:]]/) prose_lines++
    low = tolower($0)
    if (low ~ tics) {
        printf "FAIL L%d: banned AI tic: %s\n", NR, $0 > "/dev/stderr"
        fails++
    }
    if (low ~ sales) {
        printf "FAIL L%d: banned sales/slop adjective: %s\n", NR, $0 > "/dev/stderr"
        fails++
    }
    if (low ~ honest_meta) {
        printf "FAIL L%d: meta-honesty phrase (just state facts plainly): %s\n", NR, $0 > "/dev/stderr"
        fails++
    }
    if (low ~ /[0-9]+\/[0-9]+[[:space:]]+(success|passed|passing|tests)/) {
        printf "FAIL L%d: prose test-counter stat (paste actual cmd output in fenced block instead): %s\n", NR, $0 > "/dev/stderr"
        fails++
    }
    if (chat == 1 && $0 ~ /^#+[[:space:]]/) {
        printf "FAIL L%d: markdown heading in chat mode\n", NR > "/dev/stderr"
        fails++
    }
}
END {
    if (prose_lines > 45) {
        printf "WARN: prose length is %d lines (>45) — consider cutting or collapsing\n", prose_lines > "/dev/stderr"
    }
    if (fails > 0) {
        printf "VOICE-LINT RESULT: FAIL (%d issue(s))\n", fails > "/dev/stderr"
        exit 1
    }
    printf "VOICE-LINT RESULT: PASS (%s, %d prose lines)\n", FILENAME, prose_lines
    exit 0
}
' "$FILE"
