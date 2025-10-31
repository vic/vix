{ vix, ... }:
{
  vix.vic.provides.editors = _: {
    includes = [
      (vix.unfree [
        "cursor"
        "vscode"
      ])
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
