# this module configures my user over all my hosts.
{ __findFile, ... }:
{
  my.user = <den.lib.parametric> {
    includes = [
      <den/primary-user>
      (<den/user-shell> "fish")

      <vix/autologin>
      <vix/nix-index>
      <vix/nix-registry>
      <vix/vscode-server>

      <vic/browser>
      <vic/cli-tui>
      <vic/direnv>
      <vic/doom-btw>
      <vic/dots>
      <vic/editors> # for normal people not btw'ing.
      <vic/fish>
      <vic/fonts>
      <vic/git>
      <vic/hm-backup>
      <vic/jujutsu>
      <vic/nix-btw>
      <vic/secrets>
      <vic/terminals>
      <vic/vim-btw>
    ];
  };
}
