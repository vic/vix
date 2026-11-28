# Retro Proposal Template (`class:retro` experiment)

```markdown
## RETRO-<N>: <one-line change>
- **Target file(s):** `<skills-source-repo>/<path>`
- **Evidence (from gathered metrics):** <gebed_metrics + a:outcome fail% + ccusage tokens, n >= 3>
- **Root cause:** <reading failure -> move to hook | prompt ambiguity -> tighten template | partition error -> split | tier mismatch>
- **Hypothesis:** Changing <X> will move <named metric> from <baseline> to <target> without lowering first-run accept rate.
- **Exact diff / rule:** <minimal concrete edit>
- **Verification next wave:** measure <metric> over >= 3 runs; **ROLLBACK if** metric does not improve OR quality drops.
```
