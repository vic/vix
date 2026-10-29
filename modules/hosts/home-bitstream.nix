# bitstream (vini): vic's lean headless home. No roles: no gui, no secrets, store-copied dotfiles.
{ yen, ... }:
{
  yen.home.bitstream = {
    user = yen.user.vic;
    system = yen.system.x86_64-linux;
  };

  # login shell is zsh (set by the host); load hm env, then hand interactive shells to fish.
  yen.aspects.bitstream = {
    at = yen.lib.all [
      yen.kinds.user
      (yen.lib.within yen.home.bitstream)
    ];
    homeManager = {
      programs.zsh.enable = true;
      programs.zsh.initContent = ''
        if [[ -o interactive && -z "$IN_NIX_SHELL" ]]; then
          exec fish -l
        fi
      '';
    };
  };
}
