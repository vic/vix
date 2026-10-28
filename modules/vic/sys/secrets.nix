# secrets: sops-nix home secrets (the emitted ones), templates and the ssh identity links.
# The aspect and its `at` are in roles/tiers.nix; this file adds its content.
{ sven, inputs, ... }:
{
  sven.aspects.vic-secrets = {
    flake-file.inputs.sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = [
      sven.secret.hello
      sven.secret.groq-api-key
      sven.secret.openrouter-api-key
      sven.secret.gemini-eco-key
      sven.secret.copilot-api-key
      sven.secret.anthropic-api-key
      sven.secret.edge-token
    ];
    homeManager =
      {
        secrets,
        config,
        pkgs,
        lib,
        ...
      }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        home.packages = [ pkgs.sops ];
        home.activation.link-ssh-id =
          lib.hm.dag.entryAfter
            [
              "check-checkout"
              "sops-nix"
              "reloadSystemd"
            ]
            ''
              run ln -sf "${config.sops.secrets."ssh/id_ed25519".path}" \
                $HOME/.ssh/id_ed25519
              run ln -sf "${config.sops.secrets."ssh/localhost_run".path}" \
                $HOME/.ssh/id_localhost_run
            '';
        home.file.".config/direnv/lib/use_vix_llm.sh".text = ''
          use_vix_llm() {
            source $HOME/.config/sops-nix/secrets/rendered/llm_apis.env
          }
        '';
        home.file.".envrc".text = ''
          use vix_llm
        '';
        sops = {
          age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          age.sshKeyPaths = [ ];
          age.generateKey = false;
          defaultSopsFile = ../secrets.yaml;
          validateSopsFiles = true;
          secrets = sven.helpers.sopsSecrets secrets;
          templates = {
            "hello.toml".content = ''
              hello = "Wooo ${config.sops.placeholder.hello} Hoo";
            '';
            "llm_apis.env".content = ''
              export OPENROUTER_API_KEY="${config.sops.placeholder.openrouter_api_key}"
              export GEMINI_API_KEY="${config.sops.placeholder.gemini_eco_key}"
              export OPENAI_API_KEY="${config.sops.placeholder.copilot_api_key}"
              export ANTHROPIC_API_KEY="${config.sops.placeholder.anthropic_api_key}"
              export GROQ_API_KEY="${config.sops.placeholder.groq_api_key}"
            '';
          };
        };
      };
  };
}
