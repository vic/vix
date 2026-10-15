{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf.jj ];
  vic.nvf.jj.vim =
    { pkgs, ... }:
    {
      lazy.plugins."jj.nvim" = {
        package = pkgs.vimPlugins.jj-nvim;
      };

      # keymaps = [ ];
    };
}
