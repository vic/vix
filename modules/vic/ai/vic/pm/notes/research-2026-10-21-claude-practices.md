# research 2026-10-21: Claude agentic practices vs vic setup (opus-5.5)

## srcs
- anthropic.com/engineering/multi-agent-research-system
- anthropic.com/engineering/effective-context-engineering-for-ai-agents
- code.claude.com/docs/en/best-practices · /sub-agents · /hooks
- platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

## facts (quoted/num)
- multi-agent: token use explains 80% of perf variance; tool calls + model choice explain the rest (95% total). multi-agent ≈15× chat tokens ⟹ only high-value parallel work. most coding = poor fit (shared ctx).
- opus lead + sonnet subagents beat single opus by 90.2% (research eval).
- delegation prompt = objective · output format · tools/sources · scope limits. vague = dup work.
- effort scaling in prompt: 1 agent 3-10 calls · 2-4 agents 10-15 calls · 10+ agents complex. early bug: 50 agents for simple query.
- parallel 3-5 subagents + parallel tool calls = up to 90% time cut.
- subagent returns 1-2k tokens; outputs to fs, pass refs (no telephone game).
- claude given prompt + failure mode diagnoses + fixes prompt; tool-desc rewrite = 40% faster task.
- eval: ~20 real queries enough early; single LLM-judge call w/ rubric 0-1 + pass/fail beat multi-judge.
- CLAUDE.md/skills: bloat ⟹ rules ignored; emphasis on many lines ⟹ none stands out; SKILL.md <500 lines; refs 1 level deep.
- 2 failed corrections ⟹ fresh context + better prompt.
- reviewer prompted for gaps always finds some ⟹ restrict to correctness/requirements.
- hooks = deterministic; instructions = advisory.
- subagent frontmatter: model, effort, maxTurns, memory(user|project|local), skills, isolation:worktree, experimental.cacheTtl.

## applied 2026-10-21
- all vic-* agents: explicit `effort:` per tier (was missing ⟹ inherited session effort; opus agents ran at session effort, not high).
- SubagentStop hook auto-logs agent·effort·out_tok·secs to ledger subagents.tsv (logging no longer PM-memory dependent).
- vic-retro agent + /vic-retro-loop skill (measure → diagnose → ≤5 proposals → prove-or-revert).
- vic-pm sync/restore carries subagents.tsv.

## open (beads)
- maxTurns per tier: calibrate from subagents.tsv secs (no data yet; no magic number).
- vic SKILL.md 584 lines + caps everywhere = documented anti-pattern; split via progressive disclosure (vic rules).
- dnet SKILL.md 1220 lines: same.
- agent-team per-PM `memory:` field: user scope lives in ~/.claude (not repo) ⟹ prefer vic-pm store.
