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
    BEFORE work: quipu_ask (no name = catalog) and quipu_query (SPARQL; label
    prefix "ledger:<proj>/mistake/" and "ledger:<proj>/evidence/" = past mistakes)
    on the task's entities; quipu_context with max_entities 3 or less. Use what is
    recorded instead of re-deriving it. quipu_search_nodes, quipu_search_facts and
    quipu_search do not work on this store: an empty answer, an error or a timeout
    is UNKNOWN, never "nothing recorded".
    AFTER a verified result (root cause, decision, measured fact, dead end):
    quipu_resolve_entity first, then quipu_knot or quipu_episode to record it with
    its evidence and with edges to its project, bead and files. Check the data
    first with quipu_validate (the store has no shapes loaded). Read it back with
    quipu_ask references_to. Record only verified facts, never guesses. Report to
    the supervisor what you read from and wrote to quipu.
  '';
}
