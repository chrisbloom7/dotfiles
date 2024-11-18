#!/usr/bin/env bash

# Check if the script is being sourced and if not, exit with an error message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo -e "\033[1;31mError:\033[0m This script must be sourced, not executed" >&2
  exit 1
fi

if [[ -n "$(command -v brew 2>/dev/null)" ]]; then
  log_debug "Homebrew installed at $(brew --prefix)"
  eval "$("$(brew --prefix)/bin/brew" shellenv)"
elif [[ -d ~/.linuxbrew ]]; then
  log_debug "Homebrew installed at ~/.linuxbrew"
  eval "$(~/.linuxbrew/bin/brew shellenv)"
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  log_debug "Homebrew installed at /home/linuxbrew/.linuxbrew"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d /opt/homebrew ]]; then
  log_debug "Homebrew installed at /opt/homebrew"
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -z ${SOURCE_HOMEBREW_SILENT:-} ]]; then
  log_error "Could not locate Homebrew installation location"
  exit 1
fi
