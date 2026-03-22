{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf._.lazy ];
  vic.nvf._.lazy.vim =
    { pkgs, ... }:
    {
      lazy.plugins."lazy.nvim".package = pkgs.vimPlugins.lazy-nvim;
    };
}
