# nvf: which-key with the helix preset.
{
  vim.binds.whichKey = {
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
