{ pkgs, ... }: {
  nix.extraOptions = builtins.readFile ../nix.conf;
  environment.systemPackages = with pkgs; [ nixFlakes direnv home-manager ];
}
