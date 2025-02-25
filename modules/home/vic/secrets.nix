{
  inputs,
  config,
  ...
}:
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

  sops.secrets = {
    "hello" = { };
    "ssh/id_ed25519" = {
      format = "binary";
      sopsFile = ./secrets/ssh/vic_mordor;
    };
  };

  sops.templates = {
    "hello.toml".content = ''
      hello = "Wooo ${config.sops.placeholder.hello} Hoo";
    '';
  };

}
