---
description: "Capture a future enhancement during workflow research — low-friction, tracked in futures.md, promoted at archive time."
user_invocable: true
---

# Workflow Future

Capture a deferred enhancement or future improvement identified during workflow research. Creates a structured entry in the workflow's `futures.md` file, which gets promoted to `docs/futures/` when the workflow archives.

## Arguments

- `<title>` — short description of the enhancement (required)
- `[--horizon]` — when this might be relevant: `next`, `quarter`, or `someday` (default: `someday`)

## Process

### Step 1: Detect active workflow

Find the active workflow by scanning `.workflows/*/state.json` for entries where `archived_at` is null.

If no active workflow exists, report the error and stop. This command only works during an active workflow's research or plan phase.

### Step 2: Ensure futures.md exists

Check for `.workflows/<name>/research/futures.md`. If it doesn't exist, create it:

```markdown
# Future Enhancements: <title>

Improvements identified during research that are OUT OF SCOPE for this workflow.
Promoted to `docs/futures/` at archive time.

---
```

### Step 3: Append entry

Append a structured entry to `.workflows/<name>/research/futures.md`:

```markdown

## <title>

**Horizon**: <next|quarter|someday>
**Domain**: <inferred from context — e.g., pipeline, auth, chat, ui>
**Identified**: <current date>

<2-4 sentence description synthesized from conversation context: what the enhancement does, why it matters, what it would require>

**Context**: <relative path to the research file where this was discussed, if applicable>
**Prerequisites**: <what must be done first, or "None">
**Complementary**: <related futures, if any>
```

Synthesize the description from the current conversation context. Include enough detail that someone reading this 6 months from now understands the enhancement without needing to read the full research notes.

### Step 4: Update research index

Add or update an entry in `.workflows/<name>/research/index.md`:

```
| <title> | <one-line summary> | future-enhancement | `futures.md` |
```

### Step 5: Confirm

Report to the user:

```
Future enhancement captured: "<title>" (horizon: <horizon>)
Stored in .workflows/<name>/research/futures.md
Will be promoted to docs/futures/ at archive time.
```

Then return to whatever was in progress — this command should feel like a quick aside, not a context switch.

## Key principles

- **Minimal friction.** This command should take seconds, not minutes. The agent synthesizes the description from context — the user just provides a title and optional horizon.
- **Rich enough to stand alone.** Six months from now, the entry must make sense without reading the surrounding research. Include the "why" and "what it requires," not just the "what."
- **No tracking system dependency.** Everything is markdown in git. No external services, no database, no sync issues.
- **Promotion is guaranteed.** The archive process reads `futures.md` and promotes unresolved entries to `docs/futures/`. The capture-to-permanent path is automatic, not opt-in.
