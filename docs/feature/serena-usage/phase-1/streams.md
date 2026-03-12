# Phase 1 Streams: Concurrency Map

## Dependency DAG
```
Phase 1:  [Stream A: serena-ensure]  ||  [Stream B: skill]
          (W-01, M)                      (W-02, M)
                    \                   /         |
                     \                 /          |
Phase 2:              [Stream C: wiring]
                      (W-03 + W-04, S+S)
```

## Stream Summary
| Stream | Title | Work Items | Depends On | Blocks | Scope |
|--------|-------|------------|------------|--------|-------|
| A | serena-ensure Auto-Detection | W-01 | -- | C | M |
| B | Serena Activate Skill | W-02 | -- | C | M |

## W-Item Coverage Matrix
| W-Item | Stream | Spec Source | Scope |
|--------|--------|-------------|-------|
| W-01 | A | 01-serena-ensure-auto-detection | M |
| W-02 | B | 02-serena-activate-skill | M |

## Integration Points
- IP-1: Stream A's stdout output format references `/serena-activate` from Stream B — both must agree on the skill name
- IP-2: Both streams depend on the contracts in `00-cross-cutting-contracts.md` (hook output format, project.yml template)

## Critical Path
Stream A or B (M) → Stream C (S) = **M + S total**

Both Phase 1 streams are the same scope, so neither dominates the critical path.
