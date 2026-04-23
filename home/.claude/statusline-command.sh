#!/bin/sh
# Claude Code status line: model name + context & rate limit progress bars
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
rate=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

if [ -z "$ctx" ]; then
    printf '%s' "$model"
    exit 0
fi

# Build a 20-char progress bar from a percentage
make_bar() {
    pct="$1"
    filled=$(echo "$pct" | awk '{printf "%.0f", $1 / 5}')
    bar=""
    i=0
    while [ "$i" -lt 20 ]; do
        if [ "$i" -lt "$filled" ]; then
            bar="${bar}█"
        else
            bar="${bar}░"
        fi
        i=$((i + 1))
    done
    printf '%s' "$bar"
}

ctx_int=$(printf '%.0f' "$ctx")
result=$(printf '%s  ctx [%s] %s%%' "$model" "$(make_bar "$ctx")" "$ctx_int")

if [ -n "$rate" ]; then
    rate_int=$(printf '%.0f' "$rate")
    result=$(printf '%s  5h [%s] %s%%' "$result" "$(make_bar "$rate")" "$rate_int")
fi

printf '%s' "$result"
