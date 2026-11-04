# secret: data kind of sops secrets; features give the ones they need on the `secrets` sink of a user or a host.
{
  yen,
  lib,
  inputs,
  ...
}:
let
  inherit (yen.lib) maybe opt;
  t = lib.types;
  bin = file: {
    format = "binary";
    sopsFile = file;
  };
  # files only vic-sops-get and vic-sops-rotate use: never given to sops-nix
  tool = file: {
    sopsKey = baseNameOf file;
    sopsFile = file;
    deploy = false;
  };
  # the sops files the secrets ss own, by name
  covered = ss: map (s: baseNameOf s.sopsFile) (lib.filter (s: s.sopsFile != null) ss);
in
{
  # one scope per secret: it gives its data to the fleet `sops` sink, so a reader resolves a secret ref with `sops.${ref.name}`
  yen.kinds.fleet.spawns.secret = _: yen.secret;
  yen.kinds.fleet.sinks.sops.reduce = yen.lib.reduce.merge; # { <secret name> = { sopsKey; format; sopsFile; sopsPath; deploy; }; }
  yen.aspects.secret-data = {
    at = yen.kinds.secret;
    sops = { secret, ... }: {
      ${secret.name} = {
        inherit (secret)
          sopsKey
          format
          sopsFile
          sopsPath
          deploy
          ;
      };
    };
  };
  yen.kinds.secret.fields = {
    sopsKey = t.str; # sops key path
    format = maybe (yen.lib.enum [ "binary" ]);
    sopsFile = maybe t.path;
    sopsPath = maybe t.str; # sops-nix `path`; `path` is a yen scope key
    deploy = opt t.bool true;
  };
  # an element is a list of secret refs; vic-secrets (vic/sys/secrets.nix) reads the user's
  yen.kinds.user.sinks.secrets = {
    reduce = yen.lib.reduce.flat;
    of = yen.lib.listOf yen.kinds.secret;
  };
  # the host's own secrets: the same element, forwarded to sops-nix
  yen.kinds.host.sinks.secrets = {
    reduce = yen.lib.reduce.flat;
    of = yen.lib.listOf yen.kinds.secret;
    nixos =
      { secrets, sops, ... }:
      lib.optionalAttrs (secrets != [ ]) {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops.secrets = yen.helpers.sopsSecrets sops secrets;
      };
  };

  # a file in vic/secrets that no instance owns is an error
  yen.aspects.secret-files = {
    at = yen.fleet.vix;
    errors =
      { sops, ... }:
      map (f: "secret: modules/vic/secrets/${f} is no yen.secret") (
        lib.subtractLists (covered (lib.attrValues sops)) (lib.attrNames (builtins.readDir ../vic/secrets))
      );
  };

  yen.secret.hello = {
    sopsKey = "hello";
  };
  yen.secret.groq-api-key = {
    sopsKey = "groq_api_key";
  };
  yen.secret.openrouter-api-key = {
    sopsKey = "openrouter_api_key";
  };
  yen.secret.gemini-eco-key = {
    sopsKey = "gemini_eco_key";
  };
  yen.secret.copilot-api-key = {
    sopsKey = "copilot_api_key";
  };
  yen.secret.anthropic-api-key = {
    sopsKey = "anthropic_api_key";
  };
  yen.secret.edge-token = bin ../vic/secrets/edge.token // {
    sopsKey = "edge.token";
  };
  yen.secret.ssh-id-ed25519 = bin ../vic/secrets/mordor // {
    sopsKey = "ssh/id_ed25519";
  };
  yen.secret.ssh-conf = bin ../vic/secrets/ssh-conf // {
    sopsKey = "ssh/sops_ssh_config";
  };
  yen.secret.ssh-localhost-run = bin ../vic/secrets/localhost_run // {
    sopsKey = "ssh/localhost_run";
  };
  yen.secret.alwaysdata-vic = tool ../vic/secrets/alwaysdata-vic;
  yen.secret.gh-recover = tool ../vic/secrets/gh-recover;
  yen.secret.nix-versions = tool ../vic/secrets/nix-versions;
  yen.secret.tangled = tool ../vic/secrets/tangled;
  yen.secret.vix = tool ../vic/secrets/vix;
}
