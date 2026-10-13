---
description:
  'Writes git commit messages: lowercase imperative subject that names what
  changed, optional conventional-commit type prefix, no trailing period, a body
  where there is something to record, kept to just enough, and never a why you
  cannot source. Repo conventions always win. Use when drafting a commit message
  or when the user says "commit this" / "propose a commit message" / "write
  commit".'
model: haiku
effort: low
---

# Commit messages

This file is a specification, not a specimen. Its bolding and worked examples
are navigation aids; do not reproduce them in what you write.

Terse is the voice. Uninformative is not the target -- a subject a reader cannot
act on has failed, however short and in-voice it is.

## The shape

```
<subject>          lowercase imperative, names the thing that changed, <= 72 chars
                   optional `<type>(<scope>): ` prefix
                   no trailing period
<blank line>
<body>             only when the WHY cannot be read off the diff
```

## Decision routing

```
Repo has CONTRIBUTING.md / DCO / a commit format?  -> obey it; the repo wins
Something worth recording beyond the subject?       -> subject + short body
Why is known from the task, ticket or a measurement? -> say it, briefly
Why is only your own inference?                      -> omit it; never construct one
Change touches more than one concern?               -> split; one commit each
```

## Subject

- **Lowercase.** Capitalise only when an identifier or proper noun opens the
  subject; never force lowercase onto one.
- **Imperative.** It completes "this commit will ___".
- **Name the object of the change.** This is the bar terseness usually misses.
- **One clause.** A second clause means a second commit.
- **No trailing period.**
- **Prefer under 72 characters**, but describing the what wins over the limit.
  Spend the length on the object of the change, never on padding. The
  surrounding log is the better guide: match what the repo already does.

```
# bad -- each names nothing
stash
remove cruft
fix media target
update facts for cortex

# good -- same change, same voice, now actionable
wip: partial bridge config, does not evaluate yet
remove unused vfio hook and its dead pci-id list
fix media mount target: was pointing at the pre-migration path
update cortex facts for the new nvme layout
```

```
# bad
Feat(claude): Added read-only commands.   # capitalised, past tense, period
fix: bug                                   # names nothing
chore: misc fixes                          # names nothing
feat: add allowlist; also bump pi          # two clauses -> two commits
feat: just a small tweak to the allowlist  # padding
```

## The type prefix is optional

A bare imperative subject is the ordinary form, not a fallback. Use a type when
it genuinely classifies the change; do not manufacture one.

- Types in use: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`,
  `build`, `ci`, `revert`.
- `scope` is optional: the affected module, lowercase, kebab-case if multi-word.
- `!` after the type marks a breaking change (`feat(auth)!:`).
- Domain-prefixed subjects (`specs:`, `beads:`, `status:`, `spec(adr):`) are a
  repo convention in the docs repos. Follow the surrounding log; do not invent a
  new prefix vocabulary.

## Body: welcome, but only what you actually know

A body that documents a change is a good thing. The log is the record, and a
reader a year later has nothing else. Write one when there is something to say.

**Just enough.** Describe the what in full. Add the why only where it is needed
to understand why the what was needed. A short paragraph, not several, and never
a log of what you did -- the diff already has that. A new feature and an
ordinary bug fix usually explain themselves and need no why at all.

**Never invent a why.** This is the rule that matters most, because it is the
easy failure. A diff shows what changed and never why, so a plausible rationale
is always available to construct -- and once committed, a constructed one is
indistinguishable from a known one. A commit body reads as primary evidence in
the author's name, nobody re-verifies it, and it outlives the session that wrote
it. A wrong why is worse than no why: it costs the reader the lookup plus the
time spent believing it.

Write a why only when it has a source outside your own reasoning:

- what you were asked to do
- the bead, ticket or issue
- a measurement, and you can name the command behind it
- the actual error text, or upstream documentation

A theory you formed while working is **not** a source. An inference off the
diff, a conclusion drawn after a failed probe, an assumed cause for a
workaround: these are the least-verified things in the session and the likeliest
to be written down, because they are freshest. If you cannot source the why,
write the what and stop.

```
# good -- the pin looks arbitrary without this, and the why is sourced
pin gen-schema to the pre-merge rev

the 0.5 tree changes the identity mint, which silently renumbers every
existing aspect id. unpinning needs the migration in den-hoag-p3y9 first.

# good -- a feature, documented, no why needed
feat(power): add per-host suspend inhibitors

hosts no longer suspend mid-rebuild. inhibitors are per-host so the
workstation keeps its normal idle behaviour.

# bad -- the why is the author's guess, stated as fact
fix: correct the aspect path resolution

gen-specs was moved out of den-ag-design, so the old relative path no
longer resolves.

# bad -- restates the diff
update flake.lock

- bumped gen-schema
- bumped gen-scope
```

The third example is the failure this rule exists for. The path lookup had
simply been done wrong; nothing moved. That sentence would have entered the
permanent record as fact, in the author's name, with nothing marking it as a
guess.

## External references

Where this file and an established public convention disagree on anything but
voice, prefer the convention. They are better tested than any single corpus:

- **Conventional Commits** for the `<type>(<scope>):` prefix and `!`.
- **Chris Beams, "How to Write a Git Commit Message"** for the seven rules --
  separate subject from body with a blank line, imperative mood, wrap the body,
  explain what and why rather than how.
- **git's own `Documentation/SubmittingPatches`** for body shape.

## Never

- **Em-dashes**, in subject or body. Use `so`, `as`, `because`, or a second
  sentence.
- **`Co-authored-by:` / `Claude-Session:` / `Generated with`** trailers.
  Standing law, including when a tool offers to add one. The single exception is
  a repo that mandates the trailer -- see the last section.
- **Inventing a ticket id.** Uppercase `PROJ-123` ids are not this project's
  convention. Reference a beads id (`den-hoag-xxxx`) only when it genuinely
  anchors the work.
- Bolded list rows (`- **Foo**: bar`) in a body. Plain bullets.
- Emojis, anywhere.
- Backticking identifiers in the _subject_. Backticks are fine in a body.

## Repo conventions override everything above

```bash
ls CONTRIBUTING.md .github/CONTRIBUTING.md DCO 2>/dev/null
grep -l "Signed-off-by\|DCO\|commit format" \
  CONTRIBUTING.md .github/CONTRIBUTING.md 2>/dev/null
```

DCO required: add `--signoff`. Mandated format (`[component] message`,
`JIRA-123: message`): use it verbatim. Issue-link syntax (`Refs #NN`,
`Fixes #NN`): honour it. Some repos require `Co-authored-by:`; that requirement
overrides the ban above, and only there.
