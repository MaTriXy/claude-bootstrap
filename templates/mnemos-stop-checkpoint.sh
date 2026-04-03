#!/bin/bash
# Mnemos Stop Hook — writes incremental checkpoint when agent stops.
#
# Captures final session state so the next session can resume cleanly.
#
# Install: add to .claude/settings.json under hooks.Stop

MNEMOS_CMD=""
if command -v mnemos &>/dev/null; then
    MNEMOS_CMD="mnemos"
elif python3 -m mnemos --version &>/dev/null 2>&1; then
    MNEMOS_CMD="python3 -m mnemos"
fi

if [ -z "$MNEMOS_CMD" ]; then
    exit 0
fi

# Only checkpoint if Mnemos is initialized
if [ ! -f ".mnemos/mnemo.db" ]; then
    exit 0
fi

# Write checkpoint
$MNEMOS_CMD checkpoint --force &>/dev/null

exit 0
