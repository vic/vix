{ pkgs, inputs, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  home.sessionVariables.EDITOR = "vim";

  programs.neovim.enable = true;
  programs.neovim.viAlias = false;
  programs.neovim.vimAlias = false;
  programs.neovim.withNodeJs = true;
  programs.neovim.extraPackages = with pkgs; [
    zig
    sqlite
    treefmt
  ];

  programs.nvf = {
    enable = true;
    settings = {
      imports = [ (import "${inputs.nvf}/configuration.nix" true) ];
    };
  };

}
