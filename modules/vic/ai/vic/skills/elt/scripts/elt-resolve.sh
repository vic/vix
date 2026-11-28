#!/bin/sh
# elt-resolve.sh — Resolve the local ELT doctrine repo and print the exact gate file path (POSIX sh)
# Usage: elt-resolve.sh [IY|ECG|WFP|AC|AC-FULL|AG|CM|TB|OA|README]
set -eu

GATE="${1:-README}"
case "$GATE" in
    -h|--help)
        cat <<'EOF'
Usage: elt-resolve.sh [IY|ECG|WFP|AC|AC-FULL|AG|CM|TB|OA|README]

Resolves the ELT doctrine repo from $ELT_REPO or XDG data dirs (~/.local/share/elt, ~/elt)
and prints the exact absolute file path to Read. Exits 1 loudly if the doctrine repo is not found.
EOF
        exit 0
        ;;
esac

ROOT=""
for cand in "${ELT_REPO:-}" "${XDG_DATA_HOME:-$HOME/.local/share}/elt" "$HOME/elt"; do
    [ -n "$cand" ] && [ -d "$cand/Epistemic Lattice Tethering (ELT)" ] && { ROOT="$cand"; break; }
done

if [ -z "$ROOT" ]; then
    echo "FAIL: ELT doctrine repo not found. Set ELT_REPO=/path/to/elt-repo (do NOT reconstruct ELT from memory)." >&2
    exit 1
fi

BASE="$ROOT/Epistemic Lattice Tethering (ELT)"
case "$GATE" in
    README)  REL="README.md" ;;
    IY)      REL="Intelligent Yielding (IY).md" ;;
    ECG)     REL="Earned Confidence Gating (ECG).md" ;;
    WFP)     REL="Workflow Fidelity Protocol (WFP).md" ;;
    AC)      REL="Adversarial Convergence ELT Optimized/AC Lite.md" ;;
    AC-FULL) REL="Adversarial Convergence ELT Optimized/AC Full.md" ;;
    AG)      REL="Alignment Governor (AG).md" ;;
    CM)      REL="Context Management (CM).md" ;;
    TB)      REL="Temporal Balance (TB).md" ;;
    OA)      REL="Ontology Anchor (OA)/Ontology Anchor (OA).md" ;;
    *) echo "FAIL: unknown ELT gate '$GATE' (use IY|ECG|WFP|AC|AC-FULL|AG|CM|TB|OA|README)" >&2; exit 2 ;;
esac

TARGET="$BASE/$REL"
[ -f "$TARGET" ] || { echo "FAIL: gate file missing at $TARGET" >&2; exit 1; }
printf '%s\n' "$TARGET"
