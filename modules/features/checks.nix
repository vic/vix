# Checks: any scope emits flake checks as { <system>.<name> = drv; }; the fleet writes `checks` once.
{ ren, ... }:
{
  ren.channels.checks = {
    fold = ren.lib.fold.attrs;
    to = _: ren.kinds.fleet;
    into = { ... }: checks: { inherit checks; };
  };
}
