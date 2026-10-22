# secret: kind of sops secrets; features emit the ones they need on the `secrets` channel.
{
  ren,
  lib,
  ...
}:
let
  vix = ren.helpers;
  t = lib.types;
  bin = file: {
    format = "binary";
    sopsFile = file;
  };
in
{
  ren.kinds.secret = {
    sopsKey = t.str; # sops key path
    format = vix.maybe (t.enum [ "binary" ]);
    sopsFile = vix.maybe t.path;
    path = vix.maybe t.str;
  };
  ren.channels.secrets = {
    fold = ren.lib.fold.list;
    at = ren.kinds.user;
    to = e: e;
  };

  ren.secret.hello = {
    sopsKey = "hello";
  };
  ren.secret.groq-api-key = {
    sopsKey = "groq_api_key";
  };
  ren.secret.openrouter-api-key = {
    sopsKey = "openrouter_api_key";
  };
  ren.secret.gemini-eco-key = {
    sopsKey = "gemini_eco_key";
  };
  ren.secret.copilot-api-key = {
    sopsKey = "copilot_api_key";
  };
  ren.secret.anthropic-api-key = {
    sopsKey = "anthropic_api_key";
  };
  ren.secret.edge-token = bin ../vic/secrets/edge.token // {
    sopsKey = "edge.token";
  };
  ren.secret.ssh-id-ed25519 = bin ../vic/secrets/mordor // {
    sopsKey = "ssh/id_ed25519";
  };
  ren.secret.ssh-conf = bin ../vic/secrets/ssh-conf // {
    sopsKey = "ssh/sops_ssh_config";
  };
  ren.secret.ssh-localhost-run = bin ../vic/secrets/localhost_run // {
    sopsKey = "ssh/localhost_run";
  };
}
