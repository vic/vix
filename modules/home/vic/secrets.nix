{ inputs, config, ... }:
{

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    age.sshKeyPaths = [ ];
    age.generateKey = false;
    defaultSopsFile = ./secrets.yaml;

  };

  sops.secrets =
    let
      vic-owned = {
        mode = "0400";
        owner = "vic";
      };
    in
    {
      "hello" = { };
    };

}
