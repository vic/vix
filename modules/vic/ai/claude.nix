# Claude Code: a read-only declarative settings.json. CC cannot mutate it at
# runtime; change config here, not in the TUI.
{
  ren,
  inputs,
  vicAt,
  mod,
  ...
}:
{

  ren.aspects.ai-claude = {
    at = vicAt.core;
    homeManager = mod (
      {
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      {
        home.packages = [
          pkgs.nodejs_22
          pkgs.jq # budget.sh
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          # CC's Bash sandbox
          pkgs.socat
          pkgs.bubblewrap
        ];

        programs.git.ignores = [ ".claude" ];

        programs.claude-code = {
          enable = true;
          package = inputs'.llm-agents.packages.claude-code;
          enableMcpIntegration = true;

          lspServers.nix = {
            command = lib.getExe pkgs.nil;
            extensionToLanguage.".nix" = "nix";
          };

          settings = {
            theme = lib.mkDefault "auto";
            verbose = lib.mkDefault true;
            effortLevel = lib.mkDefault "xhigh";
            remoteControlAtStartup = false;
            includeCoAuthoredBy = false;
            gitAttribution = false;
            attribution = {
              commit = "";
              pr = "";
            };
            autoMemoryDirectory = "~/.claude/memory";
            teammateMode = "in-process";

            permissions.allow = [
              # Edit(**) covers Write/MultiEdit/NotebookEdit; Read(**) covers Grep/Glob
              "Read(**)"
              "Edit(**)"
              "Grep(**)"
              "LS(**)"
              "WebSearch"
              "TodoRead(**)"
              "TodoWrite(**)"
              "Task(**)"

              "Bash(git status *)"
              "Bash(git diff *)"
              "Bash(git log *)"
              "Bash(git show *)"
              "Bash(git blame *)"
              "Bash(git rev-parse *)"
              "Bash(git remote *)"
              "Bash(git branch:*)"
              # Literal form: a force-push or another ref still prompts.
              "Bash(git push origin main)"
              "Bash(git fetch *)"
              "Bash(git add *)"
              "Bash(git commit *)"
              "Bash(git stash *)"

              "Bash(treefmt *)"
              "Bash(just *)"

              "Bash(nix eval *)"
              "Bash(nix flake *)"
              "Bash(nix build *)"
              "Bash(nix fmt)"
              "Bash(nix develop *)"

              "Bash(ls:*)"
              "Bash(cat:*)"
              "Bash(head:*)"
              "Bash(tail:*)"
              "Bash(grep:*)"
              "Bash(rg:*)"
              "Bash(fd:*)"
              "Bash(find:*)"
              "Bash(which:*)"
              "Bash(pwd)"
              "Bash(whoami)"
              "Bash(uname:*)"
              "Bash(wc *)"
              "Bash(rg *)"
              "Bash(jq *)"
              "Bash(yq *)"
              "Bash(sort *)"
              "Bash(journalctl *)"
            ];

            env = {
              CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
              # CC prepends this file to every Bash tool shell; the hooks below keep
              # it a snapshot of the cwd's direnv, so agents see the devshell.
              CLAUDE_ENV_FILE = "${config.home.homeDirectory}/.claude/direnv-snapshot.sh";
              ENABLE_TOOL_SEARCH = "auto:5";
            };

            # Session start and cwd change only, never per tool call: evaluating
            # direnv on every shell fork-bombs the host.
            hooks =
              let
                hookOf = script: [
                  {
                    hooks = [
                      {
                        type = "command";
                        command = "bash ${config.home.homeDirectory}/.claude/${script} || true";
                      }
                    ];
                  }
                ];
              in
              {
                SessionStart = hookOf "load-direnv.sh" ++ hookOf "budget.sh SessionStart";
                CwdChanged = hookOf "load-direnv.sh";
                # Before a dispatch, where a "no new dispatch" gate can still bite.
                PreToolUse = [
                  {
                    matcher = "Agent";
                    inherit (builtins.head (hookOf "budget.sh PreToolUse")) hooks;
                  }
                ];
                SubagentStop = hookOf "subagent-stop.sh";
              };
          };
        };

        # A silent idle is the failure this names: agents stop without delivering, and
        # the reflex (re-dispatch) duplicates finished work.
        home.file.".claude/subagent-stop.sh" = {
          executable = true;
          text = builtins.readFile ./_scripts/subagent-stop.sh;
        };

        # One budget line per firing: context %, 5h/7d quota (from headroom's poller),
        # and the gate tripped. The gates protect the handoff, not against compaction:
        # start new work up to 75% ctx, close out from 90%, and a 7d quota >= 95%
        # means finish in-flight and dispatch nothing new.
        # Run on demand:  printf '{"transcript_path":"<session>.jsonl"}' | ~/.claude/budget.sh manual
        home.file.".claude/budget.sh" = {
          executable = true;
          text = builtins.readFile ./_scripts/budget.sh;
        };

        home.file.".claude/load-direnv.sh" = {
          executable = true;
          text = builtins.readFile ./_scripts/load-direnv.sh;
        };
      }
    );
  };
}
