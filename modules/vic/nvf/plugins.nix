# vim plugins: plain plugins on the runtime path (lazy.nvim, tv.nvim, tv.vim).
{ yen, ... }:
{
  yen.aspects.vim-lazy = {
    at = yen.helpers.vimHas "lazy";
    nvf = { pkgs, ... }: { vim.startPlugins = [ pkgs.vimPlugins.lazy-nvim ]; };
  };

  yen.aspects.vim-tv = {
    at = yen.helpers.vimHas "tv";
    nvf = { pkgs, ... }: { vim.startPlugins = [ pkgs.vimPlugins.tv-nvim ]; };
  };

  yen.aspects.vim-tv-vim = {
    at = yen.helpers.vimHas "tv-vim";
    nvf =
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
