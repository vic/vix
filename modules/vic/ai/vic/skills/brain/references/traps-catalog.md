# Brain Field-Tested Traps Catalog (Project-Agnostic)

Every trap below burned hours before becoming a hard rule:

1. **Clock-string misread on agent ages:** Comparing printed timestamps by eye misread a 6-min agent as 21 min -> ALWAYS use `scripts/check-agent-ages.sh` (`now - mtime` in seconds).
2. **Stale commit bench binary:** Building from the default checkout instead of a workspace pinned to the exact candidate commit measured an old commit -> ALWAYS record the exact built commit SHA + pinned dependency SHAs with every number.
3. **Loaded-host gap noise:** Measuring on a host with other busy processes (load 2.4–9) inverted real gaps -> check `top`/load before every timing.
4. **First-touch page-fault illusion:** Reducing a peak allocation by 18% cut 0% whole-run RSS and added +6.5% instructions because freed pages are reused -> rank memory levers by **live bytes at the global peak** and fresh pages (`sbrk`/mmap growth), not requested malloc bytes.
5. **Host fragmentation skewing THP rulings:** An old "THP dead" verdict came from a fragmented host (`thp_fault_fallback` spikes) -> check `/proc/vmstat` `thp_fault_alloc`/`thp_fault_fallback` and re-test host-state-dependent rulings.
6. **`callgrind` vs. CPUID hardware acceleration:** Valgrind disables hardware crypto/SIMD instructions (e.g., SHA-NI), making `sha256` show 43.6% self in `callgrind` vs. 3.98% in `perf` -> `callgrind` locates only; `perf stat` on release binary sizes. For syscall levers, measure `instructions` (user+kernel) + sys time, not `instructions:u` alone.
7. **The mirror (inlining) trap:** An `-O2`/LTO profile shows an inlined helper as `0%`. Before ruling a helper "below bar", check `nm` for its symbol; no symbol = `"not measured"` (`HOLD`), never `DEAD`.
8. **LTO slow-path inlining inversion:** LTO can inline a cold error/slow path into a hot caller and force the caller's hot helpers out-of-line (+4.65% `instructions:u`) -> read `instructions:u` + `cycles:u` on every perf landing, never wall alone.
9. **Inclusive total vs. per-function delta:** A no-inline inclusive total measures absolute cost, not base-to-candidate regression -> locate regressions with a per-function self-Ir **DELTA** table (base vs. cand) with a sum check.
10. **Test entrypoint vs. production entrypoint mismatch:** Before ruling a soundness hole from a failing unit test, verify the test calls the same entrypoint/preprocessing pipeline the production binary runs.
11. **Inert sanitizer flags:** Some sanitizers (e.g., `-fsanitize=function` under certain toolchains) can be silently inert -> arm with a negative test or explicit value oracle.
12. **Lane-scoped `jj` divergence check:** Guard revsets on shared history should check `divergent()` cleanly and refuse to land parents/children out of order (`rebase -r` moves children onto the old parent -> land parents first or use `rebase -s`).
13. **Crossed messages:** Re-verify current disk/`jj log` state before repeating a question to `hands`.
