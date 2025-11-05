{ __findFile, ... }:
{
  den.default.includes = [
    <my/nix-settings>
    <my/state-version>
    <den/define-user>
    <vix/hostname>
  ];
}
