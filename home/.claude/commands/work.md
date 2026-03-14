---
description: "Start or continue work — auto-assesses task depth and routes to the right tier"
user_invocable: true
---

# /work $ARGUMENTS

Start a new task or continue an active one. Auto-assesses task complexity using a 3-factor scoring formula and routes to the appropriate tier (Fix, Feature, or Initiative).

## Step 1: Detect Active Task

Scan `.work/` for `state.json` files where `archived_at` is null.

- **`.work/` does not exist**: This is the first task in this project. Proceed to Step 2 (Assessment).
- **Active task exists, no `$ARGUMENTS`**: Resume the active task. Read `current_step` from state.json and jump to the Step Router (Step 4).
- **Active task exists, `$ARGUMENTS` provided**: Ask: "You have an active task '<name>'. Continue with it, or archive it and start a new one?"
- **Multiple active tasks**: Present a list with tier and current step. Ask user to choose.
- **No active tasks** (all archived): Proceed to Step 2.
- **`$ARGUMENTS` references a beads issue** (e.g., "rag-1234"): Read issue details with `bd show` and use as context for assessment.

## Step 2: Assessment

If `$ARGUMENTS` is empty: check conversation context and `git diff` for implicit task context. If context is available, infer the task description and present for confirmation. If no context, ask: "What would you like to work on?"

Apply the 3-factor depth assessment:

| Factor | Score | Criteria |
|--------|-------|----------|
| Scope Spread | 0-2 | 0: single file, 1: 2 layers, 2: 3+ layers |
| Design Novelty | 0-2 | 0: known pattern, 1: adaptation, 2: new subsystem |
| Decomposability | 0-2 | 0: atomic, 1: 2-3 subtasks, 2: phased breakdown |
| Bulk Modifier | -1 or 0 | -1: mechanical repetition, 0: normal |

```
score = scope_spread + design_novelty + decomposability + bulk_modifier
```

Present the assessment:

```
## Assessment: <title>

| Factor | Score | Rationale |
|--------|-------|-----------|
| Scope Spread | <0-2> | <one-line> |
| Design Novelty | <0-2> | <one-line> |
| Decomposability | <0-2> | <one-line> |
| Bulk Modifier | <-1 or 0> | <one-line or "N/A"> |
| **Total** | **<score>** | |

**Tier <N> (<Label>)** — <steps list>

Proceed with this assessment, or override? (e.g., "treat as Tier 2")
```

If score is on a boundary (1 or 3): "Score is on the Tier X/Y boundary. Consider overriding if this feels more like a [Feature/Fix]."

Handle user response:
- **Accept**: proceed with assessed tier
- **Override**: record override in `assessment.rationale`: "User override: Tier N → Tier M. Original score: S". Use overridden tier.
- **More context**: user provides additional info, re-assess

## Step 3: State Initialization

1. Derive task name from title: lowercase, replace non-alnum with `-`, collapse consecutive hyphens, trim, truncate to 40 chars, add suffix if `.work/<name>/` exists
2. Capture `base_commit`: `git rev-parse HEAD`
3. Create `.work/<name>/` directory
4. Write `state.json` with tier-appropriate fields:
   - `steps` array per tier: T1=`[assess, implement, review]`, T2=`[assess, plan, implement, review]`, T3=`[assess, research, plan, spec, decompose, implement, review]`
   - `step_status`: `assess` is `active`, all others `not_started`
   - `current_step`: `assess`
   - `assessment`: null (populated after assessment completes)
   - All other fields per spec 00 schema
5. Create or claim beads issue:
   - T1-T2: `bd create --title="<title>" --type=task --priority=2` then `bd update <id> --status=in_progress`
   - T3: Create epic + initial issue
6. T2-T3: Create `docs/feature/<name>/` directory
7. T3: Create `.work/<name>/research/`, `plan/`, `specs/`, `streams/` directories
8. Populate `assessment` field with scoring result. Mark `assess` step as `completed`. Advance `current_step` to next step.

## Step 4: Step Router

Based on `current_step` from state.json, execute the appropriate tier's logic inline. The `/work` command contains the FULL step logic for all three tiers — it does not redirect to `/work-fix`, `/work-feature`, or `/work-deep`.

### Tier 1 Steps

**implement**: Search closed beads issues for context. Implement the fix. Run `make test`. Stage and commit. Advance to `review`.

**review**: Inline mini-review — read diff since `base_commit`, check for critical anti-patterns (swallowed errors, fabricated data, missing error branches). On clean: auto-archive, close beads issue. On findings: report and suggest fixes.

### Tier 2 Steps

**plan**: Write lightweight approach doc — files to modify, approach description, test strategy, subtask breakdown. Present for user approval. On approval: advance to `implement`.

**implement**: Work through subtasks via `bd ready`. Search closed issues for context. Commit after each logical unit. Suggest `/work-checkpoint` before session end. Advance to `review`.

**review**: Run `/work-review`. On pass: advance to completed. On findings: fix and re-review.

### Tier 3 Steps

**research**: Structured exploration via parallel subagents. Notes indexed in `.work/<name>/research/index.md`. Dead ends in `dead-ends.md`. Futures in `futures.md`. Generate handoff prompt. Create gate issue. Use `/work-checkpoint --step-end` to advance.

**plan**: Read research handoff. Write `docs/feature/<name>/architecture.md`. Component map with scope estimates. Generate handoff prompt. Gate issue.

**spec**: Write `00-cross-cutting-contracts.md` and numbered specs per component. Track in `.work/<name>/specs/index.md`. Generate handoff prompt.

**decompose**: Create beads issues per work item. Concurrency map. Stream execution docs. Generate handoff prompt.

**implement**: Stream execution via `bd ready`. Checkpoints at session boundaries. Optional parallel worktrees.

**review**: Mandatory `/work-review`. All critical/important findings must be triaged before archive.

## Escalation Handling

If during any step the task reveals higher complexity:

1. User says "escalate to Tier 2/3" (or the agent recognizes the need)
2. Follow escalation protocol: update `tier`, insert new steps before `implement` in canonical order, reset `implement`/`review` to `not_started`, set `current_step` to first new step
3. Create beads epic if escalating to T3, create `docs/feature/<name>/` if escalating to T2-3
4. Append note to `assessment.rationale`
5. Re-read state and route to new `current_step`

## Skill Propagation

When spawning subagents:
- **Implementation agents**: `skills: [work-harness, code-quality]`
- **Review agents**: `skills: [code-quality]` only (review agents receive context from the review command, not from the harness skill)
