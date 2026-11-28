# Workspace Isolation Contract & Disjointness Checklist

## 1. Verbatim Worker Workspace Block (paste into every repo-editing brief)

```text
WORKSPACE: <abs-path-under-$XDG_RUNTIME_DIR/jj-ws/<repo>/<lane>>
WORKSPACE RULES (binding — violation = work discarded):
  - Read and write ONLY inside WORKSPACE (plus explicit read-only paths named in this brief).
  - Never cd above WORKSPACE; never list parent directories.
  - Run ALL builds and tests FROM WORKSPACE (`cd <WORKSPACE> || exit 1`), using WORKSPACE's own `build/` dir.
  - Run ZERO jj or git commands (no commit, new, squash, describe, abandon, rebase, restore, workspace, git *).
  - Deliverable = clean edited files inside WORKSPACE + verbatim report. Landing is the supervisor's job.
  - If WORKSPACE is missing, wrong, or lacks expected files -> stop immediately and report `SPEC GAP`.
```

## 2. Pre-Dispatch Disjointness Checklist (parallel lanes)

Before opening lane `N` while lanes `1..N-1` are active:
- [ ] `FILES` of lane `N` has empty intersection with `FILES` of all active lanes.
- [ ] No shared test-registration file collision (each lane targets a distinct named anchor line or distinct test file).
- [ ] No shared global count-assertion file collision (e.g., total unit/reject count tests serialized in one lane).
- [ ] No shared build artifact collision (e.g., rebuilding a shared static library pauses linking lanes first).
- [ ] Lane `N` has its own `build/`, scratch, cache, and mutant-snapshot paths.
- [ ] Active lane count `<= 5`, concurrent heavy builds on host `<= 3`.
- [ ] Lane recorded in `<proj>/vic/lanes.md` (lane name, workspace path, base tip, ticket ID, exact `FILES`, state).

## 3. End-of-Wave Cleanup Protocol

After every wave of lanes lands:
1. Run `scripts/ws-audit.sh --repo .`
2. For any leftover workspace `<name>`:
   - `jj -R <ws-path> st`
   - Confirm no unlanded valuable work (`jj diff -r '<name>@' --stat`)
   - `jj workspace forget <name>`
   - `rm -rf <ws-path>`
3. Verify `jj log -r 'divergent() | conflicts()'` is empty.
4. Dispatch a wave-level `LAND-VERIFY` on the combined `main` tip.
