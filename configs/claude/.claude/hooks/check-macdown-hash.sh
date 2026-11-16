#!/usr/bin/env bash
# PostToolUse hook (user scope): fail when a wrapped markdown line starts with `#<digit>`, which
# Macdown renders as a heading. Fix by re-wrapping so the number is mid-line, or escape it as `\#`.
# Ignores fenced code blocks and vendored paths. See ~/.claude/rules/writing-and-markdown.md.
file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.md && -f "$file" ]] || exit 0
case "$file" in */node_modules/* | */vendor/* | */.git/*) exit 0 ;; esac

hits=$(awk '/^[[:space:]]*(```|~~~)/ { fence = !fence; next } !fence && /^[[:space:]]*#[0-9]/ { printf "%d:%s\n", NR, $0 }' "$file")
if [[ -n "$hits" ]]; then
  {
    echo "Macdown heading hazard in $file: a line starts with #<number>. Re-wrap so the number is mid-line, or escape it as \\#."
    echo "$hits"
  } >&2
  exit 2
fi
