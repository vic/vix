# nvf: jj plugin from nixpkgs.
{ pkgs, ... }:
{
  vim.lazy.plugins."jj.nvim".package = pkgs.vimPlugins.jj-nvim;
}
