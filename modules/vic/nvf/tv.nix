{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf.tv ];
  vic.nvf.tv.vim =
    { pkgs, ... }:
    {
      lazy.plugins."tv.nvim" = {
        package = pkgs.vimPlugins.tv-nvim;
      };
    };
}
