---
description: "Decompose specs into phased work items with concurrency maps and self-contained stream execution documents."
user_invocable: true
---

# Workflow Decompose

Decompose specs into phased work items, map concurrency across streams, and generate self-contained execution documents that a Claude Code session can pick up and implement without additional context.

## Arguments

- `<name>` — the workflow slug (kebab-case)

## Process

### Step 1: Load context

Read these files in parallel:

1. `.workflows/<name>/specs/handoff-prompt.md` (if exists) — primary context from the spec phase
2. `.workflows/<name>/specs/index.md` — spec dependency ordering
3. All spec files from `docs/feature/<name>/` (`00-*.md` through `NN-*.md`)
4. `.workflows/<name>/state.json` — verify phase state

If `current_phase` is not `decompose` and the spec phase is not `completed`, report the mismatch and suggest `/workflow-status <name>`.

### Step 2: Set phase active

```bash
bd set-state <epic-id> phase=decompose
```

Update `state.json`:
- `phases.decompose.status` = `"active"`
- `phases.decompose.started_at` = current ISO 8601 timestamp (only if first activation)
- `current_phase` = `"decompose"`
- `updated_at` = current ISO 8601 timestamp

### Step 3: Analyze dependencies

Map the dependency graph across all specs to determine three categories:

1. **Foundation** — must be done first: cross-cutting contracts, database schemas, migrations, shared types
2. **Parallel** — independent domain implementations that can run concurrently once foundation is complete
3. **Integration** — must be last: wiring in `cmd/server/main.go`, end-to-end flows, template integration

Build a dependency DAG from the specs' "Depends on", "Blocks", "Exposes", and "Consumes" fields.

### Step 4: Present Decomposition for Approval

Before writing any documents or creating issues, present the proposed structure:

- **Phase breakdown**: How many phases, what's in each, and why
- **Stream boundaries**: What's parallel, what's serial, and the critical path
- **Draft concurrency DAG**: ASCII art showing stream dependencies

```
Example:
Phase 1:  [stream-1: Foundation]
                    |
          +---------+---------+
          v         v         v
Phase 2: [stream-2] [stream-3] [stream-4]
                    |
                    v
Phase 3: [stream-5: Integration]
```

Ask: "Here's the proposed decomposition. Does this phasing strategy make sense? Should any streams be split, merged, or reordered?"

**Do NOT create phase docs, stream docs, or beads issues until the user approves the decomposition structure.**

### Step 5: Create phase work items

Group work into numbered phases. Write each phase to `docs/feature/<name>/phase-N-<slug>.md`:

```markdown
# Phase N: <Phase Title>

| Field | Value |
|-------|-------|
| Prerequisites | Phase N-1 complete |
| Streams | N parallel streams |
| Work items | W-01 through W-NN |

## Work Items

### W-01: <Title>
- **Source**: NN-<slug>.md, Section "<section>"
- **Depends on**: --
- **Deliverable**: <what is produced — files, migrations, endpoints>
- **Estimated scope**: XS/S/M/L

### W-02: <Title>
- **Source**: NN-<slug>.md, Section "<section>"
- **Depends on**: W-01
- **Deliverable**: <what is produced>
- **Estimated scope**: XS/S/M/L

## Phase Gate
- [ ] All W-items completed
- [ ] `make test` passes
- [ ] `make build` compiles cleanly
- [ ] (phase-specific criteria from specs' acceptance criteria)
```

### Step 6: Create concurrency maps

For each phase that has parallel work, write `docs/feature/<name>/phase-N/streams.md`:

```markdown
# Phase N Streams: Concurrency Map

## Dependency DAG
```
Phase N:  [stream-1: Foundation (contracts, schemas)]
                      |
          +-----------+-----------+
          v           v           v
Phase N: [stream-2]  [stream-3] [stream-4]
                      |
                      v
Phase N: [stream-N: Integration]
```

## Stream Summary
| Stream | Title | Work Items | Depends On | Blocks | Scope |
|--------|-------|------------|------------|--------|-------|
| 1 | Foundation | W-01, W-02 | -- | 2, 3, 4 | S |
| 2 | <domain> | W-03, W-04 | 1 | 5 | M |

## W-Item Coverage Matrix
| W-Item | Stream | Spec Source | Scope |
|--------|--------|-------------|-------|
| W-01 | 1 | 00-cross-cutting-contracts | XS |
| W-02 | 1 | 01-<slug> | S |

## Integration Points
- IP-1: Stream 2 exposes FooService interface consumed by Stream 4
- IP-2: Stream 3 creates migration that Stream 2's queries depend on

## Critical Path
[Identify the longest dependency chain through the DAG. This determines
minimum calendar time regardless of parallelism.]
```

### Step 7: Create stream execution documents

For each stream, write `docs/feature/<name>/phase-N/stream-N-<slug>.md`. These are the documents that an implementing Claude Code session will read. They must be **completely self-contained**.

```markdown
# Stream N: <Title>

| Field | Value |
|-------|-------|
| Work items | W-01, W-02, W-03 |
| Prerequisites | Stream 1 complete |
| Estimated scope | M |
| Depends on | stream-1 |
| Blocks | stream-6 |

## Existing Code Context
Read these files before starting:
- `internal/services/existing.go` -- [why this is relevant]
- `internal/handlers/existing.go` -- [pattern to follow]
- `cmd/server/main.go` -- [where to wire new code]

## Internal Work Item Ordering

### Step 1: W-01 -- <title>
[Detailed implementation instructions. Include code patterns to follow,
file paths to create, and specific acceptance criteria.]

- [ ] Acceptance: <specific, verifiable criterion>

### Step 2: W-02 -- <title>
[Detailed implementation instructions.]

- [ ] Acceptance: <specific, verifiable criterion>

## Key Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|
| `internal/services/foo.go` | Create | FooService with constructor injection |
| `internal/handlers/foo.go` | Create | HTTP handlers, HTMX-aware |
| `migrations/NNNN_create_foo.up.sql` | Create | Schema migration |

## Interface Contracts

### Exposes
[What this stream produces for other streams to consume]

### Consumes
[What this stream needs from completed prerequisite streams]

## Risk Notes
- [Potential issues, edge cases, or areas where the spec was ambiguous]

## Merge Gate Checklist
[Single consolidated definition of done for this stream. Everything required
to consider the stream complete — no chasing across multiple documents.]

### Build verification
- [ ] `make test` passes
- [ ] `make build` compiles cleanly
- [ ] `make lint` — no issues
- [ ] `make fmt` — code formatted

### Runtime verification
[Concrete runtime checks beyond build — expected HTTP responses, background
jobs registered, health check payloads, etc. Copy from spec's Runtime
Verification section.]
- [ ] [Specific runtime check from spec]

### Issue closure
[Explicit list of beads issue IDs that must be closed for this stream to
be considered complete. Include whether open non-stream issues block merge.]
- [ ] `rag-xxxx` — W-01: <title>
- [ ] `rag-yyyy` — W-02: <title>
- [ ] No open issues with `stream:N` label remain

### Artifacts produced
- [ ] [List every file that must exist when done]

## Implementation Prompt
> You are implementing Stream N (<title>) of the <name> workflow.
>
> **Read first**: [ordered list of files for context]
> **Execute in order**: [step sequence with W-item references]
> **Verify**: Run the Merge Gate Checklist above after each W-item
> **Beads**: `bd update <issue-id> --status=in_progress` before starting, `bd close <issue-id>` when done
> **Patterns**: Follow existing patterns in internal/ -- constructor injection, chi handlers, slog logging, error wrapping with fmt.Errorf
```

### Step 8: Create beads issues

Create a beads issue for each work item, linked to the workflow epic:

```bash
bd create --title="[Tag] <task title>" --type=task --parent=<epic-id> --labels="workflow:<name>,spec:NN,stream:N"
```

Set up dependencies between issues:

```bash
bd dep add <issue-id> <depends-on-issue-id>
```

Use tags from the spec sources: `[API]`, `[UX]`, `[DB]`, `[Service]`, `[Bug]`, `[Refactor]`, `[CRUD]`, `[Feature]`, `[Workflow]`, `[Integration]`.

### Step 9: Create issue manifest

Write `.workflows/<name>/issues/manifest.jsonl` with one JSON line per issue:

```json
{"work_item": "W-01", "spec": "01-<slug>", "stream": 1, "phase": 1, "beads_id": "rag-xxxx", "title": "<title>", "scope": "S"}
```

This file enables `/workflow-implement` to map between specs, streams, and beads issues.

### Step 10: Create swarm

If the decomposition has parallel streams, create a beads swarm for coordination:

```bash
bd swarm create <epic-id>
```

### Step 11: Generate handoff prompt

Write `.workflows/<name>/streams/handoff-prompt.md`:

```markdown
# Handoff: decompose -> implement

## What This Phase Produced
- Phase work items at `docs/feature/<name>/phase-N-*.md`
- Concurrency maps at `docs/feature/<name>/phase-N/streams.md`
- Stream execution docs at `docs/feature/<name>/phase-N/stream-N-*.md`
- Issue manifest at `.workflows/<name>/issues/manifest.jsonl`
- Beads issues created and linked

## Implementation Order
1. Phase 1: Foundation — [N issues, sequential]
2. Phase 2: Core — [N issues, M parallel streams]
3. Phase 3: Integration — [N issues, sequential]

## Stream Summary
[One-line per stream with scope and dependencies]

## Critical Path
[Longest dependency chain — minimum calendar time]

## Instructions for Implement Phase
1. Run `bd ready` filtered by `workflow:<name>` to find unblocked work
2. For single-issue work: read the stream doc, claim the issue, implement
3. For parallel work: use `/workflow-implement <name> parallel` to launch worktree sessions
4. After each stream completes, check if downstream streams are unblocked
```

### Step 12: On phase end

Suggest running `/workflow-checkpoint --phase-end` to finalize and transition to implement.

## Key principles

- **Stream docs are self-contained.** An implementing session reads one stream doc and has everything: context, instructions, file list, verification commands, and beads workflow. No need to read the architecture doc or other streams.
- **Dependency accuracy is critical.** Incorrect dependencies cause either blocked streams (too conservative) or integration failures (too optimistic). Trace "Exposes/Consumes" contracts carefully.
- **Scope estimates compound.** Individual W-item estimates should sum to a realistic stream estimate. If a stream totals more than L, split it into smaller streams.
- **The critical path is the bottleneck.** No amount of parallelism helps if the critical path is long. If the critical path looks too long, consider restructuring phases to shorten it.
- **Every work item gets a beads issue.** No exceptions. The issue manifest must have complete coverage of all W-items across all streams and phases.
- **Decomposition is a design decision.** The dependency analysis suggests a structure, but the user decides the final phasing and stream boundaries.
- **One place for definition of done.** The Merge Gate Checklist in each stream doc is the single source of truth for stream completion — build checks, runtime verification, issue closure, and required artifacts. Don't split completion criteria across documents.
- **Issue closure must be explicit.** Each stream doc lists the exact beads issue IDs that must be closed for stream completion. Ambiguity about whether non-stream issues block merge causes confusion at the finish line.
