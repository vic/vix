# Tooling vic used from upstream repos, taken from source (no vendored copies):
# skills from seflless/deepwiki and vercel-labs/skills, and npm CLIs run via npx
# at the versions that were installed in ~/node_modules (same pattern as calldiff
# in ../tools.nix). lightjj: ../lightjj.nix; notebooklm-mcp: ../browser-tools.nix.
{ inputs, vic, ... }:
{
  flake-file.inputs = {
    deepwiki-skill = {
      url = "github:seflless/deepwiki";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
  };

  vic.ai.includes = [ vic.ai.vic-upstream ];
  vic.ai.vic-upstream.homeManager =
    { lib, pkgs, ... }:
    let
      # bin name -> npm package spec providing it
      npx = {
        tokenjuice = "tokenjuice@0.7.1";
        vestige = "vestige-mcp-server@2.1.23";
        vestige-mcp = "vestige-mcp-server@2.1.23";
        vestige-restore = "vestige-mcp-server@2.1.23";
        ralph-tui = "ralph-tui@0.12.0";
        oldw = "@seflless/deepwiki@0.1.8"; # its `deepwiki` bin; ours is the dw REPL
      };
      binOf = name: if name == "oldw" then "deepwiki" else name;
      npxBin =
        name: spec:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ pkgs.nodejs_24 ];
          text = ''exec npx --yes -p ${spec} ${binOf name} "$@"'';
        };
    in
    {
      home.packages = lib.mapAttrsToList npxBin npx;

      programs.claude-code.skills = {
        deepwiki = "${inputs.deepwiki-skill}/skills/deepwiki";
        find-skills = "${inputs.vercel-skills}/skills/find-skills";
      };
    };
}
