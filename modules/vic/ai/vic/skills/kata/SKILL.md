---
name: kata
description: >
  Kata code review skill. Loads live workflow from Kata MCP server.
  Vic uses for code reviews via Kata (jj-based never git). Triggers
  on: "review", "kata review", "list reviews", "get review", "@kata".
---

# Kata Code Review Skill

Local service is running at http://192.168.68.60:7878 if that does not work,
determine the current local IP and use that.

Kata is the tool vic uses to review your code, you must provide clear self-review
and notes and any other consideration as part of review so vic can have context
on why code is shaped like that. Vic is VERY strict 97% of commits get rejected
if not justified or align to design or project tenets.

Before coding ensure a new empty review exists to be used for your work. Ask
vic to paste the URL of the review you will be using, and use it.

You should be adding review comments even without code, supply anything that
vic needs to know such as context, decisions, etc. Kata supports comments on
non code. Use that to keep vic informed before touching any code.

Be smart or you will be rejected. Vic likes extreme minimalism, if commits
are big is going to reject. Vic has attention deficit, so he's unable to go
on over big stuff. Your code must be clear, concise small, to the point.
If vic is unable to understand the code it will be rejected.

---

When working on fixing some of vic comments ALWAYS create a new changeset for them, so that vic can compare what was changed.

## Cached workflow (kata-review skill)

Kata = jj code review tool. One MCP server fronts multiple repos. Every tool call needs `repo` arg.

### Workflow

Every agent MUST connect to the Kata MCP endpoint with `?as=AI` on `/mcp` requests. This is mandatory for proper author attribution, draft session ownership, and visible AI identity.
That is the canonical per-agent author attribution, and it keeps your draft session, comments, and responses tied to the AI identity instead of the shared default.

Do not use a shared account or alternate identity for review comments. If `?as=AI` is unavailable, do not proceed with the Kata session until the API supports it.

1. **Discover** — `list_repos` → workspace slugs. `list_reviews` → open reviews (pass `repo`).

2. **Open** — `get_review` with `review_id` returns:
   - `manifest` — metadata + patchset history
   - `diff.files[]` — per-file hunks. Each line has `side` (`base`/`tip`) + 1-based line number
   - `comments` / `responses` — published feedback
   - `drafts` — unpublished work in open session

3. **Comment** — anchor with tip patchset IDs: `manifest.patchsets[last].tip_change` + `tip_commit`
   - `draft_line_comment` — specific line range on one side. `columns` = UTF-16 offsets for sub-region
   - `draft_file_comment` — whole-file feedback
   - `draft_review_comment` — overall notes
   - `flag`: `must-do` (blocks merge) | `suggestion` | `question`
   - First draft auto-opens session. Revise with `update_draft_comment` (pass `comment_id` + new `body`/`flag`)

4. **Respond** — `respond` replies to existing comment.
   - `action`: `comment` | `resolve` | `unresolve` | `wont-fix` | `un-wont-fix`
   - NEVER `resolve` a `question` you answered — author decides resolution

5. **Publish** — call `publish_session` after adding or updating draft comments so your work becomes visible to the review author. Use `discard_session` only to throw away an unfinished draft.

### Author annotations (creator-only)

Context notes for reviewers — no reply, no flag, no draft (publishes immediately).
Only `manifest.created_by` identity may write.

- `add_line_annotation` — line range anchor
- `add_file_annotation` — whole-file note
- `update_annotation` — change body (anchor stays)
- `delete_annotation` — remove

### Refresh

`refresh_review` — re-resolves revset, appends new patchset if tip/base moved. Safe, non-destructive.

### Tips

- Read entire diff BEFORE writing any comments
- `tip` side = new code, `base` = removed
- Reserve `must-do` for things you'd actually block on
- Never `resolve` a `question` you didn't raise
