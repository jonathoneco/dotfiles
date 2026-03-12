# Serena Usage — Architecture

| Field | Value |
|-------|-------|
| Status | Draft |
| Workflow | serena-usage |
| Created | 2026-03-12 |

## Overview

Make Claude Code effectively use Serena's LSP-backed semantic tools instead of defaulting to its built-in Read/Grep/Glob. The dashboards currently show "No tool usage stats collected yet" because nothing tells Claude to call Serena tools. This architecture introduces a skill-based activation mechanism, auto-detection of project languages, and exclusion of redundant Serena tools.

## System Context

Serena already runs as an HTTP MCP server, started by the `SessionStart` hook via `serena-ensure`. The server is healthy and accessible — the gap is purely instructional. This change touches the dotfiles repo only (global Claude Code config, scripts, project templates).

### Current Flow (Broken)
```
SessionStart hook → serena-ensure → server starts → >/dev/null → Claude ignores Serena
```

### Target Flow
```
SessionStart hook → serena-ensure → server starts
                  → hook outputs activation context
                  → Claude calls /serena-activate skill
                  → skill calls mcp__serena__initial_instructions
                  → skill calls mcp__serena__check_onboarding_performed
                  → Serena's system prompt teaches Claude which tools to use
                  → Claude prefers semantic tools for code navigation
```

## Tech Stack Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Activation mechanism | Claude Code skill + hook context injection | Skills persist across compaction, are manually re-invocable, and follow existing patterns (`fix-issue`, `review`, `add-feature`) |
| Language detection | Shell heuristics in `serena-ensure` | Simple file-presence checks (go.mod → Go, package.json → TypeScript, etc.) — no external deps |
| Tool exclusion | Per-project `project.yml` `excluded_tools` | Reduces token overhead from redundant tool descriptions |
| Scope | Global (`~/.claude/`) | All projects benefit; per-project `project.yml` handles language-specific config |

### Rejected Approaches
- **CLAUDE.md-only approach**: Instructions get buried in long CLAUDE.md files and don't trigger reliable tool calls. A skill provides structured, actionable steps.
- **Hook-only approach**: Hook context is lost after context compaction. Need the skill for re-activation.
- **Codex-style comment directives**: Claude Code doesn't support comment-based activation rules. Skills are the equivalent mechanism.

## Component Map

### C1: Serena Activate Skill
**File**: `home/.claude/skills/serena-activate/SKILL.md`

A new Claude Code skill that handles Serena initialization. Invocable as `/serena-activate`. Steps:
1. Call `mcp__serena__check_onboarding_performed` — determine if project needs onboarding
2. If onboarding needed, call `mcp__serena__onboarding`
3. Call `mcp__serena__initial_instructions` — load Serena's system prompt
4. Report activation status

Also includes ongoing behavioral guidance: when to prefer `find_symbol` over Grep, when to use `get_symbols_overview` instead of reading files, when `rename_symbol` is the right choice over Edit `replace_all`.

### C2: SessionStart Hook Update
**File**: `home/.claude/settings.json` (hooks section)

Modify the existing SessionStart hook to output activation context to stdout instead of suppressing it. The output tells Claude that Serena is available and instructs it to run `/serena-activate`.

Two options:
- **Option A**: Modify `serena-ensure` to output activation text on success (keeps hooks config simple)
- **Option B**: Add a second SessionStart hook that checks for Serena availability and outputs context (separation of concerns)

**Recommended: Option A** — `serena-ensure` already knows whether the server started successfully. Remove the `>/dev/null 2>&1` suppression and have it output structured activation context on success.

### C3: CLAUDE.md Serena Section
**File**: `home/.claude/CLAUDE.md`

Minimal persistent reference — not a full instruction set. Points to the skill for details:

```markdown
## Serena

Serena MCP tools provide LSP-backed semantic code navigation. When available:
- Run `/serena-activate` at session start (auto-triggered by hook)
- Prefer `find_symbol`, `find_referencing_symbols`, `get_symbols_overview` over reading entire files
- Use `rename_symbol` for cross-file renames (no Claude Code equivalent)
```

### C4: Language Auto-Detection in `serena-ensure`
**File**: `bin/serena-ensure`

Add a function that detects project language(s) from file presence and creates `.serena/project.yml` if missing:

| Marker File | Language |
|-------------|----------|
| `go.mod` | go |
| `package.json` | typescript (or javascript) |
| `pyproject.toml` / `setup.py` / `requirements.txt` | python |
| `Cargo.toml` | rust |
| `*.lua` in root or `lua/` dir | lua |
| `Makefile` only | (no language server) |

If `.serena/project.yml` already exists, skip detection — user config takes precedence.

### C5: Project.yml Tool Exclusions
**File**: `.serena/project.yml` (template applied by C4)

Exclude redundant tools that duplicate Claude Code builtins:

```yaml
excluded_tools:
  - list_dir           # Glob/ls covers this
  - find_file          # Glob covers this
  - search_for_pattern # Grep covers this
  - think_about_collected_information  # Model reasoning
  - think_about_task_adherence         # Model reasoning
  - think_about_whether_you_are_done   # Model reasoning
  - summarize_changes  # Just a prompt template
  - get_current_config # Admin/debug only
```

Keep all symbol navigation, symbol editing, memory, and onboarding tools.

## Data Flow

```
User starts Claude Code session in ~/src/myproject/
  │
  ├─ SessionStart hook fires
  │   └─ serena-ensure ~/src/myproject/
  │       ├─ Check port registry → find/assign port
  │       ├─ If no .serena/project.yml:
  │       │   ├─ Detect language (go.mod → go)
  │       │   └─ Write .serena/project.yml with excluded_tools
  │       ├─ Start/verify server health
  │       ├─ Update .mcp.json
  │       └─ Output to stdout:
  │           "Serena MCP server active at localhost:PORT.
  │            Run /serena-activate to initialize Serena tools."
  │
  ├─ Claude reads hook output as context
  │   └─ Invokes /serena-activate skill
  │       ├─ Call mcp__serena__check_onboarding_performed
  │       │   └─ If no memories → call mcp__serena__onboarding
  │       ├─ Call mcp__serena__initial_instructions
  │       │   └─ Serena system prompt loaded into context
  │       └─ Report: "Serena activated. Using semantic tools for code navigation."
  │
  └─ During session:
      ├─ Code navigation → find_symbol, find_referencing_symbols, get_symbols_overview
      ├─ Code editing → replace_symbol_body, rename_symbol (when appropriate)
      └─ Dashboard shows tool usage stats ✓
```

## Phasing Summary

| Phase | Components | Dependencies |
|-------|-----------|--------------|
| 1. Foundation | C5 (project.yml template), C4 (auto-detection) | None — `serena-ensure` changes are self-contained |
| 2. Activation | C1 (skill), C2 (hook update) | C4 must be done so the skill activates against properly configured projects |
| 3. Documentation | C3 (CLAUDE.md section) | C1 must exist so the reference is valid |

C4 and C5 can be implemented together (both modify `serena-ensure`). C1 and C2 can be implemented together (skill + hook that triggers it). C3 is a single edit after the skill exists.

## Open Questions

1. **Should `.serena/project.yml` be gitignored or committed?** Auto-generated files in project repos may surprise collaborators. Could `.serena/` be in `.gitignore` by default?
2. **Multiple languages per project**: Some projects use Go + TypeScript. Should auto-detection list all detected languages?
3. **Serena version pinning**: Currently using `git+https://github.com/oraios/serena` (latest). Should we pin to a release tag for stability?
4. **Skill auto-invocation reliability**: Will Claude reliably invoke `/serena-activate` from hook context? May need testing to tune the activation prompt.
