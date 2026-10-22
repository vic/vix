# vim moonbit: moonbit.nvim (not in nixpkgs; pinned upstream rev).
{ ren, ... }:
{
  ren.aspects.vim-moonbit = {
    at = ren.lib.when (s: builtins.elem "moonbit" (s.vim.features or [ ]));
    vim =
      { pkgs, ... }:
      {
        vim.startPlugins = [ pkgs.vimPlugins.plenary-nvim ];
        vim.extraPlugins.moonbit = {
          package = pkgs.vimUtils.buildVimPlugin {
            pname = "moonbit.nvim";
            version = "unstable-907c824";
            dependencies = [ pkgs.vimPlugins.plenary-nvim ];
            nvimSkipModules = [
              "neotest-moonbit" # optional neotest adapter
              "neotest-moonbit.json"
              "moonbit.mooncakes.completion.blink" # needs blink.cmp at require time
            ];
            src = pkgs.fetchFromGitHub {
              owner = "moonbit-community";
              repo = "moonbit.nvim";
              rev = "907c8240d3d2f96fa8e8569c73973e8604a7b1e6";
              hash = "sha256-jDJ1ACAT86oeyimQ+/k9rEHSAqoJe7u8hpcW3jQoGjk=";
            };
          };
          setup = ''
            require("moonbit").setup({
              mooncakes = { virtual_text = true, use_local = true },
              treesitter = { enabled = true, auto_install = false },
            })
          '';
        };
      };
  };
}
