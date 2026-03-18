let

  app =
    pkgs:
    pkgs.writeShellApplication {
      name = "gh-deps-update";
      derivationArgs.buildInputs = [ pkgs.bash pkgs.coreutils ];
      runtimeInputs = [ pkgs.bash pkgs.coreutils pkgs.npins ];
      text = ''
        export GIT_AUTHOR_NAME="Victor Borja"
        export GIT_AUTHOR_EMAIL="vborja@apache.org"
        export GIT_COMMITTER_NAME="Victor Borja"
        export GIT_COMMITTER_EMAIL="vborja@apache.org"

        branch="deps-update-$(date '+%F')"

        git checkout -b "$branch"
        title="Updating inputs $(date)"

        (
          echo "$title"
          echo -ne "\n\n\n\n"
          echo '```shell'
          echo '$ npins update'
          npins update 2>&1
          echo '```'
          echo -ne "\n\n\n\n"
          echo 'request-checks: true'
        ) | tee /tmp/commit-message.md

        changes="$(git status -s | grep -o 'M ' | wc -l)"

        if test "$changes" -eq 0; then
          echo "No changes"
          exit 0
        fi

        git status -s | grep 'M ' | cut -d 'M' -f 2 | xargs git add
        git commit -F /tmp/commit-message.md --no-signoff --no-verify --trailer "request-checks:true" --no-edit --cleanup=verbatim
        git push origin "$branch:$branch" --force

        gh pr create --base main --label deps-update --reviewer vic --assignee vic --body-file /tmp/commit-message.md --title "$title" --head "$branch" | tee /tmp/pr-url
      '';
    };

in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.gh-deps-update = app pkgs;
    };
}
