{ inputs, config, lib, ... }:
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
      sopsFile = ./secrets/ssh/id_ed25519;
    };
  };

  sops.templates = {
    "hello.toml".content = ''
      hello = "Wooo ${config.sops.placeholder.hello} Hoo";
    '';
  };

  home.file.".ssh/id_ed25519.pub".source = ./secrets/ssh/id_ed25519.pub;
  home.activation.link_ssh_id = lib.hm.dag.entryAfter ["writeBoundary"] ''
  run ln -s "${config.sops.secrets."ssh/id_ed25519".path}" $HOME/.ssh/id_ed25519
  '';
}
