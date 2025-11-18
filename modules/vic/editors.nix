{ __findFile, ... }:
{
  vic.editors = {
    includes = [
      (<den/unfree> [ "cursor" "vscode" ])
    ];

    homeManager =
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
