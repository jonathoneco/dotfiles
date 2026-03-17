# Workflow Harness Guide

Multi-session workflow system for structured feature development. State lives in `.workflows/`, permanent docs in `docs/feature/<name>/`.

## Phases (sequential)

```
research -> plan -> spec -> decompose -> implement
```

Each phase reads the previous phase's handoff prompt and produces its own.

## Directory Structure

```
.workflows/<name>/
  state.json              # Source of truth (phase, timestamps, epic ID)
  research/
    index.md              # One-line summaries (context-rot firewall)
    dead-ends.md          # Failed approaches
    futures.md            # Deferred enhancements
    checkpoints/          # Mid-session saves
    handoff-prompt.md     # Bridge to plan phase
  plan/
    handoff-prompt.md     # Bridge to spec phase
  specs/
    index.md              # Spec dependency ordering
    handoff-prompt.md     # Bridge to decompose phase
  streams/
    handoff-prompt.md     # Bridge to implement phase
  issues/
    manifest.jsonl        # Maps W-items to beads IDs, specs, streams
docs/feature/<name>/
  architecture.md         # From plan phase
  00-cross-cutting-contracts.md
  NN-<slug>.md            # Implementation specs
  phase-N-<slug>.md       # Phase work items
  phase-N/stream-N-*.md   # Self-contained execution docs
```

## State Model (state.json)

```json
{
  "name": "<name>",
  "title": "<title>",
  "created_at": "<ISO 8601>",
  "updated_at": "<ISO 8601>",
  "beads_epic_id": "<id>",
  "docs_path": "docs/feature/<name>",
  "current_phase": "research",
  "phases": {
    "research": { "status": "not_started", "started_at": null, "completed_at": null, "gate_id": null, "sessions": [], "handoff_prompt": null },
    "plan": { ... },
    "spec": { ... },
    "decompose": { ... },
    "implement": { ... }
  },
  "archived_at": null
}
```

Phase statuses: `not_started` -> `active` -> `completed`

## Operations

### Start a workflow

1. Validate name is kebab-case, `.workflows/<name>/` does not exist
2. Create full directory structure (see above)
3. Initialize state.json with all phases `not_started`
4. Create seed files: research/index.md (empty table), research/dead-ends.md
5. Create beads epic: `bd create --title="[Workflow] <title>" --type=epic --priority=1`
6. Store epic ID in state.json
7. Git commit: `feat: initialize workflow <name>`

### Check status

Read-only. Read state.json, count artifacts per phase, show compact table, suggest next action. Never modifies state.

### Research

1. Read: state.json, research/index.md, research/dead-ends.md, latest checkpoint
2. Set phase active in state.json
3. Present existing research, ask user for topic direction
4. For each topic: search closed beads first (`bd search`), then explore code, then web search
5. Write findings to `research/<topic-slug>.md`, update index.md
6. Check in with user after each topic
7. When complete: generate handoff-prompt.md for plan phase

### Plan

1. Read: research/handoff-prompt.md (primary), research/index.md, state.json
2. Set phase active
3. Ask user for high-level direction before drafting
4. Produce `docs/feature/<name>/architecture.md` with: Overview, System Context, Tech Stack, Patterns, Data Model, Data Flow, Component Map, Phasing Summary, Open Questions
5. Review gate: present outline to user
6. Generate plan/handoff-prompt.md

### Spec

1. Read: plan/handoff-prompt.md, architecture.md, specs/index.md, state.json
2. Set phase active
3. Create `00-cross-cutting-contracts.md` first (shared interfaces, types, policies)
4. Write numbered specs `NN-<slug>.md` in dependency order. Each spec is self-contained with: Existing Code Context, Files to Create/Modify, Implementation Steps, Interface Contracts, Testing Strategy, Acceptance Criteria
5. Update specs/index.md after each spec
6. Check in with user after each spec
7. Generate specs/handoff-prompt.md

### Decompose

1. Read: specs/handoff-prompt.md, specs/index.md, all spec files, state.json
2. Set phase active
3. Analyze dependencies: foundation -> parallel -> integration
4. Present decomposition for user approval before creating anything
5. Create phase docs, concurrency maps, stream execution docs
6. Create beads issues for each work item, set up dependencies
7. Write issues/manifest.jsonl
8. Generate streams/handoff-prompt.md

### Implement

Four modes:
- **next**: Pick highest-priority unblocked issue from `bd ready`
- **\<issue-id>**: Target specific issue
- **stream N**: Execute entire stream from its execution doc
- **parallel**: Launch worktree sessions for all unblocked streams

Always: present plan -> user confirms -> claim issue -> implement -> verify -> close issue

### Checkpoint

1. Generate checkpoint file with: Accomplished, Files Modified, Remaining Work, Open Questions, Resumption Prompt
2. Present to user for approval before writing
3. If `--phase-end`: generate handoff prompt, advance to next phase, create gate issue

### Reground (context recovery)

Read-only. Load minimal phase-specific files to recover context:
- Research: index.md, dead-ends.md, latest checkpoint
- Plan: research/handoff-prompt.md, index.md, architecture.md
- Spec: plan/handoff-prompt.md, architecture.md, specs/index.md
- Implement: streams/handoff-prompt.md, `bd ready` output

Never read raw research notes during reground — index.md is the firewall.

### Record dead end

Append to `<phase>/dead-ends.md`: what was tried, why it failed, key learning, time spent. Update index if in research phase.

### Capture future enhancement

Append to `research/futures.md`: title, horizon (next/quarter/someday), domain, description, prerequisites. Low-friction aside.

### Archive

1. Verify all phases complete and all beads issues closed
2. Promote futures.md to `docs/futures/<name>.md`
3. Generate archive/summary.md
4. Close beads epic
5. Move `.workflows/<name>` to `.workflows/archive/<name>/`
6. `docs/feature/<name>/` stays in place (permanent)

## Core Principles

- **State.json is source of truth** for workflow state
- **Index.md is the context-rot firewall** — never read raw research notes when index exists
- **Handoff prompts bridge sessions** — written by session with deep context for cold-start session
- **Beads integration required** — every workflow has an epic, every work item has an issue
- **User directs phase transitions** — never advance phases without confirmation
- **Always present before writing** — checkpoint content, handoff prompts, and decompositions need user approval
- **Closed issues before code exploration** — `bd search` before spinning up agents
- **Self-contained stream docs** — implementer reads one doc and has everything needed
