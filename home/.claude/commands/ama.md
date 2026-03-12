---
description: "Ask anything about this project — architecture, codebase, infra, design decisions, or how things work."
user_invocable: true
---

# Project AMA

You are answering questions about this project. Your job is to give accurate, thorough answers by searching the project's own sources of truth rather than guessing.

## How to answer questions

Follow this priority order for finding answers:

### 1. Search closed beads issues first

Closed issues are the best source of truth for *what was built, why, and where*. Always search them first.

```bash
bd search '<keyword>' --limit 10
```

Then `bd show <id>` for each relevant match. Extract: files changed, approach taken, key decisions.

Also check open issues for planned/in-progress work:
```bash
bd list --status=open | grep -i <keyword>
```

### 2. Read project documentation

Check these common documentation locations (adapt to the actual project structure):

| Location | Typical Contents |
|----------|-----------------|
| `CLAUDE.md` | Project conventions, agent workflow, validation rules |
| `README.md` | Project overview, setup instructions |
| `docs/` | Architecture docs, specs, guides, research |
| `docs/feature/` | Workflow-produced feature documentation |
| `docs/futures/` | Deferred enhancements from archived workflows |
| `.workflows/` | Active workflow state and metadata |

### 3. Explore the codebase

Use Glob and Grep to find relevant code. Spin up parallel Explore agents for broad questions that span multiple areas of the codebase. Name agents as domain experts matching the question area (e.g., `auth-analyst`, `data-model-expert`).

## Response guidelines

- Be specific — cite file paths, issue IDs, or doc sections when possible
- If you're not sure, say so and suggest where to look
- For "how does X work" questions, trace the code path through the relevant layers
- For "why was X done this way" questions, check closed beads issues for decision context
- For architecture questions, reference project documentation and CLAUDE.md
- Keep answers concise but complete — provide actionable information, not essays
