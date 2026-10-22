# Memory retrieval for the laptop: research (2026-10-21)

## SPECS (measured)
- CPU: AMD Ryzen 5 7530U, 12 threads. GPU: integrated Radeon only (no CUDA, no usable inference GPU).
- RAM: 35 GiB total, 28 GiB available at measure time. Swap: 52 GiB (1.7 GiB in use).
- Disk: /home 918G, 707G free. Battery: 6% at measure time, so idle CPU cost matters.

## CURRENT COST (measured, `ps` RSS / %CPU)
| piece | RSS | CPU | disk | when |
|---|---|---|---|---|
| omni `ingest` (Stop hook `omni-ingest.sh`) | 1.2 GB at 41s, 1.3 GB at 48s, **2.27 GB at 92s** | ~105% (1 core pegged) | omni.db 1.6G (+1.2G ~/.claude/projects source) | every Stop, flock-guarded |
| omni `mcp` | 57-76 MB | ~0 | same db | per session |
| quipu-server (stdio) | 59 MB | ~0 | 27M | per session |
| codegraph (node) | 72-118 MB x2 | ~0 | - | per session |
| codebase-memory-mcp | 17 MB x2 | ~0 | - | per session |
| serena (python) | 152 MB x2 | ~0 | - | per session |
| notebooklm-mcp (node) | 153-157 MB x2 | ~0 | - | per session (not memory, but idle RSS) |
| claude-ledger | - | - | 175M | hook writes |
| auto-memory `~/.claude/memory` | 0 | 0 | 140K, 35 files | loaded into prompt |
| vic-lessons skill | 0 | 0 | 5 md, 359 lines | loaded on skill use |
Takeaway: the only real cost is **omni ingest**. It re-parses transcripts on each Stop and grows past 2 GB RSS on one full core.
That is a battery problem. The stdio MCP servers are cheap per server (~60-150 MB each), but they multiply by the number of open sessions.

## SINI: hindsight (how it runs)
- Runs as a cluster service on the axon k8s cluster, not on the laptop. The laptop reaches it over an http MCP URL (`modules/features/dev/ai/hindsight.nix`).
- Resources: hindsight-api pod (requests 200m CPU / 1 GiB, limits 2 CPU / 4 GiB, 5 Gi PVC), control plane (up to 1 CPU / 1 GiB), CloudNativePG with 2 instances x 10 Gi, and pgvector.
- Every retain makes an **LLM call** (`gpt-oss-20b` through llama.cpp on the cluster) for fact extraction. A local embedder and reranker are pulled from HuggingFace on first boot.
- Laptop side: hooks (`hindsight-hooks*.nix`), systemd user units `hindsight-handoff-reconcile` and `hindsight-backfill` (timer).
- Agents get read tools only. Retain goes through a narrow, named write path.
- vix README section 8 already records it as "not set up here: needs a server".

## OPTIONS
| option | RAM | disk | daemons | LLM/embedding cost | retrieval quality | src |
|---|---|---|---|---|---|---|
| A. md files + rg / Claude native `memory:` (auto-memory, agent-memory, skills via hooks) | 0 | KB | none | none | good for small curated lessons: index is in prompt, agent reads files | [1] |
| B. SQLite FTS5/BM25 over curated md (one stdio MCP or CLI) | ~20-60 MB on call | MB | none | none | strong baseline: bakeoff shows BM25 beats pure vector; enrichment helps more than vectors | [3][4][5] |
| C. B + sqlite-vec + MiniLM-L6 ONNX CPU (e.g. basic-memory/fastembed) | +~90-150 MB (87 MB fp32 / 22 MB int8 weights) | 1.5 KB/vector | none (stdio) | local CPU embed per write, ms | +~9pp R@5 on paraphrase/preference (LongMemEval, vendor-run) | [2][6][7] |
| D. quipu (RDF/SPARQL KG, stdio) | 59 MB | 27M | none | none | structured facts, exact; recall depends on entity naming | measured |
| E. omni (FTS over all transcripts) | 57 MB mcp + **2.3 GB ingest** | 1.6G | none, but heavy Stop job | none | broad history search; noisy (raw transcripts) | measured |
| F. hindsight local (pg0 + embedder + reranker + LLM) | GBs (sini sizes 1-4 GiB + pg) | GBs | postgres + api server | **LLM call per retain** + embeddings | best hybrid (vector+BM25+graph+temporal, RRF, cross-encoder) | [8], sini manifests |
| G. mem0 local | qdrant/pg + embedder | GBs | vector DB | LLM call per add | similar class to F | (not fetched) |

Key question (do we need embeddings?): **not for agent-lesson recall**.
- Lessons are short, curated, and keyword-rich (tool names, error strings, paths), which is BM25's strong case [3][5].
- MemoryAgentBench measured BM25 above text-embedding-3-small on one task group [4].
- Embeddings pay off on paraphrased, conversational recall: LongMemEval +9pp R@5 [2][6]. That is transcript-mining territory, not lesson recall.
- Write-time enrichment (tags, error signature, synonyms in the file) gives more lift than vectors [3].

## RECOMMENDATION (one stack, best quality per resource)
1. **Keep, primary: files in the vix repo.**
   - Auto-memory (`~/.claude/memory`), vic-lessons skill files, and Claude `memory: project|user` on the agents that learn (gen-scout, vic-hunter).
   - Write each lesson with tags plus the exact error signature. That is the enrichment.
   - Hooks inject the index. Agents use rg for lookup. Cost: zero RAM, zero daemons, zero LLM.
2. **Keep: quipu** (59 MB stdio, 27M). It is cheap and gives exact, structured facts.
   - Trim the "MANDATORY for every agent" mandate in `modules/vic/ai/_quipu.nix` to tasks that need decisions or measured facts. That saves tokens.
3. **Change omni: take ingest off the Stop hook.**
   - Edit `modules/vic/ai/vic/hooks.nix` (Stop list): drop `(hookOf "omni-ingest.sh")`.
   - Run ingest instead from a `systemd.user` timer: nightly, `ConditionACPower=true`, `Nice=19`, `CPUQuota=50%`, `MemoryMax=1G`.
   - Or run it on demand. Keep `omni mcp` for history search.
   - Check why ingest grows past 2 GB. It is probably a full re-parse, not an incremental one. That is an omni bug to file.
4. **Drop hindsight for the laptop.** It needs postgres, a cross-encoder, and an LLM per retain. That fails the "no daemons, no per-write LLM" rule. Revisit only if a shared server like sini's exists.
5. **Optional, only if rg/BM25 misses measurably:** add basic-memory (stdio, md source of truth, FTS + fastembed) over the vic-lessons dir. Cost: about 150 MB on call, no daemon.
6. Side win, not memory: notebooklm-mcp and serena cost about 300 MB idle each per session pair. Consider lazy-enabling them.
Files to change: `modules/vic/ai/vic/hooks.nix`, `modules/vic/ai/vic/tools.nix` (systemd timer beside omni), `modules/vic/ai/_quipu.nix` (mandate wording), `modules/vic/ai/agents.nix` (`memory:` field, and drop the hindsight tool list).

## SOURCES
1. Claude Code subagent `memory` field: https://code.claude.com/docs/en/sub-agents
2. LongMemEval (Wu et al., ICLR 2025): https://arxiv.org/pdf/2410.10813
3. agent-memory-bakeoff (BM25 + enrichment vs vector): https://github.com/JaysonRawlins/agent-memory-bakeoff
4. MemoryAgentBench: https://arxiv.org/pdf/2507.05257
5. EvoMemBench: https://arxiv.org/pdf/2605.18421
6. agentmemory LongMemEval numbers (vendor): https://github.com/rohitg00/agentmemory/blob/main/benchmark/LONGMEMEVAL.md
7. all-MiniLM-L6-v2 sizes: https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/discussions/39 , basic-memory: https://github.com/basicmachines-co/basic-memory
8. hindsight: https://github.com/vectorize-io/hindsight ; sini: `generated/manifests/prod-axon/hindsight/Deployment-hindsight.yaml`, `hindsight-pg/Cluster-hindsight-pg.yaml`
