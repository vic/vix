# nvf: tv plugin from nixpkgs.
{ pkgs, ... }:
{
  vim.lazy.plugins."tv.nvim".package = pkgs.vimPlugins.tv-nvim;
}
