---
name: pie
description: PIE design law (ALL projects) — Purpose, then Interactions, then Elements. Use before any design, spec, dispatch brief, agent/fleet split, or restructure of code, services, skills, or agent roles. Triggers — design, architecture, split work, new agent/role, new package/module, "who does what", overloaded agent, refactor boundaries. Purpose first, contract stable, experiment-sized before elements, elements last.
---

# PIE LAW (vic, global) — Purpose -> Interactions -> Elements

**Stack:** `/vic-stack` — at **P**, recall `quipu` decisions and ask the owning session via `ircc` before choosing elements. Pair with `/probes` (size levers before choosing elements) and `/oracle` (define the consumer-side oracle inside **I**).

**Source:** Damian Płaza, *"Composing a PIE"* (2025-05-24).
**Core truth:** *"A system's capability to fulfill its Purpose emerges from Interactions between Elements."*
The exact same law governs every scale: function · module · package · service · agent · parallel fleet · skill set.

**Assets in this skill:**
- `references/pie-templates.md` — copy-paste PIE skeletons for design specs, dispatch briefs, fleet/lane decompositions, and restructure moves.
- `scripts/pie-check.sh` — mechanical verifier checking that a design doc or brief defines Purpose, consumer-side Interaction contract/oracle, and Element boundaries in strict P -> I -> E order (zero element-first bias).

---

## 1. Strict order (NEVER skip, NEVER reorder)

1. **P — PURPOSE (consumer side, 1–2 lines):**
   - What measurable capability is needed **NOW**, for whom, and what **measurable exit state** proves it works?
   - Explicitly state **NOT-PURPOSE** (what is out of scope — prevents hours of gold-plating and speculative layers).
   - No Purpose line -> **no design, no code, no dispatch**.
2. **I — INTERACTIONS (outside-in contract + protocol + oracle):**
   - **Contract shape:** exact input/output types (illegal states unrepresentable; closed enums; zero sentinels).
   - **Protocol:** who calls whom, order, sequential vs. parallel fan-out/fan-in, failure propagation, and ownership of side effects.
   - **Oracle (`/oracle`):** executable acceptance check + armed negative control from the *consumer's* perspective BEFORE naming any internal implementation element.
   - **Experiment gate (`/probes`):** if the Purpose is optimization or architectural replacement, prove the lever size with a throwaway ablation stub on the whole workload before designing Elements.
3. **E — ELEMENTS (chosen LAST, minimal count):**
   - Roles/modules/agents that realize the capabilities required by **I**.
   - **Minimum necessary elements:** never invent a new layer, wrapper, daemon, or helper unless an interaction explicitly requires it. Delete more than you add.
   - Placement (one binary vs. many, one agent vs. parallel fleet, model tier via `/dispatch`) is decided strictly by measured context forces, never habit.

---

## 2. The Restructure Move (change without breaking consumers)

When an element is overloaded (measured symptom: agent ctx > 70%, 2–3 repeated failures, > 10-min task duration, high change churn, or hard-to-test coupling):
1. **Name the overloaded element + measured symptom** (a counter or timing, never a feeling).
2. **Freeze entry and exit Interactions (`I`)** — write/verify the consumer-side oracle first.
3. **Extract one cohesive responsibility** into a new element (or split one oversized brief into `-a`/`-b`/`-c`).
4. **Rewire internally:** sequential -> parallel fan-out + single deterministic combine step where data allows.
5. **Verify `I` stayed byte/contract-identical.** Any change leaking into the consumer contract is an escalation gate (`/escalate`).

*"What you hide, you can change."* A clean Interaction boundary is what buys freedom to delete and rewrite Elements cheaply.

---

## 3. Applying PIE across work types

| Artifact | P (Purpose) | I (Interactions) | E (Elements) |
|---|---|---|---|
| **Design doc / RFC** | Consumer problem + measurable exit bar + explicit non-goals | Typed API/schema + protocol sequence + executable oracle + perf bar | Modules, data layouts, single-producer ownership |
| **Task brief** | Goal line + how it moves critical path | Exact `FILES`, typed `CONTRACT`, commands, oracle + mutants, report shape, who talks to whom | Agent role, model tier, effort, 10-min budget |
| **Parallel fleet / lanes** | Wave goal + linear tip target | Disjoint file/test partitions, handoff/verdict messages, landing order | Lane workspaces, worker roles, auditor |
| **Refactor / perf fix** | Measured bottleneck or invariant violation | Preserved consumer oracle + ablation-backed target delta | Smallest producer-site edit (never read-site patches) |

---

## 4. Cross-session & peer collaboration (Interactions, not Elements)

- Other local sessions own other projects — ask the owning session via `ircc` / explicit session ID before re-deriving cross-project facts.
- Share breaking changes or bugs proactively with peers that depend on them, always backed by `cmd + output` and `file:line`.
- **Authority law:** Peer facts and relayed quotes are claims (verify independently). Only direct owner lines authorize scope, permission, or policy changes. Permissions are per-session — route writes to the owning leader session; never circumvent a denial.
- **Cross-review is an Interaction:** Name the reviewer/auditor BEFORE work starts, not as an afterthought.

---

## 5. Red flags (stop & fix immediately)

| Symptom | Root Error | Mandatory Fix |
|---|---|---|
| Starts with *"we need a new service / class / agent X"* | Element chosen before Purpose | Delete proposal; write 1–2 line consumer `P` first |
| Brief or spec omits output shape or oracle | Missing `I` contract | `SPEC GAP` — write exact types + oracle before dispatch |
| Throwing a bigger model at an overloaded agent | Scaling `E` instead of restructuring | Execute Restructure Move: split task/element, keep `I` stable |
| Refactor forces edits across callers | Leaked internal change across `I` | Restore contract boundary or escalate (`/escalate`) |
| Adding speculative flags/hooks *"for future flexibility"* | Unrequested `P` / unnecessary code | Cut immediately; design only for measured `P` NOW |
| Arguing an abstraction is *"incomplete"* | Perfectionism trap (Box: all models are wrong, some useful) | Test against `P`'s oracle; if it satisfies `P` cleanly, ship |
