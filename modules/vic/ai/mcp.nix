# Local stdio MCP servers for code discovery, spawned per session by Claude Code.
# (codegraph lives in tools.nix beside its CLI; headroom in headroom.nix.)
{
  ren,
  ...
}:
{
  ren.aspects.ai-mcp = {
    at = ren.aspects.vic-headless;
    claude-allow = { ... }: [ "Bash(serena *)" ] ++ (import ./_quipu.nix).tools;
    git-ignores = { ... }: [
      ".serena"
      ".cbmignore"
      ".quipu"
    ];
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cbm = pkgs.codebase-memory-mcp;
        serena = pkgs.callPackage ./_pkgs/serena-agent.nix { };
        # serena imports pywebview when it loads, and nixpkgs marks pywebview broken on darwin
        withSerena = pkgs.stdenv.hostPlatform.isLinux;
        quipu = pkgs.callPackage ./_pkgs/quipu.nix { };
        # One global graph, like the global codegraph. The signing key defaults to
        # .quipu/ in the cwd, which would drop a private key into every repo.
        kb = import ./_quipu.nix;
        quipuDir = "${config.xdg.dataHome}/quipu";

        hookOf = command: [
          {
            hooks = [
              {
                type = "command";
                inherit command;
              }
            ];
          }
        ];

        # Shown to the main session and injected into every subagent, so the index is
        # used before grep and its known blind spots are not read as absence.
        discovery = ''
          Code discovery: prefer codebase-memory-mcp (search_graph, trace_path,
          get_code_snippet, query_graph, search_code) over grep for languages the index
          covers. Confirm coverage with a known-positive symbol query, never from
          get_architecture's languages field (it omits Nix). CALLS edges miss
          attrset-mediated Nix calls, so ZERO CALLERS IS NOT EVIDENCE OF DEAD CODE:
          cross-check with Grep before concluding or deleting. Never pass `mode` to
          index_repository: fast/moderate silently skip dirs named docs, scripts,
          tools, bin, build. Use Grep/Glob/Read for text and configs.
        '';
      in
      {
        home.packages = [
          cbm
          quipu
        ]
        ++ lib.optional withSerena serena;

        # auto_index defaults to false, leaving the graph empty until an agent
        # volunteers to index. `|| true`: a live session pinning another build refuses.
        home.activation.cbmAutoIndex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${lib.getExe cbm} config set auto_index true || true
        '';

        programs.claude-code = {
          mcpServers = {
            codebase-memory = {
              type = "stdio";
              command = lib.getExe cbm;
            };
            serena = lib.mkIf withSerena {
              type = "stdio";
              command = lib.getExe serena;
              args = [
                "start-mcp-server"
                "--project-from-cwd"
                "--context"
                "claude-code"
                "--open-web-dashboard"
                "False"
              ];
            };
            quipu = {
              type = "stdio";
              command = lib.getExe quipu;
              args = [
                "mcp"
                "--db"
                "${quipuDir}/quipu.db"
              ];
              env.QUIPU_SIGNING_KEY = "${quipuDir}/verifier.pk8";
            };
          };

          settings = {
            hooks = {
              PreToolUse = [
                {
                  matcher = "Grep|Glob";
                  hooks = [
                    {
                      type = "command";
                      command = "${lib.getExe cbm} hook-augment 2>/dev/null; exit 0";
                    }
                  ];
                }
              ];
              SessionStart = hookOf "${pkgs.writeShellScript "cbm-session-reminder" ''
                cat <<'EOF'
                ${discovery + kb.instructions}
                EOF
              ''}";
              # SubagentStart delivers only `additionalContext`, never plain stdout.
              SubagentStart = hookOf "${pkgs.writeShellScript "cbm-subagent-reminder" ''
                printf '%s\n' ${
                  lib.escapeShellArg (
                    builtins.toJSON {
                      hookSpecificOutput = {
                        hookEventName = "SubagentStart";
                        additionalContext = discovery + kb.instructions;
                      };
                    }
                  )
                }
              ''}";
            };
          };
        };

      };
  };
}
