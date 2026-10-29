# Synthesis an agent can call (a stored query, so `ask` and the MCP server reach it): krn finds a value that meets the constraints.
# - freePort { name }   the lowest port in 8000..8999 that no service of the machine or home, or of its users, uses (`ports` sink)
{ yen, lib, ... }:
let
  K = yen.lib.krn;
in
{
  yen.queries.freePort =
    { name, r }:
    let
      ps = yen.queries.portsOf { inherit name r; };
      used = map (p: p.port) ps;
      a = K.run 1 (q: [ (K.infd [ q ] 8000 8999) ] ++ map (K.neqfd q) used ++ [ (K.label [ q ]) ]);
    in
    if !lib.isList ps then
      ps
    else if a == [ ] then
      {
        error = "no free port on ${name} in 8000..8999";
        inherit used;
      }
    else
      {
        port = lib.head a;
        inherit used;
      };
}
