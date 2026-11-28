{
  yen,
  inputs,
  lib,
  ...
}:
{
  yen.aspects.ai-tuios = {
    at = yen.aspects.vic-headless;
    flake-file.inputs.tuios = {
      url = "github:Gaurav-Gosain/tuios";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-allow = [ "Bash(tuios *)" ];
    homeManager =
      { pkgs, ... }:
      let
        tuios = (yen.helpers.perSystem pkgs inputs.tuios).packages.default;

        hook =
          {
            name,
            timeout ? 5,
          }:
          {
            ${name} = [
              {
                hooks = [
                  {
                    type = "command";
                    command = "tuios agent-hook claude-code --integration 3";
                    inherit timeout;
                  }
                ];
              }
            ];
          };
      in
      {
        home.packages = [ tuios ];
        programs.claude-code.settings.hooks =
          (hook { name = "PostToolUse"; })
          // (hook { name = "PreCompact"; })
          // (hook { name = "SessionStart"; })
          // (hook { name = "Stop"; })
          // (hook { name = "SubagentStart"; })
          // (hook { name = "SubagentStop"; })
          // (hook { name = "UserPromptSubmit"; })
          // (hook {
            name = "PermissionRequest";
            timeout = 310;
          })
          // (hook { name = "PostToolUseFailure"; })
          // (hook { name = "PermissionDenied"; })
          // (hook { name = "ElicitationResult"; })
          // (hook { name = "Notification"; })
          // (hook { name = "StopFailure"; })
          // (hook { name = "SessionEnd"; })
          // { };
      };
  };
}
