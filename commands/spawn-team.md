# /spawn-team - Spawn Agent Team

Spawn the default agent team for this project. Creates a coordinated team of agents that implement features in parallel following the strict TDD pipeline.

**Pipeline:** Specs > Tests > Ensure tests fail > Implement > Test again > Code Review > Security > Create branch > Create PR

---

## Phase 1: Prerequisites Check

### 1.1 Check Agent Definitions

Verify `.claude/agents/` exists and has the required agent definitions:

```bash
ls .claude/agents/
```

Required files (with proper frontmatter: name, description, model, tools, disallowedTools, maxTurns):
- `team-lead.md`
- `quality.md`
- `security.md`
- `code-review.md`
- `merger.md`
- `feature.md`

If missing, copy from the agent-teams skill:
```bash
cp -r ~/.claude/skills/agent-teams/agents/ .claude/agents/
```

### 1.2 Check Feature Specs

```bash
ls _project_specs/features/
```

If no feature specs exist, ask the user:

> **No feature specs found.** The agent team needs features to implement.
>
> What are the key features of this project? I'll create a spec file for each one.

For each feature the user lists, create `_project_specs/features/{feature-name}.md` with a skeleton spec.

### 1.3 Check GitHub CLI

```bash
gh auth status
```

Needed by the merger agent for PR creation. Warn if not authenticated but don't block.

---

## Phase 2: Spawn Default Agents

Spawn the 5 permanent agents. Each agent reads `.claude/agents/{type}.md` for its full definition including frontmatter (tools, model, maxTurns, etc.).

### 2.1 Team Lead
```
Agent tool:
  name: "team-lead"
  subagent_type: "team-lead"
  prompt: "You are the team lead. Read .claude/agents/team-lead.md for your full instructions. Start by reading _project_specs/features/*.md to identify features, then create task chains and spawn feature agents."
```

### 2.2 Quality Agent
```
Agent tool:
  name: "quality-agent"
  subagent_type: "quality-agent"
  prompt: "You are the quality agent. Read .claude/agents/quality.md for your instructions. Watch TaskList for tasks assigned to you. Process them in task ID order."
```

### 2.3 Security Agent
```
Agent tool:
  name: "security-agent"
  subagent_type: "security-agent"
  prompt: "You are the security agent. Read .claude/agents/security.md for your instructions. Watch TaskList for security-scan tasks assigned to you."
```

### 2.4 Code Review Agent
```
Agent tool:
  name: "review-agent"
  subagent_type: "review-agent"
  prompt: "You are the code review agent. Read .claude/agents/code-review.md for your instructions. Watch TaskList for code-review tasks assigned to you."
```

### 2.5 Merger Agent
```
Agent tool:
  name: "merger-agent"
  subagent_type: "merger-agent"
  prompt: "You are the merger agent. Read .claude/agents/merger.md for your instructions. Watch TaskList for branch-pr tasks assigned to you."
```

---

## Phase 3: Spawn Feature Agents

For each feature spec in `_project_specs/features/`:

```
Agent tool:
  name: "feature-{feature-name}"
  subagent_type: "feature-agent"
  prompt: "You are the feature agent for {feature-name}. Read .claude/agents/feature.md for your instructions. Your feature spec is at _project_specs/features/{feature-name}.md. Start by checking TaskList for your first task."
```

---

## Phase 4: Team Status Summary

Show the user:

```
AGENT TEAM DEPLOYED
───────────────────

Team: {project-name}
Features: {N}
Total tasks: {N * 10}

AGENTS
──────
  Team Lead        Orchestrating
  Quality Agent    Watching for verification tasks
  Security Agent   Watching for security scan tasks
  Code Review      Watching for review tasks
  Merger Agent     Watching for branch/PR tasks
  feature-{name1}  Starting spec for {name1}
  feature-{name2}  Starting spec for {name2}

PIPELINE
────────
Spec > Review > Tests > RED Verify > Implement >
GREEN Verify > Validate > Code Review > Security > Branch+PR

The team runs autonomously until all PRs are created.
```

---

## Monitoring

After the team is spawned, the user can:
- **Check progress:** Ask team lead for status
- **Message agents:** Use SendMessage to contact any agent
- **Handle blockers:** Message the blocked agent or team lead

The team runs autonomously until all PRs are created, then the team lead shuts everything down.
