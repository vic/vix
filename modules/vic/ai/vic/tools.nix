# vic CLIs and MCP servers, ported from frodo:
# - vic-* run/recall/mine/telemetry/law/gc/ws scripts (./bin, were ~/bin)
# - omni: cross-project session graph + MCP (./omni, was ~/.claude/omni; DB stays
#   at ~/.claude/omni.db, never in the store)
# - deepwiki MCP + REPL (./dw, vendored from github:vic/dw incl. unpushed repl.js)
# - notebooklm MCP (npx, unpinned as on frodo) + notebooklm-pack
{ yen, inputs, lib, ... }:
let
  node = pkgs: lib.getExe pkgs.nodejs_24; # omni needs builtin node:sqlite
  claudeDir = config: "${config.home.homeDirectory}/.claude";
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

        # Same path as before: omni's own docs point here.
        home.file.".claude/omni" = {
          source = ./omni;
          recursive = true;
        };

        programs.claude-code.mcpServers = {
          omni = {
            type = "stdio";
            command = node pkgs;
            args = [
              "${claudeDir config}/omni/omni.js"
              "mcp"
            ];
            env.OMNI_DB = "${claudeDir config}/omni.db";
          };
          deepwiki = {
            type = "stdio";
            command = node pkgs;
            args = [ "${./dw}/mcp.js" ];
          };
        };
      };

    # Off the Stop hook: ingest peaks ~3.3 GB RSS, so run it on a capped timer.
    homeLinux =
      { config, pkgs, ... }:
      {
        systemd.user.services.omni-ingest = {
          Unit = {
            Description = "omni session graph ingest";
            ConditionACPower = true;
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${node pkgs} ${claudeDir config}/omni/omni.js ingest";
            Environment = [ "OMNI_DB=${claudeDir config}/omni.db" ];
            Nice = 19;
            CPUQuota = "50%";
            MemoryMax = "1G";
            IOSchedulingClass = "idle";
          };
        };
        systemd.user.timers.omni-ingest = {
          Unit.Description = "omni session graph ingest";
          Timer = {
            OnBootSec = "10min";
            OnUnitActiveSec = "30min";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
  };
}
