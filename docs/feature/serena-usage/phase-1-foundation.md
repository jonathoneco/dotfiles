# Phase 1: Foundation

| Field | Value |
|-------|-------|
| Prerequisites | -- |
| Streams | 2 parallel streams |
| Work items | W-01, W-02 |

## Work Items

### W-01: Add language auto-detection and project.yml generation to serena-ensure
- **Source**: 01-serena-ensure-auto-detection.md
- **Depends on**: --
- **Deliverable**: Modified `bin/serena-ensure` with `detect_languages()`, `ensure_project_yml()`, new stdout output
- **Estimated scope**: M

### W-02: Create serena-activate skill
- **Source**: 02-serena-activate-skill.md
- **Depends on**: --
- **Deliverable**: New `home/.claude/skills/serena-activate/SKILL.md`
- **Estimated scope**: M

## Phase Gate
- [ ] W-01 and W-02 completed
- [ ] `bin/serena-ensure` passes `shellcheck -x`
- [ ] `./validate.sh` passes
- [ ] `serena-ensure` outputs structured activation context (not bare URL)
- [ ] Skill file exists with correct YAML frontmatter
