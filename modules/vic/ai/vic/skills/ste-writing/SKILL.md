---
name: ste-writing
description: Rewrite technical prose (docs, READMEs, PR descriptions, error messages, release notes, comments — never code) into ASD-STE100 Simplified Technical English to eliminate AI slop. Two modes — strict (procedures/safety) and STE-flavored (general prose). Includes a mechanical STE linter script and preferred-word replacement table.
---

# ste-writing (ASD-STE100 Simplified Technical English)

Apply to documentation, READMEs, PR text, error messages, release notes, and comments. Never apply to code, identifiers, or command syntax. Do not use for essays or prose that needs a personal voice (for human maintainer tone, pair with `/vic-voice`).

**Assets in this skill:**
- `references/word-replacements.md` — curated ASD-STE100 word replacement table (slop/complex words -> plain single-meaning verbs and nouns).
- `scripts/ste-lint.sh` — deterministic POSIX `sh` linter flagging sentences > 20/25 words, semicolons, contractions, banned marketing/slop words, stacked auxiliaries, and paragraphs > 6 sentences.

## Rules

- **WORDS:** One name for one thing; one meaning per word (`fall` = move down, not decrease). Short common words (`start`, `use`, `help`, `make sure`, `before`, `after`, `about`, `get`, `show`, `also`). Zero marketing adjectives (`seamless`, `robust`, `powerful`, `cutting-edge`, `effortless`, `world-class`, `next-generation`, `revolutionary`, `leverage`, `utilize`, `delve`). American spelling.
- **VERBS:** Active voice (`the parser reads the file`). Action verbs (`analyze the log`, not `perform an analysis of the log`). No stacked auxiliaries (`this improves X`, not `it is important to note that this may help to improve X`). Simple tense over `-ing` main verbs.
- **SENTENCES:** One instruction per sentence. Max **20 words** (procedure/instruction), max **25 words** (descriptive). No contractions. Keep articles (`a`, `an`, `the`, `this`, `these`).
- **PUNCTUATION:** No semicolons — write two sentences.
- **STRUCTURE:** One topic per paragraph, max **6 sentences**. Numbered vertical lists for steps, one imperative action per step, condition BEFORE its command. Output only the requested text (no preamble or closing filler).

## Modes
- **`strict`** (procedures, runbooks, safety, error messages): enforce all rules and both length caps (`scripts/ste-lint.sh --strict <file>`).
- **`STE-flavored`** (READMEs, PRs, general docs): enforce active voice, sentence/paragraph caps, zero semicolons/slop (`scripts/ste-lint.sh <file>`), relaxing the 900-word dictionary lock.

## Mechanical Verification (run before returning prose)
Run `scripts/ste-lint.sh [--strict] <file>` on your draft instead of counting words in your head, then do one human clarity pass (consistent naming, concrete actor, true claims).
