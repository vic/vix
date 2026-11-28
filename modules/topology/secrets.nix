# secret: data kind of sops secrets; features give the ones they need on the `secrets` sink of a user or a host.
{
  yen,
  types,
  reduce,
  lib,
  inputs,
  ...
}:
let
  bin = file: {
    format = yen.secretFormat.binary;
    sopsFile = file;
  };
  tool = file: {
    sopsKey = baseNameOf file;
    sopsFile = file;
    deploy = false;
  };
  covered = ss: map (s: baseNameOf s.sopsFile) (lib.filter (s: s.sopsFile != null) ss);
in
{
  # Ref-typed secret format kind (zero string enum!)
  yen.kinds.secretFormat = { };
  yen.secretFormat.binary = { };

  yen.kinds.root.spawns.secret = _: yen.secret;
  yen.kinds.root.sinks.sops.reduce = reduce.merge;

  yen.aspects.secret-data = {
    at = yen.kinds.secret;
    sops =
      { secret, ... }:
      {
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
    sopsKey = types.str;
    format = types.maybe yen.kinds.secretFormat;
    sopsFile = types.maybe types.path;
    sopsPath = types.maybe types.str;
    deploy = types.opt types.bool true;
  };

  yen.kinds.user.sinks.secrets = {
    reduce = reduce.flat;
    of = types.listOf yen.kinds.secret;
  };

  yen.kinds.host.sinks.secrets = {
    reduce = reduce.flat;
    of = types.listOf yen.kinds.secret;
    into.nixos =
      { secrets, sops, ... }:
      lib.optionalAttrs (secrets != [ ]) {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops.secrets = yen.helpers.sopsSecrets sops secrets;
      };
  };

  # A file in vic/secrets that no instance owns is an error
  yen.aspects.secret-files = {
    at = yen.root;
    errors =
      { sops, ... }:
      map (f: "secret: modules/vic/secrets/${f} is no yen.secret") (
        lib.subtractLists (covered (lib.attrValues sops)) (lib.attrNames (builtins.readDir ../vic/secrets))
      );
  };

  yen.secret.hello.sopsKey = "hello";
  yen.secret.groq-api-key.sopsKey = "groq_api_key";
  yen.secret.openrouter-api-key.sopsKey = "openrouter_api_key";
  yen.secret.gemini-eco-key.sopsKey = "gemini_eco_key";
  yen.secret.copilot-api-key.sopsKey = "copilot_api_key";
  yen.secret.anthropic-api-key.sopsKey = "anthropic_api_key";
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
