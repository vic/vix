# Claude Code: a read-only declarative settings.json. CC cannot mutate it at
# runtime; change config here, not in the TUI. Features give permission rules on
# the `claude-allow` sink; ai-claude writes them once.
# settings.json keys that need no pkgs are layers on the `claude` sink: a higher
# rank wins per key, equal ranks must agree (rank 0 here, rank 1 vic/settings.nix).
{
  sven,
  inputs,
  lib,
  ...
}:
let
  # two layers disagree where a key they both set holds different leaves
  clash =
    a: b:
    lib.any (
      n: if lib.isAttrs a.${n} && lib.isAttrs b.${n} then clash a.${n} b.${n} else a.${n} != b.${n}
    ) (lib.attrNames (lib.intersectAttrs a b));

  # element: { rank; set; }; low ranks first, so a higher rank overwrites per key
  layers = {
    name = "layers";
    __functor =
      _: es:
      let
        sorted = lib.sort (a: b: a.value.rank < b.value.rank) es;
      in
      {
        value = lib.foldl' (acc: e: lib.recursiveUpdate acc e.value.set) { } sorted;
        errors = lib.concatLists (
          lib.imap0 (
            i: a:
            lib.concatMap (
              b:
              lib.optional (a.value.rank == b.value.rank && clash a.value.set b.value.set) {
                error = "claude: two layers of rank ${toString a.value.rank} disagree";
                from = a.from.id;
                code = "claude-layers";
              }
            ) (lib.drop (i + 1) sorted)
          ) sorted
        );
      };
  };
in
{
  sven.kinds.user.sinks.claude = {
    reduce = layers;
    homeManager =
      { claude, ... }:
      {
        programs.claude-code.settings = claude;
      };
  };

  sven.aspects.ai-claude = {
    at = sven.aspects.vic-headless;
    git-ignores = [ ".claude" ];
    claude =
      { claude-allow, ... }:
      {
        rank = 0;
        set = {
          theme = "auto";
          verbose = true;
          effortLevel = "xhigh";
          remoteControlAtStartup = false;
          includeCoAuthoredBy = false;
          gitAttribution = false;
          attribution = {
            commit = "";
            pr = "";
          };
          autoMemoryDirectory = "~/.claude/memory";
          teammateMode = "in-process";
          permissions.allow = claude-allow;

          env = {
            CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
            ENABLE_TOOL_SEARCH = "auto:5";
          };
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.nodejs_22
          pkgs.jq # budget.sh
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          # CC's Bash sandbox
          pkgs.socat
          pkgs.bubblewrap
        ];

        programs.claude-code = {
          enable = true;
          package = (sven.helpers.perSystem pkgs inputs.llm-agents).packages.claude-code;
          enableMcpIntegration = true;

          lspServers.nix = {
            command = lib.getExe pkgs.nil;
            extensionToLanguage.".nix" = "nix";
          };
        };
      };
  };
}
