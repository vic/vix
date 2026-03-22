{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf._.which-key ];

  vic.nvf._.which-key.vim.binds.whichKey = {
    enable = true;
    setupOpts = {
      delay = 550;
      preset = "helix";
      keys = {
        scroll_up = "<c-p>";
        scroll_down = "<c-n>";
      };
    };
  };

}
