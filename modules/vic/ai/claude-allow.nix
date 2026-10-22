# claude permissions: the base rules every claude session allows (features add their own).
{ ren, ... }:
{
  ren.aspects.ai-claude-allow = {
    at = ren.aspects.vic-headless;
    claude-allow = { ... }: [
      # Edit(**) covers Write/MultiEdit/NotebookEdit; Read(**) covers Grep/Glob
      "Read(**)"
      "Edit(**)"
      "Grep(**)"
      "LS(**)"
      "WebSearch"
      "TodoRead(**)"
      "TodoWrite(**)"
      "Task(**)"

      "Bash(git status *)"
      "Bash(git diff *)"
      "Bash(git log *)"
      "Bash(git show *)"
      "Bash(git blame *)"
      "Bash(git rev-parse *)"
      "Bash(git remote *)"
      "Bash(git branch:*)"
      # Literal form: a force-push or another ref still prompts.
      "Bash(git push origin main)"
      "Bash(git fetch *)"
      "Bash(git add *)"
      "Bash(git commit *)"
      "Bash(git stash *)"

      "Bash(treefmt *)"
      "Bash(just *)"

      "Bash(nix eval *)"
      "Bash(nix flake *)"
      "Bash(nix build *)"
      "Bash(nix fmt)"
      "Bash(nix develop *)"

      "Bash(ls:*)"
      "Bash(cat:*)"
      "Bash(head:*)"
      "Bash(tail:*)"
      "Bash(grep:*)"
      "Bash(rg:*)"
      "Bash(fd:*)"
      "Bash(find:*)"
      "Bash(which:*)"
      "Bash(pwd)"
      "Bash(whoami)"
      "Bash(uname:*)"
      "Bash(wc *)"
      "Bash(rg *)"
      "Bash(jq *)"
      "Bash(yq *)"
      "Bash(sort *)"
      "Bash(journalctl *)"
    ];
  };
}
