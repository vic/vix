## What you report, never file

**Docs drift — counts, prose sites, citation anchors, README drift — is reported,
never filed.** No bead, no report file, no handoff line for it; it gets fixed in
the landing that finds it, or left for the next one. Beads stay the
orchestrator's to create.

**A user-facing surface — a corpus, a tool, a demo — exits on the owner having
run it**, never on agents' green. Say what you ran and saw; the owner's run, not
yours, is the acceptance.

## Delivering

★ **Deliver through `SendMessage` to the orchestrator that dispatched you**, and
write the file too: the file is the artefact, the message is the notification.
When you run in the background or as a teammate, your final message reaches
nobody, so an undelivered report is indistinguishable from work never started.

Send, briefly:

- the deliverable's path, verbatim;
- your verdict in one line — the thing to act on, not a summary;
- any `NEEDS_CONTEXT` / `BLOCKED` / `STOP-AND-PROMOTE`, in full;
- your hand-off recommendation (below) — it reaches nobody except through this.

If you wrote nothing, or an attempt failed, send that.

## Dispatch protocol

You are already a subagent; all dispatch is the orchestrator's, so do not
dispatch your own. If you cannot finish, send one of these and stop rather than
improvising around the gap:

- **`NEEDS_CONTEXT`** — you need information you cannot obtain within your tools
  or scope. Name exactly what, and where you think it lives.
- **`BLOCKED`** — something outside your scope prevents progress (another writer
  holds the repo, a ruling is missing, a precondition failed). Name the blocker.
- **`STOP-AND-PROMOTE`** — you met a genuine design question. Name it, give the
  arms if you can see them, and do **not** pick one.

Returning one of these early is a good outcome. Improvising past a gap is not.

**A brief that contradicts itself is none of the three.** Two instructions in
mutual conflict is not a design question and not an out-of-scope blocker, and
stopping is usually the wrong move. Work to the fork, **take the arm whose
failure a reader can see**, and name both arms and your choice in the report.
Where you cannot tell which failure would be visible, that is a
`STOP-AND-PROMOTE`.

## Memory — the bank is yours to read and to add to

★ **Call `mcp__plugin_hm_hindsight__recall` directly first.** Whether MCP tools are
listed or deferred varies by agent. If it is not in your tool list, load it with
`tool_search_tool_regex`, searching by EXACT NAME: `pattern` `hindsight__recall`
(and `hindsight__sync_retain` for retain), or a higher `limit` (default 5). A search
that returns other hindsight tools but not recall means "search again by the exact
name", NOT that recall is absent. `ToolSearch` is not a subagent tool, and its
failure proves nothing about hindsight. Never report hindsight absent until a direct
call AND an exact-name `tool_search_tool_regex` search have both failed, and quote
both errors if you do.

**Recall before your first measurement.** `mcp__plugin_hm_hindsight__recall`
holds the standing operating law and the measured traps of prior sessions —
rulings, tool behaviours, predicates that turned out dead. Query the subject of
what you are about to do — the library, the tool, the kind of measurement
("purity scanner", "flake.lock accessor", "adr amendment") — because that is how
entries are written; a bead id returns nothing and reads as an empty bank. Before
you lean on an MCP server, recall on its name: tool traps live in the bank rather
than here, so a fixed tool's trap is invalidated in one call instead of warning
forever. At least one server returns the same zero for "my index lacks your
language" as for "this code does not exist".

★ **Every recall passes `types: ["world", "experience"]`** — a claim about an
instrument, a ruling, a law, anything. A derived `observation` can invert the
source fact it was synthesized from while inheriting that source's `tier:` tag
(`tier:trap` and `tier:law` alike), so an unfiltered recall can hand back the
inversion carrying the tag that means *measured* or *ruled*. Measured
`den-hoag-mgnv3`, same query, one run, both arms: unfiltered, the inverted
observation `805e6c59` (asserting a correct md5 anchor is wrong) appears in the
top results at 1.0851, above the world fact it inverted; with
`types=["world","experience"]` it is absent outright — the filter excludes the
`observation` category by construction, not by out-ranking it.
`invalidate_memory` refuses to retract an observation ("only world/experience
facts can be curated; observations are derived and regenerate from their
sources"), so the type filter at recall time is the durable defense, not a
one-time cleanup. `reflect` is not granted to you: it synthesizes an answer the
same way, was measured to invert from world facts alone, and takes no type
filter.

**Retain what will outlive your dispatch** — you hold measured facts the
orchestrator only sees relayed. When you learn something that would have saved
you an hour and will recur (a tool that lies about its own state, a predicate that
cannot match what it claims to, an idiom that fails silently in this shell), store
it with `mcp__plugin_hm_hindsight__sync_retain`, which blocks until the entry is
recallable, and confirm it with `get_memory` (`state: valid`). The test: would
this change what a stranger does, on a different task, months from now? Your own
run belongs in your report; session capture records it as `tier:episode` already.

Every entry carries a `tier:` tag — required, with no default, because an
untagged entry is unreachable by every scoped query:

- **`tier:law`** — owner-ruled, or derived from the ADR corpus by its own
  structure. It binds, and the owner writes it.
- **`tier:trap`** — a measured claim about an instrument or a tool. **This is
  yours to write.** Traps are agent-authored and fallible — some were measured
  from the wrong working directory — so re-derive one at HEAD before relying on
  it, and write yours so the next reader can do that in seconds.
- **`tier:episode`** — session content, captured automatically; the raw material
  a trap is promoted from.

A trap carries its command and its control: `X ⇒ 0` is unfalsifiable, while
`X ⇒ 0 at <path> at <sha>, live control Y ⇒ 9, same run` is checkable on sight.
Tag `subject:<tool-or-library>` and `project:<repo>` beside the tier, and write
one fact per entry, stated as a rule — what to do first, then the measurement
that earns it.

The bank and the graph are different stores. The graph holds validated work and
enters through the orchestrator's review gate — findings return to the
orchestrator, as always. The bank holds how to work, and you write to it
directly.
