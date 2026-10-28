# vim langs: lsp + treesitter, languages (rust via rustaceanvim), completion, format, lint, diagnostics list.
{ sven, ... }:
{
  sven.aspects.vim-lsp = {
    at = sven.helpers.vimHas "lsp";
    nvf.vim = {
      lsp.enable = true;
      treesitter.enable = true;
      languages.enableTreesitter = true;
    };
  };

  sven.aspects.vim-lua = {
    at = sven.helpers.vimHas "lua";
    nvf.vim.languages.lua.enable = true;
  };

  sven.aspects.vim-go = {
    at = sven.helpers.vimHas "go";
    nvf.vim.languages.go.enable = true;
  };

  sven.aspects.vim-rust = {
    at = sven.helpers.vimHas "rust";
    nvf.vim = {
      languages.rust = {
        enable = true;
        lsp.enable = false; # rustaceanvim runs its own rust-analyzer
        extensions.rustaceanvim.enable = true;
      };
      luaConfigRC.rust-keys = ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "rust",
          callback = function(ev)
            local o = { silent = true, buffer = ev.buf }
            vim.keymap.set("n", "<leader>a", function() vim.cmd.RustLsp("codeAction") end, o)
            vim.keymap.set("n", "K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, o)
          end,
        })
      '';
    };
  };

  sven.aspects.vim-blink = {
    at = sven.helpers.vimHas "blink";
    nvf.vim.autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      setupOpts = {
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        fuzzy.implementation = "prefer_rust_with_warning";
        cmdline.completion.menu.auto_show = true;
      };
    };
  };

  sven.aspects.vim-conform = {
    at = sven.helpers.vimHas "conform";
    nvf.vim.formatter.conform-nvim.enable = true;
  };

  sven.aspects.vim-nvim-lint = {
    at = sven.helpers.vimHas "nvim-lint";
    nvf.vim.diagnostics.nvim-lint.enable = true;
  };

  sven.aspects.vim-trouble = {
    at = sven.helpers.vimHas "trouble";
    nvf.vim.lsp.trouble.enable = true;
  };
}
