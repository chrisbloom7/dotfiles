#!/usr/bin/env bash
source $(dirname "${BASH_SOURCE[0]}")/helpers.sh

# Check if the script is being sourced and if not, exit with an error message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  log_error "This script must be sourced, not executed"
  exit 1
fi

# Ask for the administrator password upfront if it's not already cached
if ! sudo -n true 2>/dev/null; then
  log_attention "Enter your administrative password to install dependencies:"
  sudo -v || exit 1
fi

# Keep-alive: update existing `sudo` time stamp until script has finished
# Runs in the background and dies when the script is done
while true; do
  sudo -n true
  log_debug "Sleeping for 60..."
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &
