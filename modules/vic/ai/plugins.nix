# Claude Code plugin marketplaces, store-pinned: CC resolves plugins from these
# nix-store paths instead of cloning from GitHub at runtime.
{
  inputs,
  ren,
  ...
}:
let
  # marketplace name -> flake input (and its input url)
  marketplaces = {
    superpowers-extended-cc-marketplace = "github:pcvelz/superpowers";
    ponytail = "github:dietrichgebert/ponytail";
    mattpocock = "github:mattpocock/skills";
    diagram-design = "github:cathrynlavery/diagram-design";
    ui-ux-pro-max-skill = "github:nextlevelbuilder/ui-ux-pro-max-skill";
    claude-plugins-official = "github:anthropics/claude-plugins-official";
    caveman = "github:JuliusBrussee/caveman";
  };
  # flake inputs of the marketplaces, pinned
  pinned = {
    superpowers-extended-cc-marketplace = "github:pcvelz/superpowers/cb12f4fdfcd31e2c76b06cc2b39dc21986b97b0a";
    ponytail = "github:dietrichgebert/ponytail/2961b52fc1fe6a5a87c7a959a79512e5c2f3ffe5";
    mattpocock = "github:mattpocock/skills/49dd158d1076134a641b33efb035946536778336";
    diagram-design = "github:cathrynlavery/diagram-design/657c71d199a5bc07c61bb2071f14175024986442";
    ui-ux-pro-max-skill = "github:nextlevelbuilder/ui-ux-pro-max-skill/7246805992a42b7bba37d4cac83b01416f0c6c44";
    claude-plugins-official = "github:anthropics/claude-plugins-official/f359d43b406057f1a8cdbc4ea93b827642c162e6";
    caveman = "github:JuliusBrussee/caveman/d262ab3882952a59312ff3537cd86d894523c5ab";
  };
in
{

  ren.aspects.ai-plugins = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      builtins.mapAttrs (_: url: {
        inherit url;
        flake = false;
      }) pinned;
    homeManager =
      { lib, pkgs, ... }:
      let
        srcOf = name: inputs.${name};
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
  };
}
