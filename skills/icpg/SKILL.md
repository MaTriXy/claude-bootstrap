---
name: icpg
description: Intent-enhanced Code Property Graph — track WHY code exists, not just WHAT it is. Links tasks/goals to code symbols with typed edges for traceability, blast radius, and drift detection.
---

# iCPG Skill (Intent-enhanced Code Property Graph)

*Load with: base.md + code-graph.md*

**Purpose:** Add an Intent Graph layer on top of code structure so every
function, class, and module is traceable to the goal that created it,
the agent or human that owns it, and whether it's still doing what it
was supposed to do.

```
┌────────────────────────────────────────────────────────────────┐
│  iCPG = AST + CFG + PDG + IG (Intent Graph)                    │
│  ─────────────────────────────────────────────────────────────│
│  AST  = Abstract Syntax Tree (structure)      ← existing       │
│  CFG  = Control Flow Graph (execution paths)  ← existing       │
│  PDG  = Program Dependency Graph              ← existing       │
│  IG   = Intent Graph (WHY layer)              ← THIS SKILL     │
│                                                                │
│  The IG stores intents (goals/tasks), links them to code       │
│  symbols via typed edges, and detects when code drifts from    │
│  its original purpose.                                         │
└────────────────────────────────────────────────────────────────┘
```

---

## Core Concepts

### IntentNode — one per task/goal

```
id              Unique identifier (task ID, commit hash, or generated)
goal            Natural language: what is this trying to achieve (one sentence)
scope           Files/modules expected to be touched
owner           Human accountable
agent           Which AI agent if agent-written
status          proposed | executing | fulfilled | drifted | abandoned
source          manual | commit | migration | inferred
```

### DriftEvent — auto-generated when behavior diverges from intent

```
symbol          The code symbol that changed
from_intent     The intent it was supposed to fulfill
severity        0-1 (how far it drifted)
```

### Six Edge Types

```
CREATES      Intent  → Symbol   (this intent created this function)
MODIFIES     Intent  → Symbol   (this intent changed this function)
REQUIRES     Intent  → Intent   (B depends on A being done first)
DUPLICATES   Intent  → Intent   (these two goals overlap)
VALIDATED_BY Intent  → Test     (this test proves the intent was satisfied)
DRIFTS_FROM  Symbol  → Intent   (this symbol no longer does what it was made for)
```

---

## What You Can Query

| Question | How |
|----------|-----|
| "What was the original goal of this function?" | Follow CREATES edge backwards from symbol |
| "If I change this, what breaks?" | Traverse PDG + REQUIRES edges for blast radius |
| "Is my codebase drifting from its design?" | Count DRIFTS_FROM edges per module |
| "Did someone already solve this problem?" | Find DUPLICATES matches before writing new code |
| "Which agent wrote this and why?" | Read owner + goal on the IntentNode |
| "Do my tests actually prove intent?" | Gap between VALIDATED_BY coverage and symbols |

---

## Implementation Guide

### Storage (Supabase / SQLite / Postgres)

Four tables:

```sql
-- Intents: goals/tasks that drive code changes
CREATE TABLE intents (
    id          TEXT PRIMARY KEY,
    goal        TEXT NOT NULL,
    scope       TEXT[],
    owner       TEXT,
    agent       TEXT,
    status      TEXT DEFAULT 'proposed',  -- proposed|executing|fulfilled|drifted|abandoned
    source      TEXT DEFAULT 'manual',    -- manual|commit|migration|inferred
    task_id     TEXT,                     -- link to external task tracker
    parent_id   TEXT REFERENCES intents(id),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    fulfilled_at TIMESTAMPTZ
);

-- Symbols: code entities
CREATE TABLE symbols (
    id          TEXT PRIMARY KEY,         -- hash of file:name:type
    name        TEXT NOT NULL,
    file_path   TEXT NOT NULL,
    symbol_type TEXT NOT NULL,            -- function|class|module|route|schema|component
    language    TEXT NOT NULL,
    codebase    TEXT NOT NULL,
    signature   TEXT,                     -- function signature or field list
    checksum    TEXT,                     -- hash of symbol body for drift detection
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Intent edges: relationships
CREATE TABLE intent_edges (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_id     TEXT NOT NULL,
    to_id       TEXT NOT NULL,
    edge_type   TEXT NOT NULL,            -- CREATES|MODIFIES|REQUIRES|DUPLICATES|VALIDATED_BY|DRIFTS_FROM
    confidence  REAL DEFAULT 1.0,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Drift events
CREATE TABLE drift_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol_id       TEXT NOT NULL REFERENCES symbols(id),
    from_intent_id  TEXT NOT NULL REFERENCES intents(id),
    severity        REAL DEFAULT 0.5,
    description     TEXT,
    resolved        BOOLEAN DEFAULT FALSE,
    detected_at     TIMESTAMPTZ DEFAULT NOW()
);
```

### Symbol Extraction

**Python** — Use `ast` module (stdlib):
```python
import ast
tree = ast.parse(source)
for node in ast.walk(tree):
    if isinstance(node, ast.ClassDef):
        # Extract class name, bases, line numbers
    if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
        # Extract function name, params, return type, decorators
```

**Elixir** — Regex patterns:
```python
import re
# Modules: defmodule X do
# Functions: def/defp name(args)
# Schemas: schema "table" do ... field :name, :type
# GenServers: use GenServer
```

**TypeScript/React** — Regex patterns:
```python
# Components: export function/const X (returning JSX)
# Hooks: export function use*
# Types: export interface/type X
# Routes: <Route path="..." element={...} />
```

### Intent Capture

**Going forward** — Create an IntentNode before each task:
```markdown
## Before writing code:
1. What is the goal? (one sentence)
2. Which files will you touch?
3. Does an existing intent already cover this?

## After completing:
1. Which symbols did you create/modify?
2. Did you touch anything outside your original scope? (potential drift)
3. Update intent status to 'fulfilled'
```

**Historical** — Infer intents from git history:
```bash
# For each commit cluster in the last 90 days:
# 1. Extract commit messages + PR descriptions
# 2. LLM infers the intent
# 3. Link to symbols via git diff file/function names
```

### Drift Detection

After any commit:
1. Get symbols that changed (from git diff)
2. Find their creating intent (CREATES edge)
3. Compare current signature/checksum against what it was when intent was fulfilled
4. If changed without a new MODIFIES intent → create DriftEvent

---

## Integration with Claude Code

### Hooks (recommended)

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "http",
        "url": "http://localhost:PORT/api/hooks/pre-edit",
        "timeout": 5
      }]
    }]
  }
}
```

The pre-edit hook queries iCPG for:
- Symbols in the file being edited
- Their creating intents (why they exist)
- Blast radius (what depends on them)
- Signatures to preserve (contracts)

Claude Code sees this before every edit:
```
FILE SYMBOLS (5 in app/services/surveys.py):
  class SurveyService | Intent: BE-031 Survey transformer
  function create(self, org_id: int) → Survey | Intent: BE-031

BLAST RADIUS:
  BE-031: 106 symbols, 7 dependent tasks (BE-032, BE-033, FE-002)

PRESERVE these function signatures unless the task requires changing them.
```

### Slash Commands

```
/icpg-impact BE-001        # Blast radius of a task
/icpg-impact SurveyService # What depends on this symbol
/icpg-why create_survey    # Why does this function exist
/icpg-drift                # Show all unresolved drift
```

---

## Workflow: Before Any Code Change

```
0. INTENT     → Create or identify the intent for this change
1. LOCATE     → Find symbols via search_graph or iCPG
2. BLAST      → Check blast radius: what depends on this?
3. CONTRACTS  → Note function signatures that must be preserved
4. CHANGE     → Make the edit
5. VERIFY     → Run tests, check for drift
6. RECORD     → Update intent status, link new symbols
```

---

## Best Practices

| Do | Don't |
|----|-------|
| Create an intent before every non-trivial change | Start coding without stating the goal |
| Check blast radius before modifying shared code | Assume your change is isolated |
| Record which symbols you created/modified | Leave intent in 'executing' forever |
| Check for DUPLICATES before building something new | Rebuild what already exists |
| Use VALIDATED_BY edges to link tests to intents | Write tests that don't trace to a goal |
| Review DRIFTS_FROM after large refactors | Ignore drift accumulation |

---

## Scaling iCPG

| Codebase Size | Storage | Approach |
|---------------|---------|----------|
| < 500 files | SQLite | Single-file DB, fast queries |
| 500-5,000 files | Supabase/Postgres | Schema-scoped tables, indexes |
| 5,000+ files | Supabase + materialized views | Pre-compute blast radius, cache hot queries |

For multi-repo projects, use a `codebase` column to partition symbols and run
cross-repo dependency analysis via shared intent IDs.

---

## Anti-Patterns

| Anti-Pattern | Do This Instead |
|-------------|-----------------|
| Skipping intent creation ("I'll document later") | Spend 30 seconds stating the goal upfront |
| Huge intents covering 20 files | One intent per logical change, max 5-7 files |
| Ignoring drift events | Review weekly, resolve or create new intents |
| Using iCPG only for new code | Backfill historical intents from git log |
| Storing full source code in symbols | Store signature + checksum only — read source from files |
