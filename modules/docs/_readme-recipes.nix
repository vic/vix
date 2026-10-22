# readme recipes: the common edits, each a few lines of real vix nix.
''
  **Add a host**: facts only; community aspects key on them (`modules/hosts/<name>.nix`).
  ```nix
  ren.host.nargun = {
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    workstation = true;
    cpu = "amd";
    desktops = [ "kde" "niri" ];
  };
  ```

  **Add a user feature**: one aspect, gated by a tier (`modules/vic/<area>/<name>.nix`).
  ```nix
  ren.aspects.dev-tools = {
    at = ren.aspects.vic-full;
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.gh pkgs.jq ]; };
  };
  ```

  **Add a dev env**: an instance, then list it on a machine or home (`envs = [ ren.env.goenv ];`).
  ```nix
  ren.env.goenv.langs = [ "go" ];
  ren.aspects.env-go = {
    at = ren.lib.and [ ren.kinds.env (ren.lib.when (s: builtins.elem "go" s.env.langs)) ];
    env-packages = { system, ... }: [ system.legacyPackages.go ];
  };
  ```

  **Add an ssh host**: one instance becomes one `programs.ssh` matchBlock (`modules/net/ssh-host.nix`).
  ```nix
  ren.ssh-host.edge = {
    host = "edge";
    hostname = "192.168.192.168";
  };
  ```

  **Add a secret**: declare it, then emit it from the feature that reads it.
  ```nix
  ren.secret.groq-api-key.sopsKey = "groq_api_key";  # modules/security/secret.nix
  ren.aspects.my-feature.secrets = { ... }: [ ren.secret.groq-api-key ];
  ```
''
