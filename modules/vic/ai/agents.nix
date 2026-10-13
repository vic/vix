# The four recurring subagent roles (gen-scout, gen-gate, gen-spec, gen-build),
# declared once so a dispatch prompt carries only what is task-specific.
#
# Each agent is composed: head + shared measurement + role body + shared protocol.
# The shared halves are single-sourced, so editing them changes all four at once.
#
# Tool restriction is where the role binds: gate and scout get no Edit and no
# serena editors, so a reviewer cannot quietly repair what it judges. MCP tools
# are listed by name, never `mcp__<server>__*`, so nobody gets the destructive
# ones. Tools of a server not installed here (hindsight) are simply absent.
{ vic, ... }:
{
  vic.ai.includes = [ vic.ai._.gen-agents ];
  vic.ai._.gen-agents.homeManager =
    { lib, pkgs, ... }:
    let
      d = ./agents;
      shared = builtins.readFile "${d}/_shared-measurement.md";
      protocol = builtins.readFile "${d}/_shared-protocol.md";

      # home-manager registers programs.claude-code.mcpServers as the `hm` plugin.
      mcp = server: map (t: "mcp__plugin_hm_${server}__${t}");
      mcpCommon =
        mcp "hindsight" [
          "recall"
          "sync_retain"
          "retain"
          "get_memory"
          "list_memories"
          "invalidate_memory"
          "get_operation"
          "list_tags"
          "list_documents"
          "get_document"
          "list_directives"
          "list_mental_models"
          "get_mental_model"
          "search_knowledge_base"
          "get_knowledge_base_tree"
          "get_knowledge_page"
        ]
        ++ mcp "codebase-memory" [
          "list_projects"
          "index_status"
          "index_repository"
          "check_index_coverage"
          "get_architecture"
          "get_graph_schema"
          "get_file_outline"
          "get_code_snippet"
          "search_graph"
          "search_code"
          "query_graph"
          "trace_path"
          "detect_changes"
          "compare_graphs"
        ]
        ++ mcp "serena" [
          "initial_instructions"
          "find_symbol"
          "find_declaration"
          "find_implementations"
          "find_referencing_symbols"
          "get_symbols_overview"
          "get_diagnostics_for_file"
          "list_memories"
          "read_memory"
        ]
        ++ (import ./_quipu.nix).tools
        ++ mcp "codegraph" [ "codegraph_explore" ]
        ++ mcp "headroom" [
          "headroom_compress"
          "headroom_retrieve"
          "headroom_stats"
        ];
      serenaEdit = mcp "serena" [
        "replace_content"
        "replace_in_files"
        "replace_symbol_body"
        "rename_symbol"
        "insert_before_symbol"
        "insert_after_symbol"
        "safe_delete_symbol"
      ];
      base = [
        "Read"
        "Grep"
        "Glob"
        "Bash"
        "Write"
        "SendMessage"
      ];
      tools = {
        scout = base ++ mcpCommon;
        gate = base ++ mcpCommon;
        spec = base ++ [ "Edit" ] ++ mcpCommon ++ serenaEdit;
        build = base ++ [ "Edit" ] ++ mcpCommon ++ serenaEdit;
      };

      # Order is load-bearing; diff the rendered agent before and after a change.
      mkAgent =
        role:
        pkgs.writeText "gen-${role}.md" (
          builtins.replaceStrings [ "@TOOLS@" ] [ "[${lib.concatStringsSep ", " tools.${role}}]" ] (
            builtins.readFile "${d}/_${role}-head.md"
          )
          + "\n"
          + shared
          + "\n"
          + builtins.readFile "${d}/_${role}-body.md"
          + "\n"
          + protocol
        );
    in
    {
      programs.claude-code.agents = lib.genAttrs' [ "scout" "gate" "spec" "build" ] (
        role: lib.nameValuePair "gen-${role}" (mkAgent role)
      );
    };
}
