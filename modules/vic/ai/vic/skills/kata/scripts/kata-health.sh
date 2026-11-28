#!/bin/sh
# kata-health.sh — Probe Kata review service reachability & ?as=AI endpoint (POSIX sh)
# Usage: kata-health.sh [--url http://host:7878]
set -eu

URL="${KATA_URL:-}"
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<'EOF'
Usage: kata-health.sh [--url http://host:7878]

Checks Kata HTTP/MCP reachability using --url, $KATA_URL, localhost:7878, or local LAN IP:7878.
Prints the canonical MCP URL with mandatory `?as=AI` attribution suffix.
EOF
            exit 0
            ;;
        --url) URL="$2"; shift 2 ;;
        *) echo "kata-health: unknown arg: $1" >&2; exit 2 ;;
    esac
done

CANDIDATES=""
[ -n "$URL" ] && CANDIDATES="$URL"
CANDIDATES="$CANDIDATES http://127.0.0.1:7878"
if command -v hostname >/dev/null 2>&1; then
    for ip in $(hostname -I 2>/dev/null || true); do
        case "$ip" in *.*) CANDIDATES="$CANDIDATES http://${ip}:7878" ;; esac
    done
fi

for u in $CANDIDATES; do
    base="${u%/}"
    if command -v curl >/dev/null 2>&1; then
        code=$(curl -sS --max-time 2 -o /dev/null -w '%{http_code}' "$base/" 2>/dev/null || echo "000")
        if [ "$code" != "000" ]; then
            echo "KATA REACHABLE: $base (HTTP $code)"
            echo "MCP ENDPOINT (mandatory identity): ${base}/mcp?as=AI"
            exit 0
        fi
    fi
done

echo "FAIL: Kata service not reachable on any probed endpoint ($CANDIDATES)" >&2
exit 1
