# vim langs: lsp + treesitter, languages (rust via rustaceanvim), completion, format, lint, diagnostics list.
{ vimFeature, ... }:
{
  ren.aspects.vim-lsp = {
    at = vimFeature "lsp";
    vim.vim = {
      lsp.enable = true;
      treesitter.enable = true;
      languages.enableTreesitter = true;
    };
  };

  ren.aspects.vim-lua = {
    at = vimFeature "lua";
    vim.vim.languages.lua.enable = true;
  };

  ren.aspects.vim-go = {
    at = vimFeature "go";
    vim.vim.languages.go.enable = true;
  };

  ren.aspects.vim-rust = {
    at = vimFeature "rust";
    vim.vim = {
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

  ren.aspects.vim-blink = {
    at = vimFeature "blink";
    vim.vim.autocomplete.blink-cmp = {
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

  ren.aspects.vim-conform = {
    at = vimFeature "conform";
    vim.vim.formatter.conform-nvim.enable = true;
  };

  ren.aspects.vim-nvim-lint = {
    at = vimFeature "nvim-lint";
    vim.vim.diagnostics.nvim-lint.enable = true;
  };

  ren.aspects.vim-trouble = {
    at = vimFeature "trouble";
    vim.vim.lsp.trouble.enable = true;
  };
}
