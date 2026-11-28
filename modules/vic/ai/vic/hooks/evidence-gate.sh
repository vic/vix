#!/usr/bin/env bash
# evidence-gate: no source edit without evidence (brain skill "EVIDENCE BEFORE IMPLEMENT"; vic 2026-11-11: "risks must
# be mitigated before spending time on developing"). A repo opts in with <main>/vic/evidence-gate.conf (one guarded
# glob per line, relative to the checkout root, bash extglob). An edit of a guarded file in a checkout needs the
# ticket <main>/vic/evidence/<workspace>.md (outside the tracked tree, so jj never snapshots it):
#   measured: <main commit measured>    locus: <file:line or symbol + numbers>    baseline: <whole-workload numbers>
#   stub: <stub/ablation result on the whole workload>    predicted: <delta>    evidence: ledger:<proj>/evidence/<slug>
#   verdict: STUB | PASS | FAIL
# STUB allows edits for 30 min from the ticket's mtime (the throwaway stub that sizes the lever); PASS needs every
# field filled; FAIL and a missing ticket deny. Covers Edit/Write/MultiEdit and in-place edits by Bash (sed -i, perl -i).
in=$(cat)
tool=$(printf '%s' "$in" | jq -r '.tool_name // ""')
cwd=$(printf '%s' "$in" | jq -r '.cwd // ""')

# the checkout root of dir d (a jj workspace or the main repo), else empty
root_of() { local d=$1; while [ -n "$d" ] && [ "$d" != / ]; do [ -d "$d/.jj" ] && { echo "$d"; return; }; d=$(dirname "$d"); done; }
# the main repo of a checkout: a secondary jj workspace has .jj/repo as a file holding the main .jj/repo path
main_of() {
  local r=$1 p
  [ -f "$r/.jj/repo" ] || { echo "$r"; return; }
  p=$(cat "$r/.jj/repo"); [[ $p == /* ]] || p="$r/.jj/$p"   # jj writes it relative to the workspace's .jj
  dirname "$(dirname "$(realpath -m "$p")")"
}

deny() { echo "evidence-gate: $1" >&2; exit 2; }

# gate one absolute path; returns 0 when allowed or unguarded
gate() {
  local f=$1 r m conf rel g hit=0 t v age
  r=$(root_of "$(dirname "$f")"); [ -n "$r" ] || return 0
  m=$(main_of "$r"); conf="$m/vic/evidence-gate.conf"; [ -f "$conf" ] || return 0
  rel=${f#"$r"/}
  shopt -s extglob
  while IFS= read -r g; do [ -z "$g" ] || [[ $g == \#* ]] && continue; [[ $rel == $g ]] && { hit=1; break; }; done < "$conf"
  [ $hit = 1 ] || return 0
  t="$m/vic/evidence/$(basename "$r").md"
  [ "$r" = "$m" ] && t="$m/vic/evidence/default.md"
  [ -f "$t" ] || deny "no evidence ticket for $rel. Write $t first: measure TODAY's main (locus + numbers), size the lever with a stub on the WHOLE workload, predict the delta (fields: measured locus baseline stub predicted evidence verdict). verdict: STUB opens 30 min for the stub only."
  v=$(sed -n 's/^verdict:[[:space:]]*//p' "$t" | head -1)
  case "$v" in
    PASS)
      for k in measured locus baseline stub predicted evidence; do
        grep -Eq "^$k:[[:space:]]*[^[:space:]]" "$t" || deny "ticket $t says PASS but field '$k' is empty"
      done
      grep -Eq '^evidence:[[:space:]]*ledger:[a-z0-9-]+/evidence/' "$t" || deny "ticket $t: evidence must be a ledger:<proj>/evidence/<slug> label"
      return 0 ;;
    STUB)
      age=$(( $(date +%s) - $(stat -c %Y "$t") ))
      [ "$age" -le 1800 ] || deny "stub window over ($((age / 60)) min) for $t: record the stub result and set verdict PASS (with evidence) or FAIL"
      return 0 ;;
    FAIL) deny "ticket $t says FAIL: the lever is dead, no development on it" ;;
    *) deny "ticket $t has no verdict (STUB | PASS | FAIL)" ;;
  esac
}

case "$tool" in
  Edit | Write | MultiEdit | NotebookEdit)
    f=$(printf '%s' "$in" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')
    [ -n "$f" ] || exit 0
    [[ $f == /* ]] || f="$cwd/$f"
    gate "$f" ;;
  Bash)
    c=$(printf '%s' "$in" | jq -r '.tool_input.command // ""')
    # an in-place edit: sed -i / perl -i (also -pi, -0pi, --in-place); every word that names a file is gated
    printf '%s' "$c" | grep -Eq '(^|[^[:alnum:]_])(sed|perl)[[:space:]][^|;&]*(-[a-zA-Z0-9]*i|--in-place)' || exit 0
    # relative words resolve against the session cwd and every `cd DIR` of the command (~ expanded)
    bases=("$cwd")
    while read -r d; do d=${d/#\~/$HOME}; [[ $d == /* ]] || d="$cwd/$d"; bases+=("$d"); done < <(printf '%s' "$c" | grep -Eo '(^|[;&|[:space:]])cd[[:space:]]+[^;&|[:space:]]+' | sed -E 's/.*cd[[:space:]]+//')
    for w in $c; do
      w=${w//[\"\';]/}
      [[ $w == -* || $w != *.* ]] && continue
      if [[ $w == /* ]]; then [ -e "$w" ] && gate "$w"
      else for b in "${bases[@]}"; do [ -e "$b/$w" ] && gate "$b/$w"; done
      fi
    done ;;
esac
exit 0
