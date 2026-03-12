# Handoff: spec → decompose

## What This Phase Produced
- Cross-cutting contracts at `docs/feature/serena-usage/00-cross-cutting-contracts.md`
- 4 implementation specs at `docs/feature/serena-usage/01-04-*.md`
- Spec index at `.workflows/serena-usage/specs/index.md`

## Spec Summary

| # | Spec | Scope | Key Deliverable |
|---|------|-------|----------------|
| 00 | Cross-Cutting Contracts | -- | Hook output format, MCP sequence, project.yml template, language map |
| 01 | serena-ensure Auto-Detection | M | `detect_languages()` + `ensure_project_yml()` functions in `bin/serena-ensure`, new stdout output |
| 02 | Serena Activate Skill | M | New `home/.claude/skills/serena-activate/SKILL.md` with onboarding + tool guidance |
| 03 | Session Hook Update | S | One-line change: `>/dev/null 2>&1` → `2>/dev/null` in `home/.claude/settings.json` |
| 04 | CLAUDE.md Section | S | ~5 lines appended to `home/.claude/CLAUDE.md` |

## Dependency Graph

```
00 (contracts)
├── 01 (serena-ensure) ──┐
└── 02 (skill) ──────────┼── 03 (hook update)
                         └── 04 (CLAUDE.md)
```

- 01 and 02 can be implemented in parallel (both depend only on 00)
- 03 depends on both 01 and 02 (hook outputs context that references the skill)
- 04 depends on 02 (references the skill by name)

## Total Estimated Scope
- 2 × M (3 pts each) + 2 × S (1 pt each) = **8 story points**

## Instructions for Decompose Phase

1. Read all specs from `docs/feature/serena-usage/`
2. Create two parallel work streams:
   - **Stream A**: Spec 01 (serena-ensure modifications)
   - **Stream B**: Spec 02 (skill creation)
3. After A and B complete, sequential:
   - Spec 03 (hook update — depends on both)
   - Spec 04 (CLAUDE.md — depends on 02)
4. Create beads issues for each spec, with dependencies matching the graph above
5. Final validation: start a fresh Claude Code session and verify the full flow (hook → activation context → skill invocation → Serena tools used → dashboard shows stats)

## Files to Read First
1. `docs/feature/serena-usage/00-cross-cutting-contracts.md` (shared agreements)
2. `docs/feature/serena-usage/01-serena-ensure-auto-detection.md` (largest spec)
3. `docs/feature/serena-usage/02-serena-activate-skill.md` (new file creation)
4. `docs/feature/serena-usage/03-session-hook-update.md` (one-line change)
5. `docs/feature/serena-usage/04-claude-md-section.md` (small append)
6. `.workflows/serena-usage/specs/index.md` (dependency ordering)
