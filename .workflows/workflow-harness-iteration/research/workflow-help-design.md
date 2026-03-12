# Research: workflow-help Design

## Key Findings

- **Two modes**: No args = educational (explain the harness), with `<workflow>` = directional (status + guidance)
- **Complements, does not subsume `/workflow-status`**: status is "show me the data", help is "show me the map"
- **Fills real gaps**: No existing command explains why phases exist, what artifacts live where, or serves as an "I'm lost" entry point
- **`/workflow-reground` is closest relative** but assumes you know the harness; help does not

## Gap Analysis vs Existing Commands

| Need | Covered By | Gap |
|------|-----------|-----|
| Explain what the harness is | None | New user has no onboarding |
| Why each phase exists | Each phase command implicitly | No consolidated explanation |
| "I'm lost, what do I do?" | `/workflow-status` (suggests next action) | Status gives data, not narrative context |
| Artifact locations glossary | Each command references them | No single reference |
| Handoff prompt explanation | `/workflow-reground` mentions them | No explanation of why they exist |

## Proposed Structure

**No args (`/workflow-help`):**
1. Workflow philosophy (why multi-session workflows exist)
2. Five phases at a glance (research → plan → spec → decompose → implement)
3. Key artifacts and where they live
4. Session bridge concept (handoff prompts)
5. Orientation checklist (which command for which situation)
6. Quick-reference: "when to use which command"

**With workflow name (`/workflow-help <name>`):**
1. Everything above (condensed)
2. Current status table (from workflow-status logic)
3. Narrative "where you are" based on phase + handoff prompts
4. Actionable "what to do next" with specific commands
5. Key files to read right now
6. Recent activity summary

## Relationship Map

| Command | Purpose | Audience |
|---------|---------|----------|
| `/workflow-status` | Data: phase table, artifact counts | Task runner who knows the system |
| `/workflow-reground` | Context recovery: load phase-specific artifacts | Returning user who knows the system |
| `/workflow-help` | Education + direction: explain + guide | New user, lost user, context-switching user |

## Open Questions
- Should `/workflow-help <name>` internally invoke `/workflow-status` logic, or duplicate it?
- How much of the "no args" educational content belongs in a static section vs dynamically generated?
- Should the command detect if a user has never run a workflow and adjust messaging?
