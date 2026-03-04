---
description: "Start a new multi-session workflow — creates directory structure, state tracking, and beads epic."
user_invocable: true
---

# Workflow Start

Initialize a new multi-session workflow with all infrastructure: directory structure, state tracking, seed files, and a beads epic.

## Arguments

- `<name>` — the workflow slug (kebab-case, e.g. `plaid-integration`)
- `[title]` — optional human-readable title (defaults to name with hyphens replaced by spaces, title-cased)

## Process

### Step 1: Validate

Check that `.workflows/<name>/` does not already exist. If it does, report the error and stop — do not overwrite.

Validate that `<name>` is kebab-case (lowercase letters, numbers, hyphens only). If not, suggest a corrected slug and ask for confirmation.

### Step 2: Create directory structure

```bash
mkdir -p .workflows/<name>/research/checkpoints
mkdir -p .workflows/<name>/plan
mkdir -p .workflows/<name>/specs
mkdir -p .workflows/<name>/streams
mkdir -p .workflows/<name>/issues
mkdir -p .workflows/<name>/archive
mkdir -p docs/feature/<name>
```

### Step 3: Initialize state.json

Write `.workflows/<name>/state.json` with the following structure:

```json
{
  "name": "<name>",
  "title": "<title>",
  "created_at": "<ISO 8601 timestamp>",
  "updated_at": "<ISO 8601 timestamp>",
  "beads_epic_id": null,
  "docs_path": "docs/feature/<name>",
  "current_phase": "research",
  "phases": {
    "research": { "status": "not_started", "started_at": null, "completed_at": null, "gate_id": null, "sessions": [], "handoff_prompt": null },
    "plan": { "status": "not_started", "started_at": null, "completed_at": null, "gate_id": null, "sessions": [], "handoff_prompt": null },
    "spec": { "status": "not_started", "started_at": null, "completed_at": null, "gate_id": null, "sessions": [], "handoff_prompt": null },
    "decompose": { "status": "not_started", "started_at": null, "completed_at": null, "gate_id": null, "sessions": [], "handoff_prompt": null },
    "implement": { "status": "not_started", "started_at": null, "completed_at": null, "gate_id": null, "sessions": [], "handoff_prompt": null }
  },
  "archived_at": null
}
```

Use the current UTC time for `created_at` and `updated_at`.

### Step 4: Create seed files

**Research index** at `.workflows/<name>/research/index.md`:

```markdown
# Research Index: <title>

One-line summaries of research findings. Updated as research progresses.

| Topic | Summary | Status | Files |
|-------|---------|--------|-------|
```

**Dead ends log** at `.workflows/<name>/research/dead-ends.md`:

```markdown
# Dead Ends: <title>

Approaches tried and abandoned. Each entry explains what was tried, why it failed, and key learning.
```

### Step 5: Create beads epic

```bash
bd create --title="[Workflow] <title>" --type=epic --priority=1
```

Capture the epic ID from the output, then:

```bash
bd set-state <epic-id> phase=research
bd label add <epic-id> workflow:<name>
```

Update `state.json` to set `beads_epic_id` to the captured epic ID.

### Step 6: Git commit

Stage only the new workflow files:

```bash
git add .workflows/<name>/ docs/feature/<name>/
git commit -m "feat: initialize workflow <name>"
```

### Step 7: Report

Display the created structure as a tree listing, confirm the beads epic ID, and suggest the next step:

> Workflow `<name>` initialized. Run `/workflow-research <name>` to begin the research phase.

## Key principles

- **One workflow per feature.** Each workflow tracks a single feature or initiative through all phases.
- **Never overwrite.** If the workflow directory exists, stop. The user should use `/workflow-status` to inspect existing workflows.
- **State.json is the source of truth.** All other commands read from this file to determine workflow state.
- **Commit immediately.** The initial structure should be committed so other sessions can see it via `git pull`.
