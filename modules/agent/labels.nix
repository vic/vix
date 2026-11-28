# Trust labels by file path prefix: an aspect's label is the lowest trust over the files that declare it.
# Agents write under vic/ai/ (vic/ai/vic/hooks.nix) and agent/, so `r.floor 3` lists every element their aspects route.
{
  yen.labels = {
    "modules/" = {
      trust = 3;
    };
    "vic/ai/" = {
      trust = 2;
    };
    "agent/" = {
      trust = 1;
    };
  };
}
