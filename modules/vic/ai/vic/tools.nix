# vic CLIs and MCP servers, ported from frodo:
# - vic-* run/recall/mine/telemetry/law/gc/ws scripts (./bin, were ~/bin)
# - deepwiki MCP + REPL (./dw, vendored from github:vic/dw incl. unpushed repl.js)
# - notebooklm MCP (npx, unpinned as on frodo) + notebooklm-pack
{ yen, inputs, lib, ... }:
let
  node = pkgs: lib.getExe pkgs.nodejs_24; # deepwiki runs on node
in
{
  yen.aspects.ai-vic-tools = {
    at = yen.aspects.vic-headless;
    flake-file.inputs = {
      notebooklm-pack = {
        url = "github:meta-introspector/notebooklm-pack";
        inputs = {
          flake-utils.follows = "flake-utils";
          nixpkgs.follows = "nixpkgs";
          rust-overlay.follows = "rust-overlay";
        };
      };
      flake-utils.url = "github:numtide/flake-utils";
      rust-overlay = {
        url = "github:oxalica/rust-overlay";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    homeManager =
      { config, pkgs, ... }:
      let
        vicBin = pkgs.runCommandLocal "vic-bin" { } ''
          install -Dm755 -t $out/bin ${./bin}/*
        '';
        deepwiki = pkgs.writeShellScriptBin "deepwiki" ''exec ${node pkgs} ${./dw}/repl.js "$@"'';
      in
      {
        home.packages = [
          vicBin
          deepwiki
          pkgs.ccusage
          (yen.helpers.perSystem pkgs inputs.notebooklm-pack).packages.default
        ];
        programs.claude-code.mcpServers = {
          deepwiki = {
            type = "stdio";
            command = node pkgs;
            args = [ "${./dw}/mcp.js" ];
          };
        };
      };
  };
}
