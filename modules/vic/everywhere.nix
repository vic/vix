{
  den,
  vix,
  vic,
  ...
}:
{
  den.aspects.vic.includes = [ vic.everywhere ];
  vic.everywhere = {
    includes = [
      den.provides.primary-user

      (den.provides.user-shell "fish")
      (den.provides.unfree [
        "cursor"
        "vscode"
        "anydesk"
        "copilot-language-server"
      ])

      vix.nix-index
      vix.nix-registry
      vix.vscode-server
    ];
  };
}
