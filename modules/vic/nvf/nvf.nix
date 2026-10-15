{
  den,
  vic,
  ...
}:
{

  perSystem =
    { pkgs, ... }:
    let
      nvf = den.lib.nvf.package pkgs vic.nvf.neovim;
    in
    {
      packages.neovim = nvf { mine = true; };
    };

  vic.nvf.neovim =
    { mine }@ctx:
    den.lib.parametric.fixedTo ctx {
      includes = [ vic.nvf ];
      vim = {
        theme.enable = true;
        theme.name = "catppuccin";
        theme.style = if mine then "frappe" else "latte";
      };
    };

}
