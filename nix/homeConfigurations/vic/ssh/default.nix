{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "10m";
    forwardAgent = true;
  };
  home.file = {
    ".ssh/id_rsa".source = "${config.dots}/ssh/id_rsa";
    ".ssh/id_rsa.pub".source = ./id_rsa.pub;
    ".ssh/google_compute_engine".source = "${config.dots}/ssh/google_compute_engine";
    ".ssh/google_compute_engine.pub".source = ./google_compute_engine.pub;
  };
}
