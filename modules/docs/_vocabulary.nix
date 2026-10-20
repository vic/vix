# vocabulary: one line per Ren name; README tables fail to eval when a live name has no line here, or a line names nothing.
{
  kinds = {
    fleet = "root scope; everything lives below it";
    system = "a nix system; machines, homes and envs are built for one";
    machine = "abstract: typed facts (cpu, form, desktops, users, envs) hosts and macs share";
    host = "a NixOS machine (is machine)";
    mac = "a nix-darwin machine (is machine)";
    home = "a standalone home-manager home of one user";
    user = "a person: full name, email, login shell, admin";
    channel = "the nixpkgs, home-manager and nix-darwin pins a machine builds with";
    env = "a dev environment: langs become a devshell and user packages";
    emacs = "an emacs distribution (data only, no scopes)";
    vim = "a neovim profile: a feature list built per system into one nvf package (+ a gui wrapper)";
    guest = "a microvm on a host (is host): its own nixos and users, built inside the host";
    workspace = "a project an isolated claude guest works on (data): repo path; one guest each";
    ssh-host = "one ssh client matchBlock";
    secret = "a sops secret a feature asks for";
  };
  classes = {
    vim = "nvf: one neovim per vim profile, emitted as packages.<profile>";
    nixos = "`nixosConfigurations.<host>`";
    darwin = "`darwinConfigurations.<mac>`";
    os = "either OS: forwards to nixos or darwin";
    account = "`users.users.<user>` on the user's machine";
    homeManager = "a user's home: on a host, on a mac, or `homeConfigurations.<user>@<home>`";
    homeLinux = "homeManager on linux only";
    homeDarwin = "homeManager on darwin only";
    files = "repo files (this README): `packages.write-files` + `checks`";
    flake-file = "this flake.nix from `flake-inputs`: `packages.write-flake` + `checks.<sys>.flake-file`";
  };
  channels = {
    nix-features = [
      "any scope (base: nix-command flakes on every machine)"
      "each machine's `nix.settings.experimental-features`"
    ];
    flake-inputs = [
      "any aspect: the inputs it uses"
      "forwarded into the `flake-file` class (x86_64-linux)"
    ];
    ci-jobs = [
      "every buildable host, mac, home and linux devshell"
      "flake `ci.matrix`: one GitHub build job each"
    ];
    formatter = [
      "each system (treefmt)"
      "flake `formatter.<sys>` (`nix fmt`)"
    ];
    checks = [
      "formatter (fmt), files (README), flake-file (flake.nix), no-gui (headless homes and guests)"
      "flake `checks.<sys>.<name>`"
    ];
    packages = [
      "aspects at a system"
      "flake `packages.<sys>`, read back as `(vix.perSystem pkgs inputs.self).packages`"
    ];
    devshells = [
      "the `devshell` aspect, per env"
      "flake `devShells.<sys>`"
    ];
    env-packages = [
      "`env-<lang>` aspects"
      "the env's devshell, and users whose machine lists the env"
    ];
    unfree = [
      "any scope: `vix.allowUnfree [ … ]`"
      "the machine or home's `allowUnfreePredicate`"
    ];
    login-shells = [
      "users with a shell"
      "their machine enables `programs.<shell>`"
    ];
    secrets = [
      "user features: `[ ren.secret.x ]`"
      "`vic-secrets`: sops-nix config"
    ];
    dots = [
      "user features: `{ \"<home path>\" = \"<dots path>\"; }`"
      "`vic-dots`: links into $HOME"
    ];
    fish-functions = [
      "user features"
      "`fish` writes them once"
    ];
    git-ignores = [
      "user features"
      "`git` global ignores"
    ];
    claude-allow = [
      "user features"
      "`ai-claude` settings.json permissions"
    ];
  };
  tiers = {
    vic-headless = "everywhere vic lives: terminal tools only (homes, guests, servers)";
    vic-full = "not on iso images (not within `installer`)";
    vic-gui = "`on-graphical`: every gui program lives here";
    vic-secrets = "`on-trusted`; also the sops consumer";
  };
  roles = {
    graphical = "hosts with desktops or wsl, workstation macs (from facts)";
    installer = "iso hosts (from facts)";
    trusted = "included by a machine: holds vic's secrets";
    on-graphical = "a user within `graphical`, no non-graphical guest between";
    on-trusted = "a user within `trusted`, no untrusted guest between";
    on-linux = "a user on a linux machine or home (`homeLinux`)";
    on-darwin = "a user on a mac or darwin home (`homeDarwin`)";
    metal = "a nixos host that is not a guest: builds `nixosConfigurations`";
  };
}
