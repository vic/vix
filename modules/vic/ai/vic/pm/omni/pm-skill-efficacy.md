# omni export: skill:pm efficacy by model (omni_recall, exported 2026-10-21; all tentative)
# runs | out_tok | out_tok/turn | errs
- opus-4-8:   90 runs  15939298  1162/turn  0 errs
- haiku-4-5:  54 runs   1037463   171/turn  0 errs
- sonnet-4-6: 42 runs   1356260   291/turn  0 errs
- opus-5-5:   15 runs    204894  1366/turn  0 errs
- haiku-5-5:   6 runs     71981   375/turn  0 errs
- fable-5:     5 runs    581659  4068/turn  0 errs
# omni_health 2026-10-21: opus-4-8 = 70.9% of dispatch burn (2751 runs) -> audit for sonnet-fit; 140 runaway dispatches (>80k out or >100 tools), mostly workspace/otro -> partition; Read:codegraph 38:1 -> use codegraph first; cache reuse 319x healthy.
