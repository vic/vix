# Claude Code: a read-only declarative settings.json. CC cannot mutate it at
# runtime; change config here, not in the TUI.
{
  flake-file.inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  vic.ai.homeManager =
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
        text = ''
          #!/usr/bin/env bash
          printf '%s\tstopped\n' "$(date -Is)" >> "$HOME/.claude/subagent-stops.log" 2>/dev/null
          cat <<'MSG'
          A subagent just STOPPED.

          If its report has NOT arrived: TREE FIRST, then prompt ONCE. Never re-dispatch — a
          resend duplicates completed work, while a message revives the agent with its context.
          Read the artefact it was told to write before assuming nothing happened.

          A silent idle is NOT a clean result. Never infer a finding, a pass, or an absence from
          a report that never arrived — say it is outstanding.
          MSG
          exit 0
        '';
      };

      # One budget line per firing: context %, 5h/7d quota (from headroom's poller),
      # and the gate tripped. The gates protect the handoff, not against compaction:
      # start new work up to 75% ctx, close out from 90%, and a 7d quota >= 95%
      # means finish in-flight and dispatch nothing new.
      # Run on demand:  printf '{"transcript_path":"<session>.jsonl"}' | ~/.claude/budget.sh manual
      home.file.".claude/budget.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -uo pipefail
          sub="$HOME/.headroom/subscription_state.json"
          event="''${1:-unknown}"

          payload=""
          if [ ! -t 0 ]; then payload="$(cat 2>/dev/null || true)"; fi
          transcript=$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2>/dev/null)

          # Orchestrators run 1M-context models. Never take the model from the
          # transcript: it drops the [1m] marker and would select a 200K divisor.
          limit=1000000
          model=$(printf '%s' "$payload" \
            | jq -r 'if (.model|type)=="string" then .model else (.model.id // empty) end' 2>/dev/null)
          case "$model" in
            "" | *"[1m]") ;;
            claude-haiku-* | claude-sonnet-*) limit=200000 ;;
          esac

          ctx="?"
          if [ -n "$transcript" ] && [ -s "$transcript" ]; then
            tok=$(jq -r 'select(.type=="assistant") | select(.isSidechain != true)
                         | select(.message.usage != null) | .message.usage
                         | (.input_tokens//0)+(.cache_read_input_tokens//0)+(.cache_creation_input_tokens//0)' \
                    "$transcript" 2>/dev/null | tail -1)
            case "''${tok:-}" in
              "" | *[!0-9]*) ;;
              *) ctx=$(awk -v t="$tok" -v l="$limit" 'BEGIN{printf "%.1f", t*100/l}') ;;
            esac
          fi

          five="?"; seven="?"; mins="?"; stale=""
          if [ -s "$sub" ]; then
            vals=$(jq -r '[(.latest.five_hour.utilization_pct // "x"),
                           (.latest.seven_day.utilization_pct // "x"),
                           (.latest.five_hour.seconds_to_reset // 0)] | @tsv' "$sub" 2>/dev/null)
            five=$(printf '%s' "$vals" | cut -f1)
            seven=$(printf '%s' "$vals" | cut -f2)
            secs=$(printf '%s' "$vals" | cut -f3)
            case "$five$seven" in "" | *[!0-9.]*) five="?"; seven="?" ;; esac
            mins=$(awk -v s="''${secs:-0}" 'BEGIN{ if (s+0>0) printf "%d", s/60; else printf "?" }')
            age=$(( $(date +%s) - $(stat -c %Y "$sub" 2>/dev/null || echo 0) ))
            [ "$age" -gt 900 ] && stale=" STALE(''${age}s)"
          fi

          gate=""
          if [ "$ctx" != "?" ]; then
            gate=$(awk -v c="$ctx" 'BEGIN{
              if (c+0 >= 90)      print "CLOSE OUT (ctx>=90) - the rest of the window is the handoff";
              else if (c+0 >= 75) print "NO FRESH SUBJECTS (ctx>=75) - finish open streams, start nothing new";
            }')
          fi
          # Weekly outranks context: a session limit resumes cleanly, a weekly one doesn't.
          if [ "$seven" != "?" ] && awk -v w="$seven" 'BEGIN{exit !(w+0>=95)}'; then
            gate="CLEAN CLOSEOUT (7d>=95) - unhurried; finish in-flight, no new dispatch"
          fi

          line=$(printf 'BUDGET %s · ctx %s%% · 5h %s%% (%sm) · 7d %s%%%s%s' \
            "$event" "$ctx" "$five" "$mins" "$seven" "$stale" "''${gate:+ · GATE: $gate}")

          # Plain stdout reaches the model on SessionStart only; PreToolUse needs JSON.
          case "$event" in
            PreToolUse*)
              printf '%s' "$line" \
                | jq -Rs --arg ev "$event" '{hookSpecificOutput:{hookEventName:$ev,additionalContext:.}}'
              ;;
            *) printf '%s\n' "$line" ;;
          esac
          exit 0
        '';
      };

      home.file.".claude/load-direnv.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -uo pipefail
          snap="''${CLAUDE_ENV_FILE:-$HOME/.claude/direnv-snapshot.sh}"
          mkdir -p "$(dirname "$snap")"
          # No .envrc: keep the last snapshot so tools don't vanish mid-task.
          [ -e .envrc ] || exit 0
          command -v direnv >/dev/null || exit 0
          tmp="$(mktemp)"
          # temp+mv: a half-written snapshot would be sourced by every later shell.
          if direnv export bash 2>/dev/null > "$tmp"; then
            mv "$tmp" "$snap"
          else
            rm -f "$tmp"
          fi
          exit 0
        '';
      };
    };
}
