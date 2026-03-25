# Beans Issue Tracking

Before editing code, claim an issue with `bn update <id> --status in_progress`.
If no matching issue exists, create one first with `bn create`.

## Commands

```
bn ready                              # Unblocked work
bn list --status=open                 # All open issues
bn show <id>                          # Issue details
bn create --title="..." --type=task --priority=2
bn update <id> --status in_progress   # Claim
bn close <id> --reason="what was done"
bn search '<keyword>'                 # Search history
bn dep add <issue> <depends-on>       # Add dependency
```

## Reference

- **Priority**: 0=critical, 1=high, 2=medium, 3=low, 4=backlog
- **Types**: task, bug, feature, epic
- **Status**: open, in_progress, closed
