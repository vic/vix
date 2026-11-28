#!/bin/sh
# ste-lint.sh — Deterministic ASD-STE100 prose linter (POSIX sh, skips fenced code blocks)
# Usage: ste-lint.sh [--strict] <markdown-or-text-file>
set -eu

STRICT=0
FILE=""
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: ste-lint.sh [--strict] <file>

Skips fenced code blocks (```...```) and inline `code`, then flags:
  - Semicolons (;) in prose
  - Contractions (don't, can't, won't, it's, isn't, doesn't, we're, you're, etc.)
  - Banned marketing/AI-slop words (seamless, robust, leverage, utilize, delve, etc.)
  - Sentences exceeding 25 words (20 words under --strict)
  - Paragraphs exceeding 6 sentences
EOF
            exit 0
            ;;
        --strict) STRICT=1; shift ;;
        *) FILE="$1"; shift ;;
    esac
done

[ -n "$FILE" ] && [ -f "$FILE" ] || { echo "ste-lint: file required and must exist" >&2; exit 2; }

MAX_WORDS=25
[ "$STRICT" -eq 1 ] && MAX_WORDS=20

awk -v maxw="$MAX_WORDS" '
BEGIN {
    in_code = 0; fails = 0; para_sents = 0; para_start = 0
    slop = "(seamless|robust|powerful|cutting-edge|effortless|world-class|next-generation|revolutionary|leverage|utilize|delve|facilitate|furthermore|moreover|additionally|commence|subsequent to|prior to)"
    contr = "([A-Za-z]+'\''(t|re|ve|ll|m|d)|[Ii]t'\''s|[Tt]hat'\''s|[Tt]here'\''s)"
}
function flush_para() {
    if (para_sents > 6) {
        printf "FAIL L%d: paragraph has %d sentences (max 6)\n", para_start, para_sents > "/dev/stderr"
        fails++
    }
    para_sents = 0; para_start = 0
}
/^```/ { in_code = !in_code; flush_para(); next }
in_code { next }
/^[[:space:]]*$/ { flush_para(); next }
/^[[:space:]]*(#|\||>|---)/ { flush_para(); next }
{
    line = $0
    # Strip inline code spans and markdown links URLs
    gsub(/`[^`]*`/, "CODE", line)
    gsub(/\]\([^)]*\)/, "]", line)

    if (para_start == 0) para_start = NR

    if (line ~ /;/) {
        printf "FAIL L%d: semicolon in prose (split into two sentences)\n", NR > "/dev/stderr"
        fails++
    }
    if (tolower(line) ~ slop) {
        printf "FAIL L%d: banned/non-STE word in: %s\n", NR, line > "/dev/stderr"
        fails++
    }
    if (line ~ contr) {
        printf "FAIL L%d: contraction in prose (expand it): %s\n", NR, line > "/dev/stderr"
        fails++
    }

    # Split into rough sentences on . ! ?
    n = split(line, sents, /[.!?]+([[:space:]]+|$)/)
    for (i = 1; i <= n; i++) {
        s = sents[i]
        gsub(/^[[:space:]-*0-9.)]+|[[:space:]]+$/, "", s)
        if (s == "") continue
        para_sents++
        wc = split(s, words, /[[:space:]]+/)
        if (wc > maxw) {
            printf "FAIL L%d: sentence has %d words (max %d): %.70s...\n", NR, wc, maxw, s > "/dev/stderr"
            fails++
        }
    }
}
END {
    flush_para()
    if (fails > 0) {
        printf "STE-LINT RESULT: FAIL (%d issue(s), max_words=%d)\n", fails, maxw > "/dev/stderr"
        exit 1
    }
    printf "STE-LINT RESULT: PASS (%s, max_words=%d)\n", FILENAME, maxw
    exit 0
}
' "$FILE"
