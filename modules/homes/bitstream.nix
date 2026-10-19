# bitstream (vini): vic's lean headless home. No roles: no gui, no secrets, store-copied dotfiles.
{ ren, ... }:
{
  ren.home.bitstream = {
    user = ren.user.vic;
    system = ren.system.x86_64-linux;
  };

  # login shell is zsh (set by the host); load hm env, then hand interactive shells to fish.
  ren.aspects.bitstream = {
    at = ren.lib.and [
      ren.kinds.user
      (ren.lib.within ren.home.bitstream)
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
