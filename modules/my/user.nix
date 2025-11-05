# this module configures my user over all my hosts.
{ __findFile, ... }:
{
  my.user.__functor = <den>.lib.parametric.atLeast;
  my.user.includes = [
    <den/primary-user>
    (<den/user-shell> "fish")
    <vix/autologin>
    <vic/fonts>
    <vic/browser>
    <vic/hm-backup>
    <vic/fish>
    <vic/terminals>
    <vic/cli-tui>
    <vic/editors> # for normal people not btw'ing.
    <vic/doom-btw>
    <vic/vim-btw>
    <vic/nix-btw>
    <vic/dots>
    <vic/secrets>
    <vic/jujutsu>
    <vic/git>
    <vic/direnv>
    (x: builtins.trace (builtins.attrNames x) { })
    ({ OS, HM, user, ... }: <vix/nix-index>)
    ({ OS, HM, user, ... }: <vix/nix-registry>)
    ({ OS, HM, user, ... }: <vix/vscode-server>)
  ];
}
