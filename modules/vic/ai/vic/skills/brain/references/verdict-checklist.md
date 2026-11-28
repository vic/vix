# Brain Verdict Rules & Checklist

Apply on every lane report before issuing `land` / `land-with-condition` / `dead` / `hold`:

1. **Never slower on ANY benchmark:** One benchmark's gain never pays for another's regression.
2. **Pay-per-use:** A new checker/feature must cost `~0` on workloads that do not use it (`HOLD` + locate + gate on the trigger if it taxes unused code). Only a P0 soundness fix on workloads that DO use the feature may carry a measured, ablation-proved, ruled cost.
3. **Release ablation sizes; un-inlined profiles locate:** Checkpoint 1 sizes the lever on a release (`-O2`) inlined build; never size from a `-fno-inline` profile.
4. **ROI bar:** `>= 1–2%` for new machinery; strictly-faster reshaping in the same language may land below it.
5. **Armed controls & zero surviving mutants:** Every check has a killed product-site mutant + clean-restore SHA; every zero-count scan has an armed positive control; soundness probes include a positive control of the same shape.
6. **Type-enforced & zero comment-guarded "unreachable" arms:** Make invalid state unrepresentable; remove dead arms rather than commenting them.
7. **P0 holes preempt perf:** Any soundness/correctness hole discovered mid-lane becomes a tracked bead (P0 if unsafe input is accepted) BEFORE perf lanes on those files.
8. **Widenings require proof:** Any widening stays ONLY with a written soundness invariant + killed mutant; otherwise revert it.
9. **Deterministic counters decide:** `instructions:u` (or `instructions` u+k for syscalls) + median peak RSS decide; wall time only on a verified quiet host.
10. **Bead & experiments-log parity:** Every verdict is commented on the bead (after reading back the bead title) AND backed by an experiments-log row carrying the bead ID and pinned commit hashes.
