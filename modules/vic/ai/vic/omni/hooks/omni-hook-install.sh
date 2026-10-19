#!/usr/bin/env bash
# omni-hook-install.sh — idempotent PreToolUse hook wirer for Claude Code settings.json
# Usage:
#   omni-hook-install.sh --install [--target <path>]
#   omni-hook-install.sh --uninstall [--target <path>]
# Default target: $HOME/.claude/settings.json

set -euo pipefail

TARGET="$HOME/.claude/settings.json"
ACTION=""

while [ $# -gt 0 ]; do
    case "$1" in
        --install)   ACTION="install";   shift ;;
        --uninstall) ACTION="uninstall"; shift ;;
        --target)
            TARGET="$2"
            shift 2
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            exit 1
            ;;
    esac
done

if [ -z "$ACTION" ]; then
    printf 'Usage: %s --install|--uninstall [--target <path>]\n' "$0" >&2
    exit 1
fi

# Ensure the target file exists (create minimal JSON if missing).
if [ ! -f "$TARGET" ]; then
    printf 'Target not found; creating: %s\n' "$TARGET"
    mkdir -p "$(dirname "$TARGET")"
    printf '{}\n' > "$TARGET"
fi

# Backup before touching.
BACKUP="${TARGET}.omni-hook.bak"
cp "$TARGET" "$BACKUP"
printf 'Backed up to: %s\n' "$BACKUP"

# Use node to parse + edit JSON safely.
node -e "
'use strict';
const fs   = require('fs');
const path = require('path');

const target = process.argv[1];
const action = process.argv[2];
const hookCmd = 'bash \$HOME/.claude/hooks/omni-pretool.sh';
const matcher = 'Bash|Edit|Write';

let raw;
try {
    raw = fs.readFileSync(target, 'utf8');
} catch (e) {
    console.error('Cannot read ' + target + ': ' + e.message);
    process.exit(1);
}

let cfg;
try {
    cfg = JSON.parse(raw);
} catch (e) {
    console.error('Invalid JSON in ' + target + ': ' + e.message);
    process.exit(1);
}

if (!cfg || typeof cfg !== 'object') cfg = {};
if (!cfg.hooks)                       cfg.hooks = {};
if (!cfg.hooks.PreToolUse)            cfg.hooks.PreToolUse = [];

const arr = cfg.hooks.PreToolUse;

if (action === 'install') {
    // Idempotency: check if an equivalent entry already exists.
    const alreadyPresent = arr.some(entry => {
        if (!entry || !Array.isArray(entry.hooks)) return false;
        return entry.hooks.some(h => h && h.command === hookCmd);
    });

    if (alreadyPresent) {
        console.log('Entry already present — no change (idempotent).');
    } else {
        arr.push({
            matcher: matcher,
            hooks: [{ type: 'command', command: hookCmd }]
        });
        console.log('Added PreToolUse hook entry.');
    }
} else if (action === 'uninstall') {
    const before = arr.length;
    cfg.hooks.PreToolUse = arr.filter(entry => {
        if (!entry || !Array.isArray(entry.hooks)) return true;
        return !entry.hooks.some(h => h && h.command && h.command.includes('omni-pretool.sh'));
    });
    const removed = before - cfg.hooks.PreToolUse.length;
    if (removed > 0) {
        console.log('Removed ' + removed + ' omni-pretool.sh entry/entries.');
    } else {
        console.log('No omni-pretool.sh entries found — no change.');
    }
}

fs.writeFileSync(target, JSON.stringify(cfg, null, 2) + '\n', 'utf8');
console.log('Wrote: ' + target);
" "$TARGET" "$ACTION"
