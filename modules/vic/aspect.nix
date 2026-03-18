{
  den,
  vic,
  vix,
  ...
}:
{
  den.aspects.vic = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")
      (den.provides.unfree [
        "cursor"
        "vscode"
        "anydesk"
        "copilot-language-server"
      ])
      vic.git
      vic.fish
      vic.nvim
      vic.direnv
      vic.dots
      vic.doom
      vic.secrets
      vic.ssh
      vic.jujutsu
      vic.apps
      vic.desktop-apps
      vic.rdesk
      vix.nix-index
      vix.nix-registry
      vix.vscode-server
    ];

    user =
      { pkgs, ... }:
      {
        description = "oeiuwq";
        packages = with pkgs.nerd-fonts; [
          victor-mono
          jetbrains-mono
          inconsolata
        ];
      };

  };
}
