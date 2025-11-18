{ __findFile, ... }:
{
  den.default.includes = [
    <den/define-user>
    <my/nix-settings>
    <my/state-version>
    <vix/hostname>
  ];
}
