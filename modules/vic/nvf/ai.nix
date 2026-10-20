# vim ai: avante, codecompanion, copilot (as a blink source), CopilotChat.
{ ren, ... }:
let
  vix = ren.helpers;
in
{
  ren.aspects.vim-avante = {
    at = ren.lib.when (s: builtins.elem "avante" (s.vim.features or [ ]));
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
    at = ren.lib.when (s: builtins.elem "codecompanion" (s.vim.features or [ ]));
    # shortcut: nvf's action_palette.provider enum has no "snacks" (old config used it); default kept.
    vim.vim.assistant.codecompanion-nvim.enable = true;
  };

  ren.aspects.vim-copilot = {
    at = ren.lib.when (s: builtins.elem "copilot" (s.vim.features or [ ]));
    unfree = vix.allowUnfree [ "copilot-language-server" ];
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
    at = ren.lib.when (s: builtins.elem "copilot-chat" (s.vim.features or [ ]));
    unfree = vix.allowUnfree [ "copilot-language-server" ]; # via copilot-lua
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
