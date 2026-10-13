# ccstatusline: the Claude Code status line. The config is a read-only store
# symlink; browse widgets in its TUI, but change the layout here.
{
  vic.ai = {
    homeManager =
      {
        lib,
        pkgs,
        inputs',
        ...
      }:
      let
        # `id` is required on every widget by ccstatusline's schema and carries no
        # meaning for a generated config, so it is derived from position rather than
        # hand-maintained. The TUI mints UUIDs; nothing reads them across saves that
        # we do not regenerate anyway.
        withIds = lib.imap0 (i: line: lib.imap0 (j: w: w // { id = "l${toString i}-${toString j}"; }) line);

        sep = {
          type = "separator";
          character = " · ";
          color = "brightBlack";
        };

        settings = {
          # Must equal the binary's CURRENT_VERSION. On a lower number ccstatusline
          # migrates the config and WRITES THE RESULT BACK — into the store symlink's
          # target, which is read-only, so the write throws, the whole load is
          # abandoned and the bar renders "⚠ invalid config" off the defaults. A
          # generated config has to arrive pre-migrated; bump this and the shape
          # below together whenever the ccstatusline input moves.
          version = 4;

          lines = withIds [
            # Line 1 — WHERE YOU ARE and WHAT IS UNLANDED. Every widget here is one
            # the close protocol asks about: which worktree holds the writer, what
            # is uncommitted, what is committed but unpushed.
            [
              {
                type = "current-working-dir";
                color = "cyan";
                # Drops the "cwd: " label; a path does not need naming.
                rawValue = true;
                # metadata is record(string,string) in the schema — booleans are
                # compared against the STRING "true", so `true` would read as unset.
                metadata.abbreviateHome = "true";
              }
              sep
              {
                type = "git-branch";
                color = "magenta";
                metadata.hide = "no-git";
              }
              {
                type = "git-changes";
                color = "yellow";
                metadata.hide = "no-git";
              }
              {
                # ↑n↓m against upstream: the "unpushed commits" half of the close
                # protocol, and the one a clean `git status` hides completely.
                # `hide` is deliberately NOT set here, unlike its neighbours:
                # in sync the widget returns null on its own, so the flag only ever
                # gates "(no git)" and "(no upstream)" — and a branch with no
                # upstream is the exact shape a fresh .worktrees/<task> takes, which
                # is where unpushed work strands.
                type = "git-ahead-behind";
                color = "brightRed";
              }
              {
                # Renders nothing outside a worktree, so it is a positive signal:
                # visible ⇒ you are in .worktrees/<task> and are its single writer.
                type = "worktree-name";
                color = "yellow";
              }
            ]

            # Line 2 — WHAT IT COSTS. The agent cap is quota-driven and model-tiered,
            # so the weekly Opus figure is a scheduling input, not trivia.
            [
              {
                type = "model";
                color = "cyan";
                rawValue = true;
              }
              {
                type = "thinking-effort";
                color = "brightBlack";
              }
              sep
              {
                type = "context-percentage";
                color = "green";
              }
              sep
              {
                type = "session-cost";
                color = "brightYellow";
              }
              {
                type = "session-usage";
                color = "brightBlue";
              }
              {
                # ★ `weekly-usage`, NOT `weekly-opus-usage`. Measured 2026-08-28 against
                # the live account: weekly-usage 70.0%, weekly-opus-usage 0.0%,
                # weekly-sonnet-usage 0.0%. There is no per-model weekly cap for this
                # account, so both per-model widgets report a limit that does not exist
                # and read a permanent, plausible-looking zero. The original choice was
                # reasoning from OUR agent cap being model-tiered — but that is a quota
                # policy we invented, not a limit the API reports.
                type = "weekly-usage";
                color = "brightMagenta";
                # `slider` is the only display mode that earns its width: a 10-block bar
                # AND the number. Measured — `progress` is 46 chars, `slider-only` drops
                # the number, and full-data/icon-* are no-ops that render exactly like the
                # default. Two sliders side by side make the BINDING constraint legible
                # without reading either figure.
                metadata.display = "slider";
              }
              {
                # ★ Fable has a REAL per-model weekly cap where Opus and Sonnet do not,
                # and on 2026-08-28 it was the tighter one: Fable 88.0% against overall
                # 70.0%. Showing only the overall figure hides the limit that actually
                # binds first.
                type = "fable-weekly-usage";
                color = "brightRed";
                metadata.display = "slider";
              }
            ]
          ];

          flexMode = "full-minus-40";
          compactThreshold = 60;
          colorLevel = 2;
          defaultPadding = " ";
          inheritSeparatorColors = false;
          globalBold = false;
          gitCacheTtlSeconds = 5;
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
      in
      {
        home.packages = [ inputs'.llm-agents.packages.ccstatusline ];

        # home.file, not xdg.configFile: ccstatusline joins homedir + ".config"
        # directly and never consults XDG_CONFIG_HOME, so this is the path it reads.
        home.file.".config/ccstatusline/settings.json".source =
          (pkgs.formats.json { }).generate "ccstatusline-settings.json"
            settings;

        programs.claude-code.settings.statusLine = {
          type = "command";
          command = lib.getExe inputs'.llm-agents.packages.ccstatusline;
          padding = 0;
        };
      };
  };
}
