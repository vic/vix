{ vic, den, ... }:
{
  flake-file.inputs.nix-claude-code = {
    url = "github:ryoppippi/nix-claude-code";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.nixConfig = {
    extra-substituters = [ "https://ryoppippi.cachix.org" ];
    extra-trusted-public-keys = [ "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms=" ];
  };

  vic.everywhere.includes = [ vic.ai ];

  vic.ai.includes = [
    (den.provides.unfree [ "copilot-language-server" "claude" "github-copilot-cli" ])
  ];

  vic.ai.hmLinux =
    { pkgs, inputs', ... }:
    {
      home.packages = [
        inputs'.nix-claude-code.packages.default
        pkgs.github-copilot-cli
        pkgs.copilot-language-server
        pkgs.aider-chat
        pkgs.gemini-cli-bin
      ];
    };
}
