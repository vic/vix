# secret: data kind of sops secrets; features give the ones they need on the `secrets` sink of a user or a host.
{
  sven,
  lib,
  inputs,
  ...
}:
let
  inherit (sven.lib) maybe opt;
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
  # the sops files the instances own, by name
  covered = map (s: baseNameOf s.sopsFile) (
    lib.filter (s: s.sopsFile != null) (lib.attrValues sven.secret)
  );
in
{
  sven.kinds.secret.fields = {
    sopsKey = t.str; # sops key path
    format = maybe (sven.helpers.enum [ "binary" ]);
    sopsFile = maybe t.path;
    path = maybe t.str;
    deploy = opt t.bool true;
  };
  # an element is a list of secret refs; vic-secrets (vic/sys/secrets.nix) reads the user's
  sven.kinds.user.sinks.secrets = {
    reduce = sven.helpers.flat;
    of = sven.helpers.listOf sven.kinds.secret;
  };
  # the host's own secrets: the same element, forwarded to sops-nix
  sven.kinds.host.sinks.secrets = {
    reduce = sven.helpers.flat;
    of = sven.helpers.listOf sven.kinds.secret;
    nixos =
      { secrets, ... }:
      lib.optionalAttrs (secrets != [ ]) {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops.secrets = sven.helpers.sopsSecrets secrets;
      };
  };

  # a file in vic/secrets that no instance owns is an error
  sven.aspects.secret-files = {
    at = sven.fleet.vix;
    errors = map (f: "secret: modules/vic/secrets/${f} is no sven.secret") (
      lib.subtractLists covered (lib.attrNames (builtins.readDir ../vic/secrets))
    );
  };

  sven.secret.hello = {
    sopsKey = "hello";
  };
  sven.secret.groq-api-key = {
    sopsKey = "groq_api_key";
  };
  sven.secret.openrouter-api-key = {
    sopsKey = "openrouter_api_key";
  };
  sven.secret.gemini-eco-key = {
    sopsKey = "gemini_eco_key";
  };
  sven.secret.copilot-api-key = {
    sopsKey = "copilot_api_key";
  };
  sven.secret.anthropic-api-key = {
    sopsKey = "anthropic_api_key";
  };
  sven.secret.edge-token = bin ../vic/secrets/edge.token // {
    sopsKey = "edge.token";
  };
  sven.secret.ssh-id-ed25519 = bin ../vic/secrets/mordor // {
    sopsKey = "ssh/id_ed25519";
  };
  sven.secret.ssh-conf = bin ../vic/secrets/ssh-conf // {
    sopsKey = "ssh/sops_ssh_config";
  };
  sven.secret.ssh-localhost-run = bin ../vic/secrets/localhost_run // {
    sopsKey = "ssh/localhost_run";
  };
  sven.secret.alwaysdata-vic = tool ../vic/secrets/alwaysdata-vic;
  sven.secret.gh-recover = tool ../vic/secrets/gh-recover;
  sven.secret.nix-versions = tool ../vic/secrets/nix-versions;
  sven.secret.tangled = tool ../vic/secrets/tangled;
  sven.secret.vix = tool ../vic/secrets/vix;
}
