# Handoff: research → plan

## What This Phase Produced
- Root cause analysis: empty dashboards = zero tool calls, not a config bug
- Tool value classification: 7-9 tools worth using, rest redundant
- Activation strategy: dual-mechanism approach (hook + CLAUDE.md)

## Key Artifacts

| File | Purpose |
|------|---------|
| `.workflows/serena-usage/research/dashboard-no-stats.md` | Root cause: no instructions → no tool calls |
| `.workflows/serena-usage/research/serena-tools-value-analysis.md` | Which tools to use and which to skip |
| `.workflows/serena-usage/research/activation-instructions.md` | How to activate Serena in Claude Code |
| `.workflows/serena-usage/research/index.md` | Summary index of all research |

## Decisions Made
- `activate_project` is not needed for Claude Code (`single_project: true` auto-activates) — activation sequence is just `initial_instructions` + `check_onboarding_performed`
- Dual-mechanism approach: SessionStart hook for imperative activation + CLAUDE.md for persistent behavioral guidance
- Redundant tools should be excluded from `project.yml` to reduce token noise

## Open Questions Carried Forward
- Exact `project.yml` `excluded_tools` list for each project type
- Per-project language server configuration strategy (auto-detect vs manual)
- Subagent Serena access pattern
- Token budget analysis of Serena system prompt

## Instructions for Next Phase (plan)

The planning phase should produce a concrete implementation plan for making Claude Code effectively use Serena's valuable tools. Read the research artifacts first, then design:

1. **SessionStart hook modification**: Either modify `serena-ensure` to output activation instructions to stdout, or add a second hook script. Must output text telling Claude to call `mcp__serena__initial_instructions` and `mcp__serena__check_onboarding_performed`.

2. **CLAUDE.md Serena section**: Draft the exact text to add to global `~/.claude/CLAUDE.md` (via `home/.claude/CLAUDE.md` in the dotfiles repo). Should cover when to prefer Serena tools and which specific tools to use for code navigation vs editing.

3. **`project.yml` template**: Define a base configuration with `excluded_tools` for redundant tools, and per-language variants (Go, TypeScript, Python, Lua).

4. **`serena-ensure` updates**: Any changes needed to the startup script (e.g., auto-detecting project language, configuring `project.yml` if missing).

5. **Validation plan**: How to verify Serena tools are actually being called after changes (check dashboard stats, review tool call logs).

## Files to Read First
1. `.workflows/serena-usage/research/activation-instructions.md`
2. `.workflows/serena-usage/research/serena-tools-value-analysis.md`
3. `.workflows/serena-usage/research/dashboard-no-stats.md`
4. `home/.claude/CLAUDE.md` (current global Claude Code instructions)
5. `home/.codex/rules/default.rules` (working Codex activation reference)
6. `bin/serena-ensure` (current hook script)
