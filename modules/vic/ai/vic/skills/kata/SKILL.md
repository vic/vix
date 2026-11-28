---
name: kata
description: >
  Kata (jj-based, never git) code review workflow skill. Enforces ?as=AI attribution,
  extreme commit minimalism, empty-review-first pre-code context annotations, new changeset
  per comment fix, and self-review evidence before publishing. Triggers on: "review",
  "kata review", "list reviews", "get review", "@kata".
---

# Kata Code Review Skill (`jj`-only)

**Assets in this skill:**
- `references/self-review-template.md` — concise pre-code annotation template and pre-publish minimalism/evidence checklist.
- `scripts/kata-health.sh` — checks Kata endpoint reachability (configurable via `$KATA_URL`, probing localhost/LAN IP fallback) and verifies `?as=AI` attribution path.

---

## 1. Strict Review Discipline (97% Rejection Bar)

- **Extreme minimalism:** Small, focused, crystal-clear commits only. If a commit is large, entangled, or hard to read at a glance, it WILL be rejected — split it before submitting.
- **Empty review BEFORE coding:** Ensure a new empty Kata review exists before writing code (ask owner for the review URL). Post non-code context annotations (`P` purpose, design decisions, invariants, ablation receipts) BEFORE touching code so the reviewer has full context.
- **New changeset per comment fix:** Whenever addressing review comments, ALWAYS create a **new `jj` changeset** (`jj new`) so the reviewer can diff exactly what changed in response to each comment.
- **Mandatory `?as=AI` identity:** Every agent MUST connect to the Kata MCP endpoint with `?as=AI` on `/mcp` requests. Never use a shared or default human identity. If `?as=AI` is unavailable, STOP until supported.

---

## 2. Kata MCP Workflow (`repo` arg required on every tool)

Run `scripts/kata-health.sh` if endpoint discovery is needed (default `$KATA_URL` or local service on port `7878`).

1. **Discover:** `list_repos` -> workspace slugs · `list_reviews(repo)` -> open reviews.
2. **Open:** `get_review(repo, review_id)` -> `manifest` (patchset history), `diff.files[]` (`side: base|tip` + 1-based line), `comments`/`responses`, `drafts`. Read the ENTIRE diff before commenting.
3. **Comment (anchor on `manifest.patchsets[last].tip_change` + `tip_commit`):**
   - `draft_line_comment` (1-based lines; `columns` = UTF-16 offsets) · `draft_file_comment` · `draft_review_comment`.
   - `flag`: `must-do` (blocks merge — reserve for real blockers) | `suggestion` | `question`.
   - Revise drafts with `update_draft_comment(comment_id, body, flag)`.
4. **Respond:** `respond` with `action`: `comment` | `resolve` | `unresolve` | `wont-fix` | `un-wont-fix`.
   - **NEVER `resolve` a `question` you did not raise** — the question's author decides resolution.
5. **Publish:** `publish_session` to make drafts visible (`discard_session` to drop unfinished drafts).
6. **Author annotations (creator-only, publishes immediately):** `add_line_annotation`, `add_file_annotation`, `update_annotation`, `delete_annotation`.
7. **Refresh:** `refresh_review` safely appends a new patchset after moving tip/base.
