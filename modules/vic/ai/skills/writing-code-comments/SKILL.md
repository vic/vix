---
description:
  "Opinionated style for inline source-code comments. Default to no comment. Add
  a comment only when the WHY is non-obvious: a hidden constraint, a subtle
  invariant, a workaround for a specific bug, or behavior that would surprise a
  reader. No multi-paragraph docstrings. One short line max. Use when editing
  source files, when asked 'should I comment this', or whenever the agent
  considers adding a comment to code."
model: haiku
effort: low
---

# Opinionated source-code comments

This file is a specification, not a specimen. Its bolding and worked examples
are navigation aids; do not reproduce them in what you write.

A prescriptive style guide for inline comments and docstrings. The default is to
write no comment. Each rule below pairs the comment that earns its place with
the noise it replaces.

The prose voice comes from the `writing-tone` skill.

**The gen libraries are the standing exception**: there, a comment on a
non-obvious construction cites the result it implements. See "Theory citations"
below.

## Decision routing

```
Repo mandates headers/docstrings (rustdoc, godoc, jsdoc, license blocks)?  -> honor them
Reason for the code non-obvious from the code itself?                       -> one-line comment
Comment would just restate a well-named identifier?                          -> no comment
Editing code with restating / task-context / commented-out comments?         -> delete them
```

## First, check the project's conventions

Some repos mandate header comments, license blocks, or structured docstrings.
Sweep before applying the defaults:

```bash
ls CONTRIBUTING.md .github/CONTRIBUTING.md 2>/dev/null
grep -E "doc(string)?|comment|header" \
  CONTRIBUTING.md .editorconfig .github/CONTRIBUTING.md 2>/dev/null
```

Honor required license/copyright headers and language-mandated public-API
docstrings (one line, see Shape). When the repo has no conventions, apply the
defaults below.

## The default: no comment

Well-named identifiers describe what the code does; a comment restating them is
noise. This holds inside bodies, above definitions, above blocks, and inline.

## Theory citations: the gen-library exception

In `gen-*` and `den-hoag`, a construction that implements a published result
carries the citation in a comment. This is a documentation gate, not optional
cleanup, and it is per-task rather than deferrable.

```nix
# Instantiated Beta inheritance (Bracha 1990 §2.2) with inner = ∅.
# `conservativeEq` is Palmer's own term for this relation (§2.3, §5.3, §8).
```

Cite the author, year and section. Never drop a citation when editing the line
it sits on.

**Never invent one.** If you cannot name the result and section from the
surrounding code, its spec, or an existing citation nearby, write no comment and
say the citation is missing. A fabricated reference lands in the codebase's most
authority-bearing comments, reads as verified, and nobody re-checks it. Verify
at the primary or leave it out. Everywhere else in this config, the no-comment
default holds.

## Add a comment only for a non-obvious WHY

A comment is justified only when the reason for the code cannot be read off the
code. The rationale IS the test, if it fits none of these, do not write it:

- a hidden constraint ("must run before the connection pool initializes")
- a subtle invariant ("loop assumes single ownership; map is never re-entered")
- a workaround for a specific upstream bug, with a link or identifier
- behavior that would surprise a reader ("returns the second match, not the
  first, for compat with old config")
- a non-obvious cross-file dependency ("mirrored in `<other-file>:NN`; bump
  both")

```
# good -- names a non-obvious WHY a reader could not infer
sleep 2  # API rate-limits writes to 1/sec; the retry below assumes this gap

# bad -- restates what the line already says
i += 1   # increment i
```

## Shape when a comment is added: judgment, with rationale

- One short line. If it needs more, the code is too clever or the explanation
  belongs in the commit/PR body.
- Lowercase preferred; do not force it when an identifier or proper noun opens.
- Causal connectives `so`, `as`, `because`. No em-dashes (`—`) for elaboration.
- Backtick referenced identifiers.
- Language-mandated docstrings: one line on the symbol's purpose; skip
  parameter-by-parameter unless a parameter is genuinely surprising.

```
# good -- one line, purpose only
/// resolves the tap trust file, honoring XDG split

# bad -- multi-paragraph docstring restating signature
/// Resolves the tap trust file.
/// @param path the path to resolve
/// @returns the resolved path
/// This function takes a path and returns the resolved path...
```

## Remove these in the same edit you touch them

Rot is likelier than refresh; these are not load-bearing.

```
# bad -- delete on sight
// returns the user id        (above a function literally named getUserId)
// added for the X flow        (task context -- belongs in the PR)
// ===== SETUP =====           (section decoration)
// const old = ...             (commented-out code -- git has the history)
// TODO: maybe refactor someday (naked hedge -- open an issue or drop it)
```

## When tempted, prefer a structural fix over a comment

- Confusing order of operations -> a rename, a small refactor, or an assertion
  often carries the meaning better than a comment. Reach for those first; fall
  back to a one-line comment only when they do not fit.
- About to add a `// TODO` with no linked issue or owner -> do not. Raise it in
  the PR, or open an issue and link it. Naked TODOs rot.

## Never

- Multi-line block comments or multi-paragraph docstrings.
- Comments referencing the current task, fix, issue, or caller. No task keys, no
  spec keys, no dates: they are stale the moment the work lands.
- Tool-attribution lines (`// generated by ...`), that belongs in commit
  metadata.
- Emojis or bolded prose in comments.
- Mass-adding comments to "improve documentation" without a specific WHY for
  each.
