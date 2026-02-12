# Claude Bootstrap

> An opinionated project initialization system for Claude Code. **Agent teams by default, strict TDD pipeline, multi-engine code review, security-first.**

**The bottleneck has moved from code generation to code comprehension.** AI can generate infinite code, but humans still need to review, understand, and maintain it. Claude Bootstrap provides guardrails that keep AI-generated code simple, secure, and verifiable.

**New in v2.5.0:** Every project now runs as a coordinated team of AI agents. A Team Lead orchestrates, a Quality Agent enforces TDD, a Security Agent scans for vulnerabilities, a Code Review Agent runs multi-engine reviews, a Merger Agent creates PRs, and dedicated Feature Agents implement each feature in parallel - all following an immutable pipeline: **Spec > Tests > Fail > Implement > Pass > Review > Security > PR.**

## Core Philosophy

```
┌────────────────────────────────────────────────────────────────┐
│  ITERATIVE LOOPS BY DEFAULT                                    │
│  ─────────────────────────────────────────────────────────────│
│  Every task runs in a self-referential loop until tests pass.  │
│  Claude iterates autonomously. You describe what, not how.     │
│  Powered by Ralph Wiggum - iteration > perfection.             │
├────────────────────────────────────────────────────────────────┤
│  TESTS FIRST, ALWAYS                                           │
│  ─────────────────────────────────────────────────────────────│
│  Features: Write tests → Watch them fail → Implement → Pass    │
│  Bugs: Find test gap → Write failing test → Fix → Pass         │
│  No code ships without a test that failed first.               │
├────────────────────────────────────────────────────────────────┤
│  SIMPLICITY IS NON-NEGOTIABLE                                  │
│  ─────────────────────────────────────────────────────────────│
│  20 lines per function │ 200 lines per file │ 3 params max     │
│  If you can't understand the whole system in one session,      │
│  it's too complex.                                             │
├────────────────────────────────────────────────────────────────┤
│  SECURITY BY DEFAULT                                           │
│  ─────────────────────────────────────────────────────────────│
│  No secrets in code │ No secrets in client env vars            │
│  Dependency scanning │ Pre-commit hooks │ CI enforcement       │
├────────────────────────────────────────────────────────────────┤
│  CODE REVIEWS ARE MANDATORY                                    │
│  ─────────────────────────────────────────────────────────────│
│  Every commit requires /code-review before push.               │
│  🔴 Critical + 🟠 High = blocked │ 🟡 Medium + 🟢 Low = can ship │
│  AI catches what humans miss. Humans catch what AI misses.     │
├────────────────────────────────────────────────────────────────┤
│  AGENT TEAMS BY DEFAULT                                        │
│  ─────────────────────────────────────────────────────────────│
│  Every project runs as a coordinated team of AI agents.        │
│  Team Lead + Quality + Security + Review + Merger + Features   │
│  Strict pipeline: Spec > Test > Fail > Build > Pass > PR       │
│  Task dependencies make it impossible to skip steps.           │
└────────────────────────────────────────────────────────────────┘
```

## Why This Exists

After hundreds of AI-assisted projects across Node, React, Python, and React Native, patterns emerged:

1. **Engineers struggle with Claude Code not because of the tool, but because of how they instruct it** - The delta is in the guardrails
2. **Complexity has a ceiling** - There's a point where AI loses coherent understanding of the system. That's a signal, not a failure
3. **Restart is a feature, not failure** - When fixing something increases complexity, restart with learnings. Each iteration is faster

This toolkit encodes those learnings into reusable skills.

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
2. **Ask questions** - Language, framework, AI-first?, database
3. **Set up repository** - Create or connect GitHub repo
4. **Create structure** - Skills, security, CI/CD, specs, todos
5. **Ask for features** - List your key features
6. **Spawn agent team** - Deploy Team Lead + Quality + Security + Review + Merger + Feature agents
7. **Work begins** - Each feature runs the strict TDD pipeline in parallel

## Automatic Iterative Loops (Ralph Wiggum)

**You talk naturally. Claude automatically runs iterative TDD loops.**

```
┌─────────────────────────────────────────────────────────────┐
│  You say: "Add email validation to signup"                  │
├─────────────────────────────────────────────────────────────┤
│  Claude automatically:                                       │
│  1. Extracts requirements from your request                 │
│  2. Structures as TDD loop with completion criteria         │
│  3. Runs /ralph-loop with tests as exit condition           │
│  4. Iterates until all tests pass + lint clean              │
└─────────────────────────────────────────────────────────────┘
```

No need to manually invoke `/ralph-loop`. Just describe what you want:

| You Say | Claude Does |
|---------|-------------|
| "Add user authentication" | Loops until auth tests pass |
| "Fix the login bug" | Finds test gap → writes test → loops until fixed |
| "Build a REST API for todos" | Loops until all endpoint tests pass |
| "Refactor the auth module" | Loops with tests as safety net |

**Opt-out phrases** (for when you don't want loops):
- "Just explain..." → explanation only
- "Quick fix..." → one-liner, no loop
- "Don't loop..." → explicit opt-out

### Setup Ralph Wiggum Plugin

```bash
# Install from official marketplace (in Claude Code)
/plugin install ralph-loop@claude-plugins-official
```

**Troubleshooting: "Source path does not exist: .../ralph-wiggum"**

The plugin was renamed from `ralph-wiggum` to `ralph-loop` in the marketplace. If you see this error, the cache references the old name but the plugin folder uses the new name. Fix with a symlink:

```bash
ln -s ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/ralph-loop \
      ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/ralph-wiggum
```

Then retry `/plugin install ralph-loop@claude-plugins-official`.

## Commit Hygiene (Automatic PR Size Management)

**Claude monitors your changes and advises when to commit before PRs become too large.**

```
┌─────────────────────────────────────────────────────────────┐
│  COMMIT SIZE THRESHOLDS                                     │
├─────────────────────────────────────────────────────────────┤
│  🟢 OK:     ≤ 5 files,  ≤ 200 lines                         │
│  🟡 WARN:   6-10 files, 201-400 lines  → "Commit soon"      │
│  🔴 STOP:   > 10 files, > 400 lines    → "Commit NOW"       │
└─────────────────────────────────────────────────────────────┘
```

**Claude automatically checks and advises:**

| Status | Claude Says |
|--------|-------------|
| 3 files, 95 lines | ✅ Tests passing. Good time to commit! |
| 7 files, 225 lines | 💡 Approaching threshold. Consider committing. |
| 12 files, 400 lines | ⚠️ Changes too large! Commit now. |

**Why this matters:**
- PRs < 200 lines: 15% defect rate
- PRs 200-400 lines: 23% defect rate
- PRs > 400 lines: 40%+ defect rate (rubber-stamped, not reviewed)

**Atomic commit principle:** If you need "and" to describe your commit, split it.

## Agent Teams (Default Workflow)

**Every project runs as a coordinated team of AI agents.** Features are implemented in parallel by dedicated agents following a strict TDD pipeline.

```
┌─────────────────────────────────────────────────────────────┐
│  STRICT FEATURE PIPELINE (IMMUTABLE)                        │
├─────────────────────────────────────────────────────────────┤
│  1. Spec           Feature Agent writes specification       │
│  2. Spec Review    Quality Agent reviews completeness       │
│  3. Tests          Feature Agent writes failing tests       │
│  4. RED Verify     Quality Agent confirms tests FAIL        │
│  5. Implement      Feature Agent writes minimum code        │
│  6. GREEN Verify   Quality Agent confirms tests PASS        │
│  7. Validate       Feature Agent runs lint + typecheck      │
│  8. Code Review    Review Agent runs /code-review           │
│  9. Security Scan  Security Agent runs OWASP checks         │
│  10. Branch + PR   Merger Agent creates branch and PR       │
└─────────────────────────────────────────────────────────────┘
```

**Default Team Roster:**

| Agent | Role |
|-------|------|
| **Team Lead** | Orchestrates, assigns tasks, monitors progress (never writes code) |
| **Quality Agent** | Verifies RED/GREEN TDD phases, enforces coverage >= 80% |
| **Security Agent** | OWASP scanning, secrets detection, dependency audit |
| **Code Review Agent** | Multi-engine reviews (Claude/Codex/Gemini) |
| **Merger Agent** | Creates feature branches and PRs via `gh` CLI |
| **Feature Agent (x N)** | One per feature, follows strict TDD pipeline |

**How it works:**
1. `/initialize-project` asks for your features
2. Spawns 5 permanent agents + 1 feature agent per feature
3. Creates 10-task dependency chain per feature (enforces pipeline order)
4. All features run in parallel - shared agents handle verification as tasks unblock
5. Each feature results in a separate PR with full pipeline results

**Task dependencies make it structurally impossible to skip steps.** A feature agent cannot implement until the quality agent verifies tests fail. The merger cannot create a PR until security scan passes.

**10-task dependency chain per feature:**
```
┌─────────────────────────────────────────────────────────────┐
│  Feature: "auth"                                             │
│                                                              │
│  auth-spec ──> auth-spec-review ──> auth-tests               │
│  (Feature)     (Quality)            (Feature)                │
│                                         │                    │
│  auth-fail-verify ──> auth-implement ──> auth-pass-verify    │
│  (Quality)            (Feature)          (Quality)           │
│                                              │               │
│  auth-validate ──> auth-code-review ──> auth-security        │
│  (Feature)         (Review Agent)       (Security)           │
│                                              │               │
│  auth-branch-pr                                              │
│  (Merger)                                                    │
│                                                              │
│  Each arrow = addBlockedBy dependency                        │
│  Cannot start until predecessor completes                    │
└─────────────────────────────────────────────────────────────┘
```

**Cross-agent verification (trust but verify):**
- Quality Agent independently runs tests (doesn't trust feature agent's report)
- Security Agent independently scans (doesn't trust review agent)
- Merger Agent verifies all predecessors before branching
- Every PR includes full pipeline results: test output, coverage, review, security

**Multiple features run in parallel.** If your project has auth, dashboard, and payments - that's 3 feature agents working simultaneously, with shared Quality/Review/Security/Merger agents processing tasks as they unblock.

```bash
# Auto-spawned by /initialize-project
# Or spawn manually on existing project:
/spawn-team
```

**Environment required:**
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

## Agentic Ad Optimization (Reddit Ads)

**Run automated Reddit ad campaigns with AI-powered optimization.**

```
┌─────────────────────────────────────────────────────────────┐
│  BACKGROUND SERVICE (runs every 4-6 hours)                  │
├─────────────────────────────────────────────────────────────┤
│  1. Fetch performance data (CTR, CPA, ROAS)                 │
│  2. Claude analyzes and recommends actions                  │
│  3. Auto-execute: pause, scale, adjust bids, rotate ads     │
└─────────────────────────────────────────────────────────────┘
```

**AI-driven actions:**

| Action | Trigger | Result |
|--------|---------|--------|
| `PAUSE` | CTR < 0.3%, no conversions | Stop wasting budget |
| `SCALE` | CTR > 1%, CPA < target | Increase budget 1.5x |
| `ADJUST_BID` | Moderate performance | Tweak bids ±10-20% |
| `ROTATE_CREATIVE` | Declining CTR 3+ days | Flag for new creative |

**Deploy as Docker service:**
```bash
docker-compose up -d reddit-ads-optimizer
```

## Multi-Repo Workspace Awareness

**Claude Code now understands your entire workspace - monorepo or multi-repo.**

```
┌─────────────────────────────────────────────────────────────┐
│  /analyze-workspace                                          │
├─────────────────────────────────────────────────────────────┤
│  Discovers: Modules, dependencies, contracts                 │
│  Generates: TOPOLOGY.md, CONTRACTS.md, KEY_FILES.md         │
│  Tracks: API contracts, shared types, cross-repo changes    │
└─────────────────────────────────────────────────────────────┘
```

**Generated context artifacts:**

| Artifact | Purpose |
|----------|---------|
| `TOPOLOGY.md` | What modules exist, their roles, tech stacks |
| `CONTRACTS.md` | API endpoints, shared types, validation status |
| `DEPENDENCY_GRAPH.md` | Who calls whom, change order |
| `KEY_FILES.md` | What to load for each context |
| `CROSS_REPO_INDEX.md` | Search capabilities before reimplementing |

**Contract freshness (automatic):**

| Trigger | Action | Time |
|---------|--------|------|
| Session start | Staleness check | ~5s |
| Post-commit | Auto-sync if contracts changed | ~15s |
| Pre-push | Validation gate | ~10s |

**Cross-repo change detection:**
```
⚠️  CROSS-REPO CHANGE DETECTED
This change affects: apps/api
Recommended order: shared-types → backend → frontend
```

## Code Reviews (Mandatory Guardrail)

**Every push requires code review. No exceptions.**

```
┌─────────────────────────────────────────────────────────────┐
│  WORKFLOW: Code → Test → Commit → Push → Review blocks     │
├─────────────────────────────────────────────────────────────┤
│  Run manually: /code-review                                 │
│  Enforced: Pre-push hook blocks on Critical/High            │
└─────────────────────────────────────────────────────────────┘
```

**Enable pre-push hook in any project:**
```bash
~/.claude/install-hooks.sh
```

**Severity levels:**

| Level | Action | Can Push? |
|-------|--------|-----------|
| 🔴 Critical | Must fix now | ❌ BLOCKED |
| 🟠 High | Must fix now | ❌ BLOCKED |
| 🟡 Medium | Fix soon | ✅ Advisory |
| 🟢 Low | Nice to have | ✅ Advisory |

**What it catches:**
- Security vulnerabilities (SQL injection, XSS, secrets)
- Performance issues (N+1 queries, memory leaks)
- Architecture problems (coupling, SOLID violations)
- Code quality (complexity, duplication, missing types)

**Integration:** Pre-push hooks, GitHub Actions, and CI/CD pipelines automatically run code review.

## Team Coordination (Multi-Person Projects)

**When multiple devs use Claude Code on the same repo, coordination is essential.**

```
┌─────────────────────────────────────────────────────────────┐
│  /check-contributors                                        │
├─────────────────────────────────────────────────────────────┤
│  Detects: Solo or team project?                             │
│  Shows: Who's working on what right now                     │
│  Converts: Solo → Team with full state management           │
└─────────────────────────────────────────────────────────────┘
```

**Team structure created:**
```
_project_specs/team/
├── state.md           # Who's active, claimed todos, conflicts
├── contributors.md    # Team members, ownership, focus areas
└── handoffs/          # Notes when passing work to others
```

**How it works:**

| Feature | Purpose |
|---------|---------|
| **Todo claiming** | Claim before starting - prevents duplicate work |
| **Active sessions** | See who's working on what files right now |
| **Conflict watch** | Warns when multiple people touch same area |
| **Handoff notes** | Pass context when handing off work |
| **Decision sync** | Shared decisions.md - check before deciding |

**Workflow:**
```
Start session → Pull → Check state.md → Claim todo → Work → Update state → Push
```

**Quick commands:**
```bash
/check-contributors          # Check state, offer conversion
/check-contributors --status # Quick status only
/check-contributors --team   # Convert to team project
```

## Code Deduplication (Prevent Semantic Bloat)

**AI doesn't copy/paste - it reimplements. The problem is duplicate PURPOSE, not duplicate code.**

```
┌─────────────────────────────────────────────────────────────┐
│  CHECK BEFORE YOU WRITE                                     │
├─────────────────────────────────────────────────────────────┤
│  Before creating ANY new function:                          │
│  1. Check CODE_INDEX.md for existing capabilities           │
│  2. Search codebase for similar functionality               │
│  3. Extend existing if possible                             │
│  4. Only create new if nothing suitable exists              │
└─────────────────────────────────────────────────────────────┘
```

**Semantic capability index** (organized by what things DO):

```markdown
## Validation
| Function | Location | Does What |
|----------|----------|-----------|
| `isEmail()` | utils/validate.ts | Validates email format |
| `isPhone()` | utils/validate.ts | Validates phone number |

## Date/Time
| Function | Location | Does What |
|----------|----------|-----------|
| `formatRelative()` | utils/dates.ts | "2 days ago" format |
```

Before writing `validateEmail()`, Claude searches → finds `isEmail()` exists → uses it.

**Commands:**
```bash
/update-code-index      # Regenerate index from codebase
/audit-duplicates       # Find semantic duplicates to merge
```

**For large codebases (100+ files):** Optional vector DB integration (ChromaDB/LanceDB) for semantic search.

## What Gets Created

```
your-project/
├── .claude/skills/           # Coding guardrails
│   ├── base.md               # Universal patterns
│   ├── security.md           # Security requirements
│   ├── [language].md         # Language-specific
│   └── [framework].md        # Framework-specific
├── .github/workflows/
│   ├── quality.yml           # Lint, type-check, test (80% coverage)
│   └── security.yml          # Secret scanning, dependency audit
├── _project_specs/
│   ├── overview.md           # Project vision
│   ├── features/             # Feature specifications
│   └── todos/                # Atomic todos with test cases
├── docs/                     # Technical documentation
├── scripts/
│   ├── verify-tooling.sh     # CLI validation
│   └── security-check.sh     # Pre-commit security
└── CLAUDE.md                 # Claude instructions
```

## Philosophy

### TDD-First Development (Mandatory)

**Every feature and bug fix follows the same pattern:**

| Phase | Feature Development | Bug Fixing |
|-------|---------------------|------------|
| **1. RED** | Write tests based on acceptance criteria | Identify test gap, write test that reproduces bug |
| **2. RUN** | Execute tests → ALL MUST FAIL | Execute test → MUST FAIL (proves it catches bug) |
| **3. GREEN** | Write minimum code to pass | Fix the bug |
| **4. RUN** | Execute tests → ALL MUST PASS | Execute test → MUST PASS |
| **5. VALIDATE** | Lint + TypeCheck + Coverage ≥80% | Full test suite + Lint + TypeCheck |

**Why tests must fail first:**
- Proves the test actually validates the requirement
- For bugs: proves the test would have caught it
- Prevents false confidence from tests that always pass

**Anti-patterns we prevent:**
- ❌ Fixing bugs without adding a test first
- ❌ Writing tests after implementation
- ❌ Marking todos complete with failing tests
- ❌ Skipping lint/typecheck before completion

### Complexity is the Enemy

Every line of code is a liability. The goal is software simple enough that any engineer (or AI) can understand the entire system in one session.

**Measurable constraints, not vague guidance:**

| Constraint | Limit |
|------------|-------|
| Lines per function | 20 max |
| Parameters per function | 3 max |
| Nesting depth | 2 levels max |
| Lines per file | 200 max |
| Test coverage | 80% minimum |

### Security is Non-Negotiable

- No secrets in code - ever
- No secrets in `VITE_*` or `NEXT_PUBLIC_*` env vars (client-exposed!)
- `.env` files always gitignored
- Dependency scanning on every PR
- Pre-commit security checks

### Centralized Credentials

Store all your API keys in one file (e.g., `~/Documents/Access.txt`):

```
OpenAI API: sk-proj-xxx
Claude API: sk-ant-xxx
Stripe: sk_test_xxx
Supabase url: https://xxx.supabase.co
Anon key: eyJxxx
```

When starting a project, Claude asks for your access file location, auto-detects keys by pattern, validates them, and creates your `.env`.

### AI-First Architecture

For applications where LLMs handle core logic:

- **LLM for logic, code for plumbing** - Classification, extraction, decisions via LLM; validation, routing, auth via code
- **Test LLM calls properly** - Mocks for unit tests, fixtures for parsing, evals for accuracy
- **Track costs** - Monitor token usage and latency

### Spec-Driven Development

Define before you build:

1. **Feature specs** in `_project_specs/features/`
2. **Atomic todos** with validation criteria and test cases
3. **Move, don't delete** - Completed todos go to `completed.md` for reference

## Skills Included (53 Skills)

### Core Skills
| Skill | Purpose |
|-------|---------|
| `base.md` | Universal patterns, constraints, TDD workflow, atomic todos |
| `iterative-development.md` | Ralph Wiggum loops - self-referential TDD iteration until tests pass |
| `code-review.md` | Mandatory code reviews via `/code-review` - choose Claude, Codex, Gemini, or multi-engine |
| `codex-review.md` | OpenAI Codex CLI code review with GPT-5.2-Codex, CI/CD integration |
| `gemini-review.md` | Google Gemini CLI code review with Gemini 2.5 Pro, 1M token context |
| `workspace.md` | Multi-repo workspace awareness, contract tracking, cross-repo context |
| `commit-hygiene.md` | Atomic commits, PR size limits, commit thresholds, stacked PRs |
| `code-deduplication.md` | Prevent semantic duplication with capability index, check-before-write |
| `agent-teams.md` | Default agent team workflow - Team Lead, Quality, Security, Review, Merger + Feature agents |
| `team-coordination.md` | Multi-person projects - shared state, todo claiming, handoffs, conflict prevention |
| `security.md` | OWASP patterns, secrets management, security testing |
| `credentials.md` | Centralized API key management from Access.txt |
| `session-management.md` | Context preservation, tiered summarization, resumability |
| `project-tooling.md` | gh, vercel, supabase, render CLI + deployment platform setup |
| `existing-repo.md` | Analyze existing repos, maintain structure, setup guardrails (Husky, pre-commit, commitlint) |

### Language & Framework Skills
| Skill | Purpose |
|-------|---------|
| `python.md` | Python + ruff + mypy + pytest |
| `typescript.md` | TypeScript strict + eslint + jest |
| `nodejs-backend.md` | Express/Fastify patterns, repositories |
| `react-web.md` | React + hooks + React Query + Zustand |
| `react-native.md` | Mobile patterns, platform-specific code |
| `android-java.md` | Android Java with MVVM, ViewBinding, Espresso testing |
| `android-kotlin.md` | Android Kotlin with Coroutines, Jetpack Compose, Hilt, MockK/Turbine |
| `flutter.md` | Flutter with Riverpod, Freezed, go_router, mocktail testing |

### UI Skills
| Skill | Purpose |
|-------|---------|
| `ui-web.md` | Web UI - glassmorphism, Tailwind, dark mode, accessibility |
| `ui-mobile.md` | Mobile UI - React Native, iOS/Android patterns, touch targets |
| `ui-testing.md` | Visual testing - catch invisible buttons, broken layouts, contrast |
| `playwright-testing.md` | E2E testing - Playwright, Page Objects, cross-browser, CI/CD |
| `user-journeys.md` | User experience flows - journey mapping, UX validation, error recovery |
| `pwa-development.md` | Progressive Web Apps - service workers, caching strategies, offline, Workbox |

### AI & Agentic Skills
| Skill | Purpose |
|-------|---------|
| `agentic-development.md` | Build AI agents - Pydantic AI (Python), Claude SDK (Node.js) |
| `llm-patterns.md` | AI-first apps, LLM testing, prompt management |
| `ai-models.md` | Latest models reference - Claude, OpenAI, Gemini, Eleven Labs, Replicate |

### Database & Backend Skills
| Skill | Purpose |
|-------|---------|
| `database-schema.md` | Schema awareness - read before coding, type generation, prevent column errors |
| `supabase.md` | Core Supabase CLI, migrations, RLS, Edge Functions |
| `supabase-nextjs.md` | Next.js + Supabase + Drizzle ORM |
| `supabase-python.md` | FastAPI + Supabase + SQLAlchemy/SQLModel |
| `supabase-node.md` | Express/Hono + Supabase + Drizzle ORM |
| `firebase.md` | Firebase Firestore, Auth, Storage, real-time listeners, security rules |
| `cloudflare-d1.md` | Cloudflare D1 SQLite with Workers, Drizzle ORM, migrations |
| `aws-dynamodb.md` | AWS DynamoDB single-table design, GSI patterns, SDK v3 |
| `aws-aurora.md` | AWS Aurora Serverless v2, RDS Proxy, Data API, connection pooling |
| `azure-cosmosdb.md` | Azure Cosmos DB partition keys, consistency levels, change feed |

### Content & SEO Skills
| Skill | Purpose |
|-------|---------|
| `aeo-optimization.md` | AI Engine Optimization - semantic triples, page templates, content clusters for AI citations |
| `web-content.md` | SEO + AI discovery (GEO) - schema, content structure, ChatGPT/Perplexity optimization |
| `site-architecture.md` | Technical SEO - robots.txt, sitemap, meta tags, AI crawler handling, Core Web Vitals |

### Integration Skills
| Skill | Purpose |
|-------|---------|
| `web-payments.md` | Stripe Checkout, subscriptions, webhooks, customer portal |
| `reddit-api.md` | Reddit API with PRAW (Python) and Snoowrap (Node.js) |
| `reddit-ads.md` | Reddit Ads API - campaigns, targeting, conversions + **agentic optimization service** |
| `ms-teams-apps.md` | Microsoft Teams bots and AI agents - Claude/OpenAI integration, Adaptive Cards, Graph API |
| `posthog-analytics.md` | PostHog analytics, event tracking, feature flags, project-specific dashboards |
| `shopify-apps.md` | Shopify app development - Remix, Admin API, checkout extensions, GDPR compliance |
| `woocommerce.md` | WooCommerce REST API - products, orders, customers, webhooks |
| `medusa.md` | Medusa headless commerce - modules, workflows, API routes, admin UI |
| `klaviyo.md` | Klaviyo email/SMS marketing - profiles, events, flows, segmentation |

## Usage Patterns

### New Project
```bash
mkdir my-new-app && cd my-new-app
claude
> /initialize-project
# Answer questions, get full setup
```

### Existing Project
```bash
cd my-existing-app
claude
> /initialize-project
# Skills updated, existing config preserved
```

### Existing Codebase (Auto-Analysis!)
```bash
cd unfamiliar-codebase
claude
> /initialize-project
# Auto-detects existing code → runs analysis first
# Shows: structure, tech stack, guardrails status, conventions
# Asks: "What would you like me to do?"
#   1. Add Claude skills only
#   2. Add skills + missing guardrails
#   3. Full setup
#   4. Just show analysis
```

### Standalone Analysis
```bash
cd any-repo
claude
> /analyze-repo
# Run analysis anytime without making changes
```

### Update Skills Globally
```bash
cd "$(cat ~/.claude/.bootstrap-dir)"
git pull
./install.sh

# Then in any project:
claude
> /initialize-project
# Gets latest skills
```

## Prerequisites

Install and authenticate these CLIs:

```bash
# GitHub CLI
brew install gh
gh auth login

# Vercel CLI
npm i -g vercel
vercel login

# Supabase CLI
brew install supabase/tap/supabase
supabase login
```

## Quality Gates

Every project gets automated enforcement:

### Pre-Commit (Local)
- Linting with auto-fix
- Type checking
- Security checks (no secrets, no .env)
- Unit tests on changed files

### CI (GitHub Actions)
- Full lint + type check
- All tests with 80% coverage
- Secret scanning (trufflehog)
- Dependency audit (npm audit / safety)

## Atomic Todos

All work is tracked with validation, test cases, and **TDD execution logs**:

```markdown
## [TODO-042] Add email validation to signup form

**Status:** in-progress
**Priority:** high
**Estimate:** S

### Acceptance Criteria
- [ ] Email field shows error for invalid format
- [ ] Form cannot submit with invalid email

### Test Cases
| Input | Expected |
|-------|----------|
| user@example.com | Valid |
| notanemail | Error |

### TDD Execution Log
| Phase | Command | Result |
|-------|---------|--------|
| RED | `npm test -- --grep "email validation"` | 2 tests failed ✓ |
| GREEN | `npm test -- --grep "email validation"` | 2 tests passed ✓ |
| VALIDATE | `npm run lint && npm run typecheck && npm test -- --coverage` | Pass, 84% ✓ |
```

**Bug reports include test gap analysis:**

```markdown
## [BUG-007] Email validation accepts "user@"

### Test Gap Analysis
- Existing tests: `signup.test.ts` - only tested valid emails
- Gap: Missing test for email without domain
- New test: Add case for partial emails

### TDD Execution Log
| Phase | Command | Result |
|-------|---------|--------|
| DIAGNOSE | `npm test` | All pass (test gap!) |
| RED | `npm test -- --grep "partial email"` | 1 test failed ✓ |
| GREEN | `npm test -- --grep "partial email"` | 1 test passed ✓ |
| VALIDATE | `npm run lint && npm test -- --coverage` | Pass ✓ |
```

## Error Handling in Loops

**Not all failures are equal. Claude classifies errors before iterating:**

| Error Type | Examples | Claude Fixes? | Action |
|------------|----------|---------------|--------|
| **Code Error** | Logic bug, wrong assertion | ✅ Yes | Continue loop |
| **Access Error** | Missing API key, DB refused | ❌ No | Stop + report |
| **Environment Error** | Missing package, wrong version | ❌ No | Stop + report |

**When Claude hits an access/environment error:**

```
🛑 LOOP BLOCKED - Human Action Required

Error: ECONNREFUSED 127.0.0.1:5432

Required Actions:
1. Start PostgreSQL: brew services start postgresql
2. Verify connection: psql -U postgres -c "SELECT 1"
3. Check DATABASE_URL in .env

After fixing, run /ralph-loop again.
```

**Common blockers and fixes:**

| Error | Cause | Fix |
|-------|-------|-----|
| `ECONNREFUSED :5432` | PostgreSQL not running | `brew services start postgresql` |
| `ECONNREFUSED :6379` | Redis not running | `brew services start redis` |
| `401 Unauthorized` | Bad API key | Check `.env` file |
| `MODULE_NOT_FOUND` | Missing package | `npm install` |

---

## FAQ

### How is this different from just using Claude Code?

Claude Code is powerful but unpredictable without guardrails. Claude Bootstrap adds:
- **TDD enforcement** - Tests must fail before implementation
- **Automatic iteration** - Loops until tests pass, not one-shot
- **Error classification** - Knows when to stop and ask for help
- **Complexity limits** - Hard caps prevent unmaintainable code

### Do I need to manually run `/ralph-loop` every time?

No. With Claude Bootstrap skills loaded, Claude **automatically** transforms your requests into iterative TDD loops. Just say "add email validation" and it loops until tests pass.

### What if I don't want a loop for something?

Use opt-out phrases:
- "Just explain..." → explanation only
- "Quick fix..." → one-liner
- "Don't loop..." → explicit opt-out

### What if the loop runs forever?

Three safety mechanisms:
1. **`--max-iterations`** - Hard limit (default 20-30)
2. **Error classification** - Stops on access/environment errors
3. **Blocker detection** - Reports when stuck and needs human help

### Does this work with existing projects?

Yes. Run `/initialize-project` in any directory. It adds skills without breaking existing config.

### What about test coverage?

Minimum 80% coverage enforced. CI blocks PRs below threshold.

### How do I update skills?

```bash
cd "$(cat ~/.claude/.bootstrap-dir)"
git pull
./install.sh
```

Then run `/initialize-project` in your project to get latest skills.

### Can I customize the skills?

Yes. Skills are markdown files in `.claude/skills/`. Edit or add your own.

### What languages/frameworks are supported?

| Category | Supported |
|----------|-----------|
| Languages | TypeScript, Python, Kotlin, Dart, Java |
| Frontend | React, Next.js, React Native, Flutter, PWA |
| Mobile | React Native, Flutter, Android (Java/Kotlin) |
| Backend | Node.js, Express, FastAPI |
| Database | Supabase, Firebase, Cloudflare D1, AWS DynamoDB, Aurora, Azure Cosmos DB |
| Web Tech | PWA (Service Workers, Workbox, Offline-First) |
| E-commerce | Shopify, WooCommerce, Medusa |
| Advertising | Reddit Ads API (campaigns, targeting, conversions) |
| Collaboration | Microsoft Teams (bots, AI agents, Adaptive Cards) |
| Marketing | Klaviyo, PostHog |

---

## Comparison

| Feature | Other Tools | Claude Bootstrap |
|---------|-------------|------------------|
| **Testing** | Optional, often skipped | TDD mandatory - tests fail first |
| **Iteration** | One-shot | Loops until tests pass |
| **Bug Fixes** | Jump to fix | Test gap analysis → failing test → fix |
| **Error Handling** | Loop forever | Classifies errors, stops on blockers |
| **Security** | Rarely covered | First-class with CI enforcement |
| **Complexity** | Vague guidance | Hard limits (20 lines/function, 200/file) |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Key principles:
- Measurable constraints over vague guidance
- Working code examples
- Maintain idempotency
- Test locally before submitting

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

**Latest: v2.5.0** - 54 skills with Agent Teams default workflow, strict TDD pipeline, and `/spawn-team` command

## License

MIT - See [LICENSE](LICENSE)

## Credits

Built on learnings from 100+ projects across customer experience management, agentic AI platforms, mobile apps, and full-stack web applications.

---

**Need help scaling AI in your org?** [Claude Code & MCP experts](https://leanai.ventures/aiops/claude)

