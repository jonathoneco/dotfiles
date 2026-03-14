---
description: "Archive a completed task — verify completion and set archived_at"
user_invocable: true
---

# Work Archive

Archive a completed task. Verifies all steps are complete, checks finding triage status, generates an archive summary (Tier 3), and closes beads issues. The `.work/<name>/` directory remains in place with `archived_at` set — it is NOT deleted.

## Arguments

- `$ARGUMENTS` — optional task name. If omitted, find active task via discovery.

## Process

### Step 1: Find the task to archive

- If `$ARGUMENTS` specifies a name: use `.work/<name>/state.json`
- If no arguments: find active task via state discovery (scan `.work/`, filter `archived_at` null)
- If no active tasks: "No active tasks to archive."

### Step 2: Verify completion

Check that all steps in the `steps` array are `completed` or `skipped`:

- If any step is `active` or `not_started`: refuse with "Task is not complete. Current step: <step>. Complete all steps before archiving."

### Step 3: Check finding triage gate (Tier 2-3 only)

Read `.review/findings.jsonl` for this task (filter by `task_name`):

1. For each finding ID, the last line with that ID is the current state
2. All `critical` severity findings must be `FIXED` or have a non-null `beads_issue_id` (deferred with tracking)
3. All `important` severity findings must be `FIXED` or have a non-null `beads_issue_id`
4. `suggestion` findings are NOT gated — they do not block archive

If untriaged critical/important findings exist:

```
Cannot archive — <N> findings need triage:
- <finding-id>: [CRITICAL] <title> (status: OPEN, no beads issue)
- <finding-id>: [IMPORTANT] <title> (status: OPEN, no beads issue)

Run /work-review to reconcile, or create beads issues for deferred findings.
```

### Step 4: Generate archive summary (Tier 3 only)

Write `.work/<name>/archive-summary.md`:

```markdown
# Archive Summary: <name>

**Tier:** <N>
**Duration:** <created_at> → <archived_at>
**Sessions:** <N>
**Beads epic:** <epic_id>

## What Was Built
[Summarized from conversation context and step artifacts]

## Key Files
[List of files created/modified during this task]

## Findings Summary
- <N> total findings (<N> fixed, <N> deferred)

## Futures Promoted
[Any future enhancements from futures.md promoted to docs/futures/]
```

### Step 5: Set archived_at

Update `state.json`:
- Set `archived_at` to current ISO 8601 timestamp
- Update `updated_at`

### Step 6: Close beads issue/epic

- **Tier 1-2**: `bd close <issue_id> --reason="Task archived: <title>"`
- **Tier 3**: Close all open issues under the epic, then close the epic:
  ```bash
  bd list --status=open --label=workflow:<name>  # find remaining open issues
  bd close <issue-ids> --reason="Task archived"
  bd close <epic_id> --reason="Task archived: <title>"
  ```

### Step 7: Promote futures

If `.work/<name>/research/futures.md` exists and has entries:

1. Create `docs/futures/` directory if needed
2. Copy to `docs/futures/<name>.md`
3. Skip entries already marked as adopted

### Step 8: Git commit

```bash
git add .work/<name>/
git add docs/futures/<name>.md  # if futures were promoted
git commit -m "chore: archive <name>"
```

### Step 9: Report

```
Task `<name>` archived.

Location: .work/<name>/ (archived_at set)
Beads: <issue_id> closed

<summary stats if Tier 3: N steps, N sessions, N findings>
```

## Key principles

- **Verify before archiving.** Never archive a task with incomplete steps or untriaged findings without explicit checks. The verification gates exist to catch forgotten work.
- **The `.work/<name>/` directory is NOT deleted.** Archived tasks remain with `archived_at` set. State discovery filters them out.
- **Finding triage gate is strict.** All critical AND important findings must be FIXED or have a `beads_issue_id`. Suggestions are not gated. This is different from the review step gate (which only checks critical).
- **Futures promotion is automatic.** If futures were captured during the task, they are promoted to `docs/futures/` at archive time for discovery by future tasks.
