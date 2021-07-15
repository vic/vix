{ config, pkgs, ... }: {

  system.activationScripts.diffClosures.text = ''
    echo "new configuration diff" >&2
    $DRY_RUN_CMD ${pkgs.nixUnstable}/bin/nix store \
        --experimental-features 'nix-command' \
        diff-closures /run/current-system "$systemConfig" \
        | sed -e 's/^/[diff]\t/' >&2
  '';

  system.activationScripts.preActivation.text =
    config.system.activationScripts.diffClosures.text;

}
