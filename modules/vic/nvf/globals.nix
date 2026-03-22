{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf._.globals ];
  vic.nvf._.globals =
    { pkgs, ... }:
    {
      vim.extraPackages = [
        pkgs.ripgrep
        pkgs.fd
        pkgs.fzf
        pkgs.python3
        pkgs.nodejs
        pkgs.sqlite3
      ];

      vim.opts = {
        expandtab = true;
        tabstop = 2;
        shiftwidth = 2;
        wrap = false;
      };

    };
}
