# readme recipes (a fn of sven): the common edits, each a few lines of real vix nix; "add a host" also as a change program.
{ sven }:
let
  # the change program is checked against the live schema: a renamed kind, field or aspect is an eval error here
  prog = [
    {
      op = "new";
      kind = "host";
      name = "elrond";
      fields = {
        system.ref = {
          kind = "system";
          name = "x86_64-linux";
        };
        workstation = true;
        cpu = "amd";
      };
    }
    {
      op = "set";
      path = [
        "host"
        "elrond"
        "desktops"
      ];
      value = [
        "kde"
        "niri"
      ];
    }
    {
      op = "place";
      aspect = "trusted";
      kind = "host";
      name = "elrond";
    }
  ];
  errors = sven.lib.program.validate { schema = sven.lib.schema; } prog;
  json =
    if errors == [ ] then
      builtins.toJSON prog
    else
      throw "docs/_readme-recipes.nix: ${builtins.toJSON errors}";
in
''
  **Add a host**: facts only; hardware and desktop aspects key on them (`modules/hosts/<name>.nix`).
  Hardware files in `modules/hosts/<name>/_nixos/` load by autoinclude; `ghRunner = "<label>";` makes the host a bare CI runner.
  ```nix
  sven.host.elrond = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
    workstation = true;
    cpu = "amd";
    desktops = [ "kde" "niri" ];
  };
  sven.aspects.trusted.at = sven.host.elrond;
  ```
  The same host as a change program an agent can dry-run (errors, invariant violations, diff) before it writes a file.
  Users stay in the host file: a program value is not a list of refs.
  ```sh
  echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"sven_program","arguments":{"program":${json}}}}' | nix run .#sven-mcp
  ```

  **Add a user feature**: one aspect, gated by a tier (`modules/vic/<area>/<name>.nix`).
  ```nix
  sven.aspects.dev-tools = {
    at = sven.aspects.vic-full;
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.gh pkgs.jq ]; };
  };
  ```

  **Add a dev env**: an instance, then list it on a machine or home (`envs = [ sven.env.goenv ];`).
  ```nix
  sven.env.goenv.langs = [ "go" ];
  sven.aspects.env-go = {
    at = sven.helpers.envHas "go";
    env-packages = { env, ... }: [ env.system.legacyPackages.go ];
  };
  ```

  **Add an ssh host**: one instance becomes one `programs.ssh` matchBlock (`modules/topology/ssh-hosts.nix`).
  ```nix
  sven.ssh-host.edge = {
    host = "edge";
    hostname = "192.168.192.168";
  };
  ```

  **Add a secret**: declare it, then give it from the feature that reads it (a user's or a host's `secrets` sink).
  A file in `modules/vic/secrets/` that no instance owns is an error record; `deploy = false` keeps a file off every machine.
  ```nix
  sven.secret.groq-api-key.sopsKey = "groq_api_key"; # modules/topology/secrets.nix
  sven.aspects.my-feature.secrets = [ sven.secret.groq-api-key ];
  ```

  **Add a port**: ask for a free one, then give it on the `ports` sink next to the setting that reads it.
  A second service on the same port of one machine is a unique-port violation.
  ```nix
  # (import ./query.nix).ask "freePort" { name = "frodo"; }   =>   { port = 8000; used = [ ... ]; }
  sven.aspects.my-service = {
    at = sven.aspects.vic-headless;
    ports = [ { port = 8000; what = "my-service"; } ];
  };
  ```
''
