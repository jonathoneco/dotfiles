# Stream A: serena-ensure Auto-Detection

| Field | Value |
|-------|-------|
| Work items | W-01 |
| Prerequisites | -- |
| Estimated scope | M |
| Depends on | -- |
| Blocks | Stream C |

## Existing Code Context
Read these files before starting:
- `bin/serena-ensure` — 120-line bash script managing Serena HTTP MCP servers. Add new functions before the port assignment section.
- `docs/feature/serena-usage/00-cross-cutting-contracts.md` — Defines the project.yml template, language detection map, and hook output format.
- `docs/feature/serena-usage/01-serena-ensure-auto-detection.md` — Full spec with implementation steps.

## Internal Work Item Ordering

### Step 1: W-01 — Add language auto-detection and project.yml generation

1. **Add `detect_languages()` function** after the `SERENA_PATH` variable block (~line 14):
   - Check for marker files: `go.mod`→go, `package.json`→typescript, `pyproject.toml`/`setup.py`/`requirements.txt`→python, `Cargo.toml`→rust, `*.lua` or `lua/` dir→lua
   - Return comma-separated language list

2. **Add `ensure_project_yml()` function** after `detect_languages()`:
   - Skip if `.serena/project.yml` already exists (never overwrite)
   - Create `.serena/` directory
   - Write YAML with: project_name (basename of dir), detected languages, encoding utf-8, use_gitignore true, read_only false, excluded_tools list (8 tools from contracts)

3. **Call `ensure_project_yml "$PROJECT_DIR"`** after `PROJECT_DIR` is resolved, before port assignment

4. **Replace final stdout output** — change `echo "http://localhost:${PORT}/mcp"` to:
   ```bash
   PROJECT_NAME="$(basename "$PROJECT_DIR")"
   DETECTED_LANGS="$(detect_languages "$PROJECT_DIR")"
   echo "Serena MCP server active for ${PROJECT_NAME} (languages: ${DETECTED_LANGS:-none})."
   echo "Run /serena-activate to initialize semantic code navigation tools."
   ```

- [ ] Acceptance: `detect_languages()` returns correct languages for test directories
- [ ] Acceptance: `.serena/project.yml` created with correct template when missing
- [ ] Acceptance: Existing `.serena/project.yml` preserved (not overwritten)
- [ ] Acceptance: stdout output matches contracts hook output format
- [ ] Acceptance: `shellcheck -x bin/serena-ensure` passes

## Key Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|
| `bin/serena-ensure` | Modify | Add detect_languages(), ensure_project_yml(), change stdout |

## Interface Contracts

### Exposes
- Structured stdout output: activation context consumed by SessionStart hook (Stream C)
- Auto-generated `.serena/project.yml` with excluded_tools

### Consumes
- Project.yml template from `00-cross-cutting-contracts.md`
- Language detection map from `00-cross-cutting-contracts.md`

## Risk Notes
- The `ls "$dir"/*.lua` glob may fail with `set -euo pipefail` if no lua files exist — must be guarded with `2>/dev/null` or a subshell
- Python detection has three markers (`pyproject.toml`, `setup.py`, `requirements.txt`) — use OR logic carefully in bash

## Merge Gate Checklist

### Build verification
- [ ] `shellcheck -x bin/serena-ensure` passes
- [ ] `./validate.sh` passes

### Runtime verification
- [ ] Running `serena-ensure /path/to/go-project` creates `.serena/project.yml` with `go` in languages
- [ ] Running `serena-ensure /path/to/existing-serena-config` does NOT overwrite `project.yml`
- [ ] stdout output contains "Serena MCP server active" and "Run /serena-activate"

### Issue closure
- [ ] W-01 beads issue closed

### Artifacts produced
- [ ] Modified `bin/serena-ensure` with two new functions and updated output

## Implementation Prompt
> You are implementing Stream A (serena-ensure Auto-Detection) of the serena-usage workflow.
>
> **Read first**: `docs/feature/serena-usage/00-cross-cutting-contracts.md`, `docs/feature/serena-usage/01-serena-ensure-auto-detection.md`, `bin/serena-ensure`
> **Execute**: Add detect_languages() and ensure_project_yml() functions, call ensure_project_yml before port assignment, replace final echo with activation context output
> **Verify**: `shellcheck -x bin/serena-ensure` && `./validate.sh`
> **Beads**: `bd update <issue-id> --status=in_progress` before starting, `bd close <issue-id>` when done
