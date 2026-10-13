# Tooling vic used from upstream repos, taken from source (no vendored copies):
# skills from seflless/deepwiki, vercel-labs/skills and chronologos/lightjj,
# the lightjj release binary, and npm CLIs run via npx at the versions that were
# installed in ~/node_modules (same pattern as calldiff in ../tools.nix).
{ inputs, vic, ... }:
let
  lightjjVersion = "1.27.0";
in
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
    lightjj = {
      url = "github:chronologos/lightjj/v${lightjjVersion}";
      flake = false;
    };
  };

  vic.ai.includes = [ vic.ai._.vic-upstream ];
  vic.ai._.vic-upstream.homeManager =
    { lib, pkgs, ... }:
    let
      lightjj = pkgs.runCommandLocal "lightjj-${lightjjVersion}" { } ''
        install -Dm755 ${
          pkgs.fetchurl {
            url = "https://github.com/chronologos/lightjj/releases/download/v${lightjjVersion}/lightjj-linux-x86_64";
            sha256 = "0zrinvjjwjp6rqzhlkwb2axp068871g71cmpcw1a56r01jqlr9i2";
          }
        } $out/bin/lightjj
      '';

      # bin name -> npm package spec providing it
      npx = {
        tokenjuice = "tokenjuice@0.7.1";
        vestige = "vestige-mcp-server@2.1.23";
        vestige-mcp = "vestige-mcp-server@2.1.23";
        vestige-restore = "vestige-mcp-server@2.1.23";
        ralph-tui = "ralph-tui@0.12.0";
        notebooklm-mcp = "notebooklm-mcp@2.0.0";
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
      home.packages = [ lightjj ] ++ lib.mapAttrsToList npxBin npx;

      programs.claude-code.skills = {
        deepwiki = "${inputs.deepwiki-skill}/skills/deepwiki";
        find-skills = "${inputs.vercel-skills}/skills/find-skills";
        lightjj = "${inputs.lightjj}/cmd/lightjj/SKILL.md";
      };
    };
}
