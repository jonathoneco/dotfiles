# Research: Dashboard "No Tool Usage Stats" Issue

## Key Findings

1. **Stats are per-session and in-memory only.** Serena does NOT persist tool usage stats across server restarts. Each time `serena-ensure` starts a new server, the stats counter resets to zero.

2. **"No tool usage stats collected yet" means zero Serena tools were called.** The message comes from `dashboard.js` — it renders when the stats dictionary is empty (`Object.keys(stats).length === 0`). This is not a config issue; it means Claude Code literally never called any Serena tool (e.g., `find_symbol`, `get_symbols_overview`, `search_for_pattern`) during that session.

3. **Stats recording is always on in current Serena versions.** The old `record_tool_usage_stats` config flag was removed. Stats are always collected when tools are called. The `token_count_estimator` is set to `CHAR_COUNT` (no external deps), which is correct.

4. **The real problem: Claude Code prefers its built-in tools over Serena.** Claude Code has `Read`, `Grep`, `Glob`, `Bash` as native tools. These are faster and more direct than Serena's LSP-backed semantic tools. Without explicit instructions to use Serena tools, Claude Code will default to its own tools for file reading, searching, and navigation — Serena never gets called.

## Current Integration Architecture

```
Claude Code session start
  → SessionStart hook: `serena-ensure "$PWD"`
    → Starts HTTP MCP server on port 9710+
    → Updates .mcp.json with endpoint
    → Serena tools become available to Claude Code
  → BUT: No instructions telling Claude Code to USE Serena tools
  → Result: Claude Code uses Read/Grep/Glob, Serena sits idle
```

### Scripts
- `bin/serena-ensure` — Starts server, manages port registry (`~/.serena/ports.conf`), PID files, health checks, updates `.mcp.json`
- `bin/serena-status` — Shows table of all servers (project, port, PID, health)
- `bin/serena-stop` — Stops one or all servers, optional `--clean` to remove from `.mcp.json`

### Config Files
- `.serena/project.yml` — Per-project config (language: lua, read-write enabled, all tools)
- `~/.serena/serena_config.yml` — Global config (dashboard enabled, CHAR_COUNT estimator)
- `.mcp.json` — MCP endpoint registration (streamable-http on localhost:PORT/mcp)
- `home/.claude/settings.json` — SessionStart hook that calls `serena-ensure`

### Codex Integration
- `home/.codex/config.toml` — Defines Serena MCP server with `--context codex`
- `home/.codex/rules/default.rules` — Explicitly activates Serena on session start (`serena.activate_project`, `serena.check_onboarding_performed`, `serena.initial_instructions`)
- **Note:** Codex rules actively instruct the agent to use Serena. Claude Code has no equivalent instructions.

## Root Cause Analysis

| Factor | Codex | Claude Code |
|--------|-------|-------------|
| Server starts automatically | Yes (config.toml) | Yes (SessionStart hook) |
| Agent told to activate Serena | Yes (default.rules) | **No** |
| Agent told to use Serena tools | Yes (initial_instructions) | **No** |
| Native file tools available | Limited | Read, Grep, Glob, Bash |

**The gap is clear**: Codex has explicit rules telling it to activate and use Serena. Claude Code has the server running but no instructions to prefer Serena's semantic tools over its own built-in alternatives.

## Serena Tools Available (When Used)

- `find_symbol` — LSP-backed symbol lookup across codebase
- `find_referencing_symbols` — Find all references to a symbol
- `get_symbols_overview` — Structural overview of a file/module
- `replace_symbol_body` — Semantic code editing (replace by symbol, not text match)
- `insert_after_symbol` — Insert code after a named symbol
- `read_file` / `search_for_pattern` — File operations (overlap with Claude Code native tools)
- `write_memory` / `read_memory` — Persistent cross-session context
- `onboarding` — Project orientation

## Implications for Design

- Need CLAUDE.md instructions or hooks that tell Claude Code when/how to use Serena tools
- Could follow the Codex pattern: session-start instructions that activate Serena and tell Claude to prefer semantic tools for navigation
- Must be selective — Serena's `read_file` adds no value over Claude's `Read`, but `find_symbol` and `find_referencing_symbols` are genuinely better for code navigation
- The `write_memory`/`read_memory` tools could complement the existing memory system

## Open Questions

1. Should CLAUDE.md instruct Claude Code to always activate Serena on session start (like Codex rules do)?
2. Which Serena tools provide genuine value over Claude Code's built-in tools? (Likely: `find_symbol`, `find_referencing_symbols`, `get_symbols_overview`, `write_memory`)
3. Should we add a SessionStart hook that calls `serena.activate_project` / `serena.initial_instructions` via the MCP connection?
4. Is the per-project `.serena/project.yml` correctly configured for each project? (Current dotfiles config only lists `lua` as language)
5. Should Serena be configured per-project with the correct language servers for each repo (Go, TypeScript, Python, etc.)?
