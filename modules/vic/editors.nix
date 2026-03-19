{ vic, ... }:
{
  vic.everywhere.includes = [ vic.editors ];
  vic.editors = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.code-cursor
          pkgs.zed-editor
          pkgs.vscode
        ];
      };
  };
}
