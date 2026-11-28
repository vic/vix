# Starlight splash homepage (`docs/src/content/docs/index.mdx`) for Vix.
{ yen, ... }:
let
  b = builtins;
  d = yen.helpers.vixDocs;

  allHosts = {
    instances = yen.kinds.host;
  };
  allMacs = {
    instances = yen.kinds.mac;
  };
  allHomes = {
    instances = yen.kinds.home;
  };
  allEnvs = {
    instances = yen.kinds.env;
  };
  allVims = {
    instances = yen.kinds.vim;
  };
in
{
  yen.docPage.index = {
    title = "vix";
    section = yen.docSection.home;
    route = "index";
    order = 0;
    summary = "Vic's real-world NixOS, macOS, Home Manager, devShell, and Neovim fleet built with Yen.";
    frontmatter = {
      template = "splash";
      editUrl = false;
      hero = {
        title = "One fleet. Every machine, verified.";
        tagline = "Vic's real-world NixOS, macOS, Home Manager, and Neovim fleet powered by ${d.yenHtml}, ${d.tupuHtml}-inspired Datalog, and ${d.cyclejsHtml} reactivity.";
        actions = [
          {
            text = "Explore the Fleet";
            link = "/fleet/machines/";
            icon = "right-arrow";
          }
          {
            text = "Architecture Tour";
            link = "/architecture/overview/";
            variant = "minimal";
          }
        ];
      };
    };
  };

  yen.aspects.doc-index = {
    at = yen.docPage.index;
    cycle =
      { tree, ... }:
      (nHosts: nMacs: nHomes: nEnvs: nVims: {
        tree = [
          allHosts
          allMacs
          allHomes
          allEnvs
          allVims
        ];
        docBody = ''
          ## About vix

          Vix is a living production Nix fleet built directly on ${d.yen} with zero `import-tree` glue and zero string tags.
          One folder of small Nix files builds ${toString nHosts} NixOS hosts, ${toString nMacs} Macs, ${toString nHomes} standalone homes, ${toString nEnvs} dev shells, and ${toString nVims} Neovim profiles.
          Every page on this site is computed straight from the live fleet, so documentation can never drift from reality.

          ## How Vix uses Yen

          <Features>

            <Feature icon="platforms" href="/fleet/machines/" title="Facts over module glue">
              Host files declare plain typed facts like `yen.cpu.amd` and `yen.desktop.niri`.
              Hardware, desktop, and user features activate automatically without manual imports.
            </Feature>

            <Feature icon="related" href="/architecture/kits-and-boundaries/" title='${d.cyclejsHtml} walls and kits'>
              Kind inheritance shares `os` sinks across NixOS and macOS, while `wall = true` isolates standalone homes.
              Native `yen.kits` wire GitHub runners and hardware reports without duplicating config.
            </Feature>

            <Feature icon="proof" href="/verify/invariants-and-queries/" title='${d.tupuHtml}-inspired fleet checks'>
              Pure-Nix Datalog invariants guarantee secrets stay on trusted machines, CI runners never get users, and ports never clash.
              Stored queries answer live questions from any shell.
            </Feature>

            <Feature icon="law" href="/architecture/overview/" title="Self-documenting architecture">
              Vix generates its own `README.md`, CI workflow matrix, and every page of this website directly from live `tree.select` queries.
            </Feature>

          </Features>

          ## Tour Vix in four steps

          <Ladder>
            <Rung href="/architecture/overview/" title="Architecture overview">See how Vix decouples topology, roles, platforms, and features with one scope tree.</Rung>
            <Rung href="/fleet/machines/" title="Live machines and homes">Browse every NixOS host, macOS laptop, CI runner, and standalone home with activation commands.</Rung>
            <Rung href="/fleet/envs-and-editors/" title="Dev shells and Neovim profiles">Inspect all 6 language devShells and 5 ref-typed NVF Neovim configurations.</Rung>
            <Rung href="/verify/invariants-and-queries/" title="Invariants and live queries">Run fleet verification, port allocation, and unfree audits right from `nix eval .#yen`.</Rung>
          </Ladder>

          ## Explore

          <Explore />

          ## Built with Yen

          Vix serves as the primary real-world reference fleet for ${d.yen}.
          Fork it, borrow patterns, or explore the source on GitHub.

          <GetInvolved />

          ## Sponsors

          Vix and ${d.yen} are built independently by [vic](https://oeiuwq.com) in the open-source Nix ecosystem.
          Thank you to everyone supporting this work.

          <Sponsors />

          ## Frequently asked questions

          <Faq />
        '';
      })
        (b.length (tree.select allHosts))
        (b.length (tree.select allMacs))
        (b.length (tree.select allHomes))
        (b.length (tree.select allEnvs))
        (b.length (tree.select allVims));
  };
}
