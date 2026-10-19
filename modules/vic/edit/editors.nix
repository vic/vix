# editors: gui editors, vscode vim hook, vscode-server and the unfree editors.
{
  ren,
  vicAt,
  inputs,
  allowUnfree,
  ...
}:
let
  at = ren.lib.and [
    vicAt.full
    vicAt.desktop
  ];
in
{
  ren.aspects.vic-vscode-server.homeManager =
    { pkgs, ... }:
    {
      imports = [ "${inputs.vscode-server}/modules/vscode-server/home.nix" ];

      services.vscode-server = {
        enable = true;
        nodejsPackage = pkgs.nodejs_latest;
        extraRuntimeDependencies = with pkgs; [
          curl
          wget
        ];
      };
    };

  ren.aspects.vic-editors = {
    inherit at;
    includes = [ ren.aspects.vic-vscode-server ];
    unfree = allowUnfree [
      "cursor"
      "vscode"
    ];
    homeManager =
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
        home.file.".config/fish/conf.d/vscode-vim.fish".text = ''
          if test "$VSCODE_INJECTION" = "1"
            set -x VISUAL code
          end
        '';
      };
  };
}
