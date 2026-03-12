---
description: "Archive a completed workflow — verify completion, generate summary, and archive workflow state."
user_invocable: true
---

# Workflow Archive

Archive a completed workflow. Verifies all phases and issues are complete, generates an archive summary, closes the beads epic, and moves workflow metadata to the archive directory. Permanent documentation in `docs/feature/<name>/` stays in place.

## Arguments

- `<name>` — the workflow slug (kebab-case)

## Process

### Step 1: Verify completion

Read `.workflows/<name>/state.json` and check:

1. **All phases** have status `completed` or `skipped`. List any that do not.
2. **All child beads issues** are closed:
   ```bash
   bd list --status=open --label=workflow:<name>
   ```
3. **Epic status**:
   ```bash
   bd show <epic-id>
   ```

If anything is incomplete, report exactly what remains:

```
Workflow <name> has incomplete items:

Phases:
  - implement: active (3 sessions, started 2026-02-28)

Open issues:
  - rag-0042: [Service] Implement FooService (in_progress)
  - rag-0045: [Integration] Wire Foo into router (open)

Archive anyway? This will close all remaining issues and mark phases as complete.
```

Wait for user confirmation before proceeding if items are incomplete. If the user confirms, close remaining issues and mark phases as completed before continuing.

### Step 1.5: Reconcile deferred enhancements

Check for `.workflows/<name>/research/futures.md`. If it exists and has entries:

1. Read the futures file and identify all entries
2. For each entry, check if it was adopted during this workflow (marked `status: adopted` with a link). Skip adopted entries.
3. For unresolved futures, ensure context links point to files that will survive archival:
   - If a context link points to `.workflows/<name>/research/*.md`, note it — these files will move to `.workflows/archive/<name>/research/` and the link will need updating
4. Promote the futures file to permanent docs:
   ```bash
   mkdir -p docs/futures
   cp .workflows/<name>/research/futures.md docs/futures/<name>.md
   ```
5. Update context links in `docs/futures/<name>.md` to point to the archived locations (`.workflows/archive/<name>/research/...`)

If no futures.md exists or it has no entries, skip this step.

### Step 2: Generate archive summary

Write `.workflows/<name>/archive/summary.md`:

```markdown
# Workflow Archive: <title>

| Field | Value |
|-------|-------|
| Name | <name> |
| Created | <date from state.json created_at> |
| Archived | <current date> |
| Duration | <days between created and archived> |
| Epic | <epic-id> |

## Timeline
| Phase | Started | Completed | Sessions | Duration |
|-------|---------|-----------|----------|----------|
| Research | <date> | <date> | <count> | <days> |
| Plan | <date> | <date> | <count> | <days> |
| Spec | <date> | <date> | <count> | <days> |
| Decompose | <date> | <date> | <count> | <days> |
| Implement | <date> | <date> | <count> | <days> |

## Key Decisions
[Distilled from phase artifacts — architecture choices, technology selections,
patterns adopted. Reference the architecture doc for full detail.]

## Dead Ends
[Summarized from dead-ends.md files across all phases. Each entry: what was
tried, one-line reason it was abandoned.]

## Future Enhancements
[Deferred improvements identified during research. Each was captured via
/workflow-future and promoted to docs/futures/<name>.md for discovery by
future workflows. Omit this section if no futures were captured.]

| Title | Horizon | Domain | Context |
|-------|---------|--------|---------|
| <enhancement title> | <next/quarter/someday> | <domain> | <link to research context> |

## Statistics
- Research notes: N
- Spec documents: N
- Work items: N completed, N total
- Beads issues: N closed
- Streams: N
- Phases: N completed, N skipped

## Documents Produced
[List of permanent docs in docs/feature/<name>/ with one-line descriptions]

| Document | Description |
|----------|-------------|
| `docs/feature/<name>/architecture.md` | System architecture and design decisions |
| `docs/feature/<name>/00-cross-cutting-contracts.md` | Shared interfaces and types |
| `docs/feature/<name>/01-<slug>.md` | <description> |
```

Populate each section from the actual workflow artifacts. Read research index, dead-ends files, spec index, and phase docs to compile accurate statistics and summaries.

### Step 3: Close beads epic

```bash
bd close <epic-id> --reason="Workflow completed and archived"
bd set-state <epic-id> phase=archived
```

### Step 4: Update state.json

Set `archived_at` to the current ISO 8601 timestamp. Set all phase statuses to `completed` (or leave as `skipped` if they were skipped). Update `updated_at`.

### Step 5: Move workflow metadata to archive

```bash
mkdir -p .workflows/archive
mv .workflows/<name> .workflows/archive/<name>
```

The `docs/feature/<name>/` directory stays in place. It is permanent reference documentation and should not be moved or archived.

### Step 6: Git commit

Stage the archive and commit:

```bash
git add .workflows/archive/<name>/ docs/feature/<name>/
git commit -m "chore: archive workflow <name>"
```

### Step 7: Report

Confirm the archival and provide orientation:

```
Workflow `<name>` archived.

Archive location: .workflows/archive/<name>/
Permanent docs:   docs/feature/<name>/

Summary: .workflows/archive/<name>/archive/summary.md

<N> beads issues closed, <N> documents produced over <N> days.
```

If any cleanup is advisable (orphaned branches, temporary files, promoted research docs that could be consolidated), suggest it.

## Key principles

- **Verify before archiving.** Never archive a workflow with open issues or incomplete phases without explicit user confirmation. The verification step exists to catch forgotten work.
- **Permanent docs stay put.** The `docs/feature/<name>/` directory is the lasting output of the workflow. Architecture docs, specs, and stream docs remain accessible for future reference. Only workflow metadata (state, checkpoints, handoff prompts) moves to the archive.
- **The summary is the legacy.** Six months from now, someone reading the archive summary should understand: what was built, what was tried and abandoned, how long it took, and where the permanent docs live. Write it for that reader.
- **Clean shutdown.** Close all beads issues, commit everything, and leave no loose ends. The archive should be a complete record with no dangling references.
