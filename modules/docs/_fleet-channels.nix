# fleet channels: one `emitter -> receiver` per Ren channel for the README channel map; the map fails to eval on a missing or stale line.
{
  nix-features = "any scope -> machine";
  flake-inputs = "any scope -> flake-file class";
  ci-jobs = "host mac home devshell -> flake outputs";
  formatter = "system -> flake outputs";
  checks = "fmt README flake.nix no-gui -> flake outputs";
  packages = "system -> flake outputs";
  devshells = "env -> flake outputs";
  env-packages = "env-lang aspects -> env devshell and users";
  unfree = "any scope -> machine or home";
  login-shells = "user -> machine";
  secrets = "user feature -> vic-secrets";
  dots = "user feature -> vic-dots";
  fish-functions = "user feature -> fish";
  git-ignores = "user feature -> git";
  claude-allow = "user feature -> ai-claude";
}
