# vim plugins: plain plugins on the runtime path (lazy.nvim, tv.nvim, tv.vim).
{ ren, ... }:
{
  ren.aspects.vim-lazy = {
    at = ren.lib.when (s: builtins.elem "lazy" (s.vim.features or [ ]));
    vim = { pkgs, ... }: { vim.startPlugins = [ pkgs.vimPlugins.lazy-nvim ]; };
  };

  ren.aspects.vim-tv = {
    at = ren.lib.when (s: builtins.elem "tv" (s.vim.features or [ ]));
    vim = { pkgs, ... }: { vim.startPlugins = [ pkgs.vimPlugins.tv-nvim ]; };
  };

  ren.aspects.vim-tv-vim = {
    at = ren.lib.when (s: builtins.elem "tv-vim" (s.vim.features or [ ]));
    vim =
      { pkgs, ... }:
      {
        vim.startPlugins = [
          (pkgs.vimUtils.buildVimPlugin {
            pname = "tv.vim";
            version = "unstable-88163c4";
            src = pkgs.fetchFromGitHub {
              owner = "prabirshrestha";
              repo = "tv.vim";
              rev = "88163c4cfd72e580452a72af46282d707abc186b";
              hash = "sha256-OUVrExrxBNjjZVpNJNFxJAyeyBS5ySLhAPZUSIeQ6uI=";
            };
          })
        ];
      };
  };
}
