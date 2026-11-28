#!/bin/sh
# pm-board-check.sh — Validate a PM wave dispatch table before spawning agents (POSIX sh)
# Usage: pm-board-check.sh <wave-table.md>
set -eu

if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage: pm-board-check.sh <wave-plan.md>

Checks a PM wave table (markdown rows: | agent | model/effort | bead | files | est_min |):
  - Every row specifies an explicit valid tier (haiku/low, sonnet/med, opus/high, fable/xhigh)
  - Every est_min <= 10 (warns if haiku/low > 5)
  - Zero duplicate files across rows in the same wave
EOF
    [ $# -eq 1 ] && exit 0 || exit 2
fi

PLAN="$1"
[ -f "$PLAN" ] || { echo "FAIL: file not found: $PLAN" >&2; exit 1; }

awk -F'|' '
BEGIN { fails = 0; rows = 0 }
/^\|/ {
    if ($0 ~ /^\|[[:space:]]*[-:]+/ || tolower($2) ~ /agent/) next
    rows++
    agent = $2; tier = $3; bead = $4; files = $5; est = $6
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", agent)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", tier)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", bead)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", files)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", est)
    if (tier !~ /^(haiku|sonnet|opus|fable)\/(low|med|medium|high|xhigh|max)$/) {
        printf "FAIL row %d (%s): invalid tier \"%s\"\n", rows, agent, tier > "/dev/stderr"
        fails++
    }
    if (bead == "" || bead == "-") {
        printf "FAIL row %d (%s): missing bead/ticket id\n", rows, agent > "/dev/stderr"
        fails++
    }
    est_num = est + 0
    if (est_num <= 0 || est_num > 10) {
        printf "FAIL row %d (%s): est_min=%s out of 1..10 range (split task)\n", rows, agent, est > "/dev/stderr"
        fails++
    } else if (tier ~ /^haiku\// && est_num > 5) {
        printf "WARN row %d (%s): haiku/low est=%sm > 5m target\n", rows, agent, est > "/dev/stderr"
    }
    n = split(files, arr, /,[[:space:]]*/)
    for (i = 1; i <= n; i++) {
        f = arr[i]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", f)
        if (f == "" || f == "read-only" || f == "none") continue
        if (f in owner) {
            printf "FAIL overlap: \"%s\" assigned to both %s and %s\n", f, owner[f], agent > "/dev/stderr"
            fails++
        } else {
            owner[f] = agent
        }
    }
}
END {
    if (rows == 0) {
        print "FAIL: no markdown table rows found" > "/dev/stderr"
        exit 1
    }
    if (fails > 0) {
        printf "PM-BOARD-CHECK: FAIL (%d error(s) across %d row(s))\n", fails, rows > "/dev/stderr"
        exit 1
    }
    printf "PM-BOARD-CHECK: PASS (%d row(s), disjoint files, valid tiers & caps)\n", rows
}
' "$PLAN"
