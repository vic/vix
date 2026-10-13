# quipu is the agentic knowledge base. Shared by mcp.nix (hooks, permissions)
# and both agent sets, so every agent gets the same mandate and the same tools.
let
  # Reads plus additive writes. Retract, set, freeze, merge, schema and ontology
  # changes stay out: those rewrite what other agents recorded.
  names = [
    "context"
    "search"
    "search_nodes"
    "search_facts"
    "hybrid_search"
    "unified_search"
    "query"
    "ask"
    "cord"
    "unravel"
    "explain"
    "impact"
    "graph_list"
    "report"
    "resolve_entity"
    "validate"
    "knot"
    "episode"
    "episodes_complete"
  ];
in
{
  # home-manager serves its mcpServers as the `hm` plugin, hence the prefix.
  tools = map (t: "mcp__plugin_hm_quipu__quipu_${t}") names;

  instructions = ''
    Knowledge base: quipu (mcp__plugin_hm_quipu__*) is MANDATORY for every agent.
    BEFORE work: quipu_context / quipu_search_nodes / quipu_search_facts on the
    task's entities. Use what is recorded instead of re-deriving it.
    AFTER a verified result (root cause, decision, measured fact, dead end):
    quipu_resolve_entity first, then quipu_knot or quipu_episode to record it with
    its evidence. Record only verified facts, never guesses. Report to the
    supervisor what you read from and wrote to quipu.
  '';
}
