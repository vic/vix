# vim ai: avante, codecompanion, copilot (as a blink source), CopilotChat.
{ vimFeature, allowUnfree, ... }:
{
  ren.aspects.vim-avante = {
    at = vimFeature "avante";
    vim.vim = {
      assistant.avante-nvim.enable = true;
      # avante's rockspec deps; nvf's avante module omits them (require "avante" fails without)
      luaPackages = [
        "mega-cmdparse"
        "mega-logging"
      ];
    };
  };

  ren.aspects.vim-codecompanion = {
    at = vimFeature "codecompanion";
    # shortcut: nvf's action_palette.provider enum has no "snacks" (old config used it); default kept.
    vim.vim.assistant.codecompanion-nvim.enable = true;
  };

  ren.aspects.vim-copilot = {
    at = vimFeature "copilot";
    unfree = allowUnfree [ "copilot-language-server" ];
    vim =
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

  ren.aspects.vim-copilot-chat = {
    at = vimFeature "copilot-chat";
    unfree = allowUnfree [ "copilot-language-server" ]; # via copilot-lua
    vim =
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
