# Research: Effective Serena Activation Instructions for Claude Code

## Key Findings

### The Codex Pattern (Working Reference)

`home/.codex/rules/default.rules` contains a comment directive:
```
# Call serena.activate_project, serena.check_onboarding_performed and serena.initial_instructions
```
Codex interprets this as an instruction to call those three tools at session start. The sequence:
1. **`activate_project`** — Makes LSP aware of working directory (disabled in `claude-code` context because `single_project: true` auto-activates)
2. **`check_onboarding_performed`** — Checks for existing memories; if none, tells agent to run `onboarding`
3. **`initial_instructions`** — Returns the full Serena system prompt ("Instructions Manual") teaching the agent how to use all tools

### What Each Activation Tool Does

**`initial_instructions`** — THE KEY TOOL. Returns a rendered system prompt template containing:
- How to use symbolic tools
- How to use memories
- Context description (claude-code context prompt says "prioritize Serena tools, avoid reading entire files")
- Mode descriptions

**`check_onboarding_performed`** — Checks `memories_manager.list_project_memories()`:
- If 0 memories → tells agent to run `onboarding`
- If memories exist → says onboarding done, consider reading relevant ones
- Always appends: "If you have not read the 'Serena Instructions Manual', do so now"

**`activate_project`** — Disabled in `claude-code` context (auto-activated via `--project-from-cwd`). Not needed.

**`onboarding`** — Returns a prompt instructing the agent to explore the project and write memories. Only needs to run once per project.

### The Claude Code Gap

Current hook in `home/.claude/settings.json`:
```json
"SessionStart": [{"command": "serena-ensure \"$PWD\" >/dev/null 2>&1 || true"}]
```

Problems:
- Output suppressed (`>/dev/null 2>&1`) — Claude never sees activation instructions
- Even without suppression, `serena-ensure` only outputs the MCP URL, not usage instructions
- No CLAUDE.md instructions mention Serena
- Claude sees Read/Grep/Glob as familiar tools and defaults to them

### Claude Code Hook Capabilities

**SessionStart hooks** can inject context via:
- **Plain stdout** (exit 0): Text printed to stdout is added as context for Claude
- **JSON with `additionalContext`**: Structured context injection

This is the mechanism to use. The hook can output text that tells Claude to call Serena's activation tools.

### For `claude-code` Context Specifically

Since `activate_project` is disabled (auto-activated), the activation sequence simplifies to:
1. Call `mcp__serena__initial_instructions` — loads the Serena system prompt
2. Call `mcp__serena__check_onboarding_performed` — checks if project needs onboarding

## Recommended Implementation: Three Complementary Strategies

### Strategy A: SessionStart Hook Context Injection (Imperative Activation)

Add a second SessionStart hook (or modify existing) that outputs activation instructions to stdout:

```
Serena MCP tools are available for this project. At the start of this session:
1. Call `mcp__serena__initial_instructions` to read the Serena Instructions Manual
2. Call `mcp__serena__check_onboarding_performed` to check if project onboarding is needed
Prefer Serena's semantic tools (find_symbol, find_referencing_symbols, get_symbols_overview) over reading entire files.
```

**Pros**: Automatic, no per-project config needed
**Cons**: Only fires once at session start; lost after context compaction

### Strategy B: CLAUDE.md Instructions (Persistent Behavioral Guidance)

Add a Serena section to global `~/.claude/CLAUDE.md` or per-project CLAUDE.md:

```markdown
## Serena Integration

When Serena MCP tools are available (prefixed `mcp__serena__`):

- At session start, call `mcp__serena__initial_instructions` to load Serena's system prompt
- Call `mcp__serena__check_onboarding_performed` to check if project needs onboarding
- For code navigation, prefer Serena's semantic tools:
  - `find_symbol` — LSP symbol search (more precise than grep)
  - `find_referencing_symbols` — Find all references to a symbol
  - `get_symbols_overview` — File structure without reading contents
- For code editing, consider Serena's symbol-based tools:
  - `replace_symbol_body` — Replace entire function/class by name
  - `rename_symbol` — Cross-file LSP rename
```

**Pros**: Persistent across compaction, visible to subagents, versionable
**Cons**: Token cost in every session, may not trigger tool calls as reliably

### Strategy C: Both (Recommended)

- Hook for imperative activation ("call these tools now")
- CLAUDE.md for ongoing behavioral guidance ("prefer these tools when doing X")

This mirrors the Codex approach: rules activate tools, Serena's own system prompt (via `initial_instructions`) teaches the agent how to use them.

## Design Considerations

1. **`initial_instructions` is the gateway.** Once called, Serena's own system prompt takes over — CLAUDE.md just needs to trigger this one call.
2. **MCP tool names** in Claude Code follow `mcp__serena__<tool_name>` pattern.
3. **Per-project `project.yml`** must list correct languages for each repo. Current dotfiles config only lists `lua` — Go/TypeScript/Python projects need their languages configured or Serena's semantic tools won't work.
4. **Subagent awareness**: CLAUDE.md instructions are visible to subagents; hook context is not. Both strategies needed for full coverage.
5. **Token budget**: Serena's `initial_instructions` returns a substantial system prompt. Combined with CLAUDE.md instructions, this could be significant. May want to keep CLAUDE.md instructions minimal and let Serena's own prompt do the heavy lifting.

## Open Questions

1. Does calling `initial_instructions` at every session start waste tokens, or is the guidance necessary each time?
2. Should the hook check whether Serena tools are actually available before outputting instructions?
3. How to handle subagents — should they also call `initial_instructions`, or is CLAUDE.md guidance sufficient?
4. Per-project language configuration: should `serena-ensure` auto-detect project language and configure `project.yml`?
