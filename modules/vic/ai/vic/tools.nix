# vic CLIs and MCP servers, ported from frodo:
# - vic-* run/recall/mine/telemetry/law/gc/ws scripts (./bin, were ~/bin)
# - omni: cross-project session graph + MCP (./omni, was ~/.claude/omni; DB stays
#   at ~/.claude/omni.db, never in the store)
# - deepwiki MCP + REPL (./dw, vendored from github:vic/dw incl. unpushed repl.js)
# - notebooklm MCP (npx, unpinned as on frodo) + notebooklm-pack
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.ai-vic-tools = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        notebooklm-pack = {
          url = "github:meta-introspector/notebooklm-pack/a6cda4392ad06b409147f5d4083afcbe6ae36bc8";
          inputs = {
            flake-utils.follows = "flake-utils";
            nixpkgs.follows = "nixpkgs";
            rust-overlay.follows = "rust-overlay";
          };
        };
        flake-utils.url = "github:numtide/flake-utils/04c1b180862888302ddfb2e3ad9eaa63afc60cf8";
        rust-overlay = {
          url = "github:oxalica/rust-overlay/3100cf6ff140fb298f09192de610f4037d3bab0f";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        node = lib.getExe pkgs.nodejs_24; # omni needs builtin node:sqlite
        claudeDir = "${config.home.homeDirectory}/.claude";

        vicBin = pkgs.runCommandLocal "vic-bin" { } ''
          install -Dm755 -t $out/bin ${./bin}/*
        '';
        deepwiki = pkgs.writeShellScriptBin "deepwiki" ''exec ${node} ${./dw}/repl.js "$@"'';
      in
      {
        home.packages = [
          vicBin
          deepwiki
          (vix.perSystem pkgs inputs.notebooklm-pack).packages.default
          pkgs.util-linux # flock: omni-ingest.sh
        ];

        # Same path as before: hooks/omni-ingest.sh and omni's own docs point here.
        home.file.".claude/omni" = {
          source = ./omni;
          recursive = true;
        };

        programs.claude-code.mcpServers = {
          omni = {
            type = "stdio";
            command = node;
            args = [
              "${claudeDir}/omni/omni.js"
              "mcp"
            ];
            env.OMNI_DB = "${claudeDir}/omni.db";
          };
          deepwiki = {
            type = "stdio";
            command = node;
            args = [ "${./dw}/mcp.js" ];
          };
        };
      };
  };
}
