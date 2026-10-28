#!/usr/bin/env bash
# sven-mcp: MCP server (JSON-RPC 2.0, one message per line on stdio) over a sven fleet.
# Env: SVEN_FLEET (the fleet dir; default ../), SVEN_FLAKE (its flake ref; default path:<git top>?dir=<fleet dir in the repo>),
#      SVEN_TIMEOUT (seconds per nix call; default 120).
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
SVEN_FLEET=$(cd "${SVEN_FLEET:-$HERE/..}" && pwd -P)
SVEN_TIMEOUT=${SVEN_TIMEOUT:-120}
top=$(git -C "$SVEN_FLEET" rev-parse --show-toplevel 2>/dev/null || echo "$SVEN_FLEET")
rel=${SVEN_FLEET#"$top"}; rel=${rel#/}
SVEN_FLAKE=${SVEN_FLAKE:-path:$top${rel:+?dir=$rel}}   # a fleet inside a repo keeps its relative inputs
export SVEN_FLEET SVEN_FLAKE
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

TOOLS='[
 {"name":"sven_schema","description":"Every kind, aspect and invariant of the fleet.","inputSchema":{"type":"object","properties":{}}},
 {"name":"sven_check","description":"Invariants: violations, incomplete, ok, and the why rules of each violation.","inputSchema":{"type":"object","properties":{}}},
 {"name":"sven_context","description":"One scope: parent, children, aspects, elements given and received, errors.","inputSchema":{"type":"object","properties":{"id":{"type":"string"},"maxEdges":{"type":"integer"},"maxAspects":{"type":"integer"}},"required":["id"]}},
 {"name":"sven_explain","description":"Why an aspect is active, inactive or undefined at a scope.","inputSchema":{"type":"object","properties":{"aspect":{"type":"string"},"scope":{"type":"string"},"depth":{"type":"integer"}},"required":["aspect","scope"]}},
 {"name":"sven_errors","description":"Error records, optionally only one code.","inputSchema":{"type":"object","properties":{"code":{"type":"string"}}}},
 {"name":"sven_declared_in","description":"The files that answer a declaration path.","inputSchema":{"type":"object","properties":{"path":{"type":"array","items":{"type":"string"}}},"required":["path"]}},
 {"name":"sven_export","description":"The fleet as sorted N-Triples with sha256 and count. The agent decides whether to store it.","inputSchema":{"type":"object","properties":{}}},
 {"name":"sven_stage","description":"Evaluate a change (a module as JSON) without applying it: ok, errors, violations, diff, refused, sha.","inputSchema":{"type":"object","properties":{"change":{"type":"object"}},"required":["change"]}},
 {"name":"sven_queries","description":"The stored-query catalog: each query with its required and optional parameters.","inputSchema":{"type":"object","properties":{}}},
 {"name":"sven_ask","description":"Run a stored query by name with an args object. Errors (missing-param, unknown query) come back as the result.","inputSchema":{"type":"object","properties":{"name":{"type":"string"},"args":{"type":"object"}},"required":["name"]}},
 {"name":"sven_impact","description":"The scopes an element of a scope reaches over routed elements, by depth.","inputSchema":{"type":"object","properties":{"id":{"type":"string"},"hops":{"type":"integer"},"sinks":{"type":"array","items":{"type":"string"}},"max":{"type":"integer"}},"required":["id"]}},
 {"name":"sven_labels","description":"Trust labels per aspect; with floor n, the edges whose aspect has trust below n.","inputSchema":{"type":"object","properties":{"floor":{"type":"integer"}}}},
 {"name":"sven_why_not","description":"Whether an invariant atom is violated, and the why/whyNot rules for it.","inputSchema":{"type":"object","properties":{"atom":{"type":"string"}},"required":["atom"]}},
 {"name":"sven_program","description":"Dry-run a change program (list of op objects): valid, errors, ok, violations, diff.","inputSchema":{"type":"object","properties":{"program":{"type":"array","items":{"type":"object"}}},"required":["program"]}}
]'

reply() { jq -cn --argjson id "$1" --argjson result "$2" '{jsonrpc:"2.0",id:$id,result:$result}'; }
fail() { jq -cn --argjson id "$1" --argjson code "$2" --arg m "$3" '{jsonrpc:"2.0",id:$id,error:{code:$code,message:$m}}'; }

# content TEXT-JSON ISERROR -> MCP tool result
content() { jq -cn --arg t "$1" --argjson e "$2" '{content:[{type:"text",text:$t}],isError:$e}'; }

call() { # id name args
  local id=$1 name=$2 args=$3 tool=${2#sven_}
  if ! jq -e --arg n "$name" 'any(.[]; .name == $n)' <<<"$TOOLS" >/dev/null; then
    fail "$id" -32602 "unknown tool: $name"; return
  fi
  printf '%s' "$args" >"$tmp/args.json"
  SVEN_TOOL=$tool SVEN_ARGS=$tmp/args.json \
    timeout -k 2 "$SVEN_TIMEOUT" nix eval --offline --impure --json --file "$HERE/tool.nix" >"$tmp/out.json" 2>"$tmp/err.txt"
  local rc=$?
  if [ $rc -eq 124 ] || [ $rc -eq 137 ]; then
    reply "$id" "$(content '{"complete":false,"error":"timeout"}' false)"
  elif [ $rc -ne 0 ]; then
    local msg
    msg=$(grep -m1 -E '^[[:space:]]*error:' "$tmp/err.txt" || head -n1 "$tmp/err.txt")
    reply "$id" "$(content "$(jq -cn --arg m "$msg" '{complete:false,error:$m}')" true)"
  else
    # from a file: an export is too big for argv
    jq -c --argjson id "$id" '{jsonrpc:"2.0",id:$id,result:{content:[{type:"text",text:({complete:true,result:.}|tojson)}],isError:false}}' "$tmp/out.json"
  fi
}

while IFS= read -r line; do
  [ -z "$line" ] && continue
  if ! jq -e 'type == "object"' <<<"$line" >/dev/null 2>&1; then
    fail null -32700 "parse error"; continue
  fi
  method=$(jq -r '.method // ""' <<<"$line")
  id=$(jq -c '.id // null' <<<"$line")
  case $method in
    initialize)
      reply "$id" '{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"sven-mcp","version":"0.1.0"}}' ;;
    notifications/*) ;;
    tools/list) reply "$id" "$(jq -c '{tools:.}' <<<"$TOOLS")" ;;
    tools/call)
      call "$id" "$(jq -r '.params.name // ""' <<<"$line")" "$(jq -c '.params.arguments // {}' <<<"$line")" ;;
    *) [ "$id" = null ] || fail "$id" -32601 "method not found: $method" ;;
  esac
done
