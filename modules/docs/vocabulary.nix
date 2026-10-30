# vocabulary guard of the README tables: a live name with no doc line, or a doc line that names nothing live, is an error record.
{ yen, lib, ... }:
let
  inherit (yen.lib.batteries.docs) vocabulary;
  vocab = import ./_vocabulary.nix;
  vocabDirs = import ./_vocabulary-dirs.nix;
  dirsOf =
    p:
    let
      e = builtins.readDir p;
    in
    lib.filter (n: e.${n} == "directory") (lib.attrNames e);
  sinkNames = lib.unique (
    lib.concatMap (k: lib.attrNames k.sinks) (lib.attrValues yen.lib.schema.kinds)
  );
  # aspects: stale lines only
  live = what: lib.filter (n: yen.aspects ? ${n}) (lib.attrNames vocab.${what});
in
{
  yen.aspects.docs-vocabulary = {
    at = yen.kinds.fleet;
    errors =
      vocabulary {
        what = "kinds";
        names = lib.attrNames yen.kinds;
        lines = vocab.kinds;
      }
      ++ vocabulary {
        what = "sinks";
        names = sinkNames;
        lines = vocab.sinks;
      }
      ++ vocabulary {
        what = "tiers";
        names = live "tiers";
        lines = vocab.tiers;
      }
      ++ vocabulary {
        what = "roles";
        names = live "roles";
        lines = vocab.roles;
      }
      ++ vocabulary {
        what = "modules/";
        names = dirsOf ./..;
        lines = vocabDirs.top;
      }
      ++ vocabulary {
        what = "modules/vic/";
        names = dirsOf ./../vic;
        lines = vocabDirs.vic;
      };
  };
}
