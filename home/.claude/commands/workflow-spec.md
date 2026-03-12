---
description: "Enter the spec phase — write detailed implementation specifications from the architecture document."
user_invocable: true
---

# Workflow Spec

Enter the spec phase of a workflow. Writes detailed, implementation-ready specifications from the architecture document. Each spec maps to a component from the architecture's Component Map and contains everything needed to implement it without referring back to the architecture doc.

## Arguments

- `<name>` — the workflow slug (kebab-case)
- `[section]` — optional specific component/section to spec. If omitted, work through the Component Map in dependency order.

## Process

### Step 1: Load context

Read these files in parallel:

1. `.workflows/<name>/plan/handoff-prompt.md` — **primary context** from the planning phase
2. `docs/feature/<name>/architecture.md` — the architecture document
3. `.workflows/<name>/specs/index.md` — see what specs are already written (if file exists)
4. `.workflows/<name>/state.json` — verify phase state

If `current_phase` is not `spec` and the plan phase is not `completed`, report the mismatch and suggest `/workflow-status <name>`.

### Step 2: Set phase active

```bash
bd set-state <epic-id> phase=spec
```

Update `state.json`:
- `phases.spec.status` = `"active"`
- `phases.spec.started_at` = current ISO 8601 timestamp (only if first activation)
- `current_phase` = `"spec"`
- `updated_at` = current ISO 8601 timestamp

### Step 3: Gather codebase context

Spin up parallel Explore agents — one per major spec area from the architecture's Component Map. Each agent gathers:

- Existing code patterns in the relevant source directories
- File paths and interface shapes that the spec will integrate with
- Test coverage for related existing code
- Entry points and routing relevant to the component
- UI/template files if the component has a frontend

Findings feed directly into the "Existing Code Context" section of each spec.

### Step 4: Present and Ask

Present the loaded context:

- **Component Map**: List components from the architecture doc with their dependency order
- **Codebase context**: Summarize what the Explore agents found (existing patterns, integration points)
- **Specs already written**: List any completed specs from index.md

Then direct the conversation:

- If `[section]` was provided: "Writing spec for `<section>`. Here's the relevant codebase context I found: ... Proceed?"
- If no section: "Which component should I spec next? Here's the dependency order from the architecture doc: ..."

**Do NOT begin writing spec files until the user confirms which component to work on.**

### Step 5: Create cross-cutting contracts first

Before writing individual specs, create `docs/feature/<name>/00-cross-cutting-contracts.md`:

```markdown
# Cross-Cutting Contracts

| Field | Value |
|-------|-------|
| Workflow | <name> |
| Source | architecture.md |

## Policy Rules
[Top-level rules that apply across all specs. Make implicit assumptions explicit
so implementers don't have to guess. Examples:]

- No legacy compatibility columns unless explicitly listed below
- All new tables use UUID primary keys
- [Add project-specific rules here]

## Go Interfaces
[Interface definitions that cross spec boundaries. Define them here so individual
specs can reference them without circular dependencies.

**Require exact signatures** — method name, parameter types, return types, and
expected error values. "FooService with a Store method" is insufficient;
copy-paste-ready signatures prevent integration mismatches.]

```go
type FooService interface {
    Store(ctx context.Context, doc *FooDocument) (uuid.UUID, error)
    Get(ctx context.Context, id uuid.UUID) (*FooDocument, error)
    // Returns ErrNotFound when document does not exist.
}
```

## Shared Types
[DTOs, domain models, and value objects used by multiple specs.
Include field names, types, and JSON/DB tags — not just struct names.]

```go
type FooDocument struct {
    ID        uuid.UUID `json:"id" db:"id"`
    Name      string    `json:"name" db:"name"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
}
```

## Job Catalog
[Background jobs or async tasks, if applicable. Name, trigger, inputs, outputs.]

## Transactional Patterns
[How multi-step operations maintain consistency — e.g., pgx transactions,
idempotency keys, saga patterns.]

## Data Store Ownership
[Which spec/service owns which tables. No table should be owned by two specs.]

| Table | Owner Spec | Read Access |
|-------|-----------|-------------|
```

If the workflow has no cross-cutting concerns (simple feature), this file can be minimal — but it must exist as the dependency anchor for all other specs.

### Step 6: Write numbered spec files

If `[section]` was provided, write that specific spec. Otherwise, work through the Component Map from the architecture doc in dependency order (foundations first).

**Parallel spec writing**: When multiple specs are independent (no "Depends on" relationship between them), launch parallel agents to write them concurrently. Name agents as domain experts matching the spec area (e.g., `database-architect` for migration specs, `api-designer` for handler specs, `pipeline-engineer` for workflow specs). Each agent receives:
- The architecture doc
- The cross-cutting contracts (00-cross-cutting-contracts.md)
- The Explore agent findings for its domain
- Instructions to write a single spec file

After parallel specs complete, spin up a **review agent** to check cross-spec consistency: interface contracts match, no duplicate table ownership, shared types align with 00-cross-cutting-contracts.md.

For specs with dependencies, write them sequentially — the downstream spec needs to reference what the upstream spec produced.

Write each spec to `docs/feature/<name>/NN-<slug>.md`:

```markdown
# NN: <Spec Title>

| Field | Value |
|-------|-------|
| Source | architecture.md, Section "<section>" |
| Depends on | 00-cross-cutting-contracts |
| Blocks | (specs that need this one completed first) |
| Estimated scope | S/M/L |

## Overview
[What this spec covers — one paragraph max]

## Existing Code Context
[What already exists in the codebase that this spec builds on or integrates with.
Include specific file paths and describe relevant patterns to follow.]

- `internal/services/existing.go` — [existing service this extends]
- `internal/handlers/existing.go` — [handler patterns to follow]
- `templates/existing.html` — [template structure to match]

## Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|
| `internal/services/foo.go` | Create | FooService with constructor injection |
| `internal/handlers/foo.go` | Create | HTTP handlers, HTMX-aware |
| `cmd/server/main.go` | Modify | Wire FooService into router |
| `migrations/NNNN_create_foo.up.sql` | Create | Schema for foo table |
| `templates/foo/index.html` | Create | List view with HTMX |

## Implementation Steps
1. [Step with sufficient detail to implement without ambiguity]
2. [Step referencing specific patterns from Existing Code Context]
3. [Step with HTMX-specific details: hx-target, hx-swap, partial vs full]

## Interface Contracts

### Exposes
[What this spec outputs for other specs to consume — function signatures,
HTTP endpoints, template blocks]

### Consumes
[What this spec needs from cross-cutting contracts or other specs]

## Testing Strategy
[Table-driven tests, what to mock, key scenarios to cover]

## Migration Review Checklist
[Include this section when the spec creates or modifies database tables.
Complete before implementation begins.]

- [ ] All tables listed with columns, types, constraints, and nullability
- [ ] Unique keys and indexes defined
- [ ] Foreign key relationships and ON DELETE behavior specified
- [ ] Seed data or default values documented (if any)
- [ ] Down migration behavior specified (drop table vs. remove columns)
- [ ] No gap migrations anticipated — schema is complete as specified

## Acceptance Criteria
- [ ] Criterion 1 — specific and verifiable
- [ ] Criterion 2 — specific and verifiable

## Runtime Verification
[Go beyond `make test/build/lint`. Specify concrete runtime checks where
applicable — expected HTTP response shapes, background job registration,
health check payloads, etc.]

- [ ] `GET /api/foo` returns `{"items": [...]}` with status 200
- [ ] [Additional runtime verification criteria]
```

### Step 7: Check in with the user

After writing each spec, present its summary to the user:

- **Spec title and scope** (S/M/L)
- **Files to create/modify** (count and key files)
- **Acceptance criteria count**

Ask: "Spec `NN-<slug>` written. Want to review it, or move on to the next component?"

**Do not** proceed to the next spec without user direction.

### Step 8: Update spec index

Create or update `.workflows/<name>/specs/index.md`:

```markdown
# Spec Index: <name>

Dependency-ordered list of specs. Complete specs in order — each spec's "Depends on" field lists prerequisites.

| # | Spec | Depends On | Status | Path |
|---|------|------------|--------|------|
| 00 | Cross-Cutting Contracts | -- | done | 00-cross-cutting-contracts |
| 01 | <title> | 00 | done | 01-<slug> |
| 02 | <title> | 00, 01 | pending | 02-<slug> |
```

Update status as each spec is written: `pending` -> `done`.

### Step 9: Generate handoff prompt

When all specs are written (or when ending the phase), write `.workflows/<name>/specs/handoff-prompt.md`:

```markdown
# Handoff: spec -> decompose

## What This Phase Produced
- Cross-cutting contracts at `docs/feature/<name>/00-cross-cutting-contracts.md`
- N implementation specs at `docs/feature/<name>/NN-*.md`
- Spec index at `.workflows/<name>/specs/index.md`

## Spec Summary
[One-line summary per spec with dependency relationships]

## Dependency Graph
[Text-based DAG showing spec dependencies]

## Total Estimated Scope
[Sum of individual spec estimates: S=1, M=3, L=5 story points]

## Instructions for Decompose Phase
1. Read all specs from `docs/feature/<name>/`
2. Identify parallelizable work streams
3. Create phased work items with concurrency maps
4. Generate self-contained stream execution documents
5. Create beads issues for each work item
```

### Step 10: On phase end

Suggest running `/workflow-checkpoint --phase-end` to finalize the spec phase and transition to decompose.

## Key principles

- **Self-contained specs.** Each spec must contain enough detail to implement without referencing the architecture document or other specs (except through explicit "Consumes" contracts). The implementer reads one spec and has everything they need.
- **Existing code first.** The "Existing Code Context" section is critical. Spin up Explore agents to find real patterns rather than inventing conventions. Specs that ignore existing code produce implementations that clash with the codebase.
- **Dependency ordering matters.** The spec index defines implementation order. Get dependencies right — a spec that "Depends on 00" but actually needs types from spec 03 will block the decompose phase.
- **Scope honestly.** S means a few hours, M means a day, L means multiple days. Do not compress scope estimates to make the project look smaller.
- **Contracts prevent integration bugs.** Cross-cutting contracts exist so that specs implemented by different agents or sessions produce code that fits together. Define interfaces precisely.
- **One spec at a time.** Write one spec, check in with the user, then proceed. Don't batch-write all specs without review.
- **Pin exact signatures in contracts.** Method names alone are insufficient. Cross-cutting contracts must include full Go signatures — parameter types, return types, and documented error values. Vague contracts cause integration failures.
- **Make policies explicit.** Implicit assumptions ("no legacy compat", "UUIDs everywhere") become ambiguity during implementation. State them once in the Policy Rules section of cross-cutting contracts.
- **Migrations need a checklist.** Any spec that creates or modifies tables must include a Migration Review Checklist — columns, constraints, nullability, indexes, down behavior. Incomplete migration specs cause gap migrations mid-flight.
