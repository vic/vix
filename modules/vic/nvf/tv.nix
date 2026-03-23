{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf._.tv ];
  vic.nvf._.tv.vim =
    { pkgs, ... }:
    {
      lazy.plugins."tv.nvim" = {
        package = pkgs.vimPlugins.tv-nvim;
      };
    };
}
