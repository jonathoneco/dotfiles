# Work Harness Detection

At session start, check for active tasks:

1. Look for `.work/*/state.json` files
2. For each, check if `archived_at` is null (meaning active)
3. If active tasks exist, display a brief notification:

```
Active task detected: <name> (Tier <N>)
Current step: <step> (status: <status>)
Run /work-status for details or /work-reground to recover context.
```

4. If `.work/` exists but only archived tasks:
```
No active tasks. Start a new one with /work <description>.
```

5. If no `.work/` directory exists, do nothing.

## Legacy Workflow Detection

Also check for `.workflows/*/state.json` files (legacy system):

1. If active legacy workflows exist (`archived_at` is null):
```
Legacy workflow detected: <name> (<title>)
The new /work commands replace /workflow-*. Complete or archive legacy workflows before using the new system.
Run /workflow-status <name> for details.
```

2. If `.workflows/` exists but only archived workflows, do nothing (archived workflows are historical records).
