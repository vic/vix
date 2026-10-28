# ircc: local IRC-like chat between Claude Code sessions on this machine.
{ sven, inputs, ... }:
{
  sven.aspects.ai-ircc = {
    at = sven.aspects.vic-headless;
    flake-file.inputs.ircc = {
      url = "github:vic/ircc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ (sven.helpers.perSystem pkgs inputs.ircc).packages.default ];
      };
  };
}
