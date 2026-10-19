# nvf: vic's neovim, built with nvf and emitted as packages.neovim on every system.
{
  ren,
  inputs,
  pkgsFor,
  ...
}:
let
  mine = true;
  # Parity with the old Den build: Den silently dropped _globals _mini _which-key _keys _tv _lazy
  # (parametric fn/include quirks), so the old drv has only theme, jj and snacks. Add them here to enable.
  modules = [
    ./_jj.nix
    (import ./_snacks.nix mine)
    {
      vim.theme = {
        enable = true;
        name = "catppuccin";
        style = if mine then "frappe" else "latte";
      };
    }
  ];
in
{
  ren.aspects.vic-neovim = {
    at = ren.kinds.system;
    packages =
      { system, ... }:
      {
        neovim =
          (inputs.nvf.lib.neovimConfiguration {
            pkgs = pkgsFor system;
            inherit modules;
          }).neovim;
      };
  };
}
