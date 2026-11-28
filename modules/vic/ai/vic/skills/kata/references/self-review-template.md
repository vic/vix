# Kata Pre-Code Annotation & Self-Review Checklist

## 1. Pre-Code Review Context Annotation (post on empty review BEFORE coding)
```markdown
## Context (before code)
- **Purpose (P):** <1-2 lines: exact goal gap or bug fixed>
- **Invariant / Design (I):** <typed boundary + spec citation `file:line`>
- **Experiment / Sizing:** <baseline + ablation stub receipt, if perf/architecture>
- **Planned diff:** <exact 1-3 files, minimal footprint>
- **Oracle & Negative Control:** <RED test + compiling mutant>
```

## 2. Pre-Publish Minimalism & Evidence Checklist
- [ ] Diff is minimal and readable in one pass (split oversized commits before publishing).
- [ ] Every non-obvious hunk has an author line annotation explaining *why* (not *what*).
- [ ] Exact verification commands + verbatim outputs pasted (multi-compiler, sanitizer, golden, mutant + clean-restore SHA, perf gate).
- [ ] Addressing prior comments? Put fixes in a **new `jj` changeset** and call `refresh_review`.
- [ ] Connected with `?as=AI`; never resolved someone else's `question`.
