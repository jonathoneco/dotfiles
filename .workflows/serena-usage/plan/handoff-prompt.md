# Handoff: plan → spec

## What This Phase Produced
- Architecture document at `docs/feature/serena-usage/architecture.md`
- 5-component design with clear phasing and dependency order

## Key Artifacts

| File | Purpose |
|------|---------|
| `docs/feature/serena-usage/architecture.md` | Full architecture with component map, data flow, phasing |
| `.workflows/serena-usage/research/activation-instructions.md` | Detailed activation strategy research |
| `.workflows/serena-usage/research/serena-tools-value-analysis.md` | Tool-by-tool comparison with Claude Code builtins |

## Component Map (becomes specs)

1. **C1: Serena Activate Skill** — New skill at `home/.claude/skills/serena-activate/SKILL.md` that calls `mcp__serena__initial_instructions` + `mcp__serena__check_onboarding_performed`, includes behavioral guidance for when to prefer Serena tools
2. **C2: SessionStart Hook Update** — Modify `home/.claude/settings.json` hooks + `bin/serena-ensure` to output activation context to stdout instead of suppressing it
3. **C3: CLAUDE.md Serena Section** — Minimal 3-line addition to `home/.claude/CLAUDE.md` referencing the skill
4. **C4: Language Auto-Detection** — Add language detection function to `bin/serena-ensure` (go.mod → go, package.json → typescript, etc.), create `.serena/project.yml` if missing
5. **C5: Project.yml Tool Exclusions** — Template with 8 redundant tools excluded (list_dir, find_file, search_for_pattern, think_about_*, summarize_changes, get_current_config)

## Tech Stack Decisions
- Activation via Claude Code skill (not CLAUDE.md-only) — persists across compaction, manually re-invocable
- Language detection via shell heuristics in `serena-ensure` — file-presence checks, no external deps
- Tool exclusion via `project.yml` `excluded_tools` — reduces token overhead
- Global scope — all projects via `~/.claude/` config

## Open Questions for Spec Phase
1. Should auto-generated `.serena/project.yml` be gitignored or committed per-project?
2. Multiple languages per project — list all detected or pick primary?
3. Serena version pinning — latest vs tagged release?
4. Skill auto-invocation reliability — how to tune the hook output prompt for reliable triggering?

## Instructions for Spec Phase

1. Read `docs/feature/serena-usage/architecture.md` first — it has the full component map, data flow, and phasing
2. Create cross-cutting contracts (`00-cross-cutting-contracts.md`) covering:
   - The hook output format (what `serena-ensure` prints to stdout)
   - The skill's MCP tool call sequence
   - The `project.yml` template structure
3. Write one numbered spec per component:
   - `01-serena-ensure-auto-detection.md` (C4 + C5 combined — both modify `serena-ensure`)
   - `02-serena-activate-skill.md` (C1)
   - `03-session-hook-update.md` (C2)
   - `04-claude-md-section.md` (C3)
4. Each spec must include:
   - Existing code context (current file contents, what changes)
   - Exact files to create or modify
   - Acceptance criteria (how to verify it works)
   - Shell validation commands where applicable
5. Dependency ordering: 01 → 02 → 03 → 04 (each builds on the previous)

## Files to Read First
1. `docs/feature/serena-usage/architecture.md` (architecture document)
2. `bin/serena-ensure` (primary file to modify for C2/C4/C5)
3. `home/.claude/skills/fix-issue/SKILL.md` (skill format reference)
4. `home/.claude/settings.json` (hooks config to modify for C2)
5. `home/.claude/CLAUDE.md` (to modify for C3)
