# Research: workflow-meta Design

## Key Findings

- **Purpose**: Transform the harness from static documentation into a self-aware, self-improving system
- **Core capability**: Automated harness introspection — inventory, health checks, gap detection, improvement suggestions
- **Bootstrapping validated**: This session (using /workflow-start to create a workflow about improving the workflow) proves the meta-iteration pattern works
- **Recommended approach**: Use full workflow system for non-trivial harness changes; lightweight mode for quick checks

## What Context a Meta Session Needs

1. **Harness inventory**: All 11 workflow commands, 3 skills, 10 agents with their file paths
2. **Interconnections**: How commands share state.json schema, handoff prompt chain, beads labeling conventions
3. **Active workflows**: Phase progress of all `.workflows/*/state.json` files
4. **Conventions**: YAML frontmatter requirements, phase ordering, artifact locations

## Proposed Modes

| Mode | Purpose | Output |
|------|---------|--------|
| (default) / `status` | Harness inventory + workflow health | Table of commands/skills/agents + active workflow summary |
| `validate` | Consistency checks | YAML frontmatter validation, handoff structure, beads labeling |
| `analyze <aspect>` | Deep dive into specific area | Detailed analysis of commands, workflows, skills, or dead-ends |

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Self-referential loops (meta fixing meta) | Read-only during analysis; suggest improvements, don't auto-apply |
| Breaking harness while editing | Validate changes via `./validate.sh`; add harness-specific checks |
| Stale/corrupted workflow state | Defensive analysis (skip malformed state files, report them) |
| Improvement suggestions get lost | Track via beads issues in a meta-workflow |

## Prior Art

- This session itself is the proof-of-concept: `/workflow-start workflow-harness-iteration` bootstrapped a structured approach to improving the harness
- The pattern works but requires manual priming (knowing to use /workflow-start for meta work)
- `/workflow-meta` would formalize and streamline this bootstrapping

## Implications for Design

- Should scan `home/.claude/commands/`, `home/.claude/skills/`, `home/.claude/agents/` in parallel
- Should read all `.workflows/*/state.json` for health assessment
- Should detect drift between command documentation and actual behavior
- For significant changes, should recommend `/workflow-start workflow-<improvement>` to track formally

## Open Questions
- Should workflow-meta own the concept of "harness validation" or should that be a separate check in validate.sh?
- How to handle the case where workflow-meta suggests changes to workflow-meta itself?
- Should it maintain a harness changelog or is git history sufficient?
