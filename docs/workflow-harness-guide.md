# Multi-Session Workflow Harness — User Guide

This guide covers the complete workflow harness: what it is, how each command works, and
how to use it to build features in gaucho across multiple Claude Code sessions.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Quick Reference](#2-quick-reference)
3. [Getting Started](#3-getting-started)
4. [The Standard Flow — End-to-End Example](#4-the-standard-flow--end-to-end-example)
5. [Phase Deep Dives](#5-phase-deep-dives)
   - [Research](#5a-research-phase)
   - [Plan](#5b-plan-phase)
   - [Spec](#5c-spec-phase)
   - [Decompose](#5d-decompose-phase)
   - [Implement](#5e-implement-phase)
6. [Cross-Cutting Commands](#6-cross-cutting-commands)
7. [The Interaction Contract](#7-the-interaction-contract)
8. [Procedural Edge Cases](#8-procedural-edge-cases)
9. [File Layout Reference](#9-file-layout-reference)
10. [Beads Integration](#10-beads-integration)

---

## 1. Overview

The workflow harness is a system of 11 Claude Code slash commands that coordinate
feature development across multiple sessions. It solves a specific problem: Claude
Code sessions are stateless. When a session ends, all context is lost. The next
session starts cold with no memory of what was researched, decided, or built.

The harness solves this with **structured file handoffs**. Each phase writes
artifacts — research notes, architecture docs, specs, stream execution documents —
that the next session reads to reconstruct context. The key insight is that a session
with full context (the one that just finished the work) is the best author of
instructions for a session starting cold.

### The Five Phases

```
Research -> Plan -> Spec -> Decompose -> Implement
```

Each phase has a clear input, a clear output, and a handoff artifact that bridges to
the next phase:

| Phase | Input | Output |
|-------|-------|--------|
| Research | Workflow title, existing codebase | Indexed research notes, dead-ends log |
| Plan | Research handoff + user vision | Architecture document |
| Spec | Architecture document | Numbered implementation specs |
| Decompose | Specs + dependency graph | Phase/stream docs, beads issues |
| Implement | Stream execution docs | Working code, closed beads issues |

The harness is **human-directed with automated seams**. Claude automates context
loading, state tracking, and bookkeeping. You direct topic selection, architecture
decisions, spec ordering, decomposition structure, and implementation approach.
Claude presents options and waits. It does not proceed past a decision point without
your input.

---

## 2. Quick Reference

| Command | Purpose | When to use |
|---------|---------|-------------|
| `/workflow-start <name> [title]` | Initialize a new workflow | Starting a new feature |
| `/workflow-status [name]` | Show phase progress and next action | Start of session, checking progress |
| `/workflow-research <name> [topic]` | Enter or continue the research phase | Exploring the problem space |
| `/workflow-plan <name> [doc]` | Enter the planning phase | After research is complete |
| `/workflow-spec <name> [section]` | Write implementation specs | After architecture is approved |
| `/workflow-decompose <name>` | Break specs into streams and beads issues | After all specs are written |
| `/workflow-implement <name> [mode]` | Pick up and execute work | During active implementation |
| `/workflow-checkpoint [--phase-end]` | Save progress or close a phase | End of session or phase |
| `/workflow-reground [name]` | Reload context after compaction or new session | After context compaction, new session |
| `/workflow-redirect <reason>` | Record a dead end and pivot | When an approach fails |
| `/workflow-archive <name>` | Archive a completed workflow | After all issues are closed |

---

## 3. Getting Started

Run `/workflow-start` to initialize a workflow. This is the only setup step.

```
/workflow-start loan-documents "Loan Document Processing"
```

What happens:

1. The slug is validated (must be kebab-case). If the workflow already exists, the
   command stops — it never overwrites.
2. The directory structure is created.
3. `state.json` is initialized with all five phases at `not_started`.
4. Seed files are created: research index and dead-ends log.
5. A beads epic is created and its ID stored in `state.json`.
6. Everything is committed to git so other sessions can see it via `git pull`.

### Directory Structure Created

```
.workflows/loan-documents/
    state.json
    research/
        index.md           # One-line summaries of all research topics
        dead-ends.md       # Failed approaches with reasons
        checkpoints/       # Mid-session resumption prompts
    plan/
    specs/
    streams/
    issues/
    archive/

docs/feature/loan-documents/
    # Architecture doc and specs land here during Plan and Spec phases
```

The split between `.workflows/` and `docs/feature/` is intentional. Workflow metadata
(state, checkpoints, handoff prompts) lives in `.workflows/` and can be archived when
the workflow is done. Permanent documentation (architecture, specs, stream docs)
lives in `docs/feature/` and stays there permanently as reference material.

### state.json

```json
{
  "name": "loan-documents",
  "title": "Loan Document Processing",
  "created_at": "2026-03-01T14:00:00Z",
  "updated_at": "2026-03-01T14:00:00Z",
  "beads_epic_id": "rag-0100",
  "docs_path": "docs/feature/loan-documents",
  "current_phase": "research",
  "phases": {
    "research": { "status": "not_started", "started_at": null, "completed_at": null,
                  "gate_id": null, "sessions": [], "handoff_prompt": null },
    "plan":     { "status": "not_started", ... },
    "spec":     { "status": "not_started", ... },
    "decompose":{ "status": "not_started", ... },
    "implement":{ "status": "not_started", ... }
  },
  "archived_at": null
}
```

`state.json` is the source of truth. Every command reads it before doing anything.
`archived_at: null` means the workflow is active (the workflow-detect rule uses this
to show the active-workflow notification at session start).

---

## 4. The Standard Flow — End-to-End Example

This section walks through building a complete feature called "loan-documents" — a
document upload and processing pipeline. Follow the commands and interactions in
order. Each step shows the command, what Claude presents, what you decide, and what
happens next.

### Step 1: Start

```
/workflow-start loan-documents "Loan Document Processing"
```

Claude creates the directory structure, commits it, and reports:

```
Workflow `loan-documents` initialized.
Epic: rag-0100

.workflows/loan-documents/
.workflows/loan-documents/research/
  index.md
  dead-ends.md
  checkpoints/
...
docs/feature/loan-documents/

Run /workflow-research loan-documents to begin the research phase.
```

---

### Step 2: Research

```
/workflow-research loan-documents
```

Claude reads `state.json`, `research/index.md`, `research/dead-ends.md`, and the
latest checkpoint (none yet). It activates the research phase in `state.json` and
then presents:

```
Research phase started for loan-documents.

Index: empty (no topics researched yet)
Dead ends: none

Areas not yet covered based on the workflow title:
  1. Existing file upload patterns in the codebase
  2. AWS Textract integration (currently enabled via config flag)
  3. Document storage — S3 patterns and MinIO local dev
  4. Existing document models and database tables

What would you like to investigate first?
```

**You say:** "Start with existing file upload patterns."

Claude spins up Explore agents, searches closed beads issues for prior file-upload
work, and writes `.workflows/loan-documents/research/file-upload-patterns.md`. It
updates the research index and then checks in:

```
Topic `file-upload-patterns` researched and indexed.

Key finding: internal/storage/s3.go has an Upload method that handles both S3 and
MinIO. Handlers in internal/handlers/documents.go use multipart parsing. The pattern
is well-established.

What next?
  - Research another topic
  - Promote this finding to permanent docs
  - Save a checkpoint
  - End the research phase
```

**You say:** "Research Textract integration next."

Claude researches Textract, finds the existing `internal/clients/textract.go`, writes
the note, updates the index, and checks in again. After three topics are covered:

**You say:** "That's enough. End the research phase."

Claude suggests:

```
Run /workflow-checkpoint --phase-end to generate the handoff prompt and transition
to the plan phase.
```

```
/workflow-checkpoint --phase-end
```

Claude synthesizes the session into a checkpoint and a handoff prompt, presents both
for your review, then asks: "Does the resumption prompt capture where we are? Anything
to add or correct?"

**You say:** "Looks good."

Claude writes the files, marks the research phase as `completed` in `state.json`,
advances `current_phase` to `plan`, creates a gate issue in beads, and commits.

---

### Step 3: Plan

```
/workflow-plan loan-documents
```

Claude reads `research/handoff-prompt.md` and `research/index.md` in parallel,
activates the plan phase, and presents:

```
Plan phase started.

Handoff from research:
  - Existing Upload method in internal/storage/s3.go handles S3 and MinIO
  - Textract client at internal/clients/textract.go, enabled via cfg.TextractEnabled()
  - No existing document model — will need new table and service
  - Open question: async processing or synchronous?

Before I draft the architecture, what's your vision for the high-level approach?
Any constraints, priorities, or technology preferences I should know?
```

**You say:** "Process documents synchronously for now — we can make it async later.
Keep it simple: upload handler calls storage service, which calls Textract if enabled,
stores the result. Standard handler -> service -> database layering."

Claude writes `docs/feature/loan-documents/architecture.md` with the full system
context, data model, component map, and phasing summary. It then presents the outline
for review:

```
Architecture outline:

  Overview: Document upload pipeline with optional OCR extraction
  System Context: Integrates with existing storage/s3.go, adds new document service
  Tech Stack: Go, pgx, AWS Textract (optional), S3/MinIO
  Data Model: documents table (id, loan_id, filename, s3_key, textract_result, created_at)
  Data Flow: POST /loans/{id}/documents -> handler -> DocumentService -> S3 + Textract
  Component Map:
    1. DocumentService (DB + business logic)
    2. Upload handler + HTMX partial
    3. Textract processing (synchronous call)
    4. Document list view
  Phasing: DB + service first, then handler, then UI

Review it before I write the handoff prompt?
```

**You say:** "Looks good. Continue."

Claude writes `plan/handoff-prompt.md` and suggests running `/workflow-checkpoint
--phase-end`. You run it, approve the handoff content, and the plan phase completes.

---

### Step 4: Spec

```
/workflow-spec loan-documents
```

Claude reads `plan/handoff-prompt.md`, `docs/feature/loan-documents/architecture.md`,
and `specs/index.md` (empty). It spins up parallel Explore agents per component area,
activates the spec phase, and presents:

```
Spec phase started.

Component Map (from architecture.md):
  1. DocumentService — database queries and business logic (depends on: contracts)
  2. Upload handler — HTTP handler + HTMX partial (depends on: 1)
  3. Textract processing — synchronous OCR call (depends on: 1)
  4. Document list view — full page + partial rendering (depends on: 2)

Existing code context:
  - internal/services/ has 4 services following NewXxxService(pool, ...) pattern
  - internal/handlers/handlers.go has the Handlers struct and existing HTMX helpers
  - migrations/ has 12 existing migrations following NNNN_name.up.sql format

Which component should I spec next? I recommend starting with the cross-cutting
contracts (00), then following the dependency order above.
```

**You say:** "Start with cross-cutting contracts."

Claude writes `docs/feature/loan-documents/00-cross-cutting-contracts.md` with the
`DocumentService` interface and shared types, then checks in:

```
Spec 00-cross-cutting-contracts written.
  Files to create: 1 (00-cross-cutting-contracts.md — already done)
  Defines: DocumentService interface, Document struct, UploadRequest/Response types

Want to review it, or move on to the next component?
```

**You say:** "Move on to DocumentService."

Claude writes `01-document-service.md`. This continues until all four components are
specced. After each spec, Claude checks in and waits for your direction.

After the last spec, Claude suggests running `/workflow-checkpoint --phase-end`.

---

### Step 5: Decompose

```
/workflow-decompose loan-documents
```

Claude reads all spec files and the spec handoff prompt, analyzes dependencies, and
presents the proposed decomposition before creating anything:

```
Proposed decomposition:

Phase 1 — Foundation (sequential):
  stream-1: Contracts + Migration + DocumentService
    W-01: 00-cross-cutting-contracts (XS)
    W-02: Migration (creates documents table) (S)
    W-03: DocumentService with queries (M)

Phase 2 — Core (2 parallel streams after stream-1):
  stream-2: Upload handler + Textract processing
    W-04: Upload handler with multipart (M)
    W-05: Synchronous Textract call in service (S)
  stream-3: Document list view
    W-06: HTMX partial list rendering (S)
    W-07: Full page document view (S)

Phase 3 — Integration (sequential):
  stream-4: Wire everything into cmd/server/main.go
    W-08: Router registration, middleware, dependency injection (S)

Critical path: stream-1 -> stream-2 -> stream-4 (5 days minimum)
Parallelism: stream-2 and stream-3 can run concurrently in Phase 2.

Does this phasing strategy make sense? Should any streams be split, merged, or
reordered?
```

**You say:** "Looks right. Proceed."

Claude creates the phase docs, concurrency maps, and stream execution documents. It
then creates beads issues for all 8 work items, links them to the epic, sets up
inter-issue dependencies, writes the issue manifest, and generates the decompose
handoff prompt.

---

### Step 6: Implement

```
/workflow-implement loan-documents next
```

Claude reads the streams handoff prompt, checks `bd ready`, finds W-01 (the
cross-cutting contracts work item) as the highest-priority unblocked issue, reads
stream-1's execution doc, and presents:

```
Next issue: rag-0101 — [DB] Create cross-cutting contracts

Plan:
  Read first:
    1. docs/feature/loan-documents/00-cross-cutting-contracts.md
    2. internal/services/existing_service.go (pattern reference)

  Execute:
    Step 1: Write 00-cross-cutting-contracts.md (already exists from spec phase)
    Step 2: Verify content matches spec interface definitions

  Verify: make test && make build
  Beads: bd update rag-0101 --status=in_progress, bd close rag-0101 when done

Ready to proceed, or want to adjust the approach?
```

**You say:** "Proceed."

Claude claims the issue (`bd update rag-0101 --status=in_progress`) and begins. After
W-01 is done, it closes the issue and checks what's next. W-02 (migration) is now
unblocked, so Claude suggests:

```
rag-0101 closed. W-02 (migration) is now unblocked.
Run /workflow-implement loan-documents next for the next issue.
```

This continues until Phase 1 is complete. At that point:

```
Phase 1 complete. Streams 2 and 3 are now unblocked and can run in parallel.
Run /workflow-implement loan-documents parallel to launch worktree sessions.
```

---

## 5. Phase Deep Dives

### 5a. Research Phase

**Command:** `/workflow-research <name> [topic]`

**What it produces:**
- Individual research note files at `.workflows/<name>/research/<topic-slug>.md`
- Updated entries in `research/index.md` (one row per topic)
- Dead-end entries in `research/dead-ends.md` (for failed approaches)
- Checkpoint files in `research/checkpoints/` (for session continuity)
- A handoff prompt at `research/handoff-prompt.md` (written at phase end)

**The topic selection loop:**

Claude loads the index, presents what is already known and what is missing, then asks
what to investigate. You pick a topic. Claude researches it (closed beads issues
first, then codebase, then web if needed), writes the findings file, updates the
index, and checks in. You decide what to do next — another topic, a promotion to
permanent docs, a checkpoint, or end the phase. Claude never moves to the next topic
without your direction.

**Dead end tracking:**

When a research direction proves unproductive, run `/workflow-redirect` to record it
before pivoting. See [Section 6](#workflow-redirect) for details. The dead-ends log
prevents future sessions from repeating the same failed approach.

**Promoting research to permanent docs:**

Research notes live inside `.workflows/` and move to `.workflows/archive/` when the
workflow is archived. If a note has standalone reference value (edge case analysis,
infrastructure evaluation, competitive research), Claude can promote it to
`docs/research/<name>-<topic>.md`. This promotion is optional and requires your
direction — Claude offers but never promotes automatically.

**Ending the phase:**

When you signal readiness ("that's enough" or "end the research phase"), Claude
suggests running `/workflow-checkpoint --phase-end`. The checkpoint session asks you
to approve both the resumption prompt and the handoff prompt before writing either
file. The handoff prompt is the most important artifact from the research phase — it
carries findings and open questions forward to the planning session.

---

### 5b. Plan Phase

**Command:** `/workflow-plan <name> [doc]`

**What it reads (in parallel at startup):**
1. `research/handoff-prompt.md` — primary context. Trust its instructions over your
   own reading of raw research notes.
2. `research/index.md` — summaries only. Raw research notes are not read unless the
   handoff prompt directs you to a specific file.
3. `state.json` — phase verification
4. External doc (if provided as second argument)

**The "Present and Ask" gate:**

After loading context, Claude summarizes what the research phase discovered and asks
for your vision before writing a word of the architecture document. This is a hard
stop — Claude cannot know your technology preferences, organizational constraints, or
product priorities from research alone. You provide direction; Claude writes.

**The review gate:**

After drafting the architecture, Claude presents the outline (section headings plus
one-line summaries) and asks whether you want to review it before the handoff prompt
is generated. This is another hard stop. You review, request changes, then approve.

**External document ingestion (Mode B):**

If you have a PRD, RFC, or external spec that should drive the architecture, pass its
path as the second argument:

```
/workflow-plan loan-documents ~/docs/loan-processing-prd.md
```

Claude reads the document, writes a summary to `plan/external-ref.md` (extracted
requirements, link to original), and uses it as the primary input for architecture
alongside research findings. If the external doc conflicts with research findings,
Claude flags the conflict rather than silently preferring one source.

---

### 5c. Spec Phase

**Command:** `/workflow-spec <name> [section]`

**The one-spec-at-a-time pattern:**

Claude reads the plan handoff prompt, the architecture document, and the spec index.
It spins up parallel Explore agents per component area to gather existing code context.
Then it presents the component map and asks which component to spec next. You choose.
Claude writes one spec, presents a summary, and waits. You review, request changes,
or direct it to the next component. Never more than one spec at a time without your
approval.

**Cross-cutting contracts first:**

Before any numbered specs, Claude creates `00-cross-cutting-contracts.md`. This file
defines shared Go interfaces, DTOs, and table ownership rules. All subsequent specs
reference it via their "Consumes" section. Defining interfaces before implementations
prevents the most common integration failure: two specs that implement incompatible
types for the same boundary.

**The review loop per spec:**

After writing each spec, Claude presents:
- Spec title and scope estimate (XS/S/M/L)
- File count and key files to create or modify
- Acceptance criteria count

You can review the full spec file, request revisions, or approve and move on.

**Dependency ordering:**

The spec index at `.workflows/<name>/specs/index.md` records specs in dependency
order. Get this right — a spec that claims to depend only on contracts but actually
needs types defined in a later spec will cause stream blocking during decompose.
Claude tracks "Depends on" and "Blocks" fields in each spec, but you are the final
arbiter of ordering.

**Targeting a specific section:**

If you want to work on a particular component without going through the full
presentation, pass it as the second argument:

```
/workflow-spec loan-documents document-service
```

Claude jumps directly to that component's context-gathering and writing, skipping the
full component map presentation.

---

### 5d. Decompose Phase

**Command:** `/workflow-decompose <name>`

**The approval gate:**

Decompose reads all spec files and analyzes the dependency graph, but it does
not write a single file or create a single beads issue until you approve the
proposed structure. Claude presents the full phase and stream layout, the
concurrency DAG as ASCII art, and the critical path. You review, request
restructuring, and approve. Then Claude proceeds.

This gate matters because decomposition is a design decision. How you split work into
streams determines what can be parallelized, what the critical path is, and how
much coordination overhead you pay. Claude proposes based on dependency analysis; you
decide based on team size, calendar, and risk tolerance.

**Concurrency maps and stream execution documents:**

For each phase with parallel work, Claude writes a `streams.md` concurrency map
showing the dependency DAG, stream summary table, work-item coverage matrix, and
integration points.

For each stream, Claude writes a self-contained stream execution document. "Self-
contained" means: an implementing session reads that one document and has everything
needed — existing code context (specific file paths and patterns), ordered work items
with acceptance criteria, files to create or modify, interface contracts, and a
pre-written implementation prompt. The implementing session should not need to read
the architecture doc or spec files.

**Beads issue creation:**

After you approve the decomposition, Claude creates a beads issue for every work item,
links each to the workflow epic, and sets up inter-issue dependencies matching the
stream dependency structure. It writes an issue manifest at
`.workflows/<name>/issues/manifest.jsonl` so the implement phase can map between
issue IDs, stream numbers, and spec references.

If the decomposition has parallel streams, Claude creates a beads swarm for
coordination:

```bash
bd swarm create <epic-id>
```

**What "self-contained" means in practice:**

When an implementing session runs `/workflow-implement loan-documents stream 2`, it
reads `stream-2-upload-handler.md` and finds: which files to read first, which
existing patterns to follow, the exact implementation steps, acceptance criteria for
each step, verify commands, and beads commands. It does not need to re-read specs,
the architecture doc, or the research index. This is the harness's core value
proposition for parallel sessions.

---

### 5e. Implement Phase

**Command:** `/workflow-implement <name> [mode]`

**Four modes:**

```
/workflow-implement loan-documents          # same as 'next'
/workflow-implement loan-documents next     # highest-priority unblocked issue
/workflow-implement loan-documents rag-0103 # specific beads issue
/workflow-implement loan-documents stream 2 # full stream execution
/workflow-implement loan-documents parallel # all unblocked streams as worktrees
```

**The review gate in every mode:**

In all four modes, Claude reads the relevant stream doc, generates an implementation
plan (files to read, steps to execute, verify commands, beads commands), presents the
plan, and asks for confirmation before claiming the issue or writing a line of code.
This is the same "Present and Pause" pattern as all other phases.

**Parallel worktree sessions:**

When `parallel` mode identifies multiple unblocked streams, Claude generates worktree
setup instructions:

```bash
git worktree add .worktrees/loan-documents-stream-2 -b workflow/loan-documents-stream-2
cd .worktrees/loan-documents-stream-2
# Start Claude Code and run: /workflow-implement loan-documents stream 2

git worktree add .worktrees/loan-documents-stream-3 -b workflow/loan-documents-stream-3
cd .worktrees/loan-documents-stream-3
# Start Claude Code and run: /workflow-implement loan-documents stream 3
```

Each parallel session gets its own branch. You create the worktrees and start the
sessions manually — the harness generates the instructions, but branch management is
yours to control.

**Post-implementation flow:**

After each work item completes:

1. Verify: `make test && make build && make lint`
2. Close the beads issue: `bd close <id> --reason="implemented FooService"`
3. Check what is now unblocked: `bd ready --label=workflow:loan-documents`
4. Claude suggests the next action (next issue, parallel run, or archive)

Close issues incrementally as work items complete, not all at the end of a stream.
Incremental closing unblocks downstream work sooner.

---

## 6. Cross-Cutting Commands

### Checkpoints (`/workflow-checkpoint`)

**Mid-session checkpoint** (no flags):

```
/workflow-checkpoint
```

Writes a checkpoint file to `.workflows/<name>/<phase>/checkpoints/<timestamp>.md`
containing: what was accomplished, files modified, remaining work, open questions,
and a self-contained resumption prompt. Claude presents the draft — especially the
resumption prompt — and asks for your approval before writing. The checkpoint is then
committed to git so other sessions can see it.

The resumption prompt is the most critical part of a checkpoint. It must be detailed
enough that a cold session reading it needs no additional explanation. Claude writes
it based on the conversation context; you verify it captures the right state.

**Phase-end checkpoint** (`--phase-end`):

```
/workflow-checkpoint --phase-end
```

Does everything a mid-session checkpoint does, plus:
- Generates a handoff prompt (the next phase's primary context)
- Marks the current phase as `completed` in `state.json`
- Advances `current_phase` to the next phase
- Creates a beads gate issue at the phase transition

Claude presents both the resumption prompt and the handoff prompt for your approval
before writing either file. Phase state does not advance until you approve.

**When to checkpoint vs when to end a phase:**

Checkpoint mid-session when you are stopping for the day but the phase is not done —
tomorrow's session reads the resumption prompt and picks up exactly where you left.
Use `--phase-end` when the phase's deliverable is complete and you are ready to move
forward. These are different operations that produce different artifacts.

---

### Status (`/workflow-status`)

```
/workflow-status
/workflow-status loan-documents
```

Displays a compact table of all phases with status, session count, artifact count,
and last activity date. Ends with a concrete next-step suggestion. Read-only — makes
no state changes.

Use it at the start of any session to orient yourself, or any time you want a quick
picture of where the workflow stands. If you have only one active workflow, you can
omit the name.

---

### Reground (`/workflow-reground`)

```
/workflow-reground
/workflow-reground loan-documents
```

Loads the minimal set of artifacts needed to resume work in the current phase,
presents a concise summary, and makes no state changes. Use this at the start of a
new session that is picking up an active workflow, or after Claude Code compacts
context mid-session.

**What it loads per phase:**

| Phase | Files loaded |
|-------|-------------|
| Research | `research/index.md`, `research/dead-ends.md`, latest checkpoint |
| Plan | `research/handoff-prompt.md`, `research/index.md`, `architecture.md` (if exists) |
| Spec | `plan/handoff-prompt.md`, `architecture.md`, `specs/index.md` |
| Decompose | `specs/handoff-prompt.md`, `specs/index.md`, `docs/feature/<name>/` listing |
| Implement | `streams/handoff-prompt.md`, `bd ready` output, `docs/feature/<name>/` listing |

**The index.md firewall:**

During the research phase, `/workflow-reground` reads `research/index.md` and never
opens individual research note files. The index contains one-line summaries of all
research. This is intentional — reading all raw research notes on every session
start would consume the context window and slow everything down. The index is the
summary layer that makes the research phase's output navigable without re-reading it.

---

### Redirect (`/workflow-redirect`)

```
/workflow-redirect "Polling for Textract results doesn't work at this scale"
```

Records a dead end and pivots. When an approach fails — a library doesn't fit, a
pattern proves too complex, an assumption turns out wrong — run this command before
trying something else. The reason can be a brief phrase; Claude will gather details
if needed.

Claude appends to the appropriate dead-ends file with: what was tried, why it failed,
key learning, and time spent. If the current phase is research, the research index is
also updated to mark the topic's status as `dead-end`. The dead end is noted as a
comment on the beads epic. Everything is committed.

Then Claude presents three options and waits for your choice:

1. **Continue in the same phase** with a different approach
2. **Skip to the next phase** if enough information exists despite the dead end
3. **Checkpoint and pause** — save progress and revisit later

Claude does not proceed with any of these options until you choose one.

---

### Archive (`/workflow-archive`)

```
/workflow-archive loan-documents
```

Verifies completion, generates an archive summary, closes the epic, and moves workflow
metadata to `.workflows/archive/loan-documents/`. Permanent docs in
`docs/feature/loan-documents/` stay in place.

Before archiving, Claude checks:
- All phases are `completed` or `skipped`
- All child beads issues are closed

If anything is incomplete, Claude lists exactly what remains and asks whether to archive
anyway. If you confirm, it closes remaining issues and marks phases complete before
proceeding.

The archive summary at `.workflows/archive/loan-documents/archive/summary.md` is the
lasting record: what was built, what was tried and abandoned, how long it took, and
where the permanent docs live. Write it for the reader six months from now.

---

## 7. The Interaction Contract

The workflow harness has a consistent interaction pattern across all six phase
commands (research, plan, spec, decompose, implement, checkpoint). Understanding it
prevents frustration when Claude pauses and also helps you recognize when something
has gone wrong.

### What Claude does automatically

At the start of every command, Claude handles the bookkeeping without asking:
- Reads `state.json` to verify the current phase
- Loads phase-specific context files in parallel
- Sets the phase status to `active` in `state.json` and beads
- Syncs state to git at phase transitions

### Where Claude must wait for you

These are the decision points where the harness requires human input. Claude presents
information and stops.

**Research phase:**
- Topic selection — Claude presents gaps, you choose what to investigate
- After each topic — you decide: another topic, promotion, checkpoint, or end

**Plan phase:**
- Vision gate — Claude asks for your architectural direction before writing
- Review gate — Claude presents the architecture outline before generating the handoff

**Spec phase:**
- Component selection — Claude presents the component map, you choose which to write
- After each spec — you review and direct: revise, or move to the next component

**Decompose phase:**
- Approval gate — Claude presents the full decomposition structure before writing
  any documents or creating any issues

**Implement phase:**
- Plan review — Claude presents the implementation plan before claiming the issue
  or touching any files

**Checkpoint:**
- Content review — Claude presents the resumption prompt and/or handoff prompt for
  your approval before writing the file

### Why this matters

These gates exist because the decisions at each pause are design decisions, not
bookkeeping. Which research topic to pursue next depends on what you already know and
what you are most uncertain about — Claude can suggest, but you have the broader
context. The architecture's technology choices depend on organizational preferences
and future constraints Claude does not know about. Decomposition strategy depends on
your team size and calendar.

If Claude proceeds past a gate without presenting and waiting, that is a bug in
the command's behavior, not the intended design. Interrupt and redirect. Say "stop
— I haven't approved that yet" and Claude will step back.

---

## 8. Procedural Edge Cases

### Starting a session in an active workflow

At session start, the workflow-detect rule fires and displays a notification if any
workflow has `archived_at: null` in its `state.json`:

```
Active workflow detected: loan-documents (Loan Document Processing)
Current phase: spec (status: active)
Run /workflow-status for details or /workflow-reground to recover context.
```

Use `/workflow-status` for a quick orientation, or `/workflow-reground` to load
enough context to actually resume work. You do not need to run `/workflow-start`
again — the workflow persists across sessions.

---

### Context compaction mid-phase

If Claude Code compacts the context window during a long session, run:

```
/workflow-reground
```

This reloads the minimal context for the current phase from files rather than from
compressed conversation history. If you have unsaved progress from the current session
that is not yet reflected in files, checkpoint first:

```
/workflow-checkpoint
/workflow-reground
```

The checkpoint preserves in-session progress; the reground then loads a clean picture
from files.

---

### Wanting to revisit a completed phase

Phase transitions are one-way in `state.json`. If you need to go back to the plan
phase after starting spec work, edit `state.json` manually:

```json
"current_phase": "plan",
"phases": {
  "plan": { "status": "active", ... },
  "spec": { "status": "not_started", ... }
}
```

Then run `/workflow-plan loan-documents` to re-enter the phase. This is intentionally
not automated — reverting a phase is a deliberate decision that should not happen
accidentally.

---

### Multiple active workflows

Each workflow has its own `state.json`. Commands auto-detect when there is one active
workflow and require you to specify the name when there are multiple:

```
/workflow-status                  # auto-detects if only one workflow
/workflow-status loan-documents   # explicit name for multiple workflows
```

`/workflow-checkpoint` auto-detects from `active` or `in_progress` phase status.
If multiple workflows have active phases, it lists them and asks which one to
checkpoint.

---

### Parallel worktree sessions

When using `parallel` mode in the implement phase:

- Each session gets its own branch (`workflow/<name>-stream-N`)
- You create the worktrees and start the sessions (the harness generates the commands,
  but branch management stays with you per CLAUDE.md)
- Claim issues immediately with `bd update --status=in_progress` before touching any
  file — this prevents two sessions from picking up the same issue
- Run `bd sync` frequently to coordinate — other sessions' claims become visible after
  sync

If two sessions try to claim the same issue, the second one will see the issue as
`in_progress` when it checks and should skip to the next ready issue.

---

### A research topic turns into a dead end

Run `/workflow-redirect` immediately — do not wait until the end of the session.

```
/workflow-redirect "AWS Textract webhooks not available in us-east-2"
```

Claude records the dead end with enough detail that six months from now you will
remember exactly what failed. Then it asks what direction to try next: different
approach, skip to next phase, or checkpoint and pause. Choose one.

---

### External document as input to planning

Pass the document path as the second argument:

```
/workflow-plan loan-documents ~/docs/loan-processing-prd.md
```

Claude reads the document (Mode B), writes a summary to `plan/external-ref.md`, and
uses it as the primary architecture input alongside research findings. It flags any
conflicts between the external doc and research discoveries rather than silently
deferring to one source.

---

### Skipping phases

Not recommended, but possible. Advance `current_phase` in `state.json` manually and
mark the skipped phase as `"status": "skipped"`. The next phase command will load
whatever context exists from earlier phases.

Be aware that skipping research means the plan phase will not have a
`research/handoff-prompt.md` to read — Claude will note the missing file and proceed
with only whatever you provide directly in the session.

---

### Phase gate issues

At each `--phase-end` checkpoint, Claude creates a beads gate issue:

```
[Gate] loan-documents: research -> plan
```

The gate issue is a review checkpoint at the phase boundary. Close it manually when
you are satisfied that the phase's output is solid enough to proceed. The next phase
command checks whether a gate issue is still open and warns you if so. It does not
block progress — it is a signal, not an enforcer.

---

### When Claude proceeds without asking

This is a bug in the skill — the interaction contract says Claude must present and
wait at each gate. If you notice Claude writing architecture docs without asking for
your vision, or creating beads issues before you approved the decomposition, stop it:

"Stop. You proceeded without my approval. Go back to the gate — present the
[architecture outline / decomposition structure / etc.] and wait for my direction."

Claude will step back and re-present. If it happens repeatedly, report it as a
harness issue.

---

### Long-running research with multiple sessions

Research phases often span multiple sessions. The pattern is:

1. Session N: Research topics, run `/workflow-checkpoint` before ending
2. Session N+1: Run `/workflow-reground` to reload context from the checkpoint and
   index, then continue with `/workflow-research loan-documents`

The checkpoint's resumption prompt tells the next session exactly where to pick up.
The research index provides the summary layer so the next session does not need to
re-read all previous research notes.

---

### Spec changes after decompose

If you need to change a spec after the decompose phase has already created stream
docs and beads issues:

1. Edit the spec file directly (`docs/feature/loan-documents/NN-slug.md`)
2. Re-run `/workflow-decompose loan-documents` to regenerate affected stream docs
3. Update the affected beads issues manually (or close and recreate them)

Re-running decompose presents the full approval gate again, so you review the
revised structure before any new documents are written. Affected stream docs that
were already partially executed need manual reconciliation — the harness does not
track partial stream completion state.

---

## 9. File Layout Reference

A mature workflow with all phases completed looks like this:

```
.workflows/
  loan-documents/
    state.json

    research/
      index.md                         # Summary table: topic | summary | status | file
      dead-ends.md                     # Abandoned approaches with reasons
      file-upload-patterns.md          # Research note: upload patterns
      textract-integration.md          # Research note: Textract client
      document-storage.md              # Research note: S3/MinIO patterns
      checkpoints/
        2026-03-01-140000.md           # Session 1 resumption prompt
        2026-03-02-091500.md           # Session 2 resumption prompt
      handoff-prompt.md                # research -> plan handoff (written at phase end)

    plan/
      external-ref.md                  # Present only if Mode B was used
      handoff-prompt.md                # plan -> spec handoff

    specs/
      index.md                         # Dependency-ordered spec list
      handoff-prompt.md                # spec -> decompose handoff

    streams/
      handoff-prompt.md                # decompose -> implement handoff

    issues/
      manifest.jsonl                   # One line per issue: W-item, stream, beads ID

    archive/
      (empty until /workflow-archive runs)

docs/feature/
  loan-documents/
    architecture.md                    # System architecture — permanent reference
    00-cross-cutting-contracts.md      # Shared interfaces and types
    01-document-service.md             # DocumentService spec
    02-upload-handler.md               # Upload handler + HTMX partial spec
    03-textract-processing.md          # Synchronous Textract call spec
    04-document-list-view.md           # List view spec

    phase-1-foundation.md              # Phase 1 work items
    phase-1/
      streams.md                       # Concurrency map for Phase 1
      stream-1-contracts-and-service.md  # Self-contained execution doc

    phase-2-core.md                    # Phase 2 work items
    phase-2/
      streams.md                       # Concurrency map for Phase 2
      stream-2-upload-handler.md       # Self-contained execution doc
      stream-3-list-view.md            # Self-contained execution doc

    phase-3-integration.md             # Phase 3 work items
    phase-3/
      streams.md
      stream-4-wiring.md
```

After `/workflow-archive loan-documents`, the `.workflows/loan-documents/` directory
moves to `.workflows/archive/loan-documents/`, and the archive summary is written to
`.workflows/archive/loan-documents/archive/summary.md`. The `docs/feature/loan-documents/`
directory does not move.

---

## 10. Beads Integration

The workflow harness and beads (`bd`) are tightly coupled. Every workflow artifact
has a corresponding beads record.

### Epic per workflow

`/workflow-start` creates a beads epic with the workflow title:

```bash
bd create --title="[Workflow] Loan Document Processing" --type=epic --priority=1
```

The epic ID is stored in `state.json` as `beads_epic_id`. All subsequent beads
commands reference this ID. The epic's phase label (`bd set-state <epic-id>
phase=research`) tracks which phase is active.

### Issue per work item

`/workflow-decompose` creates one beads issue per work item (W-01, W-02, etc.),
linked to the epic:

```bash
bd create --title="[DB] Create documents table migration" \
  --type=task --parent=rag-0100 \
  --labels="workflow:loan-documents,spec:01,stream:1"
```

Labels allow filtering by workflow, spec, and stream. Use these to scope `bd ready`
and `bd list` output to your active workflow:

```bash
bd ready --label=workflow:loan-documents
bd list --status=open --label=workflow:loan-documents
```

### Dependencies mirror spec dependencies

`/workflow-decompose` sets up beads inter-issue dependencies matching the stream
dependency structure:

```bash
bd dep add <stream-2-issue> <stream-1-issue>  # stream 2 blocked by stream 1
```

`bd ready` only shows issues whose blockers are all closed. This means `bd ready
--label=workflow:loan-documents` always gives you the correct next issue to pick up
without manually tracking the dependency graph.

### Gate issues at phase transitions

`/workflow-checkpoint --phase-end` creates a gate issue at each phase transition:

```bash
bd create --title="[Gate] loan-documents: research -> plan" --type=task --priority=2
```

Close the gate issue manually when you are satisfied with the phase's output. The
next phase command checks the gate issue status and surfaces a warning if it is still
open.

### Session end workflow

Before ending any session that has touched workflow files:

```bash
git status
git add .workflows/loan-documents/ docs/feature/loan-documents/
bd sync
git commit -m "chore: checkpoint workflow loan-documents (research)"
bd sync                  # catch any beads changes from the commit
git push
```

The workflow-check hook (`/.claude/hooks/workflow-check.sh`) runs at session end and
warns if workflow files were modified without a checkpoint:

```
Workflow files modified without checkpoint. Consider running /workflow-checkpoint
before ending session.
```

This is a warning, not a block. You can end the session without checkpointing, but
the next session will have no resumption prompt and will need to reconstruct state
from the index and handoff files alone.
