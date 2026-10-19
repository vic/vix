# vic's frodo settings.json preferences. Where sini's claude.nix sets the
# same key it uses lib.mkDefault, so these win.
{
  ren,
  vicAt,
  mod,
  ...
}:
{
  ren.aspects.ai-vic-settings = {
    at = vicAt.core;
    homeManager = mod (
      { lib, ... }: {
        programs.claude-code.settings = {
          model = "opus";
          effortLevel = "high";
          theme = "dark";
          verbose = false;
          tui = "fullscreen";
          editorMode = "vim";
          enableWorkflows = true;
          worktree.baseRef = "fresh";
          skipDangerousModePermissionPrompt = true;
          inputNeededNotifEnabled = true;
          agentPushNotifEnabled = true;

          permissions = {
            defaultMode = "auto";
            # (mkBefore: old order) home-manager serves its mcpServers as the `hm` plugin, hence the prefix.
            allow = lib.mkBefore (
              map (t: "mcp__plugin_hm_codegraph__codegraph_${t}") [
                "search"
                "context"
                "callers"
                "callees"
                "impact"
                "node"
                "status"
              ]
            );
          };
        };
      }
    );
  };
}
