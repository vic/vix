---
description:
  "Routes a code search to the right tool: `ast-grep outline` to map structure,
  `ast-grep`/`sg` for code shapes and for every find-and-replace that spans more
  than one site, `rg`/Glob for literal text, `gh search` for repos not cloned
  here. Use when starting a search, and whenever renaming or replacing a
  construct across files."
allowed-tools:
  Bash(rg:*) Bash(grep:*) Bash(ast-grep:*) Bash(sg:*) Bash(gh:*) Read Glob
model: haiku
effort: low
---

# Code Search

Four ways to search code on this machine, and they are not interchangeable.
Picking the right one per query is the whole skill. The default reflex of
reaching for `grep` is usually wrong here. ast-grep is the preferred tool for
finding code, and `rg` is the fallback for literal text.

This skill routes. Three other skills own the syntax, and you should load them
rather than guess at it:

- `ast-grep-outline`, how to read a structural map of files and directories
- `ast-grep`, how to write ast-grep rules and patterns
- `calldiff`, how to read a call graph, and how to diff one across two trees

Neither ast-grep skill covers rewriting, so section 2a below owns that.

Outline and calldiff answer different questions and are not substitutes. Outline
names what a file declares. calldiff names what those declarations call. Reach
for outline to orient; reach for calldiff once you need the edges.

## Decision routing

```
Orienting in unfamiliar code, or about to read a file "to see what's in it"?
    -> ast-grep outline   (load the `ast-grep-outline` skill)
       but see the language note below — it is silent on Nix and Lua
A code SHAPE — call pattern, signature, construct, refactor-grade?
    -> ast-grep (sg) or the ast-grep MCP   (load the `ast-grep` skill for rules)
Literal string, exact identifier, file path, or "every occurrence"?
    -> builtin: rg / grep / Glob / Read
Across repos — org-wide, not cloned locally, prior art on GitHub?
    -> gh search (code / repos / issues / prs / commits)
Who calls this, what does it reach, what call paths did a diff move?
    -> calldiff   (load the `calldiff` skill; it cannot parse Nix)

Replacing the same construct at two or more sites?
    -> ast-grep -p ... -r ...   (section 2a below; never Edit site by site)
Replacing one site, or a literal string?
    -> Edit
```

Order matters. Outline before reading a whole file, because it costs a fraction
of the context and usually answers the question. ast-grep before `rg`, because a
shape query written as a regex silently misses wrapped lines and hits comments.

## Language note: outline is narrower than ast-grep

`ast-grep outline` covers the mainstream languages (TypeScript, JavaScript,
Python, Go, Rust, and similar). It prints `nothing found` for Nix and Lua, which
is most of `sysinit` and all of `sysinit.nvim`.

`ast-grep` pattern search _does_ parse Nix and Lua. So in this repo's Nix and in
sysinit.nvim's Lua, skip step one and go straight to
`ast-grep run -p ... -l nix` (or `-l lua`). A `nothing found` from outline on
those files means the language is unsupported, not that the file is empty, do
not conclude anything from it.

## 1. Builtin: `rg` / `grep` / `Glob` / `Read`

The right tool when the query is lexical, not structural. That means a literal
string, a known symbol to locate, or an exact or glob path, with `Glob` for
`**/*.test.ts`. It is also right when you need _every_ hit: grep enumerates, and
ast-grep and gh search rank.

```bash
# good — literal text, known symbol, exhaustive enumeration
rg "error: connection refused"
rg -n "func ResolveTrust"

# bad — using grep to match a code shape across line breaks
rg "foo\(.*,.*\)"        # misses wrapped args, false-hits on strings and comments
```

## 2. ast-grep (`sg`): structural / AST search

Parses to an AST and matches by tree shape, so it is immune to whitespace, line
breaks, and incidental formatting that defeat regex. Language-aware via
`~/.config/ast-grep/sgconfig.yml`. Reach for it for call shapes, constructs
(empty `catch`, a return type, a JSX prop), refactor-grade finds, and
metavariable capture (`$VAR`, `$$$ARGS`).

```bash
# good — match a call shape regardless of how args wrap
sg run -p 'foo($A, $$$REST)' -l ts
sg scan                       # run the configured rule set

# bad — ast-grep for literal text in comments/configs/markdown
sg run -p 'TODO' -l ts        # slower and clumsier than `rg TODO` — that is grep's job
```

Two surfaces, one engine. The CLI is `sg run` and `sg scan`, where `sg` aliases
`ast-grep`, and it gives ad-hoc text output. The ast-grep MCP server gives
structured tool output instead of CLI text to parse.

## 2a. Find and replace: ast-grep drives it, not Edit

A rename or a construct swap that touches two or more sites belongs to ast-grep.
Edit is for one site. Editing site by site misses the wrapped occurrence, hits
the one inside a comment, and costs one tool call per site.

`-r/--rewrite` alone writes nothing. It prints a unified diff and exits, so it
is the review step, and `-U` is the apply step:

```bash
# 1. preview — prints a diff, changes no file
ast-grep run -p 'foo($A, $$$REST)' -r 'bar($A, $$$REST)' -l ts

# 2. read every hunk it printed, then apply
ast-grep run -p 'foo($A, $$$REST)' -r 'bar($A, $$$REST)' -l ts -U
```

Rules:

- Always run step 1 and read its diff before step 2. `-U` writes every file with
  no further output. A pattern one metavariable too broad lands as a silent
  multi-file change that nothing shows you afterwards.
- Never pass `-i/--interactive`. It waits on a keypress that no agent session
  can send, and the command hangs.
- Scope the run to a path when the pattern is general. Without one it walks the
  whole tree.
- A rewrite that cannot be written as a pattern, such as one that needs
  different replacement text per site, is not a find-and-replace. Do those with
  Edit.

```
# good — the shape is the same at every site, the text differs
ast-grep run -p 'lib.mkIf $C $B' -r 'lib.optionalAttrs $C $B' -l nix modules/

# bad — regex over a code shape, then Edit per hit
rg -l 'lib\.mkIf' | xargs ...     # misses wrapped args, hits comments and strings
```

### Authoring a non-trivial pattern or rule: iterate, don't guess

A pattern that misses is worse than no pattern: it reads as "no matches" when
the syntax was just wrong. For anything past a one-liner, drive the ast-grep MCP
loop instead of hand-writing YAML blind:

1. Dump the AST of a representative snippet (`dump_syntax_tree`) so you match
   real node kinds, not guessed ones.
2. Decompose the query into the smallest sub-patterns that must hold.
3. Compose them with relational (`inside`, `has`, `follows`) / composite (`all`,
   `any`, `not`) rules rather than one over-specified pattern.
4. Test each candidate against a known-good and known-bad snippet
   (`test_match_code_rule`) before running it across the tree.
5. Revise off the AST output when a match is empty or over-broad. A miss is a
   wrong node kind or a missing metavariable, never "the code isn't there."

## 3. gh search: repo-wide / org-wide / not-cloned

When the answer is not in the working tree. Searches GitHub's index, so it
reaches code you have not cloned.

```bash
# good — find prior art / usages across an org you have not cloned
gh search code '<query>' --owner <org>
gh search prs '<query>' --owner <org>

# bad — gh search for something in the repo you already have checked out
gh search code 'ResolveTrust' --owner me   # misses uncommitted work + non-default branches
```

Caveats: GitHub code search only indexes default branches and has its own syntax
and rate limits. For the current repo, stay with builtin / ast-grep, faster,
complete, and they see uncommitted work.

## 4. calldiff: call edges

Parses the repository with tree-sitter and prints who calls whom.
`calldiff diff` marks what one git tree added or dropped against another. That
is the question a line diff cannot answer: what call paths did this change move?

```bash
# good — the call paths this working tree changed
calldiff diff --max-depth 3

# good — every path from an entrypoint to a symbol the repo defines
calldiff reach -e M.setup --to compose modules/darwin/home/hammerspoon

# bad — calldiff on Nix; it does not index .nix and answers "file not found"
calldiff tree --file overlays/sysinit-gotools.nix
```

Load the `calldiff` skill for the rules. Note that it covers the Lua, Go, and
shell here and none of the Nix, which is most of this repo.

## Typical flow

1. Classify the query against the routing table before searching.
2. Map before you read. `ast-grep outline` on the file or directory costs a
   fraction of the context a `Read` costs, and usually answers the question on
   its own. Read a whole file only after outline has named the symbol you want.
3. Run the matching tool; for structural questions, write the ast-grep pattern
   rather than approximating it with a regex.
4. `Read` the top hits in full file context before concluding, ranked tools
   return slices.
5. Cite `file:line` for every source you used.

## Guardrails: and what to do instead

- Match the tool to the query shape, not to habit. Plain `grep` for a structural
  pattern is the most common mistake; ast-grep for a literal string is the
  second.
- `gh search` is for what is not in the working tree, so stay local for the
  current repo. gh search misses uncommitted changes and non-default branches.
- A multi-site replace goes through `-r` then `-U`, never through Edit per site.
  Read the `-r` diff first: `-U` prints nothing and writes everything.
- Need _all_ occurrences of a token -> use grep; the ranking tools may cap
  results.
- Reading a whole file to find out what is in it is the third common mistake.
  `ast-grep outline` on it first. It names every symbol for a fraction of the
  context, and only then do you know which range is worth reading.
- Describing in prose how a change reroutes control flow -> run `calldiff diff`
  and show the tree. The tree is shorter than the paragraph and it is checkable.
