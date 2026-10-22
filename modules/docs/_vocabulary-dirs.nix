# vocabulary dirs: one line per directory under modules/ and modules/vic/; the README table fails to eval on a missing or stale line.
{
  top = {
    community = "shared hardware and desktop aspects; they key on machine facts";
    docs = "this README: generators, vocabulary, recipes";
    editors = "vim profiles (nvf) and emacs distributions";
    envs = "dev environments and one aspect per language";
    features = "flake plumbing: ci, checks, formatter, packages, unfree, accounts";
    homes = "standalone home-manager homes";
    hosts = "NixOS and darwin machines, and frodo's guests";
    net = "ssh hosts and remote desktop";
    packages = "own packages and scripts";
    people = "users, and the vic-* feature tier aspects";
    platforms = "channels (nixpkgs pins) and how machines are built";
    security = "secrets declared as data";
    topology = "kinds and the scope tree: fleet, machines, users";
    vic = "vic's own features, by area (below)";
  };
  vic = {
    ai = "claude, agents, mcp servers, skills";
    dev = "dev tools and security ops";
    dots = "dotfiles linked into $HOME";
    edit = "browsers, editors and terminals";
    nvf = "neovim features, one file each";
    secrets = "sops setup for vic's secrets";
    shell = "fish and shell tools";
    sys = "fonts, ssh and system bits";
    vcs = "git and jujutsu";
  };
}
