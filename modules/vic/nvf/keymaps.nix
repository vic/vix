{ vic, ... }:
{
  vic.nvf.includes = [ vic.nvf._.keys ];
  vic.nvf._.keys.vim.keymaps = [
    {
      key = "<leader><leader>";
      mode = [ "n" ];
      desc = "Smart find";
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
      desc = "Command history";
      action = "function() Snacks.picker.command_history() end";
      lua = true;
    }
  ];
}
