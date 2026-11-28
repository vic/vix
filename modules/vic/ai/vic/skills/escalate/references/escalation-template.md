# Escalation Artifact & Owner Decision Memo Templates

## 1. Cold-Resumable Escalation Artifact (`<proj>/vic/notes/escalate-<slug>.md`)

```markdown
# ESCALATE: <one-line precise question or architectural block>

- **DATE / SESSION:** <YYYY-MM-DD HH:MM UTC> · `<model>/<effort>`
- **TICKET / TASK:** `<ticket-id>` · `<task-id>`
- **BLOCKED ON:** <exact symptom + command + verbatim error output>

## TRIED (every attempt with tier & falsification receipt)
1. **Try 1** (`<model>/<effort>`): <approach> -> FAILED: `<exact cmd + verbatim output>`
2. **Try 2** (`<model>/<effort>`): <approach> -> FAILED: `<exact cmd + verbatim output>`
3. **Try 3** (`<model>/<effort>`): <changed tier/design> -> FAILED: `<exact cmd + verbatim output>`

## RULED OUT (dead paths — DO NOT re-walk)
- <Hypothesis/path A>: falsified by `<probe/ablation + exact numbers>`
- <Hypothesis/path B>: falsified by `<probe/ablation + exact numbers>`

## SPEC ANCHORS CHECKED
- `<spec-file:line>` "<quote>" — insufficient because `<exact gap>`

## NEEDED TO UNBLOCK
- [ ] Derivation `<X>` | Owner ruling (A / B / C below) | Architecture redesign at `<invariant site>`

## COLD-RESUME STATE
- **Repo / commit:** `<path>` @ `<jj change/commit>` (clean working copy confirmed)
- **Minrepro path & cmd:** `<path>` — `<exact <1s repro cmd>`
- **Probe files:** `<paths>`
```

## 2. One-Page Owner Decision Memo (never open-ended)

- **Decision needed (1 line):** `<what>`
- **Option A (Recommended):** `<change>` — **Pro:** `<receipt>` · **Con:** `<cost>` · **Reversible?** yes/no
- **Option B:** `<change>` — **Pro:** `<receipt>` · **Con:** `<cost>`
- **Default if unchosen:** blocked (no speculative action taken).
