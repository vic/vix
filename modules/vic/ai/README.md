# vic.ai — sini's AI workflow + vic's tooling, as a den aspect

This directory is the `vic.ai` aspect of the vx den (`vic` is the local den
namespace). It carries the AI tooling from `sini/nix-config`
(`modules/den/aspects/applications/dev/ai`), cut down to what you can run on
your own machine, plus vic's own tooling from frodo (vic-* agents, vic skills,
workflow hooks, omni, deepwiki, notebooklm, lightjj) under `vic/`. See §10.
It was first assembled as a standalone flake (`tmp/sai`) and then moved here.

`den.aspects.vic` includes `vic.ai`. Its `homeManager` class reaches a host
only where the user has `"homeManager"` in `classes`. Today that is frodo
(`modules/den.nix`). bilbo does not get it.

```console
nix run .#frodo -- switch   # build + activate the frodo system (nh)
```

The flake inputs are in the hand-written `/flake.nix` (section `vic.ai`).
vx has no flake-file, so a new input goes there, followed by `nix flake lock`.

vx is a colocated jj/git repo. A `.#` flake ref reads the git index, so files
that jj tracks but git does not are invisible to Nix. Until you commit, use a
`path:` ref, for example `nix flake lock path:$PWD` or
`nix build path:$PWD#nixosConfigurations.frodo.config.system.build.toplevel`.

---

## How sini works with AI

The rest of this file explains each piece of the config through the workflow it
supports. Read it in order: each section builds on the one before it.

### 1. One orchestrator, many disposable agents

The main Claude Code session is an **orchestrator**. It plans, decides and
reviews, and it rarely edits code itself. It sends the actual work to
fresh-context subagents and reads what they report back. Subagent context is
cheap; orchestrator context is the scarce thing. That is why most of this
config protects orchestrator context or helps it read a subagent's result.

The subagents come in four **agent types** (`modules/users/vic/ai/agents.nix`, rendered to
`~/.claude/agents/gen-*.md`):

| agent       | role                                                                                                   | can edit? |
| ----------- | ------------------------------------------------------------------------------------------------------ | --------- |
| `gen-scout` | Measures and reduces. Answers "is this still true at HEAD?" and "where does X live?"                    | no        |
| `gen-spec`  | Writes a lean spec: problem, mechanism, acceptance oracles (§3a gating, §3b guarantee), open questions | yes       |
| `gen-gate`  | Adversarial reviewer. Defaults to REJECT and must be argued out of it with evidence. One contact       | no        |
| `gen-build` | Implements a spec that passed the gate, lands §3a only, and runs it                                     | yes       |

A typical loop is **scout → spec → gate → build → gate**. The orchestrator
dispatches each step, for example: "use gen-scout to check whether…".

Things worth noticing in how the agents are built:

- **Tool restriction is what makes a role stick.** `gen-gate` and `gen-scout`
  get no `Edit` tool and none of serena's editing tools. A reviewer that cannot
  edit cannot quietly fix the thing it is judging, so it has to report what it
  found. They can still `Write` reports, and that is on purpose: writing you can
  see is better than heredoc writing you can't.
- **The prompts are composed from parts, not stored whole.** Each agent is
  assembled as `agents/_<role>-head.md` (frontmatter and tools) +
  `_local-deltas.md` + the upstream role text from `github:sini/genie-agent`
  (`operating-memory/workflow/roles/common-protocol.md`, then `<role>.md`).
  The role text is pinned with npins, so an upstream fix arrives on
  `npins update genie-agent`. `_local-deltas.md` holds what differs on this
  machine (fish, jj, quipu); it reaches all four agents and the
  `operating-memory` skill.
- **Escalation has three fixed names:** `NEEDS_CONTEXT`, `BLOCKED` and
  `STOP-AND-PROMOTE` (a design question the agent must not decide). Returning
  one of these early counts as a good outcome. Improvising past a gap does not.
- **Agents report through `SendMessage`** and also write a file. The message is
  the notification and the file is the artefact.

The prompts mention sini's own project (gen/den, beads ids, ADRs). Read those
parts as worked examples of the discipline rather than as rules for your repos.
Once you write your own role bodies, rename the agents.

### 2. Measurement discipline

`common-protocol.md` (upstream) is the heart of the workflow. Its rules come from false
findings that actually happened:

- **Every claim carries the command that produced it.** Every *absence* also
  carries a live **positive control** from the same run. "grep found 0" means
  nothing until the same grep finds something known to exist.
- **A zero is not evidence of absence.** Indexes skip directories, tools drop
  languages, and `0/0 tests passed` reads as a pass.
- **A count needs a commit sha.** Without one it goes stale without anyone
  noticing.
- **A falsified premise goes first in the report.**

The code-discovery hooks in §4 apply the same idea to tools: each one says where
its own tool is blind.

### 3. Hooks: the harness talks to the model (`claude.nix`)

sini treats hooks as **instruments**: each one puts measured state in front of
the model at the moment a decision is made.

| event                  | hook                                                     | why                                                                                                                                                                                                        |
| ---------------------- | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SessionStart, PreToolUse(Agent) | `budget.sh`                                     | Prints one line: `BUDGET · ctx % · 5h % · 7d % · GATE`. New work can start up to 75% context. From 90%, the rest of the window goes to the handoff. When weekly quota is at or above 95%, nothing new is dispatched. |
| SubagentStop           | `subagent-stop.sh`                                       | "Tree first, then prompt once, never re-dispatch." Agents often go idle before their report arrives, and the reflex of re-dispatching duplicates work that is already done.                               |
| SessionStart, CwdChanged | `load-direnv.sh` → `CLAUDE_ENV_FILE`                   | Without this, Bash tool shells never see the project's devshell. It runs on these two events only, because evaluating direnv per shell fork-bombs the host.                                              |
| PreToolUse(Bash)       | `rtk hook claude`                                        | Rewrites commands to `rtk <cmd>` so their output is compressed (60–90% fewer tokens).                                                                                                                      |
| PreToolUse(Grep\|Glob), SessionStart, SubagentStart | codebase-memory reminders     | Tell the agent to query the code graph before grepping, and list the graph's known blind spots.                                                                                                             |

Hook output channels are easy to get wrong. Plain stdout reaches the model only
on `SessionStart`. `PreToolUse` and `SubagentStart` need JSON with
`hookSpecificOutput.additionalContext`. `SubagentStop` output reaches no one.
The comments in sini's `claude.nix` record how each of these was measured.

`settings.json` is a **read-only store symlink**. Change settings in Nix, not in
the TUI. Permissions pre-allow read-only commands, git commit/push to
`origin main` (the literal form, so a force-push still prompts), and the nix
build commands.

### 4. Code discovery: query a graph before grepping (`mcp.nix`, `tools.nix`)

| server            | what for                                                                                             |
| ----------------- | ---------------------------------------------------------------------------------------------------- |
| `codebase-memory` | Indexed call/definition graph: `search_graph`, `trace_path`, `get_code_snippet`, Cypher `query_graph` |
| `serena`          | LSP-backed symbol navigation and symbol-level edits                                                  |
| `codegraph`       | `codegraph_explore`: source of the relevant symbols plus the call paths between them, in one call   |
| `headroom`        | Compression and retrieval tools (see §5)                                                             |
| `nil` (LSP)       | Nix outline, hover, file-local definitions                                                           |

Each tool's known traps sit next to it: codebase-memory misses Nix calls made
through attrsets, so zero callers does not mean dead code. The `search-code-routing`
skill chooses between `ast-grep`, `rg` and the graphs.

### 5. Token economy (`headroom.nix`, `rtk`)

- **headroom** runs as a local proxy (`systemd --user` / launchd on
  `127.0.0.1:8787`), and Claude Code talks to it through `ANTHROPIC_BASE_URL`.
  It runs in `cache` + `LOSSLESS` mode because lossy compression was measured
  to cost about one prompt-cache token for every token it saved. It also polls
  your subscription usage, and `budget.sh` reads that file. **If the proxy is
  down, Claude Code cannot reach the API.** Check it with
  `systemctl --user status headroom`.
- **rtk** compresses the output of ordinary shell commands through the hook
  above.
- `ENABLE_TOOL_SEARCH=auto:5` defers MCP tool schemas until they are needed.
- The **status line** (`statusline.nix`, ccstatusline) shows what is still
  unlanded (branch, changes, ahead/behind, worktree) and what the session is
  costing (context %, session and weekly quota sliders).

### 6. Spec first, then review

- **openspec** (`/opsx propose|apply|verify|archive`) gives a spec-driven change
  workflow, with 12 skills rendered at build time.
- **superpowers** forces `brainstorming` before building, and also provides
  `writing-plans`, `systematic-debugging`, TDD and `verification-before-completion`.
- **adversarial-review**: critics independently try to break an artifact, and
  the author revises only against the objections that hold up.
- **mattpocock** (`grilling`, `domain-modeling`, `tdd`, …) and **gstack**
  (`/review`, `/qa`, `/ship`, `/investigate`, `/cso`, …) are broader workflow
  libraries. Use the parts you like.
- **ponytail** acts as a counterweight against over-building ("the best code is
  the code never written").

### 7. Writing like a person

The `writing-*` skills cover commit messages, PR descriptions, code comments,
design docs (KEP shape) and RFCs (Rust-RFC shape). Their shared rules: no
invented "why", no checklists, and a comment only when the reason isn't
obvious. `calldiff` and `diagram-mermaid-render` describe changes by the call
paths they moved and by diagrams, rather than in prose.

### 8. Persistent state: tracker and memory

- **beads (`br`)** is the issue tracker for agents: SQLite plus a JSONL file
  committed to git. In sini's workflow, **arc state lives in the tracker graph,
  not in markdown**. Every count is derived by query, and before compaction
  every open obligation goes into a bead body. Set `env.BEADS_DIR` in
  `tools.nix` to pin it to one tracker. Two rules sini measured: use
  `--limit 0` (the bare list commands silently cap their output), and give the
  model plain text, never `--json` (31× larger for the same information).
- **Auto memory** lives in `~/.claude/memory/`: one fact per file, with
  `MEMORY.md` as an index of one line per memory. Feedback memories record
  *why* as well as *what*.
- **hindsight** (sini runs it as a cluster service) is a shared memory bank
  tiered as `tier:law` (written by the owner), `tier:trap` (measured tool
  pitfalls, written by agents) and `tier:episode` (sessions). The agents'
  "Memory" section expects it. **It is not set up here** because it needs a
  server. Until you run one and add `programs.claude-code.mcpServers.hindsight
  = { type = "http"; url = "…/mcp/<bank>/"; }`, the agents will report it
  absent and carry on.

### 9. Plugins and skills

Plugin marketplaces are **pinned in the store** (`plugins.nix`), so Claude Code
never clones them at runtime. `known_marketplaces.json` is written in full by
home-manager with `autoUpdate = false`. Otherwise Claude Code rewrites the file
and the next activation fails. To add a marketplace, add a `name = url` entry
and enable its `plugin@marketplace`. Plain skills are any directory containing
a `SKILL.md` under `modules/users/vic/ai/skills/`.

### 10. vic's layer (`vic/`)

This layer is everything that was installed by hand on frodo before vic.ai.
Two rules apply:

- **No duplicates.** When a skill or tool comes from an upstream repo, it is
  taken from that repo (a flake input, a release, or npm). It is not copied.
  Only the files that vic wrote are copied, and they install to the same paths
  under `~/.claude`, so hooks and docs that use absolute paths still work.
- **Nix is the only source.** Nothing in `~/.claude`, `~/bin`, `~/.agents` or
  `~/node_modules` is needed after the switch. Edit the files here, not there.

| file           | carries                                                                                                                                                                                         | was                                                       |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `agents.nix`   | 16 `vic-*` subagents from `agents/` (haiku: probe, reader, sweep, scribe, chain, judge, superhaiku; sonnet: rung, isolate, reviewer, planner; opus: hunter, typesmith, lawyer, perf; xhigh: derive) | `~/.claude/agents/`                                       |
|                | vic's 23 skills from `skills/` (vic, supervisor, dispatch, oracle, probes, lanes, ledger, handoff, ensemble, superhaiku, omni, br, kata, ned, dnet, zen, …)                                      | `~/.claude/skills/`, `~/.agents/skills/`                  |
|                | global `CLAUDE.md` + `RTK.md` from `memory/`                                                                                                                                                    | `~/.claude/`                                              |
| `hooks.nix`    | `boot.sh` (SessionStart), `ctx-meter.sh` (UserPromptSubmit), `cmd-ledger.sh` (PostToolUse Bash), `stop-gate.sh` + `omni-ingest.sh` (Stop)                                                         | `~/.claude/hooks/`                                        |
| `tools.nix`    | `vic-run`, `vic-recall`, `vic-mine`, `vic-telemetry`, `vic-law`, `vic-gc`, `vic-ws` from `bin/`                                                                                                  | `~/bin/`                                                  |
|                | omni (`omni/`, installed at `~/.claude/omni`) + its MCP. The DB stays at `~/.claude/omni.db`                                                                                                    | `~/.claude/omni/`                                         |
|                | deepwiki MCP + `deepwiki` REPL (`dw/`, copied because `repl.js` has changes not pushed to `github:vic/dw`)                                                                                      | `~/hk/dw/`                                                |
|                | notebooklm MCP (`npx notebooklm-mcp@latest`) and `notebooklm-pack` (`github:meta-introspector/notebooklm-pack`)                                                                                 | `~/.claude.json`, `~/bin/`                                |
| `upstream.nix` | skills from source: `deepwiki` (`seflless/deepwiki`), `find-skills` (`vercel-labs/skills`), `lightjj` (`chronologos/lightjj` v1.27.0, `cmd/lightjj/SKILL.md`)                                    | `~/.agents/skills/`, `~/.claude/skills/lightjj`           |
|                | `lightjj` v1.27.0, the upstream release binary (`fetchurl`, same hash as the binary that was in `~/Downloads`)                                                                                   | `~/bin/lightjj`                                           |
|                | npm CLIs through `npx` at the installed versions: `tokenjuice`, `vestige`/`vestige-mcp`/`vestige-restore`, `ralph-tui`, `notebooklm-mcp`, `oldw` (`@seflless/deepwiki`)                          | `~/node_modules/.bin`, `~/bin/oldw`                       |
| `settings.nix` | model, effort, theme, vim mode, `defaultMode = auto`, workflows, `worktree.baseRef`, notifications, codegraph permissions                                                                        | `~/.claude/settings.json`                                 |

Skills that are not copied, because they come from upstream:

| skills                                                                          | from                                                                                                                                         |
| ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `cavecrew`, `caveman`, `caveman-commit`, `caveman-help`, `caveman-review`, `caveman-stats`, `compress` | the `caveman@caveman` plugin. `caveman-ultra.patch` applies vic's change to the ultra row of `skills/caveman/SKILL.md`. |
| the 14 superpowers skills (`brainstorming` … `writing-skills`)                  | the `superpowers-extended-cc` plugin (`pcvelz/superpowers`). The plain copies were `mrclrchtr/superpowers-extended-cc` without changes.      |
| `deepwiki`, `find-skills`, `lightjj`                                            | `upstream.nix`                                                                                                                               |
| `caveman-compress`                                                              | Not installed. It is Python (`scripts/*.py`). `compress` in the caveman plugin does the same job.                                            |

Changes to sini's files, all additions:

- `plugins.nix`: the `caveman` marketplace is pinned to the commit that was
  installed on frodo (`ef6050c`), patched with `vic/caveman-ultra.patch`, and
  `caveman@caveman` is enabled.
- `claude.nix`: `theme`, `verbose` and `effortLevel` are `lib.mkDefault`, so
  vic's values in `settings.nix` win. sini's values stay as the defaults.

Changes to vic's files:

- **omni follows `autoMemoryDirectory`.** `omni_learn` used to write memories
  only to `~/.claude/projects/<slug>/memory/`. sini's `claude.nix` sets
  `autoMemoryDirectory = "~/.claude/memory"`, so Claude Code would not read
  those files. `omni/lib/writeback.js` now reads `autoMemoryDirectory` from
  `settings.json` (absolute or `~/`) and falls back to the per-project
  directory. Test: case G in `omni/lib/writeback.test.mjs`. omni ingest reads
  only transcripts (`~/.claude/projects/**/*.jsonl`), so the setting does not
  affect it.
- codegraph: frodo had `@colbymchenry/codegraph@0.7.11` from vic's fork
  (`vic/codegraph`, commit `fb413c9`, which adds Nix support). sini's
  `tools.nix` installs `codegraph` 1.6.2 from llm-agents, and that version
  already has `src/extraction/languages/nix.ts`. The fork is not used. The
  global index in `~/codegraph` was built by 0.7.11, so it may need a reindex.

#### Before the first `switch` on frodo

1. **Files in the way.** home-manager does not overwrite files that it does
   not manage. Move these aside first (or set a home-manager backup
   extension): `~/.claude/{settings.json,CLAUDE.md,RTK.md}`,
   `~/.claude/agents/vic-*.md`, `~/.claude/skills/*` (except `synced/`),
   `~/.claude/hooks/*.sh`, `~/.claude/omni/`,
   `~/.claude/plugins/known_marketplaces.json`.
2. **Duplicate MCP servers.** `~/.claude.json` has user-scope entries for
   `codegraph`, `deepwiki`, `notebooklm`, `serena` and `omni`. vic.ai serves
   the same servers through the home-manager plugin. Remove the old entries
   with `claude mcp remove -s user <name>`.
3. **MCP tool names change.** home-manager serves its servers as the `hm`
   plugin, so tools become `mcp__plugin_hm_<server>__<tool>` (for example
   `mcp__plugin_hm_omni__omni_recall`). The permissions in `settings.nix` use
   the new names. The skills and `CLAUDE.md` still show the old names
   (`mcp__omni__…`, `codegraph_*`).
4. **Memory location.** sini's `autoMemoryDirectory = "~/.claude/memory"`
   replaces the per-project `~/.claude/projects/<project>/memory/`. Move the
   existing memories there, or change the setting. omni follows either value.
5. `claude-code` is now in two places: `users.users.vic.packages`
   (`modules/users/vic/includes.nix`, unchanged) and
   `programs.claude-code.package`. Both are the llm-agents build.

#### Not ported

| item                                                    | why                                                                                                    |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `~/.claude/skills/synced/`                              | Claude Code syncs these from claude.ai itself.                                                         |
| project MCPs in `~/.claude.json` (`~/hk/dnet`: `firefox`, `nb`) | Project scope. home-manager does not manage `~/.claude.json`. They stay in that file.         |
| data: `omni.db`, `~/.cache/claude-ledger`, `projects/`, `telemetry/` | State, not tooling. It stays in place.                                                         |
| caveman statusline badge                                | It was never configured on frodo. vic.ai has ccstatusline.                                             |

---

## What was left out, and why

| in sini's config                                     | here                                                                                                                                                       |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| hindsight memory bank + session-archive hooks        | Needs sini's server (§8).                                                                                                                                  |
| xmsg (messages between running agent sessions)        | sini's own daemon. Pinned to sini's agy/pi builds.                                                                                                         |
| peer-sync, PreCompact checkpoint, tracker-drift hook | Tied to sini's hosts and the `den-ag-design` tracker repo.                                                                                                 |
| `writing-tone` skill                                 | It is sini's personal voice.                                                                                                                               |
| caveman, brag, hyperframes                           | caveman is off in sini's config too. brag and hyperframes are for video.                                                                                   |
| pi / opencode / hermes / antigravity configs         | The CLIs are installed. Their per-agent config (pi's plan-mode and security-guard extensions, and the shared skills/MCPs) is not.                           |
| impermanence buckets for `~/.claude`, Syncthing      | Host-level concerns.                                                                                                                                       |

## Layout

```
flake.nix                    inputs, incl. the vic.ai section
modules/den.nix              frodo: users.vic.classes gets "homeManager"
modules/users/vic/
├── includes.nix             den.aspects.vic includes vic.ai
└── ai/
    ├── claude.nix       Claude Code settings, permissions, budget/subagent/direnv hooks
    ├── _scripts/        budget/subagent-stop/load-direnv (claude.nix), mcp-log/mcp-status (statusline.nix)
    ├── agents.nix       gen-scout / gen-gate / gen-spec / gen-build
    ├── agents/          prompt fragments the agents are composed from
    ├── mcp.nix          codebase-memory, serena (+ discovery hooks)
    ├── headroom.nix     compression proxy + MCP
    ├── tools.nix        rtk, hunk, beads, codegraph, openspec, calldiff, other agent CLIs
    ├── herdr.nix        herdr agent multiplexer + skill + SessionStart session-report hook
    ├── plugins.nix      store-pinned plugin marketplaces (+ patched caveman)
    ├── skills.nix       local skills + gstack + task-observer
    ├── skills/          local SKILL.md directories
    ├── statusline.nix   ccstatusline: 1 line (model, ctx, $, $/h, tokens, 5h/7d quota, last skill, last MCP tool)
    ├── _pkgs/           serena-agent, headroom-ai derivations
    └── vic/             vic's tooling (§10)
        ├── agents.nix   vic-* agents, vic skills, CLAUDE.md + RTK.md
        ├── hooks.nix    boot / ctx-meter / cmd-ledger / stop-gate / omni-ingest
        ├── tools.nix    vic-* CLIs, omni, deepwiki, notebooklm
        ├── upstream.nix skills from source, lightjj, npx CLIs
        ├── settings.nix vic's settings.json preferences
        ├── caveman-ultra.patch
        └── agents/ skills/ hooks/ bin/ memory/ omni/ dw/   vic's own files
```
