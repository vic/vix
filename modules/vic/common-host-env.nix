{ vix, ... }:
let
  env-providers = with vix.vic.provides; [
    admin # vic is admin in all hosts
    ({ user, ... }: vix.autologin user)
    (_: vix.state-version) # for hm
    fonts
    browser
    hm-backup
    fish
    terminals
    cli-tui
    editors # for normal people not btw'ing.
    doom-btw
    vim-btw
    nix-btw
    dots
  ];
in
{
  # for all hosts that include vic.
  vix.vic._.common-host-env =
    { host, user }:
    {
      includes = map (f: f { inherit host user; }) env-providers;
    };
}
