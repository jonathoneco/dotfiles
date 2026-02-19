# /add-feature

Plan and implement a new feature with structured beads tracking.

## Usage

```
/add-feature <feature description>
```

## Workflow

1. **Search for context**: Check existing beads issues and closed issues for related work:
   ```
   Task(subagent_type="Explore", prompt="Search beads issues for context about <feature>.
   Run: bd list --status=open && bd list --status=closed | grep -i <keyword>
   Then bd show each relevant match.
   Return: related issues, relevant files, patterns, prior decisions.")
   ```

2. **Break down the feature**: Create tagged subtask issues with dependencies:
   - `[DB]` — Migrations, schema changes
   - `[Service]` — Business logic, service layer
   - `[API]` — Handler endpoints, routing
   - `[UX]` — Templates, HTMX interactions, Tailwind styling
   - `[Workflow]` — Multi-step processing pipelines

   Set dependencies so work flows correctly:
   ```
   bd dep add <service-id> <db-id>    # Service depends on DB
   bd dep add <api-id> <service-id>   # API depends on Service
   bd dep add <ux-id> <api-id>        # UX depends on API
   ```

3. **Implement sequentially**: Work through tasks via `bd ready`:
   - Claim the next unblocked task with `bd update <id> --status=in_progress`
   - Implement, following project conventions
   - Run `make test` after each piece
   - Close with `bd close <id> --reason="Implemented: <summary>"`
   - Repeat until all subtasks are done

4. **Verify end-to-end**: After all subtasks are closed, verify the feature works as a whole. Run `make test` and manually trace the data flow from handler to database and back.
