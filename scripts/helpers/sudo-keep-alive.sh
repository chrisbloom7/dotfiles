#!/usr/bin/env bash

# Check if the script is being sourced and if not, exit with an error message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo -e "\033[1;31mError:\033[0m This script must be sourced, not executed" >&2
  exit 1
fi

prompt_password() {
  log_attention "Enter your administrative password to install dependencies:"

  sudo -v

  # Keep-alive: update existing `sudo` time stamp until script has finished
  # Runs in the background and dies when the script is done
  log_debug "Starting keep-alive loop"
  while true; do sudo -n true; sleep 30; kill -0 "$$" || exit; done 2>/dev/null &
}

# Ask for the administrator password upfront if it's not already cached
if ! sudo -n true 2>/dev/null; then
  prompt_password
fi
