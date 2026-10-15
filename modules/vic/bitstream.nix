{ vic, ... }:
{
  # vini: headless and lean. No sops (nor anything reading its secrets), no GUI apps or settings.
  den.aspects."vic@bitstream".excludes = [
    vic.secrets
    vic.sec-ops
    vic.ssh
    vic.doom
    vic.browsers
    vic.editors
    vic.terminals
    vic.desktop-tools
    vic.gui-dots
    vic.nvim-gui
    vic.ai.browser-tools
  ];

  # login shell is zsh (set by the host); load hm env, then hand interactive shells to fish.
  den.aspects."vic@bitstream".homeManager = {
    vic.liveDots = false;
    programs.zsh.enable = true;
    programs.zsh.initContent = ''
      if [[ -o interactive && -z "$IN_NIX_SHELL" ]]; then
        exec fish -l
      fi
    '';
  };
}
