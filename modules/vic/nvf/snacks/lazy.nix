{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf.lazy ];
  vic.nvf.lazy.vim =
    { pkgs, ... }:
    {
      lazy.plugins."lazy.nvim".package = pkgs.vimPlugins.lazy-nvim;
    };
}
