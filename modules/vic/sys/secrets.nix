# secrets: sops-nix home secrets, templates and the ssh identity links.
{
  vicAt,
  inputs,
  mod,
  ...
}:
{
  ren.aspects.vic-secrets = {
    at = vicAt.secrets;
    homeManager = mod (
      {
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
              "link-flake"
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
          secrets = {
            "hello" = { };
            "groq_api_key" = { };
            "openrouter_api_key" = { };
            "gemini_eco_key" = { };
            "copilot_api_key" = { };
            "anthropic_api_key" = { };
            "edge.token" = {
              format = "binary";
              sopsFile = ../secrets/edge.token;
            };
            "ssh/id_ed25519" = {
              format = "binary";
              sopsFile = ../secrets/mordor;
            };
            "ssh/sops_ssh_config" = {
              format = "binary";
              sopsFile = ../secrets/ssh-conf;
            };
            "ssh/localhost_run" = {
              format = "binary";
              sopsFile = ../secrets/localhost_run;
            };
          };
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
      }
    );
  };
}
