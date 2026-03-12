# Workflow Archive: Serena Usage

| Field | Value |
|-------|-------|
| Name | serena-usage |
| Created | 2026-03-12 |
| Archived | 2026-03-12 |
| Duration | 1 day |
| Epic | dotfiles-vku |

## Timeline
| Phase | Started | Completed | Sessions | Duration |
|-------|---------|-----------|----------|----------|
| Research | 2026-03-12 | 2026-03-12 | 1 | <1 day |
| Plan | 2026-03-12 | 2026-03-12 | 1 | <1 day |
| Spec | 2026-03-12 | 2026-03-12 | 1 | <1 day |
| Decompose | 2026-03-12 | 2026-03-12 | 1 | <1 day |
| Implement | 2026-03-12 | 2026-03-12 | 1 | <1 day |

## Key Decisions
- **Skill-based activation over CLAUDE.md-only**: Created `/serena-activate` skill for structured, re-invocable Serena initialization. Skills persist across context compaction and can be manually re-triggered.
- **Dual-mechanism activation**: SessionStart hook outputs context that triggers skill invocation + CLAUDE.md provides persistent behavioral guidance.
- **Tool exclusion via project.yml**: 8 redundant Serena tools excluded to reduce token overhead (list_dir, find_file, search_for_pattern, think_about_*, summarize_changes, get_current_config).
- **Language auto-detection in serena-ensure**: Shell heuristics detect project language from marker files (go.mod, package.json, etc.) and auto-generate `.serena/project.yml` if missing.
- **activate_project not needed**: Disabled in `claude-code` context (`single_project: true` auto-activates). Activation sequence is just `initial_instructions` + `check_onboarding_performed`.

## Dead Ends
No dead ends recorded — the root cause (missing activation instructions) was identified directly and the solution path was clear.

## Statistics
- Research notes: 3
- Spec documents: 5 (1 contracts + 4 implementation specs)
- Work items: 4 completed, 4 total
- Beads issues: 4 work items + 3 gates + 1 epic = 8 closed
- Streams: 3 (A: serena-ensure, B: skill, C: wiring)
- Phases: 5 completed, 0 skipped

## Documents Produced

| Document | Description |
|----------|-------------|
| `docs/feature/serena-usage/architecture.md` | System architecture: data flow, component map, phasing |
| `docs/feature/serena-usage/00-cross-cutting-contracts.md` | Hook output format, MCP sequence, project.yml template, language map |
| `docs/feature/serena-usage/01-serena-ensure-auto-detection.md` | Spec for detect_languages() and ensure_project_yml() |
| `docs/feature/serena-usage/02-serena-activate-skill.md` | Spec for /serena-activate skill with tool guidance |
| `docs/feature/serena-usage/03-session-hook-update.md` | Spec for removing stdout suppression from hook |
| `docs/feature/serena-usage/04-claude-md-section.md` | Spec for CLAUDE.md Serena section |
| `docs/feature/serena-usage/phase-1-foundation.md` | Phase 1 work items (parallel streams A+B) |
| `docs/feature/serena-usage/phase-2-wiring.md` | Phase 2 work items (stream C) |
| `docs/feature/serena-usage/phase-1/streams.md` | Concurrency map for Phase 1 |
| `docs/feature/serena-usage/phase-1/stream-a-serena-ensure.md` | Stream A execution doc |
| `docs/feature/serena-usage/phase-1/stream-b-skill.md` | Stream B execution doc |
| `docs/feature/serena-usage/phase-2/stream-c-wiring.md` | Stream C execution doc |

## Code Changes

| File | Change |
|------|--------|
| `bin/serena-ensure` | Added detect_languages(), ensure_project_yml(), structured activation output |
| `home/.claude/skills/serena-activate/SKILL.md` | New skill: Serena initialization with onboarding + tool guidance |
| `home/.claude/settings.json` | SessionStart hook: `>/dev/null 2>&1` → `2>/dev/null` |
| `home/.claude/CLAUDE.md` | Added 7-line Serena section with tool preferences |
