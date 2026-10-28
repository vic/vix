# vocabulary dirs: one line per directory under modules/ and modules/vic/; the README table fails to eval on a missing or stale line.
{
  top = {
    agent = "invariants, stored queries, krn synthesis, trust labels, the rdf pack and the MCP app for agents";
    checks = "flake checks over the built configs: platform packages, no gui on headless homes";
    desktops = "desktop sessions (gnome, kde, niri, xfce), remote desktop, darwin defaults";
    docs = "this README: tour, graphs, vocabulary, recipes, open decisions";
    editors = "the vim and emacs kinds";
    envs = "the env kind, vic's envs, and one aspect per language";
    flake = "flake plumbing: flake-file, files, outputs, ci, formatter, devshell";
    forms = "aspects that key on the machine form: iso, wsl, laptop, laptop power";
    hardware = "aspects that key on machine facts: cpu, gpu, wifi, keyboard, firmware";
    hosts = "NixOS hosts, macs and standalone homes: facts, roles, own aspects; hosts/<name>/_nixos is autoincluded";
    nix = "nix settings, daemon, experimental features, unfree, state version";
    packages = "own packages and scripts";
    platforms = "how hosts, guests, macs and homes build, and their sinks: accounts, impermanence, ports";
    roles = "roles and vic's feature tiers";
    topology = "the scope tree and its data: fleet, systems, channels, machines, users, workspaces, secrets, ssh hosts";
    vic = "vic's own features, by area (below)";
  };
  vic = {
    ai = "claude, agents, mcp servers, skills";
    dev = "dev tools and security ops";
    dots = "dotfiles linked into $HOME";
    edit = "browsers, editors and terminals";
    nvf = "neovim features, one file each, and the vim profiles";
    secrets = "sops-encrypted files (opaque)";
    shell = "fish and shell tools";
    sys = "fonts, ssh, secrets and system bits";
    vcs = "git and jujutsu";
  };
}
