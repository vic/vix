# vim ai: avante, codecompanion, copilot (as a blink source), CopilotChat.
{ yen, ... }:
{
  yen.aspects.vim-avante = {
    at = yen.helpers.vimHas "avante";
    nvf.vim = {
      assistant.avante-nvim.enable = true;
      # avante's rockspec deps; nvf's avante module omits them (require "avante" fails without)
      luaPackages = [
        "mega-cmdparse"
        "mega-logging"
      ];
    };
  };

  yen.aspects.vim-codecompanion = {
    at = yen.helpers.vimHas "codecompanion";
    # shortcut: nvf's action_palette.provider enum has no "snacks" (old config used it); default kept.
    nvf.vim.assistant.codecompanion-nvim.enable = true;
  };

  yen.aspects.vim-copilot = {
    at = yen.helpers.vimHas "copilot";
    unfree = yen.helpers.allowUnfree [ "copilot-language-server" ];
    nvf =
      { pkgs, ... }:
      {
        vim.assistant.copilot = {
          enable = true;
          setupOpts.panel.enabled = false; # completions come through blink-copilot
          setupOpts.suggestion.enabled = false;
          setupOpts.server = {
            type = "binary"; # nix-built server; copilot.lua would download one at startup
            custom_server_filepath = "${pkgs.copilot-language-server}/bin/copilot-language-server";
          };
        };
        vim.autocomplete.blink-cmp.sourcePlugins.copilot = {
          enable = true;
          package = pkgs.vimPlugins.blink-copilot;
          module = "blink-copilot";
        };
      };
  };

  yen.aspects.vim-copilot-chat = {
    at = yen.helpers.vimHas "copilot-chat";
    unfree = yen.helpers.allowUnfree [ "copilot-language-server" ]; # via copilot-lua
    nvf =
      { pkgs, ... }:
      {
        vim.startPlugins = [ pkgs.vimPlugins.plenary-nvim ];
        vim.extraPlugins.copilot-chat = {
          package = pkgs.vimPlugins.CopilotChat-nvim;
          setup = "require('CopilotChat').setup({})";
        };
      };
  };
}
