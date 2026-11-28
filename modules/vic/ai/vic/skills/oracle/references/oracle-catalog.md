# Oracle & Mutant Catalog

## 1. High-Assurance Oracle Patterns

| Oracle | Construction | Catches |
|---|---|---|
| **Differential + `ddmin`** | Compare candidate vs. independent reference/stage-0 in BOTH directions (unsoundness AND incompleteness); auto-shrink counterexamples with `ddmin`. | Subtle semantic divergence; unreadable counterexamples. |
| **Bijective Encoding** | Assert `decode(b) = Ok(o) ==> encode(o) == b`, plus reject non-canonical encodings (`-0`, overlong varints, non-binary bools, cycles/forward refs). | Non-deterministic hashes, canonicalization bugs. |
| **Sharded Seed-Shuffle** | Run fixed-size case slices under `timeout`, varying shuffle seed and thread count, asserting byte-identical output via `cmp`. | Order-dependence, nondeterminism, race conditions. |
| **Multi-Transport + Flat RSS** | Send identical framed workloads over CLI/socket/RPC; assert byte-identical non-trivial replies + `0 KB` RSS delta over 1,000 live requests. | Transport divergence, slow memory leaks. |
| **Back-Translation Round-Trip** | For code/rule generators: emit `stats.txt` (`unmapped=0`, `leftover=0`), back-translate to canonical form, run full golden suite. | Silent generator loss or drift. |
| **Compile-and-Run + `-O2` `objdump`** | Compile emitted code on GCC + Clang at `-O2 -Werror`, verify exit codes and verify hardening barriers survive `-O2` in disassembly. | Invalid generated code, compiler-elided security checks. |
| **Static Stack + Low-Stack Run** | Compile with `-fstack-usage` (reject VLAs / oversized frames) + run deep stress fixture under `ulimit -s 1024`. | Recursive stack overflows. |

## 2. Adversarial Mutant Checklist

- [ ] Anchor read on the real file (`rg -Fc == 1`), not predicted from memory.
- [ ] Mutates condition/constant/argument/string — never deletes calls/loops that break `-Werror=unused-*`.
- [ ] Well-defined (does not rely on reading uninitialized memory for a fake kill).
- [ ] Hits the product path (e.g., actual allocation/dispatch/emission site), never only a test helper.
- [ ] Predicts every failing check NAME (both paths for dispatch predicates; full downstream cascade for early steps).
- [ ] Armed fixture actually exposes the bug (unsorted input for sort; open pipe past limit for bounds; non-zero offset for arena OOB).
- [ ] Clean snapshot saved before mutating; restored and verified byte-identical (`sha256sum` + `cmp`).
