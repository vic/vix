# vic's frodo settings.json preferences: rank 1 on the `claude` sink, so they
# win over claude.nix (rank 0) per key.
{ sven, ... }:
{
  sven.aspects.ai-vic-settings = {
    at = sven.aspects.vic-headless;
    # home-manager serves its mcpServers as the `hm` plugin, hence the prefix.
    claude-allow = map (t: "mcp__plugin_hm_codegraph__codegraph_${t}") [
      "search"
      "context"
      "callers"
      "callees"
      "impact"
      "node"
      "status"
    ];
    claude.rank = 1;
    claude.set = {
      # main loop (the session vic talks to) = opus/high; subagents default to sonnet
      # so an untyped dispatch never inherits opus. agent-tier-gate.sh enforces explicit tiers.
      model = "opus";
      effortLevel = "high";
      env.CLAUDE_CODE_SUBAGENT_MODEL = "sonnet";
      theme = "dark";
      verbose = false;
      tui = "fullscreen";
      editorMode = "vim";
      enableWorkflows = true;
      worktree.baseRef = "fresh";
      skipDangerousModePermissionPrompt = true;
      inputNeededNotifEnabled = true;
      agentPushNotifEnabled = true;
      permissions.defaultMode = "auto";
      # idle compaction fires at 22-77% ctx; pre-compact.sh holds the rest
      idleCompaction = false;
      permissions.ask = [
        "Bash(pkill *)"
        "Bash(killall *)"
        # peer sessions work in the shared checkout
        "Bash(git stash *)"
      ];
      permissions.deny = [
        "Edit(**/flake.lock)"
      ];
    };
  };
}
