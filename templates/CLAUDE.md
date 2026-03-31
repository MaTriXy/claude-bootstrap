# CLAUDE.md - Project Instructions

## Skills (loaded via @include)
@.claude/skills/base/SKILL.md
@.claude/skills/iterative-development/SKILL.md

## Project-Specific Context

### Tech Stack
- Language: [e.g., TypeScript]
- Framework: [e.g., Next.js]
- Database: [e.g., Supabase/PostgreSQL]
- Testing: [e.g., Jest, Vitest]

### Commands
```bash
# Run tests
npm test

# Run tests with coverage
npm test -- --coverage

# Lint
npm run lint

# Type check
npm run typecheck

# Full validation
npm run lint && npm run typecheck && npm test -- --coverage
```

### Schema Location
- Schema file: `src/db/schema.ts`
- Read schema before any database code

---

## Session Persistence

- Checkpoint after completing tasks
- Log decisions to `_project_specs/session/decisions.md`
- Update `_project_specs/session/current-state.md` regularly
