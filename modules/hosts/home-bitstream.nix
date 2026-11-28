# bitstream (vini): vic's lean headless home.
{ yen, at, ... }:
{
  yen.home.bitstream = {
    user = yen.user.vic;
    system = yen.system.x86_64-linux;
  };

  yen.aspects.bitstream = {
    at = at.all [
      yen.kinds.user
      (at.under yen.home.bitstream)
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
