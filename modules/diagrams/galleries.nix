# Markdown galleries per host, user, home and the fleet.
{ ... }:
{
  perSystem =
    {
      pkgs,
      diagram,
      allHosts,
      allUsers,
      allHomes,
      everyEntry,
      ...
    }:
    let
      gallery = path: name: dir: title: {
        inherit path;
        drv = diagram.export.mkGallery pkgs {
          inherit name dir title;
          entries = everyEntry;
        };
      };
    in
    {
      _module.args.galleries =
        map (
          h: gallery "diagrams/hosts/${h.name}.md" h.name "hosts/${h.name}" "Gallery: ${h.name}"
        ) allHosts
        ++ map (
          u:
          gallery "diagrams/hosts/${u.host.name}/users/${u.userName}.md" u.userName
            "hosts/${u.host.name}/users/${u.userName}"
            "Gallery: ${u.userName} @ ${u.host.name}"
        ) allUsers
        ++ map (
          h:
          gallery "diagrams/homes/${h.safeName}.md" "home-${h.safeName}" "homes/${h.safeName}"
            "Gallery: ${h.safeName}"
        ) allHomes
        ++ [ (gallery "diagrams/fleet.md" "fleet" "fleet" "Fleet Gallery") ];
    };
}
