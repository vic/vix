# Compiler Craft Verification Gates & Oracles

## 1. Bootstrap Independence Gate (with File-Open Trace + Mutant)
1. Copy the repository into an isolated temp dir and **delete** the legacy compiler/toolchain tree.
2. Build stage-1 from seed and run the full positive + negative test suites under `strace -f -e trace=openat,open,execve -o /tmp/indep.trace`.
3. Assert zero opens/execs referencing the deleted legacy path.
4. **Armed mutant:** Inject a single read of a legacy path into the build script; assert the trace gate FAILS; restore byte-identical.

## 2. Pay-Per-Use Split Benchmark
Report two separate rows for every new language/checker feature:
- `corpus-without-feature`: MUST stay `<= +0.5%..+1.0%` instructions (ideally `~0%`, trigger-gated).
- `corpus-with-feature`: gated by ablation-proved semantic work + explicit ruling.

## 3. Static Stack + Cross-TU Inline Gate
```sh
# 1. Fail on dynamic/unbounded stack frames or frames > 4096 bytes
gcc -O2 -fstack-usage -c src/*.c
awk '$2 ~ /dynamic/ || ($2 + 0) > 4096 { print "STACK FAIL:", FILENAME, $0; fail=1 } END { exit fail }' *.su

# 2. Fail if hot static-inline helpers emitted out-of-line symbols
nm build/compiler | grep -E ' [Tt] (hotHelperOne|hotHelperTwo)$' && exit 1 || echo "INLINE GATE PASS"
```
