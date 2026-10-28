# The four recurring subagent roles (gen-scout, gen-gate, gen-spec, gen-build), declared once.
# Each agent = local head (frontmatter) + _local-deltas.md + upstream common protocol + upstream role text
# (genie-agent operating-memory, pinned: a fix there reaches all four on update).
# Gate and scout get no Edit, so a reviewer cannot quietly repair what it judges.
# MCP tools are listed by name, never `mcp__<server>__*`, so nobody gets the destructive ones.
{
  sven,
  inputs,
  lib,
  ...
}:
let
  roles = "${inputs.genie-agent}/operating-memory/workflow/roles";
  # drop the upstream file's own frontmatter; the agent's comes from the head
  body = f: lib.concatStringsSep "---\n" (lib.drop 2 (lib.splitString "---\n" (builtins.readFile f)));

  # home-manager registers programs.claude-code.mcpServers as the `hm` plugin.
  mcp = server: map (t: "mcp__plugin_hm_${server}__${t}");
  mcpCommon =
    mcp "codebase-memory" [
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
    ++ (import ./_quipu.nix).tools
    ++ mcp "codegraph" [ "codegraph_explore" ]
    ++ mcp "headroom" [
      "headroom_compress"
      "headroom_retrieve"
      "headroom_stats"
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
    spec = base ++ [ "Edit" ] ++ mcpCommon;
    build = base ++ [ "Edit" ] ++ mcpCommon;
  };
in
{
  sven.aspects.ai-agents = {
    at = sven.aspects.vic-headless;
    homeManager =
      { pkgs, ... }:
      let
        # Order is load-bearing; diff the rendered agent before and after a change.
        mkAgent =
          role:
          pkgs.writeText "gen-${role}.md" (
            builtins.replaceStrings [ "@TOOLS@" ] [ "[${lib.concatStringsSep ", " tools.${role}}]" ] (
              builtins.readFile ./agents/_${role}-head.md
            )
            + "\n"
            + builtins.readFile ./_local-deltas.md
            + body "${roles}/common-protocol.md"
            + body "${roles}/${role}.md"
          );
      in
      {
        programs.claude-code.agents = lib.genAttrs' [ "scout" "gate" "spec" "build" ] (
          role: lib.nameValuePair "gen-${role}" (mkAgent role)
        );
      };
  };
}
