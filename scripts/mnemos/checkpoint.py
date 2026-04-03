"""Checkpoint write/load for Mnemos session persistence."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

from .models import CheckpointNode, _now, _uuid
from .store import MnemosStore


def write_checkpoint(
    store: MnemosStore,
    fatigue_score: float = 0.0,
    icpg_store=None,
    task_id: str | None = None
) -> CheckpointNode:
    """Write a CheckpointNode capturing current MnemoGraph state.

    Always includes: GoalNode content, all ConstraintNodes, current sub-goal.
    Optionally includes: iCPG state, git state, compressed ResultNodes.

    Writes to:
        .mnemos/checkpoint-latest.json  (always overwritten)
        .mnemos/checkpoints/<id>.json   (archived copy)

    Returns the created CheckpointNode.
    """
    # Determine task_id from active GoalNodes
    goal_nodes = store.get_by_type('goal')
    if not task_id and goal_nodes:
        task_id = goal_nodes[0].task_id
    task_id = task_id or 'unknown'

    # Gather goal
    goal_text = '; '.join(n.content for n in goal_nodes) or 'No active goal'

    # Gather constraints (never evicted)
    constraint_nodes = store.get_by_type('constraint')
    constraints = [n.content for n in constraint_nodes]

    # Gather result summaries (compressed or active)
    result_nodes = store.get_by_type('result')
    results = []
    for rn in result_nodes[:20]:  # Cap at 20 most recent
        if rn.summary:
            results.append(rn.summary)
        elif rn.content:
            results.append(rn.content[:200])

    # Current sub-goal from working nodes
    working_nodes = store.get_by_type('working')
    current_subgoal = working_nodes[0].content if working_nodes else ''

    # Working memory
    working_memory = '\n'.join(
        n.content for n in working_nodes[:3]
    )

    # Git state
    git_state = _get_git_state(store.project_dir)

    # iCPG state
    icpg_state = None
    if icpg_store and icpg_store.exists():
        icpg_state = _get_icpg_state(icpg_store)

    # Node summary (counts by type and status)
    stats = store.get_stats()
    node_summary = {
        'total': stats['total_nodes'],
        'active': stats['active'],
        'compressed': stats['compressed'],
        'by_type': stats['by_type']
    }

    cp = CheckpointNode(
        id=_uuid(),
        task_id=task_id,
        goal=goal_text,
        active_constraints=constraints,
        active_results=results,
        current_subgoal=current_subgoal,
        working_memory=working_memory,
        fatigue_at_checkpoint=fatigue_score,
        git_state=git_state,
        icpg_state=icpg_state,
        node_summary=node_summary,
        created_at=_now()
    )

    # Persist to DB
    store.save_checkpoint(cp)

    # Write to JSON files
    cp_data = _checkpoint_to_dict(cp)

    # Latest checkpoint (overwrite)
    latest_path = store.mnemos_dir / 'checkpoint-latest.json'
    latest_path.write_text(json.dumps(cp_data, indent=2))

    # Archived copy
    archive_dir = store.mnemos_dir / 'checkpoints'
    archive_dir.mkdir(exist_ok=True)
    archive_path = archive_dir / f'{cp.id}.json'
    archive_path.write_text(json.dumps(cp_data, indent=2))

    return cp


def load_checkpoint(
    project_dir: str = '.', path: str | None = None
) -> str | None:
    """Load latest checkpoint and format as context for session injection.

    Returns formatted markdown string, or None if no checkpoint exists.
    """
    if path:
        cp_path = Path(path)
    else:
        cp_path = Path(project_dir).resolve() / '.mnemos' / 'checkpoint-latest.json'

    if not cp_path.exists():
        return None

    try:
        data = json.loads(cp_path.read_text())
    except (json.JSONDecodeError, OSError):
        return None

    return _format_checkpoint(data)


def _format_checkpoint(data: dict) -> str:
    """Format checkpoint data as structured markdown for context injection."""
    lines = []
    lines.append('## Mnemos Session Resume')
    lines.append(f'Checkpoint: {data.get("id", "unknown")[:8]}')
    lines.append(f'Created: {data.get("created_at", "unknown")}')
    lines.append(f'Fatigue at checkpoint: {data.get("fatigue_at_checkpoint", 0):.2f}')
    lines.append('')

    # Goal
    lines.append('### Goal')
    lines.append(data.get('goal', 'No goal recorded'))
    lines.append('')

    # Constraints
    constraints = data.get('active_constraints', [])
    if constraints:
        lines.append('### Active Constraints (DO NOT VIOLATE)')
        for c in constraints:
            lines.append(f'- {c}')
        lines.append('')

    # Current task
    subgoal = data.get('current_subgoal', '')
    if subgoal:
        lines.append('### Current Sub-Goal')
        lines.append(subgoal)
        lines.append('')

    # Working memory
    working = data.get('working_memory', '')
    if working:
        lines.append('### Working Memory')
        lines.append(working)
        lines.append('')

    # Progress (result summaries)
    results = data.get('active_results', [])
    if results:
        lines.append('### Progress So Far')
        for r in results:
            lines.append(f'- {r}')
        lines.append('')

    # Git state
    git = data.get('git_state', {})
    if git.get('branch'):
        lines.append('### Git State')
        lines.append(f'Branch: {git["branch"]}')
        if git.get('uncommitted'):
            lines.append('Uncommitted files:')
            for f in git['uncommitted'][:10]:
                lines.append(f'  - {f}')
        lines.append('')

    # iCPG state
    icpg = data.get('icpg_state')
    if icpg:
        lines.append('### iCPG Context')
        if icpg.get('active_reason'):
            lines.append(f'Active intent: {icpg["active_reason"]}')
        if icpg.get('unresolved_drift'):
            lines.append(f'Unresolved drift: {icpg["unresolved_drift"]}')
        if icpg.get('stats'):
            s = icpg['stats']
            lines.append(
                f'Graph: {s.get("reasons", 0)} intents, '
                f'{s.get("symbols", 0)} symbols'
            )
        lines.append('')

    # Node summary
    summary = data.get('node_summary', {})
    if summary:
        lines.append('### MnemoGraph Summary')
        lines.append(
            f'Nodes: {summary.get("active", 0)} active, '
            f'{summary.get("compressed", 0)} compressed, '
            f'{summary.get("total", 0)} total'
        )
        by_type = summary.get('by_type', {})
        if by_type:
            parts = [f'{t}:{c}' for t, c in by_type.items()]
            lines.append(f'Types: {", ".join(parts)}')

    return '\n'.join(lines)


def _get_git_state(project_dir: Path) -> dict:
    """Get current git branch and uncommitted files."""
    state = {}
    try:
        result = subprocess.run(
            ['git', 'branch', '--show-current'],
            capture_output=True, text=True, timeout=5,
            cwd=str(project_dir)
        )
        if result.returncode == 0:
            state['branch'] = result.stdout.strip()

        result = subprocess.run(
            ['git', 'diff', '--name-only'],
            capture_output=True, text=True, timeout=5,
            cwd=str(project_dir)
        )
        if result.returncode == 0:
            files = [
                f.strip() for f in result.stdout.strip().split('\n')
                if f.strip()
            ]
            state['uncommitted'] = files

        result = subprocess.run(
            ['git', 'diff', '--cached', '--name-only'],
            capture_output=True, text=True, timeout=5,
            cwd=str(project_dir)
        )
        if result.returncode == 0:
            staged = [
                f.strip() for f in result.stdout.strip().split('\n')
                if f.strip()
            ]
            if staged:
                state['staged'] = staged

    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return state


def _get_icpg_state(icpg_store) -> dict:
    """Extract summary iCPG state for checkpoint."""
    state = {}
    try:
        stats = icpg_store.get_stats()
        state['stats'] = stats

        # Find most recent executing reason
        executing = icpg_store.list_reasons(status='executing')
        if executing:
            r = executing[-1]
            state['active_reason'] = f'{r.id[:8]} -- {r.goal}'

        # Unresolved drift count
        drift = icpg_store.get_unresolved_drift()
        state['unresolved_drift'] = len(drift)
    except Exception:
        pass
    return state


def _checkpoint_to_dict(cp: CheckpointNode) -> dict:
    """Serialize CheckpointNode to JSON-safe dict."""
    return {
        'id': cp.id,
        'task_id': cp.task_id,
        'goal': cp.goal,
        'active_constraints': cp.active_constraints,
        'active_results': cp.active_results,
        'current_subgoal': cp.current_subgoal,
        'working_memory': cp.working_memory,
        'fatigue_at_checkpoint': cp.fatigue_at_checkpoint,
        'git_state': cp.git_state,
        'icpg_state': cp.icpg_state,
        'node_summary': cp.node_summary,
        'created_at': cp.created_at
    }
