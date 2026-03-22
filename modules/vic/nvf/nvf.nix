{
  den,
  vic,
  ...
}:
{

  perSystem =
    { pkgs, ... }:
    let
      nvf = den.lib.nvf.package pkgs vic.nvf._.neovim;
    in
    {
      packages.neovim = nvf { mine = true; };
    };

  vic.nvf._.neovim =
    { mine }:
    {
      includes = [ vic.nvf ];
      vim =
        { ... }:
        {
          theme.enable = true;
          theme.name = "catppuccin";
          theme.style = if mine then "frappe" else "latte";
        };
    };

}
