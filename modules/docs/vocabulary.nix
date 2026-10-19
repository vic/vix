# vocabulary: one line per Ren name; README tables fail to eval when a live name has no line here, or a line names nothing.
{ ... }:
{
  _module.args.vocab = {
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
      ssh-host = "one ssh client matchBlock";
      secret = "a sops secret a feature asks for";
    };
    classes = {
      nixos = "`nixosConfigurations.<host>`";
      darwin = "`darwinConfigurations.<mac>`";
      os = "either OS: forwards to nixos or darwin";
      account = "`users.users.<user>` on the user's machine";
      homeManager = "a user's home: on a host, on a mac, or `homeConfigurations.<user>@<home>`";
      homeLinux = "homeManager on linux only";
      homeDarwin = "homeManager on darwin only";
      files = "repo files (this README): `packages.write-files` + `checks`";
    };
    channels = {
      packages = [
        "aspects at a system"
        "flake `packages.<sys>`, read back as `self'.packages`"
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
        "any scope: `allowUnfree [ … ]`"
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
      core = "everywhere vic lives";
      full = "not on iso images (not within `installer`)";
      desktop = "within `graphical`";
      secrets = "within `trusted`";
    };
    roles = {
      graphical = "hosts with desktops or wsl, workstation macs (from facts)";
      installer = "iso hosts (from facts)";
      trusted = "included by a machine: holds vic's secrets";
      live-dots = "included by a machine: dotfiles link live into ~/.flake";
    };
  };
}
