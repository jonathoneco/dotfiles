# Workflow Detection

At session start, check for active workflows:

1. Look for `.workflows/*/state.json` files
2. For each, check if `archived_at` is null (meaning active)
3. If active workflows exist, display a brief notification:

```
Active workflow detected: <name> (<title>)
Current phase: <phase> (status: <status>)
Run /workflow-status for details or /workflow-reground to recover context.
```

4. If no active workflows but `.workflows/` directory exists with archived workflows, mention:
```
No active workflows. Archived workflows available in .workflows/archive/.
Start a new one with /workflow-start <name> [title].
```

5. If no `.workflows/` directory exists, do nothing — this rule only activates in workflow-enabled projects.
