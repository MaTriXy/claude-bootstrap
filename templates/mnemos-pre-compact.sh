#!/bin/bash
# Mnemos PreCompact Hook — emergency checkpoint + typed preservation.
#
# Runs BEFORE Claude Code's built-in compaction summarizer.
# Writes emergency checkpoint, then outputs preservation instructions
# that tell the summarizer what to keep.
#
# Install: add to .claude/settings.json under hooks.PreCompact
# This EXTENDS (not replaces) the existing pre-compact.sh

# ─── 1. Write emergency checkpoint ───

MNEMOS_CMD=""
if command -v mnemos &>/dev/null; then
    MNEMOS_CMD="mnemos"
elif python3 -m mnemos --version &>/dev/null 2>&1; then
    MNEMOS_CMD="python3 -m mnemos"
fi

if [ -n "$MNEMOS_CMD" ]; then
    $MNEMOS_CMD checkpoint --force &>/dev/null
fi

# ─── 2. Extract typed preservation priorities from MnemoGraph ───

MNEMOS_PRIORITIES=""
if [ -f ".mnemos/mnemo.db" ] && [ -n "$MNEMOS_CMD" ]; then
    MNEMOS_PRIORITIES=$(python3 -c "
import json, sys
sys.path.insert(0, '$(dirname "$(dirname "$0")")/scripts')

try:
    from mnemos.store import MnemosStore
    store = MnemosStore('.')
    if not store.exists():
        sys.exit(0)

    # Get nodes by priority
    goals = store.get_by_type('goal')
    constraints = store.get_by_type('constraint')
    working = store.get_by_type('working')
    results = store.get_by_type('result')

    lines = []
    if goals:
        lines.append('GOAL (NEVER DROP):')
        for g in goals[:5]:
            lines.append(f'  - {g.content[:100]}')

    if constraints:
        lines.append('CONSTRAINTS (NEVER DROP):')
        for c in constraints[:10]:
            lines.append(f'  - {c.content[:100]}')

    if working:
        lines.append('CURRENT TASK (HIGH PRIORITY):')
        for w in working[:3]:
            lines.append(f'  - {w.content[:100]}')

    if results:
        lines.append('RESULTS (KEEP SUMMARIES):')
        for r in results[:5]:
            summary = r.summary or r.content[:80]
            lines.append(f'  - {summary}')

    print('\n'.join(lines))
except Exception as e:
    pass
" 2>/dev/null)
fi

# ─── 3. Output preservation instructions for summarizer ───

cat <<INSTRUCTIONS
## Mnemos Memory Preservation (Pre-Compaction)

An emergency checkpoint has been written to .mnemos/checkpoint-latest.json.

### CRITICAL: Typed Preservation Priorities

The following memory nodes have TYPED eviction policies. The summarizer MUST
preserve them according to their type:

**NEVER EVICT** (include verbatim in summary):
- GoalNodes: The task's primary objective
- ConstraintNodes: Invariants and contracts that must not be violated

**COMPRESS BUT KEEP** (include summary, not full content):
- WorkingNodes: Current in-progress reasoning
- ResultNodes: Completed sub-task results (keep summaries)

**OK TO DROP** (can be re-derived from disk):
- ContextNodes: File contents, tool outputs
- Full tool call results (keep only findings)

INSTRUCTIONS

if [ -n "$MNEMOS_PRIORITIES" ]; then
cat <<INSTRUCTIONS

### Active Memory Nodes (from MnemoGraph)

$MNEMOS_PRIORITIES

These nodes represent the agent's active working memory. The summarizer
MUST preserve Goal and Constraint nodes VERBATIM. Working and Result nodes
should be summarized but not dropped entirely.

INSTRUCTIONS
fi

# ─── 4. Run existing pre-compact.sh if present ───

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/pre-compact.sh" ]; then
    bash "$SCRIPT_DIR/pre-compact.sh"
fi

exit 0
