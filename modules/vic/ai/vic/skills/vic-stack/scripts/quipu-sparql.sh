#!/bin/sh
# quipu-sparql.sh — Generate typo-free Quipu SPARQL queries for label-prefix & operating-memory scans (POSIX sh)
# Usage:
#   quipu-sparql.sh ledger <proj> [mistake|evidence|bead|handoff|landed|all] [limit]
#   quipu-sparql.sh om <keyword> [limit]
set -eu

if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<'EOF'
Usage:
  quipu-sparql.sh ledger <proj> [mistake|evidence|bead|handoff|landed|all] [limit]
  quipu-sparql.sh om <keyword> [limit]

Prints a ready-to-pass SPARQL 1.1 query string for `quipu_query`.
Prefer label-prefix scans (~65 ms) over full text CONTAINS scans (~3 s).
EOF
    [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && exit 0 || exit 2
fi

MODE="$1"
case "$MODE" in
    ledger)
        PROJ="$2"
        KIND="${3:-all}"
        LIMIT="${4:-20}"
        if [ "$KIND" = "all" ]; then
            PREFIX="ledger:${PROJ}/"
        else
            PREFIX="ledger:${PROJ}/${KIND}/"
        fi
        printf 'SELECT ?l ?c WHERE { ?e <http://www.w3.org/2000/01/rdf-schema#label> ?l ; <http://www.w3.org/2000/01/rdf-schema#comment> ?c . FILTER(STRSTARTS(STR(?l),"%s")) } LIMIT %s\n' "$PREFIX" "$LIMIT"
        ;;
    om)
        WORD=$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')
        LIMIT="${3:-10}"
        printf 'SELECT ?p ?c WHERE { ?n <http://www.w3.org/2000/01/rdf-schema#comment> ?c . OPTIONAL { ?n ?pred ?p . FILTER(STRENDS(STR(?pred),"/path")) } FILTER(CONTAINS(LCASE(STR(?c)),"%s") || CONTAINS(LCASE(STR(?p)),"%s")) } LIMIT %s\n' "$WORD" "$WORD" "$LIMIT"
        ;;
    *)
        echo "quipu-sparql: unknown mode '$MODE' (use ledger | om)" >&2
        exit 2
        ;;
esac
