#!/usr/bin/env bash
# Parity oracle: bash scripts vs target/release/vic on identical inputs. Exit 0 iff 0 mismatches.
# usage: parity.sh [guard|boot|ledger|statusline|all]   env: VIC_BIN, CORPUS, JOBS
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../../.." && pwd)               # workspace root (holds modules/ and tools/)
BIN=${VIC_BIN:-$ROOT/tools/target/release/vic}
CORPUS=${CORPUS:-$ROOT/../bash-corpus.txt}
JOBS=${JOBS:-12}
G=$ROOT/modules/vic/ai/vic/hooks/bash-guard.sh
L=$ROOT/modules/vic/ai/vic/hooks/cmd-ledger.sh
S=$ROOT/modules/vic/ai/_scripts/statusline.sh
B=$ROOT/modules/vic/ai/vic/hooks/boot.sh
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
FAIL=0
want=${1:-all}

# ---------------------------------------------------------------- guard
JJMSG='Refused: this repo uses jj. Use the jj equivalent (jj commit / jj new / jj squash / jj restore / jj rebase).'
guard_chunk() { # in out
  local in=$1 out=$2 t n=0 mm=0 nr=0 rb rr l
  t=$(mktemp -d)
  while IFS= read -r l; do
    n=$((n + 1))
    printf '%s\n' "$l" | timeout 5 bash "$G" 2>"$t/b"; rb=$?
    printf '%s\n' "$l" | timeout 5 "$BIN" hook guard 2>"$t/r"; rr=$?
    if [ "$rb" -ne "$rr" ] || ! cmp -s "$t/b" "$t/r"; then
      # only allowed difference: bash allowed, rust refuses with the jj message (new git law)
      if [ "$rb" -eq 0 ] && [ "$rr" -eq 2 ] && [ "$(cat "$t/r")" = "$JJMSG" ]; then
        nr=$((nr + 1)); printf '%s\n' "$l" >>"$out.newref"
      else
        mm=$((mm + 1)); printf 'MISMATCH rb=%s rr=%s :: %s\n' "$rb" "$rr" "$l" >>"$out.mm"
      fi
    fi
    if [ "$rb" -eq 2 ]; then head -1 "$t/b" | cut -c1-22 >>"$out.reasons"; fi
  done <"$in"
  echo "$n $mm $nr" >"$out.cnt"
  rm -rf "$t"
}

# explicit r2 cases: cmd cwd expected-rc
guard_cases() {
  local c cwd want got
  while IFS='|' read -r c cwd want; do
    got=$(jq -nc --arg c "$c" --arg d "$cwd" '{tool_input:{command:$c},cwd:$d}' | timeout 5 "$BIN" hook guard 2>/dev/null; echo $?)
    if [ "$got" != "$want" ]; then echo "  CASE FAIL: '$c' cwd=$cwd want=$want got=$got"; FAIL=1; fi
  done <<EOC
git commit -m x|$ROOT|2
git commit -m x|$ROOT/tools|2
git commit -m x|/|0
git log --oneline|$ROOT|0
git status|$ROOT|0
jj commit -m x|$ROOT|0
EOC
  echo "guard: explicit jj cases done"
}

part_guard() {
  echo "== guard"
  local d=$W/g; mkdir -p "$d"
  guard_cases
  head -n "${LIMIT:-1000000}" "$CORPUS" | jq -Rc --arg cwd "$ROOT" '{tool_input:{command:.},cwd:$cwd}' >"$d/in"
  # synthetic armed controls (appended; counted in total)
  for s in 'pkill -f foo' 'while pgrep -f x; do sleep 1; done' 'nix build .#x' 'sudo FOO=1 pkill --full bar'; do
    jq -nc --arg c "$s" '{tool_input:{command:$c}}' >>"$d/in"
  done
  jq -nc '{tool_input:{command:null}}' >>"$d/in"; echo '{"x":1}' >>"$d/in"; echo 'not json' >>"$d/in"
  split -n "l/$JOBS" "$d/in" "$d/chunk."
  local pids=() f
  for f in "$d"/chunk.??; do guard_chunk "$f" "$f" & pids+=($!); done
  for p in "${pids[@]}"; do wait "$p"; done
  local total=0 mm=0 nr=0 a b c
  for f in "$d"/chunk.??.cnt; do read -r a b c <"$f"; total=$((total + a)); mm=$((mm + b)); nr=$((nr + c)); done
  echo "guard: total=$total mismatches=$mm new-git-refusals=$nr"
  cat "$d"/chunk.*.newref 2>/dev/null | head -3 | cut -c1-200 | sed 's/^/  new-refusal sample: /'
  cat "$d"/chunk.*.reasons 2>/dev/null | sort | uniq -c | sed 's/^/  refusals: /'
  for r in 'Refused: pkill -f' 'Refused: a pgrep -f' 'Refused: uncapped'; do
    [ "$(cat "$d"/chunk.*.reasons 2>/dev/null | grep -c "^$r")" -gt 0 ] || { echo "  NO REFUSAL SEEN for: $r"; FAIL=1; }
  done
  if [ "$mm" -ne 0 ]; then cat "$d"/chunk.*.mm | head -20; FAIL=1; fi
}

# ---------------------------------------------------------------- boot
part_boot() {
  echo "== boot"
  local d=$W/b n=0 bad=0 p want got
  mkdir -p "$d"
  # fixtures: ok (no law line), bad (law line appended), stale handoff, no handoff, PWD fallback
  p=$d/ok; mkdir -p "$p/.jj" "$p/vic/.jj"; echo x >"$p/vic/HANDOFF.md"
  p=$d/stale; mkdir -p "$p/.jj" "$p/vic/.jj"; echo x >"$p/vic/HANDOFF.md"; touch -d '3 days ago' "$p/vic/HANDOFF.md"
  p=$d/nohandoff; mkdir -p "$p/.jj" "$p/vic/.jj"
  p=$d/bad; mkdir -p "$p/.beads"
  p=$d/okbeads; mkdir -p "$p/.jj" "$p/vic/.jj" "$p/vic/.beads"; ln -s vic/.beads "$p/.beads"
  for p in ok stale nohandoff bad okbeads; do
    n=$((n + 1))
    want=$(CLAUDE_PROJECT_DIR=$d/$p bash "$B"); got=$(CLAUDE_PROJECT_DIR=$d/$p "$BIN" hook boot)
    # rust = bash stdout, plus exactly one REPO LAW line when the repo violates the law
    if [ "$p" = bad ]; then
      want="$want"$'\n'"REPO LAW: no .jj; vic/ missing or not a jj workspace (no vic/.jj); .beads is not a symlink to vic/.beads; fix per /workspace LOCAL REPO LAW"
    fi
    [ "$want" = "$got" ] || { bad=$((bad + 1)); echo "  BOOT MISMATCH [$p]"; diff <(echo "$want") <(echo "$got") | head -5; }
  done
  n=$((n + 1))
  want=$(cd "$d/ok" && env -u CLAUDE_PROJECT_DIR bash "$B"); got=$(cd "$d/ok" && env -u CLAUDE_PROJECT_DIR "$BIN" hook boot)
  [ "$want" = "$got" ] || { bad=$((bad + 1)); echo "  BOOT MISMATCH [pwd fallback]"; }
  echo "boot: cases=$n mismatches=$bad"
  [ "$bad" -eq 0 ] || FAIL=1
}

# ---------------------------------------------------------------- ledger
part_ledger() {
  echo "== ledger"
  local d=$W/l; mkdir -p "$d"
  jq -nr '"é" * 70000' >"$d/big"; jq -nr '"x" * 9000' >"$d/small"
  local fx=$d/fixtures
  {
    jq -nc --rawfile o "$d/big" '{session_id:"s1",tool_input:{command:"long out"},tool_response:{stdout:$o,stderr:""}}'
    jq -nc --rawfile e "$d/small" '{session_id:"s2",tool_input:{command:"long err"},tool_response:{stdout:"o",stderr:$e}}'
    echo '{"session_id":"s3","tool_input":{"command":"ls"},"tool_response":{"stdout":"a\nb","stderr":"w"}}'
    echo '{"session_id":"s4","tool_input":{"command":"short"},"tool_response":{"stdout":"x"}}'
    echo '{}'
    echo '{"tool_input":{"command":"nosid"}}'
    echo '{"session_id":"s5","tool_response":{"stdout":"nocmd"}}'
    echo '{"session_id":"s6","tool_input":{"command":"str"},"tool_response":"plain string response"}'
    echo '{"session_id":"s7","tool_input":{"command":"output-key"},"tool_response":{"output":"via output"}}'
    echo '{"session_id":"s8","tool_input":{"command":"obj"},"tool_response":{"foo":1,"bar":[1,2],"baz":{"q":"é"}}}'
    echo '{"session_id":"s9","tool_input":{"command":"nullresp"},"tool_response":null}'
    echo '{"session_id":10,"tool_input":{"command":"numsid"},"tool_response":{"stdout":"n"}}'
    echo '{"session_id":"s11","tool_input":{"command":"emptyout"},"tool_response":{"stdout":"","output":"alt"}}'
    echo '{"session_id":"s12","tool_input":{"command":"falsey"},"tool_response":{"stdout":false,"output":"alt2","stderr":null}}'
    printf '%s\n' '{"session_id":"s13","tool_input":{"command":"esc \u007f \u0001 \t \" \\ 😀 é"},"tool_response":{"stdout":"d\u007fe"}}'
    echo '{"session_id":"s14","tool_input":{"command":"arrayout"},"tool_response":{"stdout":["a","b"]}}'
    echo '{"session_id":"s15","tool_input":{"command":"numout"},"tool_response":{"stdout":5}}'
    echo '{"session_id":"s16","tool_input":{"command":"arrresp"},"tool_response":[1,2]}'
    echo 'not json at all'
    echo ''
    echo '"just a string"'
  } >"$fx"
  local n; n=$(wc -l <"$fx"); echo "ledger: fixtures=$n"
  mkdir -p "$d/hb" "$d/hr"
  local l
  while IFS= read -r l; do
    printf '%s\n' "$l" | HOME=$d/hb CLAUDE_PROJECT_DIR=/proj/x bash "$L" >"$d/b.out" 2>&1; echo "$?" >"$d/b.rc"
    printf '%s\n' "$l" | HOME=$d/hr CLAUDE_PROJECT_DIR=/proj/x "$BIN" hook ledger >"$d/r.out" 2>&1; echo "$?" >"$d/r.rc"
    if [ -s "$d/b.out" ] || [ -s "$d/r.out" ] || ! cmp -s "$d/b.rc" "$d/r.rc"; then
      echo "  LEDGER STDOUT/RC MISMATCH on: ${l:0:80}"; FAIL=1
    fi
  done <"$fx"
  local norm='s/"ts":"[^"]*"/"ts":"T"/'
  local fb fr
  fb=$(cd "$d/hb" && find . -type f | sed 's/[0-9]\{8\}/DATE/' | sort); fr=$(cd "$d/hr" && find . -type f | sed 's/[0-9]\{8\}/DATE/' | sort)
  [ "$fb" = "$fr" ] || { echo "  LEDGER FILE SET DIFFERS: $fb VS $fr"; FAIL=1; }
  local ff
  ff=$(cd "$d/hb" && find . -type f | head -1)
  if diff <(sed "$norm" "$d/hb/$ff") <(sed "$norm" "$d/hr/$ff") >"$d/diff"; then
    echo "ledger: mismatches=0 (lines written: $(wc -l <"$d/hb/$ff") bash, $(wc -l <"$d/hr/$ff") rust)"
  else
    echo "ledger: MISMATCH"; head -c 1500 "$d/diff"; FAIL=1
  fi
  echo "  sample: $(sed -n 3p "$d/hr/$ff" | cut -c1-200)"
}

# ---------------------------------------------------------------- statusline
mk_head() { # file five_pct seven_pct five_reset_off seven_reset_off  ("-" omits resets_at)
  local f=$1 now; now=$(date +%s); mkdir -p "$(dirname "$f")"
  local r5 r7
  [ "$4" = "-" ] && r5='' || r5=",\"resets_at\":\"$(date -u -d "@$((now + $4))" +%Y-%m-%dT%H:%M:%SZ)\""
  [ "$5" = "-" ] && r7='' || r7=",\"resets_at\":\"$(date -u -d "@$((now + $5))" +%Y-%m-%dT%H:%M:%SZ)\""
  printf '{"latest":{"five_hour":{"utilization_pct":%s%s},"seven_day":{"utilization_pct":%s%s}}}\n' "$2" "$r5" "$3" "$r7" >"$f"
}

mk_tr() { # file tokens  : noise rows, target assistant row, then sidechain + user rows after
  local f=$1 t=$2
  {
    echo '{"type":"user","message":{"content":"hi"}}'
    echo '{"type":"assistant","isSidechain":false,"message":{"usage":{"input_tokens":5,"cache_read_input_tokens":1}}}'
    printf '{"type":"assistant","message":{"usage":{"input_tokens":%s,"cache_read_input_tokens":0,"cache_creation_input_tokens":0}}}\n' "$t"
    echo '{"type":"assistant","isSidechain":true,"message":{"usage":{"input_tokens":999999999}}}'
    echo '{"type":"assistant","message":{}}'
    echo '{"type":"user","message":{"content":"bye"}}'
  } >"$f"
}

SL_N=0 SL_BAD=0
sl_case() { # name json  (env: SLH=home dir, PM_STUB_MODE)
  local name=$1 json=$2 t=$W/sl/run tries
  SL_N=$((SL_N + 1))
  for tries in 1 2 3; do
    rm -rf "$t"; mkdir -p "$t/xb" "$t/xr"
    local s1 s2; s1=$(date +%s)
    printf '%s' "$json" | HOME=$SLH XDG_RUNTIME_DIR=$t/xb bash "$S" >"$t/b.out" 2>"$t/b.err"; echo $? >"$t/b.rc"
    printf '%s' "$json" | HOME=$SLH XDG_RUNTIME_DIR=$t/xr "$BIN" statusline >"$t/r.out" 2>"$t/r.err"; echo $? >"$t/r.rc"
    s2=$(date +%s); [ "$s1" = "$s2" ] && break
  done
  if cmp -s "$t/b.out" "$t/r.out" && cmp -s "$t/b.rc" "$t/r.rc"; then
    [ -n "${SL_SHOW:-}" ] && printf '  ok %-22s %s\n' "$name" "$(cat "$t/r.out")"
  else
    SL_BAD=$((SL_BAD + 1)); FAIL=1
    echo "  MISMATCH $name"; echo "    bash: $(cat -v "$t/b.out") rc=$(cat "$t/b.rc")"; echo "    rust: $(cat -v "$t/r.out") rc=$(cat "$t/r.rc")"
  fi
}

part_statusline() {
  echo "== statusline"
  local d=$W/sl; mkdir -p "$d/stub" "$d/home"
  cat >"$d/stub/vic-telemetry" <<'E'
#!/usr/bin/env bash
echo "ts agent tier secs tokens outcome"
if [ "${2:-}" = 1 ]; then
  echo "2999-01-01T00:00:00+00:00 vic-r3-deploy high 457 91035 partial"
else
  echo "2999-01-01T00:00:00+00:00 vic-a high 1 2 done"
  echo "1999-01-01T00:00:00+00:00 vic-b high 1 2 done"
  echo "2999-06-01T00:00:00+00:00 vic-c high 1 2 done"
fi
E
  cat >"$d/stub/vic-pm" <<'E'
#!/usr/bin/env bash
case "${PM_STUB_MODE:-ok}" in
  ok) echo 7 ;;
  fail) echo "noise 4"; exit 1 ;;
  words) echo "open beads: 12 (3 closed)" ;;
  none) echo "nothing" ;;
esac
E
  chmod +x "$d/stub/"*
  export PATH="$d/stub:$PATH" VIC_PM="$d/stub/vic-pm"
  SLH=$d/home
  local cwd=/proj/sl
  local base='"model":{"display_name":"Opus 4.7"},"effort":{"level":"high"},"cwd":"'$cwd'","cost":{"total_cost_usd":1.2345}'
  mk_head "$SLH/.headroom/subscription_state.json" 57.0 64.0 9000 300000
  export PM_STUB_MODE=ok
  # transcripts / ctx bands
  local tok
  for tok in 0 123456 690000 700000 849999 850000 1500000; do
    mk_tr "$d/tr-$tok" "$tok"
    sl_case "ctx-$tok" "{$base,\"transcript_path\":\"$d/tr-$tok\"}"
  done
  sl_case no-transcript-key "{$base}"
  sl_case transcript-missing "{$base,\"transcript_path\":\"$d/nope\"}"
  : >"$d/empty"; sl_case transcript-empty "{$base,\"transcript_path\":\"$d/empty\"}"
  printf '%s\n' '{"type":"assistant","message":{"usage":{"input_tokens":50000}}}' 'GARBAGE' '{"type":"assistant","message":{"usage":{"input_tokens":90000}}}' >"$d/tr-garb"
  sl_case transcript-garbage "{$base,\"transcript_path\":\"$d/tr-garb\"}"
  { for i in $(seq 1 200); do echo '{"type":"user","message":{"content":"x"}}'; done; printf '%s' '{"type":"assistant","message":{"usage":{"input_tokens":333000}}}'; } >"$d/tr-big"
  sl_case transcript-no-final-nl "{$base,\"transcript_path\":\"$d/tr-big\"}"
  { echo '{"type":"assistant","message":{"usage":{"input_tokens":111000}}}'; for i in $(seq 1 70); do echo '{"type":"user"}'; done; } >"$d/tr-old"
  sl_case transcript-beyond-tail60 "{$base,\"transcript_path\":\"$d/tr-old\"}"
  # cost / model / effort shapes
  mk_tr "$d/tr-ok" 400000; local T=",\"transcript_path\":\"$d/tr-ok\""
  sl_case cost-absent "{\"model\":{\"display_name\":\"M\"},\"cwd\":\"$cwd\"$T}"
  sl_case cost-zero "{\"model\":{\"display_name\":\"M\"},\"cwd\":\"$cwd\",\"cost\":{\"total_cost_usd\":0}$T}"
  sl_case cost-big "{\"model\":{\"display_name\":\"M\"},\"cwd\":\"$cwd\",\"cost\":{\"total_cost_usd\":123.456}$T}"
  sl_case cost-round "{\"model\":{\"display_name\":\"M\"},\"cwd\":\"$cwd\",\"cost\":{\"total_cost_usd\":0.125}$T}"
  sl_case model-id-only "{\"model\":{\"id\":\"claude-x\"},\"cwd\":\"$cwd\"$T}"
  sl_case model-none "{\"cwd\":\"$cwd\"$T}"
  sl_case model-string "{\"model\":\"opus\",\"cwd\":\"$cwd\"$T}"
  sl_case effort-string "{\"model\":{\"display_name\":\"M\"},\"effort\":\"max\",\"cwd\":\"$cwd\"$T}"
  sl_case effort-obj-nolevel "{\"model\":{\"display_name\":\"M\"},\"effort\":{},\"cwd\":\"$cwd\"$T}"
  sl_case workspace-dir "{\"model\":{\"display_name\":\"M\"},\"workspace\":{\"current_dir\":\"$cwd\"}$T}"
  sl_case no-cwd "{\"model\":{\"display_name\":\"M\"}$T}"
  sl_case pipe-in-model "{\"model\":{\"display_name\":\"A|B\"},\"effort\":\"e\",\"cwd\":\"$cwd\"$T}"
  sl_case invalid-json "not json"
  sl_case empty-stdin ""
  sl_case empty-object "{}"
  # headroom variants
  local H=$SLH/.headroom/subscription_state.json
  mk_head "$H" 40 95 3000 500000; sl_case hot-7d "{$base$T}"
  mk_head "$H" 100 100 3000 500000; sl_case full-100 "{$base$T}"
  mk_head "$H" 0 0 9000 300000; sl_case zero-pct "{$base$T}"
  mk_head "$H" 99 91 100 1000; sl_case near-reset "{$base$T}"
  mk_head "$H" 50 50 17990 604000; sl_case window-edge-60s "{$base$T}"
  mk_head "$H" 50 50 -100 -100; sl_case reset-in-past "{$base$T}"
  mk_head "$H" 50 50 99999 999999; sl_case reset-beyond-window "{$base$T}"
  mk_head "$H" 30 20 9000 - ; sl_case no-7d-reset "{$base$T}"
  mk_head "$H" 30 20 - 300000 ; sl_case no-5h-reset-shift "{$base$T}"
  mk_head "$H" 30 20 - -; sl_case no-resets "{$base$T}"
  mk_head "$H" 105 120 9000 300000; sl_case over-100 "{$base$T}"
  mk_head "$H" 12.9 89.9 9000 300000; sl_case fractional "{$base$T}"
  mk_head "$H" '"abc"' '"xyz"' 9000 300000; sl_case string-pct "{$base$T}"
  echo '{"latest":{"five_hour":{"utilization_pct":5,"resets_at":"garbage"},"seven_day":{"utilization_pct":6}}}' >"$H"; sl_case bad-date "{$base$T}"
  echo '{"latest":{"five_hour":{"utilization_pct":5,"resets_at":"2030-01-01T00:00:00.5Z"}}}' >"$H"; sl_case frac-date "{$base$T}"
  echo '{}' >"$H"; sl_case no-latest "{$base$T}"
  echo 'garbage' >"$H"; sl_case headroom-garbage "{$base$T}"
  : >"$H"; sl_case headroom-empty "{$base$T}"
  rm -f "$H"; sl_case headroom-missing "{$base$T}"
  mk_head "$H" 57.0 64.0 9000 300000
  # pm stub variants
  local m
  for m in fail words none; do PM_STUB_MODE=$m sl_case "pm-$m" "{$base$T}"; done
  PM_STUB_MODE=ok
  # agents
  local key=${cwd//\//-}; mkdir -p "$SLH/.cache/claude-ledger/$key"
  local now; now=$(date +%s)
  printf '%s\n' "$now" "$((now - 10))" "$((now - 7200))" "abc" "" "$((now - 100)).5" >"$SLH/.cache/claude-ledger/$key/sub-starts"
  sl_case agents-starts "{$base$T}"
  : >"$SLH/.cache/claude-ledger/$key/sub-starts"; sl_case agents-empty-starts "{$base$T}"
  # vic-telemetry absent from PATH-front: replace with failing stub
  printf '#!/usr/bin/env bash\nexit 3\n' >"$d/stub/vic-telemetry"
  sl_case telemetry-fails "{$base$T}"
  printf '#!/usr/bin/env bash\necho hdr\necho\necho "a vic-x"\n' >"$d/stub/vic-telemetry"
  sl_case telemetry-short-rows "{$base$T}"
  echo "statusline: cases=$SL_N mismatches=$SL_BAD"
}

[ "$want" = all ] || [ "$want" = guard ] && part_guard
[ "$want" = all ] || [ "$want" = boot ] && part_boot
[ "$want" = all ] || [ "$want" = ledger ] && part_ledger
[ "$want" = all ] || [ "$want" = statusline ] && part_statusline
if [ "$FAIL" -eq 0 ]; then echo "PARITY OK"; else echo "PARITY FAIL"; fi
exit "$FAIL"
