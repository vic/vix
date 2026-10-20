# vim vcs: jj.nvim with vic's <leader>j keys, hunk.nvim diff editor.
{ ren, ... }:
{
  ren.aspects.vim-jj = {
    at = ren.lib.when (s: builtins.elem "jj" (s.vim.features or [ ]));
    vim =
      { pkgs, ... }:
      {
        vim.extraPlugins.jj = {
          package = pkgs.vimPlugins.jj-nvim;
          setup = ''
            require("jj").setup({})
            local cmd = require("jj.cmd")
            local map = function(k, f, d) vim.keymap.set("n", k, f, { desc = d }) end
            map("<leader>ju", "<cmd>HauntTerm -t jjui jjui<CR>", "jjui")
            map("<leader>jd", cmd.describe, "JJ describe")
            map("<leader>je", cmd.edit, "JJ edit")
            map("<leader>jn", cmd.new, "JJ new")
            map("<leader>jj", cmd.status, "JJ status")
            map("<leader>ji", cmd.diff, "JJ diff")
            map("<leader>jq", cmd.squash, "JJ squash -i")
            map("<leader>gj", function() require("jj.picker").status() end, "JJ Picker status")
            map("<leader>gl", function() require("jj.picker").file_history() end, "JJ Picker file history")
            map("<leader>jl", function() cmd.log({ revisions = "all()" }) end, "JJ log")
            map("<leader>jt", function() cmd.j("tug"); cmd.log({}) end, "JJ tug")
          '';
        };
      };
  };

  ren.aspects.vim-hunk = {
    at = ren.lib.when (s: builtins.elem "hunk" (s.vim.features or [ ]));
    vim.vim.git.hunk-nvim.enable = true;
  };
}
