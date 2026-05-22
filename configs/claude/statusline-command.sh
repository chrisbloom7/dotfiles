#!/usr/bin/env bash
# Claude Code status line — agnoster-inspired
# Receives JSON on stdin from Claude Code

input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Shorten $HOME to ~
home="$HOME"
cwd="${cwd/#$home/\~}"

# Git branch (skip lock-safe flag not needed for read-only)
branch=""
if git -C "${home}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Use the project_dir if available for git context
  project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
  if [ -n "$project_dir" ]; then
    branch=$(git -C "$project_dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$project_dir" rev-parse --short HEAD 2>/dev/null)
  fi
fi

# Context window remaining
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Build the line
# Format: user@host cwd [branch] | model | ctx: XX%
printf '\033[0;32m%s@%s\033[0m \033[0;34m%s\033[0m' "$user" "$host" "$cwd"

if [ -n "$branch" ]; then
  printf ' \033[0;33m(%s)\033[0m' "$branch"
fi

if [ -n "$model" ]; then
  printf ' | \033[0;36m%s\033[0m' "$model"
fi

if [ -n "$remaining" ]; then
  printf ' | ctx: \033[0;35m%.0f%%\033[0m' "$remaining"
fi

printf '\n'
