#!/bin/sh
# sprint-metrics.sh — Summarize sprint burndown & outcome-based fail% from a TSV/CSV log (POSIX sh)
# Usage: sprint-metrics.sh <sprint-runs.tsv>
# Format (tab-separated, header optional): item  tier  points  est_sec  actual_sec  outcome
set -eu

if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage: sprint-metrics.sh <sprint-runs.tsv>

Computes sprint metrics cleanly from a TSV of completed/killed items:
  columns: item <tab> tier <tab> points <tab> est_sec <tab> actual_sec <tab> outcome
Success outcomes: ok, accept, done, pass (case-insensitive).
Outputs: burndown points, true outcome-based fail%, estimate error %, and per-tier breakdown.
EOF
    [ $# -eq 1 ] && exit 0 || exit 2
fi

FILE="$1"
[ -f "$FILE" ] || { echo "FAIL: file not found: $FILE" >&2; exit 1; }

awk -F'\t' '
BEGIN {
    tot = 0; ok = 0; pts_plan = 0; pts_done = 0; est_sum = 0; act_sum = 0
}
NR == 1 && tolower($1) ~ /^item/ { next }
NF < 6 || $1 ~ /^#/ { next }
{
    tier = $2; pts = $3 + 0; est = $4 + 0; act = $5 + 0; out = tolower($6)
    tot++
    pts_plan += pts
    est_sum += est
    act_sum += act
    t_tot[tier]++
    t_act[tier] += act
    if (out == "ok" || out == "accept" || out == "done" || out == "pass") {
        ok++
        pts_done += pts
        t_ok[tier]++
    }
}
END {
    if (tot == 0) { print "No sprint rows found."; exit 1 }
    fail_pct = ((tot - ok) / tot) * 100.0
    est_err = (est_sum > 0) ? ((act_sum - est_sum) / est_sum) * 100.0 : 0.0
    printf "SPRINT METRICS: items=%d/%d ok (fail=%.1f%%) | points=%d/%d | actual=%ds vs est=%ds (err=%+.1f%%)\n",
           ok, tot, fail_pct, pts_done, pts_plan, act_sum, est_sum, est_err
    print "PER-TIER:"
    for (t in t_tot) {
        tf = ((t_tot[t] - (t_ok[t] + 0)) / t_tot[t]) * 100.0
        printf "  %-14s runs=%d ok=%d fail=%.1f%% avg_sec=%.0fs\n", t, t_tot[t], t_ok[t] + 0, tf, t_act[t] / t_tot[t]
    }
}
' "$FILE"
