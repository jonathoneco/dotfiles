# 01: serena-ensure Auto-Detection

| Field | Value |
|-------|-------|
| Source | architecture.md, C4 + C5 |
| Depends on | 00-cross-cutting-contracts |
| Blocks | 02-serena-activate-skill, 03-session-hook-update |
| Estimated scope | M |

## Overview

Add language auto-detection and `project.yml` generation to `bin/serena-ensure`. When a project has no `.serena/project.yml`, the script detects languages from marker files and writes a config with redundant tools excluded. Also change the final stdout output from a bare URL to the structured activation context defined in the contracts.

## Existing Code Context

- `bin/serena-ensure` — 120-line bash script. Manages port registry, health checks, server startup, `.mcp.json` updates. Currently outputs `http://localhost:PORT/mcp` as its only stdout line.
- The script already resolves `PROJECT_DIR` from `$1` or `$PWD` and ensures `$SERENA_DIR` directories exist.
- The script uses `set -euo pipefail` and requires `jq`, `curl`, `uvx`.

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `bin/serena-ensure` | Modify | Add `detect_languages()` function, `ensure_project_yml()` function, change final output |

## Implementation Steps

### 1. Add `detect_languages()` function

Insert after the `SERENA_PATH` variable block (~line 14), before `PROJECT_DIR` resolution:

```bash
detect_languages() {
    local dir="$1"
    local langs=""

    [ -f "$dir/go.mod" ] && langs="${langs:+$langs, }go"
    [ -f "$dir/package.json" ] && langs="${langs:+$langs, }typescript"
    [ -f "$dir/pyproject.toml" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/requirements.txt" ] && langs="${langs:+$langs, }python"
    [ -f "$dir/Cargo.toml" ] && langs="${langs:+$langs, }rust"

    if ls "$dir"/*.lua 1>/dev/null 2>&1 || [ -d "$dir/lua" ]; then
        langs="${langs:+$langs, }lua"
    fi

    echo "$langs"
}
```

### 2. Add `ensure_project_yml()` function

Insert after `detect_languages()`:

```bash
ensure_project_yml() {
    local dir="$1"
    local yml="$dir/.serena/project.yml"

    # Never overwrite existing config
    [ -f "$yml" ] && return 0

    local project_name
    project_name="$(basename "$dir")"

    local detected
    detected="$(detect_languages "$dir")"

    mkdir -p "$dir/.serena"

    # Build YAML languages array
    local lang_lines=""
    if [ -n "$detected" ]; then
        # Split comma-separated into YAML list items
        lang_lines="$(echo "$detected" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | sed 's/^/  - /')"
    fi

    cat > "$yml" << YAML
project_name: "$project_name"
languages:
${lang_lines:-"  []"}
encoding: utf-8
use_gitignore: true
read_only: false
excluded_tools:
  - list_dir
  - find_file
  - search_for_pattern
  - think_about_collected_information
  - think_about_task_adherence
  - think_about_whether_you_are_done
  - summarize_changes
  - get_current_config
YAML
}
```

### 3. Call `ensure_project_yml()` before server start

Insert after `PROJECT_DIR` is resolved (~line 17) and before port assignment:

```bash
ensure_project_yml "$PROJECT_DIR"
```

### 4. Change final stdout output

Replace the last line (`echo "http://localhost:${PORT}/mcp"`) with:

```bash
# Extract project name and languages for activation context
PROJECT_NAME="$(basename "$PROJECT_DIR")"
DETECTED_LANGS="$(detect_languages "$PROJECT_DIR")"

echo "Serena MCP server active for ${PROJECT_NAME} (languages: ${DETECTED_LANGS:-none})."
echo "Run /serena-activate to initialize semantic code navigation tools."
```

## Testing Strategy

```bash
# Shellcheck validation
shellcheck -x bin/serena-ensure

# Test language detection (create temp dirs with marker files)
tmpdir=$(mktemp -d)
touch "$tmpdir/go.mod"
touch "$tmpdir/package.json"
# Run serena-ensure against tmpdir and verify:
# 1. .serena/project.yml created with languages: [go, typescript]
# 2. excluded_tools list present
# 3. stdout contains activation context, not bare URL

# Test existing config preservation
mkdir -p "$tmpdir/.serena"
echo "project_name: custom" > "$tmpdir/.serena/project.yml"
# Run serena-ensure — verify project.yml unchanged
```

## Acceptance Criteria

- [ ] `detect_languages()` correctly identifies go, typescript, python, rust, lua from marker files
- [ ] `ensure_project_yml()` creates `.serena/project.yml` with correct template when missing
- [ ] Existing `.serena/project.yml` files are never overwritten
- [ ] `excluded_tools` list matches the 8 tools from cross-cutting contracts
- [ ] Multiple detected languages are listed as separate YAML array items
- [ ] Final stdout output matches the hook output format from contracts
- [ ] Script passes `shellcheck -x`
- [ ] Script still works for projects with no detectable language (empty languages array)
