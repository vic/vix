# headroom (github:headroomlabs-ai/headroom): a local proxy between Claude Code and
# the API that compresses context, plus an MCP server. Claude Code is pointed at it
# with ANTHROPIC_BASE_URL — if the proxy is down, Claude Code cannot reach the API.
# It also writes ~/.headroom/subscription_state.json, which budget.sh reads.
#
# The upstream plugin is deliberately NOT installed: its hook writes an absolute
# store path into settings.local.json that goes stale on every rebuild.
{
  ren,
  ...
}:
{
  ren.aspects.ai-headroom = {
    at = ren.aspects.vic-headless;
    claude-allow = { ... }: [ "Bash(headroom *)" ];
    homeManager =
      { lib, pkgs, ... }:
      let
        headroom = pkgs.callPackage ./_pkgs/headroom-ai.nix { };
        args = [
          "proxy"
          "--host"
          "127.0.0.1"
          "--port"
          "8787"
          "--no-telemetry"
        ];
        # cache: compress only the new delta, so prior turns keep the provider's
        # prompt cache. LOSSLESS: lossy compression measured as one token knocked out
        # of cache per token saved. LOG_MESSAGES: required by `headroom inspect`, at
        # the cost of message content in local logs.
        env = {
          HEADROOM_TELEMETRY = "off";
          HEADROOM_MODE = "cache";
          HEADROOM_LOSSLESS = "1";
          HEADROOM_LOG_MESSAGES = "1";
        };
      in
      {
        home.packages = [
          headroom
          pkgs.uv
        ];

        programs.claude-code = {
          mcpServers.headroom = {
            type = "stdio";
            command = lib.getExe headroom;
            args = [
              "mcp"
              "serve"
            ];
          };
          settings = {
            env = {
              ANTHROPIC_BASE_URL = "http://127.0.0.1:8787";
              HEADROOM_1M = "1";
            };
          };
        };

        systemd.user.services.headroom = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          Unit = {
            Description = "Headroom token-compression proxy for AI coding agents";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            Environment = lib.mapAttrsToList (k: v: "${k}=${v}") env;
            ExecStart = lib.escapeShellArgs ([ (lib.getExe headroom) ] ++ args);
            Restart = "on-failure";
            RestartSec = 5;
            TimeoutStartSec = "infinity";
          };
          Install.WantedBy = [ "default.target" ];
        };

        launchd.agents.headroom = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          enable = true;
          config = {
            ProgramArguments = [ (lib.getExe headroom) ] ++ args;
            EnvironmentVariables = env;
            KeepAlive = {
              Crashed = true;
              SuccessfulExit = false;
            };
            ProcessType = "Background";
            RunAtLoad = true;
            ThrottleInterval = 5;
          };
        };
      };
  };
}
