{
  vic,
  den,
  vix,
  ...
}:
{
  vic.everywhere.includes = [ vic.editors ];
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
          pkgs.code-cursor
          pkgs.zed-editor
          pkgs.vscode
        ];
      };
  };
}
