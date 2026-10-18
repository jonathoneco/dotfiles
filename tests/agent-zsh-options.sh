#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for marker in CLAUDECODE=1 CODEX_THREAD_ID=test; do
  env -u CLAUDECODE -u CODEX_THREAD_ID "$marker" ZDOTDIR="$repo/config/zsh" zsh -e <<'ZSH'
    [[ ! -o nomatch && ! -o equals && -o shwordsplit ]]
    printf "%s\n" /nonexistent/land-code-probe-*.missing
    printf "%s\n" =====
    words="one two"
    set -- $words
    [[ "$#" -eq 2 ]]
ZSH
done

env -u CLAUDECODE -u CODEX_THREAD_ID ZDOTDIR="$repo/config/zsh" zsh -i <<'ZSH'
  [[ -o nomatch && -o equals && ! -o shwordsplit ]]
ZSH
