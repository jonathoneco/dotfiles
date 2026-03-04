---
description: "Record a dead end — document what was tried, why it failed, and pivot to a new direction."
user_invocable: true
---

# Workflow Redirect

Document a dead end and pivot to a new direction. Preserves learning from failed approaches so future sessions do not repeat them.

## Arguments

- `<reason>` — brief description of why the current approach is being abandoned. Can be a short phrase; the command will prompt for details.

## Process

### Step 1: Detect active workflow and phase

Scan `.workflows/*/state.json` for a workflow with an `active` or `in_progress` phase. If none found, report the error and suggest checking `/workflow-status`.

### Step 2: Gather details

If `<reason>` is a brief phrase (fewer than ~20 words), prompt the user for:

- **What was tried** — the specific approach, tool, library, or architecture explored
- **Why it failed** — concrete reason (performance, complexity, incompatibility, cost, etc.)
- **Key learning** — what was learned that remains useful going forward
- **Time spent** — rough estimate of how long was spent on this approach

If the conversation context already contains this information, synthesize it directly without prompting.

### Step 3: Append to dead-ends.md

Determine the correct dead-ends file based on current phase:

- Research phase: `.workflows/<name>/research/dead-ends.md`
- Other phases: `.workflows/<name>/<phase>/dead-ends.md` (create the file if it does not exist)

Append the following entry:

```markdown
## Dead End: <brief topic> — <YYYY-MM-DD>

**What was tried:** <description of the approach>

**Why it failed:** <reason — be specific and concrete>

**Key learning:** <what we learned that's useful going forward>

**Time spent:** <rough estimate>
```

### Step 4: Update research index (research phase only)

If the current phase is `research`, update `.workflows/<name>/research/index.md`:

- If the dead-end topic has an existing row in the index table, change its Status column to `dead-end`
- If it does not have a row, add one with Status set to `dead-end`

### Step 5: Add beads comment

Record the dead end on the workflow's beads epic:

```bash
bd update <epic-id> --comment "Dead end: <brief topic> — <one-line reason>"
```

Where `<epic-id>` comes from state.json's `beads_epic_id`.

### Step 6: Git commit

```bash
git add .workflows/<name>/
git commit -m "docs: record dead end in workflow <name> — <brief topic>"
```

### Step 7: Prompt for new direction

After recording the dead end, ask the user what direction to try next. Offer these options:

1. **Continue in the same phase** with a different approach — describe the new approach and proceed
2. **Skip to the next phase** if enough information exists to move forward despite the dead end
3. **Checkpoint and pause** — run `/workflow-checkpoint` to save progress and revisit later

Wait for the user's decision before taking further action.

## Key principles

- **Dead ends are valuable.** They prevent future sessions from wasting time on the same approach. Write enough detail that someone reading the entry six months later understands what happened.
- **No shame in pivoting.** This command exists because dead ends are a normal part of exploration. The goal is to capture the learning, not to assign blame.
- **Be concrete.** "It didn't work" is not a useful dead-end entry. Specify what was tried, what broke, and what the failure taught us.
- **Always record before pivoting.** Never abandon an approach without documenting it first. The documentation is the whole point.
