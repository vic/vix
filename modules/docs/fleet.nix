# Self-documenting Vix docs schema: typed `docSection` & `docPage` kinds, live `write-docs` writer,
# `.github/workflows/gh-pages.yml` emitter, sidebar generator, link checker, and Datalog invariants.
{
  yen,
  types,
  reduce,
  inputs,
  ...
}:
let
  b = builtins;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

  starlightImports = "import { Aside, Badge, Card, CardGrid, FileTree, LinkButton, LinkCard, Steps, TabItem, Tabs } from '@astrojs/starlight/components';";

  indexImports = b.concatStringsSep "\n" [
    starlightImports
    "import Features from '../../components/Features.astro';"
    "import Feature from '../../components/Feature.astro';"
    "import Ladder from '../../components/Ladder.astro';"
    "import Rung from '../../components/Rung.astro';"
    "import Explore from '../../components/Explore.astro';"
    "import GetInvolved from '../../components/GetInvolved.astro';"
    "import Sponsors from '../../components/Sponsors.astro';"
    "import Faq from '../../components/Faq.astro';"
  ];

  dropTrailingNewline =
    s:
    (n: if n > 0 && b.substring (n - 1) 1 s == "\n" then b.substring 0 (n - 1) s else s) (
      b.stringLength s
    );

  fence =
    lang: meta: text:
    "```${lang}${if meta == "" then "" else " ${meta}"}\n${dropTrailingNewline text}\n```";

  docsHelper = {
    tupu = "[Tupu](https://github.com/vic/tupu)";
    cyclejs = "[Cycle.js](https://cycle.js.org)";
    yen = "[Yen](https://yen.oeiuwq.com/)";
    tupuHtml = ''<a href="https://github.com/vic/tupu">Tupu</a>'';
    cyclejsHtml = ''<a href="https://cycle.js.org">Cycle.js</a>'';
    yenHtml = ''<a href="https://yen.oeiuwq.com/">Yen</a>'';
    code = lang: text: fence lang "" text;
    nix = text: fence "nix" "" text;
    sh = text: fence "sh" ''frame="terminal"'' text;
    mermaid = text: fence "mermaid" "" text;
    file = path: title: fence "nix" ''title="${title}"'' (b.readFile path);
    table =
      headers: rows:
      b.concatStringsSep "\n" (
        [
          "| ${b.concatStringsSep " | " headers} |"
          "| ${b.concatStringsSep " | " (map (_: "---") headers)} |"
        ]
        ++ map (r: "| ${b.concatStringsSep " | " r} |") rows
      );
  };

  frontmatterOf =
    page:
    "---\n${
      b.toJSON (
        {
          inherit (page) title;
          description = page.summary;
          editUrl = "https://github.com/vic/vix/tree/yen/modules/docs";
        }
        // page.frontmatter
      )
    }\n---";

  renderMdx =
    page: body:
    "${frontmatterOf page}\n\n${
      if page.route == "index" then indexImports else starlightImports
    }\n\n${body}\n";

  sortBy = key: xs: b.sort (x: y: key x < key y) xs;

  allSections = {
    instances = yen.kinds.docSection;
  };
  allPages = {
    instances = yen.kinds.docPage;
  };
  allHosts = {
    instances = yen.kinds.host;
  };

  linksIn =
    text:
    b.concatMap (
      x: if b.isList x && b.length x >= 2 && b.isString (b.elemAt x 1) then [ (b.elemAt x 1) ] else [ ]
    ) (b.split ''([]][(]|href=")(/[^)"#]*)'' text);

  uniqueList = xs: b.foldl' (acc: x: if b.elem x acc then acc else acc ++ [ x ]) [ ] xs;

  stripFences =
    text:
    (
      parts:
      b.concatStringsSep "\n" (
        b.genList (i: if i / 2 * 2 == i then b.elemAt parts i else "") (b.length parts)
      )
    )
      (b.filter b.isString (b.split "```" text));

  stripTicks =
    text:
    (
      parts:
      b.concatStringsSep " " (
        b.genList (i: if i / 2 * 2 == i then b.elemAt parts i else "") (b.length parts)
      )
    )
      (b.filter b.isString (b.split "`" text));

  stripLinkedBrand =
    text:
    b.replaceStrings
      [
        "[Tupu](https://github.com/vic/tupu)"
        "[tupu](https://github.com/vic/tupu)"
        ''<a href="https://github.com/vic/tupu">Tupu</a>''
        ''<a href=\"https://github.com/vic/tupu\">Tupu</a>''
        "[Cycle.js](https://cycle.js.org)"
        "[cycle.js](https://cycle.js.org)"
        ''<a href="https://cycle.js.org">Cycle.js</a>''
        ''<a href=\"https://cycle.js.org\">Cycle.js</a>''
        "https://github.com/vic/tupu"
        "https://cycle.js.org"
      ]
      [
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
      ]
      text;

  hasBareBrand =
    text:
    (prose: b.match ".*([Tt]upu|[Cc]ycle\\.js).*" prose != null) (
      stripLinkedBrand (stripTicks (stripFences text))
    );

  renderSidebar =
    sections: entries:
    (
      shown:
      (
        bySec:
        (
          orderedSecs:
          b.toJSON (
            map (s: {
              label = s.title;
              items = map (e: e.item) (sortBy (e: e.order) bySec.${s.name});
            }) orderedSecs
          )
          + "\n"
        )
          (sortBy (s: s.order) (b.filter (s: bySec ? ${s.name}) sections))
      )
        (b.groupBy (e: e.section.name) shown)
    )
      (b.filter (e: e.item.slug != "index") entries);

  brokenLinks =
    pages: files:
    (
      sitePages:
      (
        routes:
        (
          allTexts:
          (found: b.filter (l: !(b.elem l routes)) found) (uniqueList (b.concatMap linksIn allTexts))
        )
          (b.attrValues files)
      )
        (map (p: if p.route == "index" then "/" else "/${p.route}/") sitePages)
    )
      (b.filter (p: !p.readmeOnly) pages);

  unlinkedBrandFiles =
    files:
    b.filter (p: hasBareBrand files.${p}) (
      b.filter (p: b.match ".*\\.mdx" p != null) (b.attrNames files)
    );

  writeDocsDrv =
    siteFiles:
    pkgs.writeShellScriptBin "write-docs" ''
      set -euo pipefail
      root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
      cd "$root"
      rm -rf docs/src/content/docs
      ${b.concatStringsSep "\n" (
        map (p: ''
          mkdir -p "$(dirname ${pkgs.lib.escapeShellArg p})"
          cp -f ${pkgs.writeText (b.baseNameOf p) siteFiles.${p}} ${pkgs.lib.escapeShellArg p}
          chmod 644 ${pkgs.lib.escapeShellArg p}
        '') (b.attrNames siteFiles)
      )}
      echo "Wrote ${toString (b.length (b.attrNames siteFiles))} Vix docs site files."
    '';

  ghPagesYml = ''
    # generated by modules/docs/fleet.nix: nix run .#write-files
    name: Deploy Vix Docs

    on:
      push:
        branches: [yen, main]
      workflow_dispatch:

    permissions:
      contents: read
      pages: write
      id-token: write

    concurrency:
      group: pages
      cancel-in-progress: false

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v6
          - uses: DeterminateSystems/determinate-nix-action@v3
          - uses: DeterminateSystems/magic-nix-cache-action@v13
          - run: nix run .#write-docs
          - uses: actions/setup-node@v4
            with:
              node-version: 22
          - uses: pnpm/action-setup@v4
            with:
              version: 10
          - run: pnpm --dir docs install --frozen-lockfile && pnpm --dir docs build
          - uses: actions/upload-pages-artifact@v3
            with:
              path: docs/dist

      deploy:
        environment:
          name: github-pages
          url: ''${{ steps.deployment.outputs.page_url }}
        runs-on: ubuntu-latest
        needs: build
        steps:
          - id: deployment
            uses: actions/deploy-pages@v4
  '';
in
{
  yen.helpers.vixDocs = docsHelper;

  # Ref-typed documentation sections (zero string tags!)
  yen.kinds.docSection.fields = {
    title = types.str;
    order = types.int;
  };

  yen.docSection = {
    architecture = {
      title = "Architecture";
      order = 1;
    };
    fleet = {
      title = "Live Fleet";
      order = 2;
    };
    verify = {
      title = "Verification & Recipes";
      order = 3;
    };
    home = {
      title = "Home";
      order = 0;
    };
  };

  yen.kinds.docPage = {
    fields = {
      title = types.str;
      section = yen.kinds.docSection;
      route = types.derive types.str (p: "${p.section.name}/${p.name}");
      order = types.opt types.int 100;
      summary = types.str;
      frontmatter = types.opt types.attrs { };
      readmeOnly = types.opt types.bool false;
      badge = types.maybe types.str;
    };
    sinks.docBody = {
      reduce = reduce.one;
      into = {
        docSiteFiles =
          { docPage, docBody, ... }:
          if docPage.readmeOnly then
            { }
          else
            {
              "docs/src/content/docs/${docPage.route}.mdx" = renderMdx docPage docBody;
            };
        files =
          { docPage, docBody, ... }:
          if docPage.readmeOnly then
            {
              files.file."README.md".text = "${dropTrailingNewline docBody}\n";
            }
          else
            { };
      };
    };
  };

  yen.kinds.root = {
    spawns.docPage = _: yen.docPage;
    sinks = {
      docSiteFiles = {
        reduce = reduce.merge;
        into.out =
          { docSiteFiles, ... }:
          {
            docsSite.siteFiles = docSiteFiles;
            packages.x86_64-linux.write-docs = writeDocsDrv docSiteFiles;
          };
      };
      docSidebar.reduce = reduce.list;
      docAssertions = {
        reduce = reduce.merge;
        into.out =
          { docAssertions, ... }:
          {
            docsSite.assertions = docAssertions;
          };
      };
    };
  };

  yen.aspects.vix-doc-sidebar-entry = {
    at = yen.kinds.docPage.where { readmeOnly = false; };
    docSidebar =
      { docPage, ... }:
      {
        inherit (docPage) section order;
        item = {
          label = docPage.title;
          slug = docPage.route;
        }
        // (if docPage.badge != null then { inherit (docPage) badge; } else { });
      };
  };

  yen.aspects.vix-doc-build-sidebar = {
    at = yen.root;
    cycle =
      { tree, docSidebar, ... }:
      {
        tree = [ allSections ];
        docSiteFiles."docs/src/sidebar.json" = renderSidebar (tree.select allSections) docSidebar;
      };
  };

  yen.aspects.vix-doc-verify = {
    at = yen.root;
    cycle =
      { tree, docSiteFiles, ... }:
      (
        pages: hosts:
        (machinesMdx: {
          tree = [
            allPages
            allHosts
          ];
          docAssertions = {
            "site.links-resolve" = brokenLinks pages docSiteFiles == [ ];
            "site.tupu-cycle-linked" = unlinkedBrandFiles docSiteFiles == [ ];
            "site.all-hosts-documented" = b.all (h: b.match ".*`${h.name}`.*" machinesMdx != null) hosts;
          };
        })
          (docSiteFiles."docs/src/content/docs/fleet/machines.mdx" or "")
      )
        (tree.select allPages)
        (tree.select allHosts);
  };

  yen.aspects.vix-doc-pages-workflow = {
    at = yen.root;
    files.files.file.".github/workflows/gh-pages.yml".text = ghPagesYml;
  };

  # Pure-Nix Datalog invariant over Vix's own documentation pages
  yen.invariants.every-doc-page-has-summary =
    { P }:
    {
      bad = P;
      pos = [
        (yen.facts.kind yen.kinds.docPage P)
        (yen.facts.docPage.summary P "")
      ];
    };
}
