# vic CLIs and MCP servers, ported from frodo:
# - vic-* run/recall/mine/telemetry/law/gc/ws scripts (./bin, were ~/bin)
# - omni: cross-project session graph + MCP (./omni, was ~/.claude/omni; DB stays
#   at ~/.claude/omni.db, never in the store)
# - deepwiki MCP + REPL (./dw, vendored from github:vic/dw incl. unpushed repl.js)
# - notebooklm MCP (npx, unpinned as on frodo) + notebooklm-pack
{ vic, ... }:
{
  flake-file.inputs.notebooklm-pack = {
    url = "github:meta-introspector/notebooklm-pack";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  vic.ai.includes = [ vic.ai._.vic-tools ];
  vic.ai._.vic-tools.homeManager =
    {
      config,
      inputs',
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
        inputs'.notebooklm-pack.packages.default
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
        notebooklm = {
          type = "stdio";
          command = lib.getExe' pkgs.nodejs_24 "npx";
          args = [ "notebooklm-mcp@latest" ];
        };
      };
    };
}
