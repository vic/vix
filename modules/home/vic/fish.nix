{inputs, ...}: {

  programs.fish.enable = true;
  home.file.".config/fish/conf.d/init-leader.fish".source =
    "${inputs.cli-leader.outPath}/assets/leader.fish.sh";

}