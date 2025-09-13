{ inputs, ... }:
{

  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";

  flake.modules.homeManager.vic =
    {
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
          "groq_api_key" = { };
          "gemini_api_key" = { };
          "copilot_api_key" = { };
          "anthropic_api_key" = { };
          "edge.token" = {
            format = "binary";
            sopsFile = ./secrets/edge.token;
          };
          "ssh/id_ed25519" = {
            format = "binary";
            sopsFile = ./secrets/mordor;
          };
          "ssh/sops_ssh_config" = {
            format = "binary";
            sopsFile = ./secrets/ssh-conf;
          };
          "ssh/localhost_run" = {
            format = "binary";
            sopsFile = ./secrets/localhost_run;
          };
        };

        templates = {
          "hello.toml".content = ''
            hello = "Wooo ${config.sops.placeholder.hello} Hoo";
          '';
          "llm_apis.env".content = ''
            GEMINI_API_KEY="${config.sops.placeholder.gemini_api_key}"
            OPENAI_API_KEY="${config.sops.placeholder.copilot_api_key}"
            ANTHROPIC_API_KEY="${config.sops.placeholder.anthropic_api_key}"
            GROQ_API_KEY="${config.sops.placeholder.groq_api_key}"
          '';
        };
      };

    };
}
