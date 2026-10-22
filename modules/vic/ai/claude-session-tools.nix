# claude-session-send / claude-usage-limit: Claude Code helper scripts from
# https://gist.github.com/Smolevich/5d8a0619f840d66f7fca64205ef047e7 (MIT, stdlib python).
{ ren, ... }:
{
  ren.aspects.ai-claude-session-tools = {
    at = ren.aspects.vic-headless;
    homeManager =
      { pkgs, ... }:
      let
        py = name: script: pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ pkgs.python3 ];
          text = ''exec python3 ${script} "$@"'';
        };
      in
      {
        home.packages = [
          (py "claude-session-send" ./_scripts/claude_session_send.py)
          (py "claude-usage-limit" ./_scripts/claude_usage_limit.py)
        ];
      };
  };
}
