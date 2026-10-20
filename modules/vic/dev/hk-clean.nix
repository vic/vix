# hk-clean-builds / hk-prune-ws: free disk under ~/hk.
{ ren, ... }:
{
  ren.aspects.hk-clean = {
    at = ren.aspects.vic-full;
    homeManager =
      { pkgs, ... }:
      let
        clean-builds = pkgs.writeShellApplication {
          name = "hk-clean-builds";
          runtimeInputs = [ pkgs.kondo ];
          text = ''
            # interactive per project; pass --all to skip asking, -n to list only
            age=''${1:-2w}
            [ $# -gt 0 ] && shift
            kondo --older "$age" "$@" ~/hk
          '';
        };
        prune-ws = pkgs.writeShellApplication {
          name = "hk-prune-ws";
          runtimeInputs = [
            pkgs.jujutsu
            pkgs.coreutils
          ];
          text = ''
            # stale = jj workspace, empty @, parent already landed/pushed. dry run unless --yes
            root=$HOME/hk/workspace
            yes=''${1:-}
            for d in "$root"/*/; do
              d=''${d%/}
              [ -d "$d/.jj" ] || { echo "keep $d: not a jj workspace"; continue; }
              if [ -n "$(jj -R "$d" log -r '@ ~ empty()' --no-graph -T '"x"' 2>&1)" ]; then
                echo "keep $d: working copy has changes"; continue
              fi
              if [ -n "$(jj -R "$d" log -r '@- ~ ::(trunk() | remote_bookmarks())' --no-graph -T '"x"' --ignore-working-copy 2>&1)" ]; then
                echo "keep $d: parent not landed or pushed"; continue
              fi
              echo "stale $d"
              if [ "$yes" = --yes ]; then
                (cd "$d" && jj workspace forget)
                rm -rf "$d"
              fi
            done
          '';
        };
      in
      {
        home.packages = [
          pkgs.kondo
          clean-builds
          prune-ws
        ];
      };
  };
}
