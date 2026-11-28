# vic's feature tiers: vic/* features gate on them (`at = yen.aspects.vic-<tier>`).
{
  yen,
  at,
  ...
}:
{
  yen.aspects.vic-headless.at = yen.user.vic;
  yen.aspects.vic-gui.at = at.all [
    yen.aspects.vic-headless
    yen.aspects.on-graphical
  ];
  yen.aspects.vic-full.at = at.all [
    yen.aspects.vic-headless
    (at.not (at.under yen.aspects.installer))
  ];
  yen.aspects.vic-secrets.at = at.all [
    yen.aspects.vic-headless
    yen.aspects.on-trusted
  ];
}
