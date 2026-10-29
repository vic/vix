# claude-usage-limit: helper script from
# https://gist.github.com/Smolevich/5d8a0619f840d66f7fca64205ef047e7 (MIT, stdlib python). Session messaging lives in ircc.
{ yen, ... }:
{
  yen.aspects.ai-claude-session-tools = {
    at = yen.aspects.vic-headless;
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
          (py "claude-usage-limit" ./_scripts/claude_usage_limit.py)
        ];
      };
  };
}
