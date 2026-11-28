#!/bin/sh
# retro-gather.sh — Read-only snapshot of open retro experiments, ccusage cost, and outcome SPARQL (POSIX sh)
# Usage: retro-gather.sh [--since YYYYMMDD]
set -eu

SINCE=$(date -u +%Y%m%d)
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: retro-gather.sh [--since YYYYMMDD]

Gathers Step-1 retrospective inputs without mutating anything:
  1. Open class:retro beads via `vic-pm br` (if available)
  2. Active / daily token burn via `ccusage` (if available)
  3. Exact Quipu SPARQL query for true outcome-based fail% (bypassing vic-telemetry hook bug)
EOF
            exit 0
            ;;
        --since) SINCE="$2"; shift 2 ;;
        *) echo "retro-gather: unknown arg: $1" >&2; exit 2 ;;
    esac
done

echo "=== 1. OPEN RETRO EXPERIMENTS (prove or revert from prior wave) ==="
if command -v vic-pm >/dev/null 2>&1; then
    vic-pm br list --status=open 2>/dev/null | head -n 30 || echo "(vic-pm br unavailable)"
else
    echo "(vic-pm not on PATH)"
fi

echo "=== 2. CCUSAGE COST SNAPSHOT (since $SINCE) ==="
if command -v ccusage >/dev/null 2>&1; then
    timeout 20 ccusage session --json --since "$SINCE" 2>/dev/null | head -n 40 || echo "(ccusage timed out or empty)"
else
    echo "(ccusage not on PATH)"
fi

echo "=== 3. ACCURATE QUIPU OUTCOME-BASED FAIL% QUERY (pass to quipu_query) ==="
cat <<'EOF'
SELECT ?class ?tier ?outcome (COUNT(?r) AS ?n) (AVG(?s) AS ?avg_secs)
WHERE {
  ?r ?pTier ?tier ; ?pOut ?outcome ; ?pSecs ?s .
  OPTIONAL { ?r ?pClass ?class . FILTER(STRENDS(STR(?pClass), "/class")) }
  FILTER(STRENDS(STR(?pTier), "/tier") && STRENDS(STR(?pOut), "/outcome") && STRENDS(STR(?pSecs), "/secs"))
}
GROUP BY ?class ?tier ?outcome
ORDER BY ?class ?tier
EOF
