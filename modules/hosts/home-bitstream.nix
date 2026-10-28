# bitstream (vini): vic's lean headless home. No roles: no gui, no secrets, store-copied dotfiles.
{ sven, ... }:
{
  sven.home.bitstream = {
    user = sven.user.vic;
    system = sven.system.x86_64-linux;
  };

  # login shell is zsh (set by the host); load hm env, then hand interactive shells to fish.
  sven.aspects.bitstream = {
    at = sven.lib.all [
      sven.kinds.user
      (sven.lib.within sven.home.bitstream)
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
