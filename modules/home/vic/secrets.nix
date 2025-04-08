{
  inputs,
  config,
  pkgs,
  ...
}:
{

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = [ pkgs.sops ];

  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    age.sshKeyPaths = [ ];
    age.generateKey = false;
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = true;

    secrets = {
      "hello" = { };
      "ssh/id_ed25519" = {
        format = "binary";
        sopsFile = ./secrets/mordor;
      };
      "ssh/sops_ssh_config" = {
        format = "binary";
        sopsFile = ./secrets/ssh-conf;
      };
    };

    templates = {
      "hello.toml".content = ''
        hello = "Wooo ${config.sops.placeholder.hello} Hoo";
      '';
    };
  };

}
