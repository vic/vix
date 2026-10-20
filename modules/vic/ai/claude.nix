# Claude Code: a read-only declarative settings.json. CC cannot mutate it at
# runtime; change config here, not in the TUI.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  # features emit permission rules;
  # ai-claude writes them once.
  ren.channels.claude-allow = {
    fold = ren.lib.fold.list;
    at = ren.kinds.user;
    to = e: e;
  };
  ren.aspects.ai-claude = {
    at = ren.aspects.vic-headless;
    git-ignores = { ... }: [ ".claude" ];
    homeManager =
      {
        claude-allow,
        config,
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

        programs.claude-code = {
          enable = true;
          package = (vix.perSystem pkgs inputs.llm-agents).packages.claude-code;
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
            permissions.allow = lib.unique (builtins.concatLists claude-allow);

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
      };
  };
}
