---
description:
  'Writes GitHub PR descriptions. Uses the repo PR template verbatim when one
  exists; otherwise `## Summary` plus an optional validation block. Never
  invents sections and never appends checklist items. Carries the reasoning a
  hand-written description would omit. Use when drafting a `gh pr create` body,
  opening a PR, or when the user says "PR body" / "pull request description".'
model: haiku
effort: low
---

# PR descriptions

This file is a specification, not a specimen. Its bolding and worked examples
are navigation aids; do not reproduce them in what you write.

The repo PR template always wins; everything below is the fallback.

**A PR body is where the reasoning goes.** The commit subject is terse by design
and the diff shows only what changed. The body carries what neither does: why
this shape, what was tried first, what was verified by hand. That is what it is
for, not a licence to pad. Never write a reason you cannot source -- an invented
rationale reads exactly like a known one once it is merged.

## Decision routing

```
Repo has a PR template?            -> fill it verbatim; add no sections, no checklist items
No template?                        -> ## Summary + optional validation block
PR tracks an issue?                 -> issue URL alone on line 1, nothing before it
Behaviour hand-verified, no test?   -> add the validation block
Change carries several concerns?    -> stack it; one PR per concern, each based on the one below
Creating the PR?                    -> gh pr create --web; never auto-submit
```

## Title

A PR title is a commit subject: compose it with `writing-commit-message`.
Lowercase imperative, names what changed, optional `<type>(<scope>): ` prefix,
no trailing period. Do not attach an uppercase ticket id -- that is not this
project's convention.

## Read the repo's contribution docs first

```bash
ls CONTRIBUTING.md .github/CONTRIBUTING.md docs/CONTRIBUTING.md 2>/dev/null
ls .github/CODEOWNERS CODEOWNERS DCO .github/DCO 2>/dev/null
```

Take the required commit format, issue-link syntax, branch naming, whether a
"how to test" section is mandatory, which checks gate merge, and any DCO or
`--signoff` requirement. Where `CONTRIBUTING.md` conflicts with this file, the
repo wins.

## Use the repo template verbatim when one exists

```bash
ls .github/pull_request_template.md .github/PULL_REQUEST_TEMPLATE.md \
   .github/PULL_REQUEST_TEMPLATE/ docs/pull_request_template.md 2>/dev/null
```

Its structure is canonical. Fill its sections; leave its structure alone. Only
tick or leave the existing `- [ ]` items -- **never append a new one**, even
when the change seems to warrant it.

```markdown
<!-- bad -->

## Summary

...

## Risks <- invented section, not in the template

## Checklist

- [x] tests pass
- [ ] new: security review <- appended item, forbidden
```

## Fallback structure when there is no template

```markdown
<issue URL, if any, alone on the first line>

## Summary

- <one sentence, what changed and why>
- <one sentence>

## Validation

- <what was verified by hand, past tense>
```

Use `## Summary` and at most one validation section. Do not invent `## Risks`,
`## Test plan`, `## Description`, `## Motivation and context`, or
`## Types of changes`.

For a PR spanning distinct areas, group bullets under area subheads with a
trailing colon (`Schema:`, `Permissions:`, `Testing:`) rather than a flat list
of multi-sentence bullets. The shortest acceptable body for a self-evident PR is
`See title.`

## Summary bullets

One sentence each. Lead with the action. Attach the reason with `so`, `as` or
`because` -- the reason is the part the diff cannot show.

```
# good
- Removes the `aws-knowledge` MCP server as it is no longer referenced by any aspect.
- Routes clipboard restore through `panel.hide()` so the panel closes before the paste lands.

# bad
- This PR adds a bunch of changes, it removes the server and also...   <- preamble, multi-clause
- Search: now uses ast-grep                                            <- bolded-row shape
```

## Show a rerouted call path instead of describing it

When a change adds, drops or reroutes a call path, run
`calldiff diff <base> --max-depth 3` and put the plain tree in a fenced block
under `## Summary`, below the bullets. Then delete the bullet that was
describing it in prose -- the tree is shorter and a reviewer can check it.

This is a block inside `## Summary`, not a new section; the rule against
invented sections still holds. Skip it for Nix-only changes, which calldiff
cannot parse, and for changes that only edit bodies without moving edges. Load
the `calldiff` skill for the flags.

````markdown
<!-- good, the tree carries the claim -->

## Summary

- Routes clipboard restore through `panel.hide()` so the panel closes before the
  paste lands.

```
  activate(choice)
+ ├─ panel.hide()
  └─ clipboard.restore(row.entry)
```
````

## Stacked PRs

A change with more than one reviewable concern is stacked by default: one PR per
concern, each based on the one below. A stack of one is just an ordinary PR.
`gh stack` (a `gh` extension, not a skill) owns the commands --
`gh stack submit` replaces `gh pr create` and stays owner-gated the same way.

Each layer gets its own body by the rules above, and **only the bottom layer
carries the issue URL.**

## Creating the PR

```bash
gh pr create --web --title "<subject>" --body "<body>"
```

`--web` opens the pre-filled editor so the user reviews, sets labels and
reviewers, and submits. Never use `--draft`, `--fill` / `--fill-first`,
`--reviewer` / `--assignee` / `--label`, and never submit without `--web`,
unless the immediately preceding user turn directed it.

## Never

- Paste a generic template over an existing repo template.
- Preamble (`This PR adds...`, `In this change...`). Lead with the action.
- **Em-dashes.** Use `so`, `as`, `because`, or a second sentence.
- `Co-authored-by:` / `Claude-Session:` / tool-attribution trailers. Standing
  law, no exceptions.
- Architecture overviews. Those belong in a design doc.
- Marketing adjectives: `robust`, `seamless`, `comprehensive`.
- Emojis, anywhere.
