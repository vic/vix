inputs: {

  nixpkgs-lib.follows = "nixpkgs";
  helium.inputs.utils.follows = "flake-utils";
  # bun2nix (llm-agents) does `import inputs.systems`; the shim below is a list
  bun2nix.inputs.systems.follows = "nix-systems";

  den = if builtins.pathExists ./vic/den then { outPath = ./vic/den; } else { };

  doom-emacs =
    source:
    source
    // {
      rev = source.revision;
      flake = false;
    };

  enthium = source: source // { flake = false; };

  disko = source: source // { flake = false; };

  # vic.ai: skills and plugin marketplaces, read as plain sources
  gstack = source: source // { flake = false; };
  one-skill-to-rule-them-all = source: source // { flake = false; };
  graphify = source: source // { flake = false; };
  deepwiki-skill = source: source // { flake = false; };
  vercel-skills = source: source // { flake = false; };
  lightjj = source: source // { flake = false; };
  superpowers-extended-cc-marketplace = source: source // { flake = false; };
  ponytail = source: source // { flake = false; };
  mattpocock = source: source // { flake = false; };
  diagram-design = source: source // { flake = false; };
  ui-ux-pro-max-skill = source: source // { flake = false; };
  claude-plugins-official = source: source // { flake = false; };
  caveman = source: source // { flake = false; };

  # Shim nix-systems/default
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  # Shim numtide/flake-utils
  flake-utils.lib =
    let
      inherit (inputs.nixpkgs) lib;
      defaultSystems = lib.systems.flakeExposed;
      transpose = inputs.flake-aspects { inherit lib; };
      eachSystem = systems: cb: transpose (lib.genAttrs systems cb);
      eachDefaultSystem = eachSystem defaultSystems;
    in
    {
      inherit defaultSystems eachSystem eachDefaultSystem;
    };

}
