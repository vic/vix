# secrets: sops-nix home secrets (the emitted ones), templates and the ssh identity links.
{ ren, inputs, ... }:
{
  ren.aspects.vic-secrets = {
    flake-inputs =
      { ... }:
      {
        sops-nix = {
          url = "github:Mic92/sops-nix/ee48786c6f9160d2c1a084aac841f68195b8420c";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    secrets = { ... }: [
      ren.secret.hello
      ren.secret.groq-api-key
      ren.secret.openrouter-api-key
      ren.secret.gemini-eco-key
      ren.secret.copilot-api-key
      ren.secret.anthropic-api-key
      ren.secret.edge-token
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
          secrets = lib.listToAttrs (
            map (s: {
              name = s.sopsKey;
              value = lib.filterAttrs (_: v: v != null) (removeAttrs (ren.lib.data s) [ "sopsKey" ]);
            }) (lib.concatLists secrets)
          );
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
