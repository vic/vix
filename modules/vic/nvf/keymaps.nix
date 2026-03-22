{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf._.keys ];
  vic.nvf._.keys.vim.keymaps = [
    {
      key = "<leader><leader>";
      mode = [ "n" ];
      desc = "Smart Find Files";
      action = "function() Snacks.picker.smart() end";
      lua = true;
    }
    {
      key = "<leader>,";
      mode = [ "n" ];
      desc = "Buffers";
      action = "function() Snacks.picker.buffers() end";
      lua = true;
    }
    {
      key = "<leader>/";
      mode = [ "n" ];
      desc = "Grep";
      action = "function() Snacks.picker.grep() end";
      lua = true;
    }
    {
      key = "<leader>:";
      mode = [ "n" ];
      desc = "Command History";
      action = "function() Snacks.picker.command_history() end";
      lua = true;
    }
    {
      key = "<leader>n";
      mode = [ "n" ];
      desc = "Notification History";
      action = "function() Snacks.picker.notifications() end";
      lua = true;
    }
    {
      key = "<leader>e";
      mode = [ "n" ];
      desc = "File Explorer";
      action = "function() Snacks.explorer() end";
      lua = true;
    }
    {
      key = "<leader>fb";
      mode = [ "n" ];
      desc = "Buffers";
      action = "function() Snacks.picker.buffers() end";
      lua = true;
    }
    {
      key = "<leader>fc";
      mode = [ "n" ];
      desc = "Find Config File";
      action = "function() Snacks.picker.files({ cwd = vim.fn.stdpath(\"config\") }) end";
      lua = true;
    }
    {
      key = "<leader>ff";
      mode = [ "n" ];
      desc = "Find Files";
      action = "function() Snacks.picker.files() end";
      lua = true;
    }
    {
      key = "<leader>fg";
      mode = [ "n" ];
      desc = "Find Git Files";
      action = "function() Snacks.picker.git_files() end";
      lua = true;
    }
    {
      key = "<leader>fp";
      mode = [ "n" ];
      desc = "Projects";
      action = "function() Snacks.picker.projects() end";
      lua = true;
    }
    {
      key = "<leader>fr";
      mode = [ "n" ];
      desc = "Recent";
      action = "function() Snacks.picker.recent() end";
      lua = true;
    }
    {
      key = "<leader>gb";
      mode = [ "n" ];
      desc = "Git Branches";
      action = "function() Snacks.picker.git_branches() end";
      lua = true;
    }
    {
      key = "<leader>gl";
      mode = [ "n" ];
      desc = "Git Log";
      action = "function() Snacks.picker.git_log() end";
      lua = true;
    }
    {
      key = "<leader>gL";
      mode = [ "n" ];
      desc = "Git Log Line";
      action = "function() Snacks.picker.git_log_line() end";
      lua = true;
    }
    {
      key = "<leader>gs";
      mode = [ "n" ];
      desc = "Git Status";
      action = "function() Snacks.picker.git_status() end";
      lua = true;
    }
    {
      key = "<leader>gS";
      mode = [ "n" ];
      desc = "Git Stash";
      action = "function() Snacks.picker.git_stash() end";
      lua = true;
    }
    {
      key = "<leader>gd";
      mode = [ "n" ];
      desc = "Git Diff (Hunks)";
      action = "function() Snacks.picker.git_diff() end";
      lua = true;
    }
    {
      key = "<leader>gf";
      mode = [ "n" ];
      desc = "Git Log File";
      action = "function() Snacks.picker.git_log_file() end";
      lua = true;
    }
    {
      key = "<leader>sb";
      mode = [ "n" ];
      desc = "Buffer Lines";
      action = "function() Snacks.picker.lines() end";
      lua = true;
    }
    {
      key = "<leader>sB";
      mode = [ "n" ];
      desc = "Grep Open Buffers";
      action = "function() Snacks.picker.grep_buffers() end";
      lua = true;
    }
    {
      key = "<leader>sg";
      mode = [ "n" ];
      desc = "Grep";
      action = "function() Snacks.picker.grep() end";
      lua = true;
    }
    {
      key = "<leader>sw";
      mode = [
        "n"
        "x"
      ];
      desc = "Visual selection or word";
      action = "function() Snacks.picker.grep_word() end";
      lua = true;
    }
    {
      key = "<leader>s\"";
      mode = [ "n" ];
      desc = "Registers";
      action = "function() Snacks.picker.registers() end";
      lua = true;
    }
    {
      key = "<leader>s/";
      mode = [ "n" ];
      desc = "Search History";
      action = "function() Snacks.picker.search_history() end";
      lua = true;
    }
    {
      key = "<leader>sa";
      mode = [ "n" ];
      desc = "Autocmds";
      action = "function() Snacks.picker.autocmds() end";
      lua = true;
    }
    {
      key = "<leader>sb";
      mode = [ "n" ];
      desc = "Buffer Lines";
      action = "function() Snacks.picker.lines() end";
      lua = true;
    }
    {
      key = "<leader>sc";
      mode = [ "n" ];
      desc = "Command History";
      action = "function() Snacks.picker.command_history() end";
      lua = true;
    }
    {
      key = "<leader>sC";
      mode = [ "n" ];
      desc = "Commands";
      action = "function() Snacks.picker.commands() end";
      lua = true;
    }
    {
      key = "<leader>sd";
      mode = [ "n" ];
      desc = "Diagnostics";
      action = "function() Snacks.picker.diagnostics() end";
      lua = true;
    }
    {
      key = "<leader>sD";
      mode = [ "n" ];
      desc = "Buffer Diagnostics";
      action = "function() Snacks.picker.diagnostics_buffer() end";
      lua = true;
    }
    {
      key = "<leader>sh";
      mode = [ "n" ];
      desc = "Help Pages";
      action = "function() Snacks.picker.help() end";
      lua = true;
    }
    {
      key = "<leader>sH";
      mode = [ "n" ];
      desc = "Highlights";
      action = "function() Snacks.picker.highlights() end";
      lua = true;
    }
    {
      key = "<leader>si";
      mode = [ "n" ];
      desc = "Icons";
      action = "function() Snacks.picker.icons() end";
      lua = true;
    }
    {
      key = "<leader>sj";
      mode = [ "n" ];
      desc = "Jumps";
      action = "function() Snacks.picker.jumps() end";
      lua = true;
    }
    {
      key = "<leader>sk";
      mode = [ "n" ];
      desc = "Keymaps";
      action = "function() Snacks.picker.keymaps() end";
      lua = true;
    }
    {
      key = "<leader>sl";
      mode = [ "n" ];
      desc = "Location List";
      action = "function() Snacks.picker.loclist() end";
      lua = true;
    }
    {
      key = "<leader>sm";
      mode = [ "n" ];
      desc = "Marks";
      action = "function() Snacks.picker.marks() end";
      lua = true;
    }
    {
      key = "<leader>sM";
      mode = [ "n" ];
      desc = "Man Pages";
      action = "function() Snacks.picker.man() end";
      lua = true;
    }
    {
      key = "<leader>sp";
      mode = [ "n" ];
      desc = "Search for Plugin Spec";
      action = "function() Snacks.picker.lazy() end";
      lua = true;
    }
    {
      key = "<leader>sq";
      mode = [ "n" ];
      desc = "Quickfix List";
      action = "function() Snacks.picker.qflist() end";
      lua = true;
    }
    {
      key = "<leader>sR";
      mode = [ "n" ];
      desc = "Resume";
      action = "function() Snacks.picker.resume() end";
      lua = true;
    }
    {
      key = "<leader>su";
      mode = [ "n" ];
      desc = "Undo History";
      action = "function() Snacks.picker.undo() end";
      lua = true;
    }
    {
      key = "<leader>uC";
      mode = [ "n" ];
      desc = "Colorschemes";
      action = "function() Snacks.picker.colorschemes() end";
      lua = true;
    }
    {
      key = "gd";
      mode = [ "n" ];
      desc = "Goto Definition";
      action = "function() Snacks.picker.lsp_definitions() end";
      lua = true;
    }
    {
      key = "gD";
      mode = [ "n" ];
      desc = "Goto Declaration";
      action = "function() Snacks.picker.lsp_declarations() end";
      lua = true;
    }
    {
      key = "gr";
      mode = [ "n" ];
      desc = "References";
      action = "function() Snacks.picker.lsp_references() end";
      nowait = true;
      lua = true;
    }
    {
      key = "gI";
      mode = [ "n" ];
      desc = "Goto Implementation";
      action = "function() Snacks.picker.lsp_implementations() end";
      lua = true;
    }
    {
      key = "gy";
      mode = [ "n" ];
      desc = "Goto T[y]pe Definition";
      action = "function() Snacks.picker.lsp_type_definitions() end";
      lua = true;
    }
    {
      key = "<leader>ss";
      mode = [ "n" ];
      desc = "LSP Symbols";
      action = "function() Snacks.picker.lsp_symbols() end";
      lua = true;
    }
    {
      key = "<leader>sS";
      mode = [ "n" ];
      desc = "LSP Workspace Symbols";
      action = "function() Snacks.picker.lsp_workspace_symbols() end";
      lua = true;
    }
    {
      key = "<leader>z";
      mode = [ "n" ];
      desc = "Toggle Zen Mode";
      action = "function() Snacks.zen() end";
      lua = true;
    }
    {
      key = "<leader>Z";
      mode = [ "n" ];
      desc = "Toggle Zoom";
      action = "function() Snacks.zen.zoom() end";
      lua = true;
    }
    {
      key = "<leader>.";
      mode = [ "n" ];
      desc = "Toggle Scratch Buffer";
      action = "function() Snacks.scratch() end";
      lua = true;
    }
    {
      key = "<leader>S";
      mode = [ "n" ];
      desc = "Select Scratch Buffer";
      action = "function() Snacks.scratch.select() end";
      lua = true;
    }
    {
      key = "<leader>n";
      mode = [ "n" ];
      desc = "Notification History";
      action = "function() Snacks.notifier.show_history() end";
      lua = true;
    }
    {
      key = "<leader>bd";
      mode = [ "n" ];
      desc = "Delete Buffer";
      action = "function() Snacks.bufdelete() end";
      lua = true;
    }
    {
      key = "<leader>cR";
      mode = [ "n" ];
      desc = "Rename File";
      action = "function() Snacks.rename.rename_file() end";
      lua = true;
    }
    {
      key = "<leader>gB";
      mode = [
        "n"
        "v"
      ];
      desc = "Git Browse";
      action = "function() Snacks.gitbrowse() end";
      lua = true;
    }
    {
      key = "<leader>gg";
      mode = [ "n" ];
      desc = "Lazygit";
      action = "function() Snacks.lazygit() end";
      lua = true;
    }
    {
      key = "<leader>un";
      mode = [ "n" ];
      desc = "Dismiss All Notifications";
      action = "function() Snacks.notifier.hide() end";
      lua = true;
    }
    # { key = "<c-/"; mode = [ "n" ]; desc = "Toggle Terminal"; action = "function() Snacks.terminal() end"; lua = true; }
    {
      key = "<c-_>";
      mode = [ "n" ];
      desc = "which_key_ignore";
      action = "function() Snacks.terminal() end";
      lua = true;
    }
    {
      key = "]]";
      mode = [
        "n"
        "t"
      ];
      desc = "Next Reference";
      action = "function() Snacks.words.jump(vim.v.count1) end";
      lua = true;
    }
    {
      key = "[[";
      mode = [
        "n"
        "t"
      ];
      desc = "Prev Reference";
      action = "function() Snacks.words.jump(-vim.v.count1) end";
      lua = true;
    }
    {
      key = "<leader>N";
      mode = [ "n" ];
      desc = "Neovim News";
      action = "function() Snacks.win({ file = vim.api.nvim_get_runtime_file(\"doc/news.txt\", false)[1], width = 0.6, height = 0.6, wo = { spell = false, wrap = false, signcolumn = \"yes\", statuscolumn = \" \" , conceallevel = 3, }, }) end";
      lua = true;
    }
    {
      key = "<leader>Q";
      mode = [ "n" ];
      desc = "Quit";
      action = "<cmd>qa!<CR>";
      lua = false;
    }
  ];
}
