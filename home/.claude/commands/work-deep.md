---
description: "Deep work — multi-session initiative with research, planning, specs, and phased implementation"
user_invocable: true
---

# /work-deep $ARGUMENTS

Multi-session initiative. Pre-selects Tier 3, runs assessment to confirm, then routes through 7 steps: assess → research → plan → spec → decompose → implement → review.

This command replaces 13 `workflow-*` commands with step-based routing.

## Step 1: Detect Active Task

Scan `.work/` for `state.json` files where `archived_at` is null.

- **Active Tier 3 task exists**: Resume it. Read `current_step` and jump to the Step Router.
- **Active task of different tier exists**: "You have an active Tier <N> task '<name>'. Continue with it, or archive it and start a new one?"
- **No active task**: Proceed to assessment.
- **`$ARGUMENTS` references a beads issue**: Read issue details with `bd show`.

## Step 2: Assessment (Tier 3 pre-selected)

Apply the 3-factor depth assessment. If assessment agrees (score 4+): proceed. If disagrees: present mismatch, user decides.

## Step 3: State Initialization

1. Derive name from title (kebab-case, max 40 chars, unique)
2. Capture `base_commit`: `git rev-parse HEAD`
3. Create `.work/<name>/` directory
4. Write `state.json`:
   - `tier`: 3
   - `steps`: `["assess", "research", "plan", "spec", "decompose", "implement", "review"]`
   - `step_status`: assess=`completed`, research=`active`, all others=`not_started`
   - `current_step`: `research`
   - `assessment`: populated
   - `created_at`: current ISO 8601 timestamp
   - `updated_at`: same as `created_at`
   - `reviewed_at`: `null`
5. Create beads epic and initial issue:
   ```bash
   bd create --title="<title>" --type=epic --priority=1
   bd create --title="[Research] <title>" --type=task --priority=2
   bd update <research-id> --status=in_progress
   ```
6. Create directories:
   - `.work/<name>/research/`
   - `.work/<name>/plan/`
   - `.work/<name>/specs/`
   - `.work/<name>/streams/`
7. Create `docs/feature/<name>.md` summary file with initial content:
   ```markdown
   # <Title>
   **Status:** active | **Tier:** 3 | **Beads:** <epic-id>
   ## What
   <2-3 sentence description — filled in during plan step>
   ```
8. Store `beads_epic_id`, `issue_id` in state.json (no `docs_path` — deprecated)

## Step Router

Read `current_step` from state.json and execute the matching section below.

---

## Inter-Step Quality Review Protocol

Every step transition runs a two-phase review before auto-advancing. Each auto-advance block below references this protocol.

**Phase A — Artifact Validation** (existing): Spawn an Explore agent (read-only) to check structural completeness — files exist, are indexed, follow naming conventions. Each step's checklist defines what to validate.

**Phase B — Quality Review** (NEW): Spawn a step-appropriate agent to evaluate substance. The agent type and checklist vary by transition (see table below). The agent receives `skills: [code-quality]` and reads `.claude/rules/architecture-decisions.md`.

| Transition | Phase B Agent | Quality Focus |
|-----------|---------------|---------------|
| research → plan | Plan agent | Coverage vs task scope, evidence-based findings, alignment with architecture-decisions.md |
| plan → spec | Plan agent | Tech choices vs decision rules, component layering, constructor injection, fail-closed |
| spec → decompose | Plan agent | Implementability, interface consistency, testable acceptance criteria, edge cases |
| decompose → implement | Plan agent | Granularity, stream/code boundary alignment, phase ordering, parallelism |
| implement phases | go-reviewer agent | Spec compliance, code-quality anti-patterns, test coverage |
| implement → review | go-reviewer agent | Pre-screen full diff for obvious issues before formal review |

**Verdicts:**
- **PASS**: No issues found. Auto-advance immediately.
- **ADVISORY**: Minor notes that don't block progress. Auto-advance immediately, log notes in the gate issue description.
- **BLOCKING**: Substantive issues that must be fixed. Fix and re-run Phase B (up to 2 attempts). If still blocking after 2 attempts, ask the user for guidance.

**Transition behavior:** Reviews are self-driven — Phase A and Phase B run automatically without user interaction. On PASS or ADVISORY, present a brief summary of what was produced, review results, and what's next, then **wait for user acknowledgment** before advancing. The harness handles all bookkeeping; the user controls the pace.

---

### When current_step = "research"

Structured exploration to build understanding before planning.

**Process:**

1. **Read the task context**: Review `$ARGUMENTS`, beads issue details, and any conversation context.

2. **Structured exploration via parallel subagents**: Launch Explore agents to investigate aspects of the task. Spawn with `skills: [work-harness, code-quality]`.

3. **Research notes**: For each finding, create a note in `.work/<name>/research/` and index it in `.work/<name>/research/index.md`:
   ```markdown
   | Topic | Summary | Status | File |
   |-------|---------|--------|------|
   | <topic> | <one-line summary> | <explored|dead-end|future> | `<filename>.md` |
   ```

4. **Dead ends**: If an approach fails, document it in `.work/<name>/research/dead-ends.md` (same format as `/work-redirect`). Do NOT re-investigate documented dead ends.

5. **Futures**: If research reveals deferred enhancements, append to `.work/<name>/futures.md` with title, horizon (next/quarter/someday), domain, and 2-4 sentence description.

6. **Handoff prompt**: When research is sufficient, generate `.work/<name>/research/handoff-prompt.md`:
   - What this step produced (topic summaries, key findings)
   - Key artifacts and paths
   - Decisions made during research
   - Open questions to address in planning
   - Instructions for the plan step

7. **Auto-advance** (see Inter-Step Quality Review Protocol):
   a. Write the handoff prompt to `.work/<name>/research/handoff-prompt.md`
   b. **Phase A — Artifact validation** — spawn Explore agent (read-only). Checklist:
      - Are findings indexed in research/index.md?
      - Are dead ends documented?
      - Are futures captured in `.work/<name>/futures.md`?
      - Are open questions for planning identified?
   c. **Phase B — Quality review** — spawn Plan agent (read-only) with `skills: [code-quality]`. Checklist:
      - Do findings cover the full task scope (no major areas uninvestigated)?
      - Are findings evidence-based (references to code, docs, or prior art)?
      - Are findings consistent with `.claude/rules/architecture-decisions.md`?
      - Are open questions specific enough to drive planning decisions?
   d. Apply verdict: PASS/ADVISORY → continue. BLOCKING → fix and re-review (max 2 attempts, then ask user).
   e. Create gate issue: `bd create --title="[Gate] <name>: research → plan" --type=task --priority=2` (log ADVISORY notes in description)
   f. Update state.json in a single write: mark research `completed` with `gate_id`, set plan to `active`, set `current_step` to `plan`, update `updated_at`
   g. Present brief summary: what research found, key artifacts, review results, advancing to plan.
   h. **Wait for user** to acknowledge before continuing to plan.
   i. **Context refresh**: Re-read `.claude/rules/code-quality.md` and `.claude/rules/architecture-decisions.md`. Re-read the handoff prompt just written.

---

### When current_step = "plan"

Synthesize research into an architecture document.

**Process:**

1. **Read research handoff**: Read `.work/<name>/research/handoff-prompt.md` — this is the primary input. Do NOT re-read individual research notes (the handoff is the firewall).

2. **Write architecture document**: Create `.work/<name>/specs/architecture.md`:
   - Problem statement and goals
   - Component map with scope estimates
   - Data flow diagrams (text-based)
   - Technology choices with rationale
   - Open questions resolved from research
   - New questions deferred to spec

3. **Update summary**: Update `docs/feature/<name>.md` — fill in the What section and add a Components list from the architecture.

4. **Handoff prompt**: Generate `.work/<name>/plan/handoff-prompt.md`:
   - What this step produced
   - Architecture document location
   - Component list for spec writing
   - Instructions for spec step

5. **Futures**: If planning reveals deferred enhancements, append to `.work/<name>/futures.md`.

6. **Auto-advance** (see Inter-Step Quality Review Protocol):
   a. Write the handoff prompt to `.work/<name>/plan/handoff-prompt.md`
   b. **Phase A — Artifact validation** — spawn Explore agent (read-only). Checklist:
      - Does the architecture cover all goals from the research handoff?
      - Are component boundaries clear (no overlapping responsibilities)?
      - Are technology choices justified?
      - Is the dependency order between components correct?
      - Are scope exclusions explicit?
   c. **Phase B — Quality review** — spawn Plan agent (read-only) with `skills: [code-quality]`. Checklist:
      - Do technology choices align with decision rules in `.claude/rules/architecture-decisions.md`?
      - Does component layering follow handlers → services → database/storage?
      - Are all services using constructor injection (`NewXxxService(pool, ...)`)?
      - Do failure modes fail closed (no silent fallbacks)?
   d. Apply verdict: PASS/ADVISORY → continue. BLOCKING → fix and re-review (max 2 attempts, then ask user).
   e. Create gate issue: `bd create --title="[Gate] <name>: plan → spec" --type=task --priority=2` (log ADVISORY notes in description)
   f. Update state.json: mark plan `completed` with `gate_id`, set spec to `active`, set `current_step` to `spec`, update `updated_at`
   g. Present brief summary: architecture overview, component count, review results, advancing to spec.
   h. **Wait for user** to acknowledge before continuing to spec.
   i. **Context refresh**: Re-read `.claude/rules/code-quality.md` and `.claude/rules/architecture-decisions.md`. Re-read the handoff prompt.

---

### When current_step = "spec"

Write detailed implementation specifications per component.

**Process:**

1. **Read plan handoff**: Read `.work/<name>/plan/handoff-prompt.md`.

2. **Cross-cutting contracts**: Write `.work/<name>/specs/00-cross-cutting-contracts.md` — shared schemas, interfaces, naming conventions consumed by all specs.

3. **Numbered specs**: For each component from the architecture's component map, write `.work/<name>/specs/NN-<slug>.md`:
   - Overview and scope
   - Implementation steps with acceptance criteria
   - Interface contracts (exposes/consumes)
   - Files to create/modify
   - Testing strategy

4. **Spec index**: Track in `.work/<name>/specs/index.md`:
   ```markdown
   | Spec | Title | Status | Dependencies |
   |------|-------|--------|-------------|
   | 00 | Cross-cutting contracts | complete | — |
   | 01 | <slug> | complete | 00 |
   ```

5. **Dependency ordering**: Establish which specs can be written in parallel vs sequentially.

6. **Update summary**: Update `docs/feature/<name>.md` — add a Key Decisions section from the specs.

7. **Futures**: If spec writing reveals deferred enhancements, append to `.work/<name>/futures.md`.

8. **Auto-advance** (see Inter-Step Quality Review Protocol):
   a. Write the handoff prompt to `.work/<name>/specs/handoff-prompt.md`
   b. **Phase A — Artifact validation** — spawn Explore agent (read-only). Checklist:
      - Do all specs reference the cross-cutting contracts (spec 00)?
      - Are path conventions consistent across all specs?
      - Are all state.json fields used in specs declared in spec 00?
      - Do code examples match the described behavior?
      - Are testing strategies concrete?
      - Are edge cases for each rule documented?
   c. **Phase B — Quality review** — spawn Plan agent (read-only) with `skills: [code-quality]`. Checklist:
      - Are acceptance criteria testable and unambiguous?
      - Are interface contracts consistent across specs (no divergent copies)?
      - Do specs account for error paths and fail-closed behavior?
      - Are implementation steps ordered correctly (dependencies before dependents)?
      - Do specs avoid over-engineering (no premature abstractions)?
   d. Apply verdict: PASS/ADVISORY → continue. BLOCKING → fix and re-review (max 2 attempts, then ask user).
   e. Create gate issue: `bd create --title="[Gate] <name>: spec → decompose" --type=task --priority=2` (log ADVISORY notes in description)
   f. Update state.json: mark spec `completed` with `gate_id`, set decompose to `active`, set `current_step` to `decompose`, update `updated_at`
   g. Present brief summary: spec count, key design decisions, review results, advancing to decompose.
   h. **Wait for user** to acknowledge before continuing to decompose.
   i. **Context refresh**: Re-read `.claude/rules/code-quality.md` and `.claude/rules/beads-workflow.md`. Re-read the handoff prompt.

---

### When current_step = "decompose"

Break specs into executable work items with a concurrency map.

**Scope expansion check:** If the user requests changes that would add new components or specs beyond what was planned, acknowledge the regression: "This adds new scope. We're currently in decompose but this requires plan/spec work." Present options: (a) roll back to plan/spec, (b) add as lightweight amendment. Document the scope change in the handoff prompt.

**Process:**

1. **Read spec handoff**: Read `.work/<name>/specs/handoff-prompt.md`.

2. **Create beads issues**: For each work item from specs:
   ```bash
   bd create --title="[<tag>] W-NN: <title> — spec NN" --type=task --priority=2
   ```
   Title must reference the spec it implements (e.g., `W-01: state-guard.sh — spec 01`). This naming convention is verified by step output review agents.
   Set dependencies between issues to match spec dependency ordering.

3. **Concurrency map**: Identify which streams can run in parallel:
   - Group work items into streams (one per independent workstream)
   - Streams are designed as **parallel agent workloads** — each stream becomes a self-contained agent prompt
   - Identify phase ordering (which streams must complete before others)
   - Document the DAG and critical path
   - Verify: no file appears in more than one stream within the same phase

4. **Stream execution documents**: For each stream, write a self-contained agent prompt in `.work/<name>/streams/<stream-letter>.md`:
   - Stream identity and work items (beads IDs)
   - Spec references for each work item
   - Files to create/modify
   - Acceptance criteria per work item
   - Dependency constraints (what must complete before this stream starts)

5. **Issue manifest**: Create `.work/<name>/streams/manifest.jsonl` mapping work items to beads IDs, streams, and phases.

6. **Futures**: If you discover deferred enhancements during decompose, append to `.work/<name>/futures.md`.

7. **Auto-advance** (see Inter-Step Quality Review Protocol):
   a. Write the handoff prompt to `.work/<name>/streams/handoff-prompt.md`
   b. **Phase A — Artifact validation** — spawn Explore agent (read-only). Checklist:
      - Does every spec component map to at least one work item? (Title must reference spec: `W-NN: ... — spec NN`)
      - Are beads issue dependencies consistent with spec dependency ordering?
      - Can claimed "parallel" streams actually run in parallel (no hidden deps)?
      - Do stream execution docs have acceptance criteria?
      - Is the concurrency map consistent with the dependency graph?
   c. **Phase B — Quality review** — spawn Plan agent (read-only) with `skills: [code-quality]`. Checklist:
      - Are work items at the right granularity (each completable in one agent session)?
      - Do stream boundaries align with code module boundaries (no file conflicts)?
      - Is phase ordering correct (foundational work before dependent work)?
      - Are parallel streams truly independent (no shared mutable state)?
   d. Apply verdict: PASS/ADVISORY → continue. BLOCKING → fix and re-review (max 2 attempts, then ask user).
   e. Create gate issue: `bd create --title="[Gate] <name>: decompose → implement" --type=task --priority=2` (log ADVISORY notes in description)
   f. Update state.json: mark decompose `completed` with `gate_id`, set implement to `active`, set `current_step` to `implement`, update `updated_at`
   g. Present detailed summary: N work items across M streams, concurrency map, phase ordering, review results.
   h. **Wait for user** to acknowledge before continuing to implement.
   i. **Context refresh**: Re-read `.claude/rules/code-quality.md`, `.claude/rules/beads-workflow.md`, and `.claude/rules/architecture-decisions.md`. Re-read the handoff prompt.
   j. Continue to implement section.

---

### When current_step = "implement"

Execute the implementation plan from decompose.

**Scope expansion check:** If the user requests changes that would add new work items not mapped to existing specs, or architecture changes, acknowledge the regression. Present options: (a) roll back to plan/spec/decompose, (b) add as amendment. Document in the step's handoff prompt.

**Process:**

1. **Read decompose handoff**: Read `.work/<name>/streams/handoff-prompt.md`.

2. **Parallel agent execution**: Spawn one subagent per independent stream from the streams handoff:
   - Each subagent receives: its stream execution doc + relevant specs + `skills: [work-harness, code-quality]`
   - Subagents claim work with `bd update <id> --status=in_progress` and close with `bd close <id>`
   - Lead agent monitors completion and launches next-phase agents when dependencies clear

3. **Phase gating** (enforced — see Inter-Step Quality Review Protocol): After each implementation phase completes:
   - **Phase A — Artifact validation**: Spawn Explore agent (read-only) to check implementations match spec file lists and acceptance criteria
   - **Phase B — Quality review**: Spawn go-reviewer agent (read-only) with `skills: [code-quality]`. Checklist:
     - Does the implementation comply with the relevant spec's acceptance criteria?
     - Are code-quality anti-patterns absent (error swallowing, fabricated data, fail-open)?
     - Do new tests cover the acceptance criteria?
     - Are constructor injection and error wrapping patterns followed?
   - Write results to `.work/<name>/implement/phase-N-validation.jsonl`
   - Apply verdict: PASS/ADVISORY → proceed to Phase N+1. BLOCKING → fix and re-review (max 2 attempts, then ask user).
   - Only proceed to Phase N+1 when Phase N validation passes with PASS or ADVISORY

4. **Checkpoints**: Use `/work-checkpoint` at session boundaries. Multi-session implementation is normal for Tier 3.

5. **Verification**: Run `make test && make build` after each phase or logical unit.

6. **Futures**: If you discover deferred enhancements during implement, append to `.work/<name>/futures.md`.

7. **Scope expansion check**: If the user requests changes that would add new components, specs, or work items beyond what was planned, acknowledge the regression.

8. **Auto-advance** (when all work items closed — see Inter-Step Quality Review Protocol):
   a. **Phase B — Quality pre-screen**: Spawn go-reviewer agent (read-only) with `skills: [code-quality]`. Review full diff (`git diff <base_commit>...HEAD`). Checklist:
      - Are there obvious code-quality anti-patterns in the diff?
      - Do all new functions have error handling?
      - Are there any swallowed errors or fabricated defaults?
      - Do tests exist for new functionality?
   b. Apply verdict: PASS/ADVISORY → continue. BLOCKING → fix and re-review (max 2 attempts, then ask user).
   c. Create gate issue: `bd create --title="[Gate] <name>: implement → review" --type=task --priority=2` (log ADVISORY notes in description)
   d. Update state.json: mark implement `completed` with `gate_id`, set review to `active`, set `current_step` to `review`, update `updated_at`
   e. Present brief summary: items completed, phases passed, review results, advancing to review.
   f. **Wait for user** to acknowledge before continuing to review.
   g. **Context refresh**: Re-read `.claude/rules/code-quality.md`. Re-read latest checkpoint if exists.

---

### When current_step = "review"

Mandatory full review before archive.

**Process:**

1. **Run `/work-review`**: This is mandatory for Tier 3. The review command spawns specialist agents, collects findings, and writes to `.work/<name>/review/findings.jsonl`.

2. **Address findings**: All critical findings must be fixed. Important findings must be fixed or have beads issues created for deferred resolution.

3. **Re-review**: After fixes, re-run `/work-review` to reconcile.

4. **On clean review** (no critical OPEN findings): Mark `review` as `completed`.

5. **Archive**: Task remains active until `/work-archive`. The archive gate requires all critical AND important findings to be FIXED or have `beads_issue_id`.

## Escalation Handling

Already Tier 3, so escalation is rare. If needed, the user can manually adjust state.json.

## Skill Propagation

- **Implementation agents**: `skills: [work-harness, code-quality]`
- **Review agents** (via `/work-review`): `skills: [code-quality]` only
- **Research agents**: `skills: [work-harness, code-quality]`

## Session Boundaries

Tier 3 tasks span many sessions. Key patterns:
- **Starting a session**: Run `/work-deep` — it detects the active task and resumes at `current_step`
- **Ending a session**: Run `/work-checkpoint` to save progress
- **After compaction**: Run `/work-reground` to recover context
- **Dead ends**: Run `/work-redirect` to document failed approaches
- **Self-driven reviews, gated transitions**: The Inter-Step Quality Review Protocol runs Phase A + Phase B automatically at each transition. The harness handles all bookkeeping (handoff prompts, gate issues, state updates). But every step transition waits for user acknowledgment — reviews are self-driven, advancement is not.
