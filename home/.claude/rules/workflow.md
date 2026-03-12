# Workflow Harness Active

This project uses the multi-session workflow harness. Workflow state is tracked in `.workflows/` directories with standalone documentation in `docs/feature/`.

## Available Workflow Commands

| Command | Purpose |
|---------|---------|
| `/workflow-start <name> [title]` | Initialize a new workflow |
| `/workflow-status [name]` | Show workflow state and next action |
| `/workflow-research <name> [topic]` | Enter/continue research phase |
| `/workflow-plan <name> [doc]` | Enter planning phase |
| `/workflow-spec <name> [section]` | Write implementation specs |
| `/workflow-decompose <name>` | Create work items, streams, concurrency maps |
| `/workflow-implement <name> [mode]` | Generate implementation prompts |
| `/workflow-future <title> [--horizon]` | Capture a deferred enhancement for later |
| `/workflow-archive <name>` | Archive completed workflow |
| `/workflow-checkpoint [--phase-end]` | Save progress or end a phase |
| `/workflow-redirect <reason>` | Record a dead end and pivot |
| `/workflow-reground [name]` | Re-read phase artifacts for context recovery |
| `/workflow-help [name]` | Explain the harness or get contextual guidance |

## Key Principles

- **Context via files, not memory**: Each phase reads structured handoff prompts, not raw conversation history
- **index.md is the firewall**: Never read raw research notes — use index.md summaries
- **Dual location**: Workflow meta in `.workflows/`, standalone docs in `docs/feature/`
- **Beads integration**: Every workflow has an epic; every work item has an issue
- **Parallel-first**: Decompose produces concurrency maps for parallel stream execution

## When Starting a Session in a Workflow Project

If `.workflows/` contains active workflows (check state.json for non-archived entries), suggest running `/workflow-reground` to recover context before making changes.
