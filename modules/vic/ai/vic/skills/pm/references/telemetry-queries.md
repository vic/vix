# PM Telemetry, Estimation & Calibration Queries

## 1. Accurate `fail%` Query (works around `vic-telemetry` `outcome=done` bug)
`vic-telemetry` SubagentStop hook rows record `outcome=done` while `record()` sets `failed=0` only for `ok|accept`, inflating `a:failed`. Always compute `fail%` from `a:outcome` (`done`/`ok`/`accept`/`PASS` = success):

```sparql
PREFIX a: <http://example.org/ontology/>
SELECT ?class ?tier ?o (COUNT(?r) AS ?n) (AVG(?s) AS ?secs)
WHERE {
  ?r a a:Run ; a:tier ?tier ; a:outcome ?o ; a:secs ?s .
  OPTIONAL { ?r a:class ?class }
}
GROUP BY ?class ?tier ?o
ORDER BY ?class ?tier
```
*(Match the store's ontology prefix via `quipu_ask {}` or `STRENDS(STR(?pred), "/outcome")`.)*

## 2. Relative Sizing & Policy Thresholds
- **Points:** `1` = mechanical (exact steps) · `2` = tight spec, local decisions · `3` = multi-file/cross-constraint · `5` = global invariants · `8+` = NOT a unit (split; spike first if unknown).
- **PERT:** `est = (optimistic + 4*likely + pessimistic) / 6`. If `pessimistic > 300s` (mechanical) or `> 600s` (coding) -> split.
- **Wave cost (`ccusage`):** Start with `ccusage blocks --active`; end with `ccusage session --json --since <YYYYMMDD>`.
- **Policy update rules (require `n >= 3` runs per `class × tier`):**
  - `est-err > +50%` -> raise estimate or split smaller.
  - High `fail%` at tier `T` -> tighten spec/oracle FIRST; if still high -> move class up ONE tier.
  - `fail% ~ 0` and low tokens -> spike ONE tier down next wave.
  - Frequent `specgap` or `killed` -> WBS/partition defect, not model defect.
- **Calibration ledger:** Save to `quipu` as `ledger:<proj>/pm-calibration/<class>` (`replace_snapshot: true`) and mirror in `pm/notes/pm-calibration-<class>.md`.
