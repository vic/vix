# Cap every nix evaluation

Run every `nix eval`, `nix build` and `nix flake check` under a cap:

    timeout 300 <command>
    systemd-run --user --scope -q -p MemoryMax=12G <command>

A regression can make any eval runaway, and the host is shared. Exit 124/137 under the
cap is a finding: report it with its command and never re-run it uncapped.
