# readme tour: the Ren scope tree in a few lines, with real vix names.
''
  ## A tour

  - **Kinds** hold typed data. Kinds with `below` form the **scope tree**, rooted at `ren.fleet.vix`.
  - **Machines** hold facts: `host` (NixOS: frodo), `mac` (nix-darwin: varda), `guest` (microvm on a host: gen, dnx on frodo).
  - **Homes** are standalone home-manager: `bitstream`, `nargun`. **Users** (`ren.user.vic`) get one scope per machine or home.
  - **Systems** hold vim profiles (`nvim`, `lazyvim`) and dev envs (`rustenv`, `goenv`).
  - **Aspects** bundle config; `at` says where: `ren.aspects.direnv = { at = ren.aspects.vic-headless; homeManager.programs.direnv.enable = true; };`
  - **Channels** carry data from emitters to one receiver: `git-ignores = _: [ ".claude" ];` lands in `git`.
  - **Classes** are the other aspect keys (`nixos`, `homeManager`, `account`, `vim`, `files`...); each turns modules into a flake output.
''
