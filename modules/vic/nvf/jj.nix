{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf._.jj ];
  vic.nvf._.jj.vim =
    { pkgs, ... }:
    {
      lazy.plugins."jj.nvim" = {
        package = pkgs.vimPlugins.jj-nvim;
      };

      # keymaps = [ ];
    };
}
