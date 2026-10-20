# ccstatusline: the Claude Code status line. The config is a read-only store
# symlink; browse widgets in its TUI, but change the layout here.
# One line: model, burn (ctx, $, $/h, tokens), quotas, last skill, last MCP tool.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.ai-statusline = {
    at = ren.aspects.vic-headless;
    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
      let
        ccstatusline = lib.getExe (vix.perSystem pkgs inputs.llm-agents).packages.ccstatusline;

        script =
          name:
          lib.getExe (
            pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.jq ];
              text = builtins.readFile ./_scripts/${name}.sh;
            }
          );

        # `id` is required on every widget by ccstatusline's schema and carries no
        # meaning for a generated config, so it is derived from position.
        withIds = lib.imap0 (i: w: w // { id = "w${toString i}"; });

        sep = {
          type = "separator";
          character = "·"; # widget padding already spaces it
          color = "brightBlack";
        };

        # rawValue drops ccstatusline's long labels; `label` puts a short one back.
        raw = color: type: {
          inherit type color;
          rawValue = true;
        };
        label = text: {
          type = "custom-text";
          customText = text;
          color = "brightBlack";
          merge = "no-padding";
        };
        # metadata is record(string,string): hide states are a string, not a list.
        hideNoData = w: w // { metadata.hide = "no-data"; };

        settings = {
          # Must equal the binary's CURRENT_VERSION. On a lower number ccstatusline
          # migrates the config and WRITES THE RESULT BACK — into the store symlink's
          # target, which is read-only, so the write throws, the whole load is
          # abandoned and the bar renders "⚠ invalid config" off the defaults. A
          # generated config has to arrive pre-migrated; bump this and the shape
          # below together whenever the ccstatusline input moves.
          version = 4;

          lines = [
            (withIds [
              (raw "cyan" "model")
              (raw "brightBlack" "thinking-effort")
              sep
              (label "ctx ")
              (raw "green" "context-percentage")
              sep
              (raw "brightYellow" "session-cost")
              (raw "yellow" "session-cost-rate")
              (raw "brightBlue" "tokens-total")
              sep
              (label "5h ")
              (hideNoData (raw "brightBlue" "session-usage"))
              (raw "brightBlack" "reset-timer")
              # ★ `weekly-usage`, NOT `weekly-opus-usage`: measured 2026-08-28, the
              # per-model Opus/Sonnet widgets read a permanent 0% (no such cap on this
              # account) while Fable has a real, tighter weekly cap.
              (label "7d ")
              (hideNoData (raw "brightMagenta" "weekly-usage"))
              # labelled natively: renders only when the account reports a Fable cap
              {
                type = "fable-weekly-usage";
                color = "brightRed";
              }
              sep
              # "Skill: <last>"; fed by the `--hook` entries below
              {
                type = "skills";
                color = "magenta";
                metadata = {
                  mode = "current";
                  hide = "empty";
                };
              }
              {
                type = "custom-command";
                commandPath = script "mcp-status";
                color = "cyan";
              }
            ])
          ];

          flexMode = "full-minus-40";
          compactThreshold = 60;
          colorLevel = 2;
          defaultPadding = " ";
          inheritSeparatorColors = false;
          globalBold = false;
          minimalistMode = false;

          # Off on purpose: powerline separators are private-use codepoints that
          # render as tofu without a patched font, and the fallback is silent.
          powerline = {
            enabled = false;
            separators = [ "" ];
            separatorInvertBackground = [ false ];
            startCaps = [ ];
            endCaps = [ ];
            autoAlign = false;
            continueThemeAcrossLines = false;
          };
        };

        hook = command: matcher: [
          (
            {
              hooks = [
                {
                  type = "command";
                  inherit command;
                }
              ];
            }
            // lib.optionalAttrs (matcher != null) { inherit matcher; }
          )
        ];
      in
      {
        home.packages = [ (vix.perSystem pkgs inputs.llm-agents).packages.ccstatusline ];

        # home.file, not xdg.configFile: ccstatusline joins homedir + ".config"
        # directly and never consults XDG_CONFIG_HOME, so this is the path it reads.
        home.file.".config/ccstatusline/settings.json".source =
          (pkgs.formats.json { }).generate "ccstatusline-settings.json"
            settings;

        programs.claude-code.settings = {
          statusLine = {
            type = "command";
            command = ccstatusline;
            padding = 0;
          };
          hooks = {
            PreToolUse = hook "${ccstatusline} --hook" "Skill";
            UserPromptSubmit = hook "${ccstatusline} --hook" null;
            PostToolUse = hook (script "mcp-log") "mcp__.*";
          };
        };
      };
  };
}
