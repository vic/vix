# vocabulary: one line per yen name; README tables fail to eval when a live name has no line here, or a line names nothing.
{
  kinds = {
    fleet = "root scope; it spawns every system, host, mac and home";
    system = "a nix system; it spawns one scope per vim profile and per env";
    machine = "data: typed facts (cpu, form, desktops, users, envs) hosts, guests and macs copy";
    host = "a NixOS machine: `nixosConfigurations.<host>`";
    guest = "a microvm on a host: its nixos goes into the host's `microvm.vms`";
    mac = "a nix-darwin machine: `darwinConfigurations.<mac>`";
    home = "a home-manager home of one user: standalone, or on a host (`on`) behind walls";
    export = "a user outside any machine: its home content becomes `homeModules.<name>`";
    user = "a person: full name, email, login shell, admin";
    channel = "data: the nixpkgs, home-manager and nix-darwin pins a machine builds with";
    env = "a dev environment: langs become a devshell and user packages";
    vim = "a neovim profile: a feature list built per system into one nvf package (+ a gui wrapper)";
    emacs = "data: an emacs distribution";
    workspace = "data: a project an isolated guest works on (repo path)";
    ssh-host = "data: one ssh client matchBlock";
    secret = "data: a sops secret a feature asks for";
  };
  sinks = {
    out = "flake outputs";
    checks = "`checks.<sys>.<name>`: fmt, README, flake.nix, no-gui, config tests";
    ci-jobs = "one GitHub build job per buildable host, mac, home and linux devshell";
    flake-file = "this flake.nix: the inputs each aspect uses";
    files = "repo files (this README, ci.yml) built by sini/files";
    packages = "`packages.<sys>`: own packages, vim profiles, write-files";
    devshells = "`devShells.<sys>`: one per env, and the maintainer shell";
    formatter = "`formatter.<sys>` (treefmt, `nix fmt`); reduce `one`: a second formatter is an error record";
    nvf = "an nvf module of a vim profile";
    env-packages = "tools of an env's langs: its devshell, and the home of a user whose machine lists it";
    nixos = "a NixOS module";
    darwin = "a nix-darwin module";
    os = "a module for either OS";
    account = "`users.users.<user>` on the user's machine";
    homeManager = "a home-manager module: on a machine, or `homeConfigurations.\"<user>@<place>\"`";
    homeLinux = "homeManager on linux only";
    homeDarwin = "homeManager on darwin only";
    unfree = "unfree package names the machine, home or vim profile allows";
    nix-features = "each machine's `nix.settings.experimental-features`";
    caches = "cachix caches: a machine's `nix.settings` substituters and keys, the fleet's flake.nix `nixConfig`";
    login-shells = "login shells of the users; the machine enables `programs.<shell>`";
    persist = "paths impermanence keeps on the host";
    ports = "`{ port; what; }` a machine's or a user's service listens on: for unique-port, portsOf and freePort; a user's go up to `served`";
    served = "fleet: every user's ports with the scope that serves them (`entries`); ssh tunnels forward from it";
    infra = "fleet: facts per host from its data; `checks.x86_64-linux.infra-<host>` compares them with the built system";
    claude = "Claude Code settings.json layers `{ rank; set; }`: a higher rank wins per key, equal ranks must agree";
    primary-user = "the one admin user name a mac (system.primaryUser) or a wsl host (wsl.defaultUser) reads; two admins are an error record";
    secrets = "secret refs: on a user, `vic-secrets` gives them to sops-nix in home-manager; on a host, to sops-nix in NixOS";
    dots = "`{ \"<home path>\" = \"<dots path>\"; }`; `vic-dots` links them into $HOME";
    fish-functions = "fish functions; `fish` writes them once";
    git-ignores = "global git ignores; `git` reads them";
    claude-allow = "Claude Code permissions; `ai-claude` reads them";
  };
  tiers = {
    vic-headless = "everywhere vic lives: terminal tools only (homes, guests, servers)";
    vic-full = "not on iso images (not within `installer`)";
    vic-gui = "`on-graphical`: every gui program lives here";
    vic-secrets = "`on-trusted`; also the sops consumer";
  };
  roles = {
    graphical = "hosts with desktops or wsl, workstation macs (from facts); a host file can add itself";
    installer = "iso hosts (from facts)";
    trusted = "a host file adds itself: holds vic's secrets";
    on-graphical = "a user within `graphical`, no non-graphical guest between";
    on-trusted = "a user within `trusted`, no untrusted guest between";
    on-linux = "a user on a linux machine or home (`homeLinux`)";
    on-darwin = "a user on a mac or darwin home (`homeDarwin`)";
    ci-runner = "machines with a `ghRunner` label (from data): bare GitHub runners, no users";
  };
}
