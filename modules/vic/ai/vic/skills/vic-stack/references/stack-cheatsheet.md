# Vic Stack Cheatsheet

## 1. Global Hooks Matrix

| Hook | Event | Behavior | How to Satisfy |
|---|---|---|---|
| `vic hook guard` | PreToolUse:Bash | Hard block | No `pkill -f`, no mutating `git` in `jj` repos, cap builds |
| `agent-tier-gate.sh` | PreToolUse:Agent | Hard block (`exit 2`) | `description: "<model>/<effort>: <3-5 words>"` + matching explicit `model` |
| `evidence-gate.sh` | PreToolUse:Edit/Write/Bash | Hard block (`exit 2`) | Create `<main>/vic/evidence/<ws>.md` with `verdict: STUB` (<=30m) or `verdict: PASS` |
| `dev-principle.sh` | PreToolUse:Edit/Write | Reminder | Evidence-gated, experiment-first, high-ROI work |
| `stop-gate.sh` | Stop | Block once | Update `<proj>/vic/HANDOFF.md` (<=25 lines) + `state.md` when ctx >= 70% |
| `pre-compact.sh` | PreCompact | Hard block (`exit 2`) | Blocks auto-compact < 90% ctx; prefer clean restart from HANDOFF |
| `subagent-brief.sh` | SubagentStart | Injects contract | Max 3 attempts, strict scope, verbatim REPORT block |
| `vic hook ledger` | PostToolUse:Bash | Logs output | Read back via `vic-recall` instead of re-running |

## 2. Quipu Tool Reliability

- **USE:** `quipu_ask`, `quipu_query` (SPARQL), `quipu_context` (`max_entities <= 3`), `quipu_validate`, `quipu_resolve_entity`, `quipu_episode`, `quipu_knot`, `quipu_impact`, `quipu_entity_history`, `quipu_unravel`.
- **NEVER USE:** `quipu_search_nodes`, `quipu_search_facts`, `quipu_search`, `quipu_hybrid_search`, `quipu_explain`.
- **Armed-control law:** Empty result != absent. Confirm instrument liveness with a known-present prefix/label.

## 3. Quipu Ledger Naming Convention

- `ledger:<proj>/mistake/<slug>` — what happened, how caught, concrete rule/fix
- `ledger:<proj>/evidence/<slug>` — claim, command, verbatim output, armed control, verdict
- `ledger:<proj>/bead/<id>` (`replace_snapshot: true`) — status, close reason, evidence
- `ledger:<proj>/handoff/<YYYY-MM-DD>` (`replace_snapshot: true`) — daily handoff snapshot
- `ledger:<proj>/landed/<commit-or-pr>` — landed change + verification evidence
