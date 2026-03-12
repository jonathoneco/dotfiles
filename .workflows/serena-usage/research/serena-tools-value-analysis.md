# Research: Serena Tools Value Analysis vs Claude Code Builtins

## Key Findings

Serena exposes ~35 tools total. In `claude-code` context, it auto-excludes 5 redundant ones (`create_text_file`, `read_file`, `execute_shell_command`, `prepare_for_new_conversation`, `replace_content`). Of the remaining, only 7-9 provide genuine value over Claude Code builtins.

## Tool Classification

### Genuinely Valuable (USE THESE)

| Serena Tool | Claude Code Equivalent | Why Serena is Better |
|---|---|---|
| `find_symbol` | Grep/Glob, LSP `workspaceSymbol` | Semantic symbol search with type filtering — finds classes/functions/methods, not just text matches |
| `find_referencing_symbols` | Grep, LSP `findReferences` | True "find usages" — distinguishes `process()` on ClassA vs ClassB |
| `find_referencing_code_snippets` | Grep with `-C` | Semantic references with code context, not just text matches |
| `get_symbols_overview` | Read file, LSP `documentSymbol` | File structure without reading entire contents — **major token savings** |
| `replace_symbol_body` | Edit | Replace entire function/class by name — no need to specify exact old text |
| `insert_after_symbol` / `insert_before_symbol` | Edit | Insert code relative to a symbol by name — no line number hunting |
| `rename_symbol` | Edit `replace_all` + Grep | **Unique**: Cross-file LSP rename refactoring — handles imports, qualified names |

### Unique but Overlapping

| Serena Tool | Overlap | Assessment |
|---|---|---|
| `onboarding` | Manual exploration | **Unique**: Auto-analyzes project structure, build/test commands, stores as memories. Useful for new projects. |
| `check_onboarding_performed` | N/A | **Unique**: Checks if onboarding memories exist |
| `write_memory` / `read_memory` / `list_memories` / `edit_memory` / `delete_memory` | CLAUDE.md + dotfiles memory system | **Unique mechanism** but overlaps with existing memory system. Stores in `.serena/memories/`, persists across sessions. |

### Redundant (SKIP THESE)

| Serena Tool | Claude Code Equivalent | Notes |
|---|---|---|
| `list_dir` | Glob, `ls` | No advantage |
| `find_file` | Glob | No advantage |
| `search_for_pattern` | Grep | Grep is equally capable |
| `replace_lines` / `insert_at_line` / `delete_lines` | Edit | Already hidden by `editing` mode |
| `think_about_*` (3 tools) | Extended thinking | Model reasoning handles this |
| `initial_instructions` | CLAUDE.md | Provides Serena's system prompt — useful for activation but not ongoing |
| `summarize_changes` | N/A | Just a prompt template, not a real tool |
| `get_current_config` / `switch_modes` / `restart_language_server` | N/A | Admin/debug only |

## Modes and Contexts

**Contexts** (set at startup, immutable):
- `claude-code`: Correct choice. Single-project, excludes redundant file/shell tools. Prompt tells agent to prioritize symbol tools.
- Other contexts: `desktop-app`, `ide`, `agent`, `codex`, `chatgpt`

**Modes** (composable, switchable at runtime):
- `editing` (default): Enables symbol-based editing, hides line-based editing
- `interactive` (default): Encourages back-and-forth with user
- `planning`: Read-only, hides all editing tools
- `one-shot`: Autonomous without interaction
- `no-onboarding` / `no-memories`: Disable respective features

Default active modes: `interactive` + `editing` — correct for Claude Code usage.

## Claude Code LSP Plugin Overlap

Claude Code has its own LSP support (`goToDefinition`, `findReferences`, `documentSymbol`, `hover`, `getDiagnostics`) via plugins. However:
- **No `workspaceSymbol`** — Serena's `find_symbol` fills this gap
- **No `rename`** — Serena's `rename_symbol` is unique
- Both `findReferences` and `documentSymbol` overlap with Serena equivalents

## Token Cost Tradeoff

Each exposed tool adds to the system prompt token count. With ~25+ tool descriptions from Serena, this is non-trivial. Excluding redundant tools in `project.yml` would reduce noise and cost.

## Recommendation

Configure `project.yml` to exclude redundant tools, keeping only the 7-9 that add genuine value. This maximizes signal-to-noise for the model while preserving Serena's unique LSP capabilities.

## Open Questions

1. Can `project.yml` `excluded_tools` selectively hide redundant tools that aren't already hidden by context?
2. Does the gopls-lsp Claude Code plugin make some Serena tools fully redundant for Go projects specifically?
3. What's the actual token overhead of Serena's tool descriptions in the context window?
