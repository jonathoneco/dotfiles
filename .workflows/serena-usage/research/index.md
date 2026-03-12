# Research Index: Serena Usage

One-line summaries of research findings. Updated as research progresses.

| Topic | Summary | Status | Files |
|-------|---------|--------|-------|
| dashboard-no-stats | Empty stats = zero Serena tool calls; Claude Code has no instructions to use Serena tools (unlike Codex which has explicit activation rules) | complete | research/dashboard-no-stats.md |
| tools-value-analysis | Of ~35 Serena tools, only 7-9 add value over Claude Code builtins: find_symbol, find_referencing_symbols, get_symbols_overview, replace_symbol_body, rename_symbol, onboarding, memory | complete | research/serena-tools-value-analysis.md |
| activation-instructions | Three strategies: SessionStart hook context injection + CLAUDE.md instructions + Serena's own initial_instructions tool; activate_project disabled in claude-code context | complete | research/activation-instructions.md |
