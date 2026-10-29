- statusline parity PASS: 54 cases, 0 mismatches (bash vs rust, byte-equal stdout+rc)
- ledger parity PASS: 21 fixtures, 0 mismatches; guard parity PASS (full run 36700 lines, 0 mismatches; refusals pkill/pgrep/nix all >0)
- neg control: guard msg byte flipped -> 3 mismatches PARITY FAIL; statusline 'ag'->'aG' -> MISMATCH on all cases; both reverted

## rung 1 DONE
full `bash vic/tests/parity.sh all`: guard 36700 lines 0 mismatches (refusals pkill 27, pgrep-loop 11, nix 335; 4 synthetic lines appended), ledger 21 fixtures 0 mismatches, statusline 54 cases 0 mismatches. cargo test 23 pass, clippy -D warnings clean, fmt clean.
startup us/run (50 runs, bash vs rust): statusline 109543 vs 28159 (real vic-telemetry x2 dominates rust), guard 33291 vs 5098, ledger 25325 vs 6692.

## bash quirks (copied, not fixed)
- jq `a // b` does NOT swallow errors in a (jq 1.8.2): ledger with tool_response as plain string => jq errors, no line written, but `>>` already created the (empty) daily file.
- ledger: invalid/empty stdin also leaves an empty daily file. DEL (0x7f) is emitted as \u007f by jq; nested tostring double-escapes.
- statusline: model/effort/etc of wrong type (e.g. "model":"opus") => jq error => all five fields empty => empty model, cwd=$PWD.
- statusline: '|' inside model name shifts fields (IFS='|' read).
- headroom: missing resets_at drops the array element (jq `empty`), shifting r5/r7 (five reset missing => r5 gets seven's value, r7 empty->0).
- headroom: unparsable or fractional-second resets_at => jq fails => five/seven/r5/r7 all empty => renders "%" and `[ "" -ge 90 ]` errors (colour stays 35).
- `[ "$seven" -ge 90 ]` with non-integer => error, colour 35.
- telemetry timestamp compare is awk string compare against `date -Is` local-offset text.
- local time (%a %H:%M, -Is, ledger file date) needs TZ: rust shells out to `date` (shortcut, see clock.rs).
