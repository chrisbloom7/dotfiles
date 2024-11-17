#!/usr/bin/env bash

# Check if the script is being sourced and if not, exit with an error message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo -e "\033[1;31mError:\033[0m This script must be sourced, not executed" >&2
  exit 1
fi

if [ -z "${ANSI_COLOR_CODES_SET:-}" ]; then
  # Output formatting constants
  readonly ANSI_RESET="\033[0m"          ; export ANSI_RESET
  readonly ANSI_BOLD_BLACK="\033[1;30m"  ; export ANSI_BOLD_BLACK
  readonly ANSI_BOLD_RED="\033[1;31m"    ; export ANSI_BOLD_RED
  readonly ANSI_BOLD_GREEN="\033[1;32m"  ; export ANSI_BOLD_GREEN
  readonly ANSI_BOLD_YELLOW="\033[1;33m" ; export ANSI_BOLD_YELLOW
  readonly ANSI_BOLD_BLUE="\033[1;34m"   ; export ANSI_BOLD_BLUE
  readonly ANSI_BOLD_MAGENTA="\033[1;35m"; export ANSI_BOLD_MAGENTA
  readonly ANSI_BOLD_CYAN="\033[1;36m"   ; export ANSI_BOLD_CYAN
  readonly ANSI_GRAY="\033[90m"          ; export ANSI_GRAY
  readonly ANSI_COLOR_CODES_SET=true     ; export ANSI_COLOR_CODES_SET
fi
