# Ledger, Mining & Telemetry Recipes

## 1. Safe Recall-Before-Run Pattern
```sh
# 1. Check whether working tree changed since last ledger entry
scripts/recall-fresh.sh --repo . --pattern "build-test"
# 2. Fetch full prior output without re-running
vic-recall "build-test" 3
```
**NEVER trust a recalled result if:** working files changed, dependencies changed, compiler/env flags changed, or the recalled run timed out/errored.

## 2. Accurate `fail%` Query (works around `vic-telemetry` hook `outcome=done` bug)
Query Quipu via `quipu_query` using `a:outcome` directly instead of the `failed` counter:
```sparql
SELECT ?agent ?outcome (COUNT(?r) AS ?n)
WHERE {
  ?r <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t ;
     ?pAgent ?agent ;
     ?pOut ?outcome .
  FILTER(STRENDS(STR(?pAgent), "/agent") && STRENDS(STR(?pOut), "/outcome"))
}
GROUP BY ?agent ?outcome
ORDER BY DESC(?n)
```

## 3. Per-Stage `gebed_report` Split (trackers sum minutes across reports)
- **Implementation stage (`impl-agent <model>/<effort>`):** code + mutant minutes, actual diff-size weight (Fibonacci 1..21), attempts, testsPass/testsFail, complexity (1–5), `capacity: 1`.
- **Perf stage (`perf-agent haiku/low`):** perf minutes only; omit `capacity`.
- **Design stage (`design <model>`):** remaining cycle minutes, findings (commit hash, deltas, rulings, estimate vs. actual, own slips), `capacity: 1`.
- Never submit two minute-bearing reports for the same stage; omit cycle minutes when a gap holds an outage or design pause.
