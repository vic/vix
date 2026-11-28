---
description:
  "Renders Mermaid diagrams as ASCII in the terminal and as themed SVG. Use when
  a diagram clarifies more than prose: capability flow, state transitions,
  sequence of calls, option trees, dependency graphs, architecture sketches."
allowed-tools:
  Bash(mermaid-ascii:*) Bash(pretty-mermaid:*) Bash(pretty-mermaid-batch:*)
  Bash(pretty-mermaid-themes:*) Read Write Edit
---

# Diagramming

Diagrams live where they are read. Render **every** mermaid diagram as ASCII in
the terminal, including one you only read. A mermaid block in a file, a PR, or a
spec is text a reader has to simulate in their head. One command turns it into a
picture. An ASCII render also survives in markdown, openspec artifacts, and chat
with no asset pipeline. Reach for an image only when fidelity earns it.

Mermaid is always the source of truth; ASCII or image is the render. Keep the
Mermaid alongside the render so it can be edited and re-rendered later.

Provenance: per-diagram-type syntax below is distilled from the Agents365
`mermaid-skill` (`Agents365-ai/mermaid-skill`). The themed SVG and multi-type
ASCII renderer is `imxv/Pretty-mermaid-skills` (MIT). It is packaged as
`pretty-mermaid` and pinned by rev in `overlays/pretty-mermaid.nix`.
`hack/update-pretty-mermaid.sh` surfaces drift. The opinions on top are this
repository's own: ASCII-first, local-only, and the per-type routing below.

Every render runs on this machine. No path in this skill sends diagram source to
a network service.

## Decision routing: pick the render target first

```
Flowchart or graph?                                     -> ASCII via mermaid-ascii (Path A)
Sequence or ER?                                         -> ASCII via pretty-mermaid (Path A2)
State, class, gantt, pie, mindmap?                      -> themed SVG via pretty-mermaid (Path B)
Shipping to a rendering surface (published page, slide)? -> themed SVG via pretty-mermaid (Path B)
A type pretty-mermaid does not parse?                    -> no render; keep the source, say so
Trivial two-box flow shorter as prose?                   -> skip the diagram
```

The split between Path A and Path A2 is measured, not stylistic. Both renderers
were run against the five upstream examples on 2026-08-12:

- `mermaid-ascii` draws flowcharts with box-drawing characters and reads better
  than `pretty-mermaid` on the same input. It parses nothing else.
- `pretty-mermaid` ASCII is excellent for `sequenceDiagram` (lifelines, solid
  calls, dotted replies) and readable for `erDiagram`, which `mermaid-ascii`
  cannot draw at all.
- `pretty-mermaid` ASCII is NOT usable for `classDiagram` or `stateDiagram-v2`.
  Edge labels are written over the box borders, producing lines like
  `+co writes tring`, and the state diagram's first node renders empty. Send
  those two to SVG.

Prefer ASCII; escalate only when the target or the type genuinely needs it.

## When a diagram earns its place

Reach for one when it clarifies more than prose. In an openspec proposal or
`design.md`: capability flow, state transitions, sequence-of-calls. In
exploration: option trees, dependency graphs, decision points. In a bug:
what-happens against what-should. In an architecture sketch: component
boundaries. In a README: small inline visuals.

## Path A: ASCII inline (default)

Binary: `mermaid-ascii` (on PATH via the Nix overlay). Use `-f -` with a heredoc
so the source stays visible in the transcript.

```bash
mermaid-ascii -f <file>        # render a mermaid file
mermaid-ascii -f -             # read mermaid from stdin
mermaid-ascii -f - -a          # ASCII-only (no extended box chars)
mermaid-ascii -f - -x 8 -y 3   # tighten horizontal / vertical padding
```

### Stay inside the supported subset: good vs bad

`mermaid-ascii` parses a small subset. Author defensively:

```
# good — flowchart/graph, LR or TD, plain rect nodes, simple/labeled edges
flowchart LR
  A[user input] --> B[parser]
  B -->|ok| C[planner]
  B -->|err| D[reject]

# bad — renders as literal text or breaks
flowchart LR
  B{Question?}              <- decision diamond: use a rectangle B[Question?] + two labeled edges
  subgraph cluster ... end  <- subgraphs, classDefs, themes, icons, styling: ignored or broken
sequenceDiagram             <- unsupported here: model as an LR flowchart or escalate to Path B
```

### Embed both source and render

Put the Mermaid in a ` ```mermaid ` block, then the ASCII render in a plain
fenced block immediately after. The source re-renders; the ASCII is what a
plain-text reader sees.

````markdown
```mermaid
flowchart LR
  A[user input] --> B[parser]
  B --> C[planner]
```

```
┌────────────┐     ┌────────┐     ┌─────────┐
│ user input ├────►│ parser ├────►│ planner │
└────────────┘     └────────┘     └─────────┘
```
````

## Path A2: ASCII for sequence and ER

`pretty-mermaid` renders five types; two of them beat having no ASCII at all.

```bash
pretty-mermaid --input diagram.mmd --format ascii --use-ascii
pretty-mermaid --input diagram.mmd --format ascii --use-ascii --padding-x 3
```

It reads a file, not stdin, so write the block to a `.mmd` file first. Embed the
source and the render together exactly as Path A does.

## Path B: themed SVG, offline

`pretty-mermaid` renders SVG locally, with no network call and no
Puppeteer/headless-Chrome toolchain. This is the default for an image.

```bash
pretty-mermaid --input diagram.mmd --output diagram.svg --format svg --theme tokyo-night
pretty-mermaid-themes                              # the 14 available themes
pretty-mermaid-batch --input-dir ./diagrams --output-dir ./out --format svg --theme nord --workers 4
```

Themes worth knowing: `tokyo-night` for dark docs, `github-light` for light
docs, `dracula` for something vivid. `nord`, `catppuccin-mocha`, and
`solarized-*` are there too.

One caveat: the emitted SVG `@import`s Inter from Google Fonts, so a viewer
fetches a font when the file is opened. For a diagram that must not phone home,
pass `--font` with a local family. Otherwise accept that the render itself was
offline and the view is not.

## When no local renderer parses the type

`pretty-mermaid` and `mermaid-ascii` are the only renderers. A type neither one
parses gets no render at all. There is no network fallback.

Do three things instead:

1. Keep the Mermaid source in the file, fenced as ` ```mermaid `.
2. Say in one line that the type has no local render, and name the type.
3. Offer the reader a supported type. A `classDiagram` that will not render
   often works as a flowchart, and a `journey` often works as a
   `sequenceDiagram`.

Never hand-draw the boxes to fill the gap. A hand-drawn render is a claim the
renderer never made.

## Per-diagram-type syntax (distilled from mermaid-skill)

Pick the type that matches the relationship, then take the path named beside it.

- flowchart, process/decision flow. `flowchart LR|TD`; `A[rect]`, `A(round)`,
  `A{diamond}`; edges `-->`, `-->|label|`, `-.->`. Path A.
- sequenceDiagram, ordered messages. `participant A`; `A->>B: call`;
  `B-->>A: reply`; `loop`/`alt`/`opt` blocks. Path A2.
- erDiagram, data model. `CUSTOMER ||--o{ ORDER : places`. Path A2.
- stateDiagram-v2, lifecycle. `[*] --> Idle`; `Idle --> Running: start`. Path B.
- classDiagram, types. `class Foo { +field; +method() }`; `Foo <|-- Bar`. Path
  B.
- gantt, schedule. `dateFormat YYYY-MM-DD`; sections; `task :id, start, dur`.
  Path B.
- pie, proportions. `pie title T` then `"Label" : value` rows. Path B.
- mindmap, hierarchical brainstorm. `mindmap` then indented nodes. Path B.

Across types: short labels; quote labels with spaces/punctuation when a parser
complains; one relationship per line; render early and iterate.

## OpenSpec integration

- Put the Mermaid source in `design.md` (fenced ` ```mermaid `), then the
  rendered ASCII in a plain fenced block right after.
- Large diagram: save source to `design.mmd` beside `design.md`, reference it,
  and render fresh ASCII into `design.md` on every edit.

## Guardrails

- The diagram is for human comprehension, if it does not help a reader, omit.
- Always render before pasting; never hand-draw ASCII boxes or paste stale
  ASCII.
- Keep the Mermaid source in the file. A render alone is write-only.
- Stay inside the `mermaid-ascii` subset for Path A; take Path A2 or B rather
  than forcing an unsupported type into the wrong renderer.
- Render a mermaid block you are only READING, too. If a file, PR, or spec
  contains one, render it before reasoning about it: a diagram parsed by eye is
  a diagram half-read.
- Never claim an ASCII render is faithful without looking at it. Both renderers
  garble some inputs, and the routing above is the record of which ones.
