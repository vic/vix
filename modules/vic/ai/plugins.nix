# Claude Code plugin marketplaces, store-pinned: CC resolves plugins from these
# nix-store paths instead of cloning from GitHub at runtime.
{ inputs, vic, ... }:
let
  # marketplace name -> flake input (and its input url)
  marketplaces = {
    superpowers-extended-cc-marketplace = "github:pcvelz/superpowers";
    ponytail = "github:dietrichgebert/ponytail";
    mattpocock = "github:mattpocock/skills";
    diagram-design = "github:cathrynlavery/diagram-design";
    ui-ux-pro-max-skill = "github:nextlevelbuilder/ui-ux-pro-max-skill";
    claude-plugins-official = "github:anthropics/claude-plugins-official";
    # vic: pinned to the commit installed on frodo
    caveman = "github:JuliusBrussee/caveman/ef6050c5e1848b6880ff47c32ade1a608a64f85e";
  };
in
{
  flake-file.inputs = builtins.mapAttrs (_: url: {
    inherit url;
    flake = false;
  }) marketplaces;

  vic.ai.includes = [ vic.ai._.plugins ];
  vic.ai._.plugins.homeManager =
    { lib, pkgs, ... }:
    let
      # vic: caveman with vic's ultra-mode line (was a hand edit on frodo)
      srcOf =
        name:
        if name == "caveman" then
          pkgs.applyPatches {
            name = "caveman";
            src = inputs.caveman;
            patches = [ ./vic/caveman-ultra.patch ];
          }
        else
          inputs.${name};
    in
    {
      programs.claude-code.settings.enabledPlugins = {
        "superpowers-extended-cc@superpowers-extended-cc-marketplace" = true;
        "ponytail@ponytail" = true;
        "mattpocock-skills@mattpocock" = true;
        "diagram-design@diagram-design" = true;
        "ui-ux-pro-max@ui-ux-pro-max-skill" = true;
        "commit-commands@claude-plugins-official" = true;
        "skill-creator@claude-plugins-official" = true;
        "code-simplifier@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "caveman@caveman" = true;
      };

      # Written whole instead of via programs.claude-code.marketplaces: that option
      # can only express `directory` sources, but CC reserves the name
      # claude-plugins-official for a github source and otherwise appends it itself,
      # replacing HM's symlink and breaking the next activation. autoUpdate = false
      # stops CC's startup refresh from rewriting the file.
      home.file.".claude/plugins/known_marketplaces.json".source =
        (pkgs.formats.json { }).generate "claude-code-known-marketplaces.json"
          (
            lib.mapAttrs (name: url: {
              source =
                if name == "claude-plugins-official" then
                  {
                    source = "github";
                    repo = lib.removePrefix "github:" url;
                  }
                else
                  {
                    source = "directory";
                    path = "${srcOf name}";
                  };
              installLocation = "${srcOf name}";
              lastUpdated = "1970-01-01T00:00:00Z";
              autoUpdate = false;
            }) marketplaces
          );
    };
}
