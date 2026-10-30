# Use the vic skills

Invoke these through the Skill tool. Reading the file does not count. Do it before the
first action, and again when the task changes.

- `vic`: first, in every session and every subagent. It holds vic's rules.
- `vic-stack`: at task start. It sets the loop: recall in quipu, ask peers on ircc, work,
  save to quipu, share on ircc.
- `quipu`: before you read from or write to the quipu store. Recall comes before you
  re-derive anything, and a verified result is saved after.
- `pie`: before any design, spec, dispatch brief, agent split or restructure. Purpose
  first, then interactions, then elements.

ircc has no skill of its own. Use the `ircc_*` tools as `vic-stack` describes: ask the
session that owns a project before you re-derive its facts.

Skipping a skill because the task looks small is the failure this rule exists to stop.
