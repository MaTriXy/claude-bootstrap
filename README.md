# Claude Bootstrap

> An opinionated project initialization system for Claude Code. **Agent teams by default, strict TDD pipeline, multi-engine code review, security-first.**

**The bottleneck has moved from code generation to code comprehension.** AI can generate infinite code, but humans still need to review, understand, and maintain it. Claude Bootstrap provides guardrails that keep AI-generated code simple, secure, and verifiable.

**New in v3.0.0:** Aligned with Claude Code internals. Stop hooks for real TDD loops (replaces Ralph Wiggum plugin). `@include` directives for modular CLAUDE.md. Conditional rules with `paths:` frontmatter. Pre-configured permissions. Agent definitions with proper frontmatter. `CLAUDE.local.md` for private developer overrides.

## Core Philosophy

```
┌────────────────────────────────────────────────────────────────┐
│  TDD LOOPS VIA STOP HOOKS                                      │
│  ─────────────────────────────────────────────────────────────│
│  Stop hooks run tests after each Claude response.              │
│  Failures feed back automatically. Claude iterates until green.│
│  Real Claude Code infrastructure — no plugins needed.          │
├────────────────────────────────────────────────────────────────┤
│  TESTS FIRST, ALWAYS                                           │
│  ─────────────────────────────────────────────────────────────│
│  Features: Write tests → Watch them fail → Implement → Pass    │
│  Bugs: Find test gap → Write failing test → Fix → Pass         │
│  No code ships without a test that failed first.               │
├────────────────────────────────────────────────────────────────┤
│  SIMPLICITY IS THE GOAL                                        │
│  ─────────────────────────────────────────────────────────────│
│  20 lines per function │ 200 lines per file │ 3 params max     │
│  Enforced via .claude/rules/ with paths: frontmatter.          │
├────────────────────────────────────────────────────────────────┤
│  SECURITY BY DEFAULT                                           │
│  ─────────────────────────────────────────────────────────────│
│  No secrets in code │ Permission deny rules for .env files     │
│  Dependency scanning │ Pre-commit hooks │ CI enforcement       │
├────────────────────────────────────────────────────────────────┤
│  AGENT TEAMS BY DEFAULT                                        │
│  ─────────────────────────────────────────────────────────────│
│  Every project runs as a coordinated team of AI agents.        │
│  Agent definitions use proper frontmatter: tools, model,       │
│  maxTurns, effort, disallowedTools.                            │
├────────────────────────────────────────────────────────────────┤
│  CONDITIONAL RULES                                             │
│  ─────────────────────────────────────────────────────────────│
│  Rules in .claude/rules/ activate based on file paths.         │
│  React rules only load when editing .tsx files.                │
│  Python rules only load when editing .py files.                │
│  Saves tokens. Reduces noise. More targeted guidance.          │
└────────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Clone and install (clone anywhere you like)
git clone https://github.com/alinaqi/claude-bootstrap.git
cd claude-bootstrap && ./install.sh

# In any project directory
claude
> /initialize-project
```

Claude will:
1. **Validate tools** - Check gh, vercel, supabase CLIs
2. **Ask questions** - Language, framework, AI-first?, database, graph analysis level
3. **Set up repository** - Create or connect GitHub repo
4. **Create structure** - Skills, rules, settings, security, CI/CD, specs, todos
5. **Copy settings.json** - Pre-configured permissions and Stop hooks
6. **Generate CLAUDE.md** - With `@include` directives for modular skills
7. **Generate CLAUDE.local.md** - Template for private developer overrides
8. **Spawn agent team** - Deploy Team Lead + Quality + Security + Review + Merger + Feature agents

## How TDD Loops Work (Stop Hooks)

**No plugins. No fake commands.** Claude Code's Stop hook runs a script when Claude finishes a response. Exit code 2 feeds stderr back to Claude and continues the conversation.

```
┌─────────────────────────────────────────────────────────────┐
│  1. You say: "Add email validation to signup"               │
│  2. Claude writes tests + implementation                    │
│  3. Claude finishes response                                │
│  4. Stop hook runs: npm test && npm run lint                │
│  5a. All pass (exit 0) → Done!                              │
│  5b. Failures (exit 2) → stderr fed back to Claude          │
│  6. Claude sees failures, fixes, finishes again             │
│  7. Stop hook runs again → repeat until green               │
└─────────────────────────────────────────────────────────────┘
```

**Configuration** in `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "scripts/tdd-loop-check.sh",
        "timeout": 60,
        "statusMessage": "Running tests..."
      }]
    }]
  }
}
```

The `tdd-loop-check.sh` script runs tests, lint, and typecheck. It tracks iteration count (max 25) and distinguishes code errors (loop) from environment errors (stop).

## @include Directives

CLAUDE.md uses `@include` to modularly load skills:

```markdown
# CLAUDE.md
@.claude/skills/base/SKILL.md
@.claude/skills/iterative-development/SKILL.md
@.claude/skills/security/SKILL.md
```

These are **resolved at load time** by Claude Code — the content is recursively inlined (max depth 5, cycle detection built in). This means skills actually become part of the prompt instead of just being listed as text.

## Conditional Rules

Rules in `.claude/rules/` use YAML frontmatter with `paths:` to activate only when relevant files are being edited:

```yaml
# .claude/rules/react.md
---
paths: ["src/components/**", "**/*.tsx"]
---
Prefer functional components with hooks...
```

```yaml
# .claude/rules/python.md
---
paths: ["**/*.py"]
---
Use type hints, pytest, ruff...
```

**Included rules:**

| Rule | Activates When |
|------|----------------|
| `quality-gates.md` | Always (no paths: filter) |
| `tdd-workflow.md` | Always |
| `security.md` | Always |
| `react.md` | Editing .tsx/.jsx files |
| `typescript.md` | Editing .ts/.tsx files |
| `python.md` | Editing .py files |
| `nodejs-backend.md` | Editing api/routes/server files |

## Smarter Compaction (PreCompact Hook)

Claude Code's built-in compaction fires at ~83% context and summarizes everything into 20K tokens using a generic 9-section template. It doesn't know what YOUR project cares about.

The PreCompact hook fixes this by injecting **project-specific preservation priorities** into the summarizer:

```
┌─────────────────────────────────────────────────────────────┐
│  Built-in compaction:                                       │
│  "Summarize this conversation" → generic summary            │
├─────────────────────────────────────────────────────────────┤
│  With PreCompact hook:                                      │
│  "Summarize, but preserve ALL schema decisions verbatim,    │
│   keep exact error messages, keep API contract details,     │
│   reference these Key Decisions by name, and here's the     │
│   current git state to include" → project-aware summary     │
└─────────────────────────────────────────────────────────────┘
```

The hook auto-detects:
- **Project type** (TypeScript/Next.js, Python/FastAPI, Flutter, etc.)
- **Schema files** (Drizzle, Prisma, SQLAlchemy) → tells summarizer to preserve schema discussion
- **API directories** → tells summarizer to preserve endpoint paths and contracts
- **Key Decisions from CLAUDE.md** → tells summarizer to reference them by name
- **Git state** → injects branch, uncommitted changes, staged files

Zero overhead during normal usage. Only runs when compaction actually fires.

## Pre-configured Permissions

`.claude/settings.json` includes permission rules so users don't get pestered for routine operations:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test *)",
      "Bash(npm run lint *)",
      "Bash(pytest *)",
      "Bash(git status *)",
      "Bash(gh pr *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Write(.env)",
      "Write(.env.*)"
    ]
  }
}
```

## CLAUDE.local.md (Private Overrides)

Each developer gets a `.gitignore`'d `CLAUDE.local.md` for personal preferences:

```markdown
# My Preferences
- I prefer verbose explanations
- My local DB runs on port 5433
- Use pnpm instead of npm
```

This loads at **higher priority** than project `CLAUDE.md` — personal preferences override team config without polluting the repo.

## Agent Teams

Every project runs as a coordinated team of AI agents with **proper frontmatter definitions**:

```yaml
# .claude/agents/team-lead.md
---
name: team-lead
description: Orchestrates the agent team
model: sonnet
tools: [Read, Glob, Grep, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage]
disallowedTools: [Write, Edit, Bash]
maxTurns: 50
effort: high
---
```

**Default Team:**

| Agent | Role | Can Edit Code? |
|-------|------|----------------|
| **Team Lead** | Orchestrates, assigns tasks (never writes code) | No |
| **Quality Agent** | Verifies RED/GREEN TDD phases, coverage >= 80% | No |
| **Security Agent** | OWASP scanning, secrets detection, dependency audit | No |
| **Code Review Agent** | Multi-engine reviews | No |
| **Merger Agent** | Creates feature branches and PRs via `gh` CLI | No |
| **Feature Agent (x N)** | One per feature, follows strict TDD pipeline | Yes |

**Pipeline (enforced by task dependencies):**

```
Spec > Spec Review > Tests > RED Verify > Implement >
GREEN Verify > Validate > Code Review > Security > Branch+PR
```

```bash
# Auto-spawned by /initialize-project, or manually:
/spawn-team
```

## What Gets Created

```
your-project/
├── .claude/
│   ├── agents/               # Agent definitions with frontmatter
│   │   ├── team-lead.md      # name, model, tools, disallowedTools, maxTurns
│   │   ├── quality.md
│   │   ├── security.md
│   │   ├── code-review.md
│   │   ├── merger.md
│   │   └── feature.md
│   ├── rules/                # Conditional rules (paths: frontmatter)
│   │   ├── quality-gates.md  # Always active
│   │   ├── tdd-workflow.md   # Always active
│   │   ├── security.md       # Always active
│   │   ├── react.md          # Active on .tsx/.jsx files
│   │   ├── typescript.md     # Active on .ts/.tsx files
│   │   ├── python.md         # Active on .py files
│   │   └── nodejs-backend.md # Active on api/routes/server files
│   ├── skills/               # Skills loaded via @include
│   │   ├── base/SKILL.md
│   │   ├── iterative-development/SKILL.md
│   │   ├── security/SKILL.md
│   │   └── [framework]/SKILL.md
│   └── settings.json         # Permissions + Stop hooks
├── scripts/
│   ├── tdd-loop-check.sh     # Stop hook script for TDD loops
│   └── pre-compact.sh        # PreCompact hook for smarter compaction
├── .github/workflows/
│   ├── quality.yml
│   └── security.yml
├── _project_specs/
│   ├── features/
│   └── todos/
├── CLAUDE.md                 # @include directives, project context
└── CLAUDE.local.md           # Private developer overrides (gitignored)
```

## Commit Hygiene

```
┌─────────────────────────────────────────────────────────────┐
│  COMMIT SIZE THRESHOLDS                                     │
├─────────────────────────────────────────────────────────────┤
│  OK:     ≤ 5 files,  ≤ 200 lines                           │
│  WARN:   6-10 files, 201-400 lines  → "Commit soon"        │
│  STOP:   > 10 files, > 400 lines    → "Commit NOW"         │
└─────────────────────────────────────────────────────────────┘
```

## Skills Included (57 Skills)

### Core Skills
| Skill | Purpose |
|-------|---------|
| `base.md` | Universal patterns, constraints, TDD workflow, atomic todos |
| `iterative-development.md` | TDD loops via Stop hooks (replaces Ralph Wiggum) |
| `code-review.md` | Mandatory code reviews - Claude, Codex, Gemini, or multi-engine |
| `codex-review.md` | OpenAI Codex CLI code review |
| `gemini-review.md` | Google Gemini CLI code review, 1M token context |
| `workspace.md` | Multi-repo workspace awareness, contract tracking |
| `commit-hygiene.md` | Atomic commits, PR size limits |
| `code-deduplication.md` | Prevent semantic duplication with capability index |
| `agent-teams.md` | Agent team workflow with proper frontmatter definitions |
| `ticket-craft.md` | AI-native ticket writing optimized for Claude Code |
| `team-coordination.md` | Multi-person projects, shared state, handoffs |
| `code-graph.md` | Persistent code graph via MCP |
| `cpg-analysis.md` | Deep CPG analysis - Joern + CodeQL |
| `security.md` | OWASP patterns, secrets management |
| `credentials.md` | Centralized API key management |
| `session-management.md` | Context preservation, resumability |
| `project-tooling.md` | gh, vercel, supabase CLI + deployment |
| `existing-repo.md` | Analyze existing repos, setup guardrails |

### Language & Framework Skills
| Skill | Purpose |
|-------|---------|
| `python.md` | Python + ruff + mypy + pytest |
| `typescript.md` | TypeScript strict + eslint + jest |
| `nodejs-backend.md` | Express/Fastify patterns, repositories |
| `react-web.md` | React + hooks + React Query + Zustand |
| `react-native.md` | Mobile patterns, platform-specific code |
| `android-java.md` | Android Java with MVVM, ViewBinding, Espresso |
| `android-kotlin.md` | Android Kotlin with Coroutines, Jetpack Compose, Hilt |
| `flutter.md` | Flutter with Riverpod, Freezed, go_router |

### UI Skills
| Skill | Purpose |
|-------|---------|
| `ui-web.md` | Web UI - Tailwind, dark mode, accessibility |
| `ui-mobile.md` | Mobile UI - React Native, iOS/Android patterns |
| `ui-testing.md` | Visual testing |
| `playwright-testing.md` | E2E testing - Playwright, Page Objects |
| `user-journeys.md` | User experience flows |
| `pwa-development.md` | Progressive Web Apps - service workers, offline |

### Database & Backend Skills
| Skill | Purpose |
|-------|---------|
| `database-schema.md` | Schema awareness |
| `supabase.md` | Core Supabase CLI, migrations, RLS |
| `supabase-nextjs.md` | Next.js + Supabase + Drizzle ORM |
| `supabase-python.md` | FastAPI + Supabase |
| `supabase-node.md` | Express/Hono + Supabase |
| `firebase.md` | Firebase Firestore, Auth, Storage |
| `cloudflare-d1.md` | Cloudflare D1 SQLite with Workers |
| `aws-dynamodb.md` | AWS DynamoDB single-table design |
| `aws-aurora.md` | AWS Aurora Serverless v2 |
| `azure-cosmosdb.md` | Azure Cosmos DB |

### AI & Agentic Skills
| Skill | Purpose |
|-------|---------|
| `agentic-development.md` | Build AI agents |
| `llm-patterns.md` | AI-first apps, LLM testing |
| `ai-models.md` | Latest models reference |

### Content, Integration & Other Skills
| Skill | Purpose |
|-------|---------|
| `aeo-optimization.md` | AI Engine Optimization |
| `web-content.md` | SEO + AI discovery |
| `site-architecture.md` | Technical SEO |
| `web-payments.md` | Stripe Checkout, subscriptions |
| `reddit-api.md` | Reddit API |
| `reddit-ads.md` | Reddit Ads API + agentic optimization |
| `ms-teams-apps.md` | Microsoft Teams bots |
| `posthog-analytics.md` | PostHog analytics |
| `shopify-apps.md` | Shopify app development |
| `woocommerce.md` | WooCommerce REST API |
| `medusa.md` | Medusa headless commerce |
| `klaviyo.md` | Klaviyo email/SMS marketing |

## Usage Patterns

### New Project
```bash
mkdir my-new-app && cd my-new-app
claude
> /initialize-project
```

### Existing Project
```bash
cd my-existing-app
claude
> /initialize-project
# Auto-detects existing code → runs analysis first
```

### Update Skills Globally
```bash
cd "$(cat ~/.claude/.bootstrap-dir)"
git pull
./install.sh
```

## Prerequisites

```bash
# GitHub CLI
brew install gh && gh auth login

# Vercel CLI (optional)
npm i -g vercel && vercel login

# Supabase CLI (optional)
brew install supabase/tap/supabase && supabase login
```

## Key Differences from v2.x

| Feature | v2.x (Old) | v3.0.0 (New) |
|---------|-------------|---------------|
| **TDD Loops** | Ralph Wiggum plugin (doesn't exist) | Stop hooks (real Claude Code infrastructure) |
| **CLAUDE.md** | Lists skills as text | `@include` directives (actually load at parse time) |
| **Quality Rules** | In CLAUDE.md as prose | `.claude/rules/` with `paths:` frontmatter |
| **Agent Teams** | Required `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | Works natively via `.claude/agents/` |
| **Agent Definitions** | Plain markdown | Proper frontmatter: tools, model, maxTurns, effort |
| **Permissions** | Manual approval for everything | Pre-configured allow/deny in settings.json |
| **Developer Overrides** | None | `CLAUDE.local.md` (gitignored, higher priority) |
| **Framework Rules** | Always loaded (57 skills = token waste) | Conditional rules activate by file path |
| **Compaction** | Generic summarization | PreCompact hook injects project-specific priorities |
| **Enforcement** | "STRICTLY ENFORCED" prose | Real hooks that run code |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT - See [LICENSE](LICENSE)

## Credits

Built on learnings from 100+ projects across customer experience management, agentic AI platforms, mobile apps, and full-stack web applications.

---

**Need help scaling AI in your org?** [Claude Code & MCP experts](https://leanai.ventures/aiops/claude)
