# Synthesis an agent can call (a stored query, so `ask` and the MCP server reach it): uKanren finds a value that meets the constraints.
# - freePort { place }   the lowest port in 8000..8999 that no service of the machine or home, or of its users, uses (`ports` sink)
{ yen, lib, ... }:
let
  K = yen.lib.uKanren;
  # the lowest port in 8000..8999 that is not in used
  lowestFree =
    used: K.run 1 (q: [ (K.infd [ q ] 8000 8999) ] ++ map (K.neqfd q) used ++ [ (K.label [ q ]) ]);
  answerOf =
    place: used:
    if lowestFree used == [ ] then
      {
        error = "no free port on ${place.name} in 8000..8999";
        inherit used;
      }
    else
      {
        port = lib.head (lowestFree used);
        inherit used;
      };
in
{
  yen.queries.freePort = {
    params.place = yen.lib.oneOf [
      yen.kinds.host
      yen.kinds.mac
      yen.kinds.guest
      yen.kinds.home
    ];
    answer = { result, place }: answerOf place (map (p: p.port) (yen.helpers.portsOf result place));
  };
}
