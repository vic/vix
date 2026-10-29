# ircc: local IRC-like chat between Claude Code sessions on this machine.
{ yen, inputs, ... }:
{
  yen.aspects.ai-ircc = {
    at = yen.aspects.vic-headless;
    flake-file.inputs.ircc = {
      url = "github:vic/ircc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ (yen.helpers.perSystem pkgs inputs.ircc).packages.default ];
      };
  };
}
