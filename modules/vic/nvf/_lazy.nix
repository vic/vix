# nvf: lazy plugin from nixpkgs.
{ pkgs, ... }:
{
  vim.lazy.plugins."lazy.nvim".package = pkgs.vimPlugins.lazy-nvim;
}
