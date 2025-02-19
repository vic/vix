{ lib, ... }:
with lib;
{
  launcher = mkOption {
    type = types.str;
    default = "A-f1";
    description = "Key to open the launcher";
  };
  close-app = mkOption {
    type = types.str;
    default = "A-f4";
    description = "Key to close the current app";
  };
  new-tab = mkOption {
    type = types.str;
    default = "C-t";
    description = "Key to create a tab new";
  };
  close-tab = mkOption {
    type = types.str;
    default = "C-w";
    description = "Key to close the current tab";
  };
  next-app = mkOption {
    type = types.str;
    default = "G-tab";
    description = "Key to switch to the next app";
  };
  prev-app = mkOption {
    type = types.str;
    default = "G-S-tab";
    description = "Key to switch to the previous app";
  };
  next-window-in-group = mkOption {
    type = types.str;
    default = "G-`";
    description = "Key to switch to the next window in the current group";
  };
  next-desktop = mkOption {
    type = types.str;
    default = "M-tab";
    description = "Key to switch to the next desktop";
  };
  prev-desktop = mkOption {
    type = types.str;
    default = "M-S-tab";
    description = "Key to switch to the previous desktop";
  };
  copy = mkOption {
    type = types.str;
    default = "C-insert";
    description = "Key to copy";
  };
  paste = mkOption {
    type = types.str;
    default = "S-insert";
    description = "Key to paste";
  };
  cut = mkOption {
    type = types.str;
    default = "S-delete";
    description = "Key to cut";
  };
  switch-tab-n-prefix = mkOption {
    type = types.str;
    default = "A";
    description = "Key to switch to the nth tab. Modifier without -";
  };
  beginning-of-line = mkOption {
    type = types.str;
    default = "home";
    description = "Key to go to the beginning of the line";
  };
  end-of-line = mkOption {
    type = types.str;
    default = "end";
    description = "Key to go to the end of the line";
  };
}
