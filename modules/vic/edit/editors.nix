{
  den,
  vix,
  ...
}:
{
  vic.editors = {

    includes = [
      vix.vscode-server
      (den.provides.unfree [
        "cursor"
        "vscode"
      ])
    ];

    hm =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.helix
          pkgs.lapce
          pkgs.flow-control
          pkgs.code-cursor
          pkgs.zed-editor
          pkgs.vscode
        ];
      };
  };
}
