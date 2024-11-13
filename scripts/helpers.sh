#!/usr/bin/env bash
set -o nounset   # Error on unset variables. Same as -u.
set -o pipefail  # Pipes return last non-zero status.

if [[ -n "${DEBUG:-}" ]]; then
  set -o errtrace   # Functions and subcommands inherit ERR traps. Same as -E.
  set -o functrace  # Functions and subcommands inherit DEBUG and RETURN traps. Same as -T.
  set -o verbose    # Print shell input lines as they are read. Same as -v.
  set -o xtrace     # Print a trace of simple commands. Same as -x.
  VERBOSE_MODE=true # Enable verbose mode
fi

# Check if the script is being sourced and if not, exit with an error message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo -e "\033[1;31mError:\033[0m This script must be sourced, not executed" >&2
  exit 1
fi

if [[ -n "${HELPERS_LOADED:-}" ]]; then
  log_debug "Helpers script is already loaded"
  log_debug "FORCE_MODE: ${FORCE_MODE:?Not set!}"
  log_debug "MINIMAL_MODE: ${MINIMAL_MODE:?Not set!}"
  log_debug "VERBOSE_MODE: ${VERBOSE_MODE:?Not set!}"
  return 0
else
  readonly ANSI_RESET="\033[0m"          ; export ANSI_RESET
  readonly ANSI_BOLD_BLACK="\033[1;30m"  ; export ANSI_BOLD_BLACK
  readonly ANSI_BOLD_RED="\033[1;31m"    ; export ANSI_BOLD_RED
  readonly ANSI_BOLD_GREEN="\033[1;32m"  ; export ANSI_BOLD_GREEN
  readonly ANSI_BOLD_YELLOW="\033[1;33m" ; export ANSI_BOLD_YELLOW
  readonly ANSI_BOLD_BLUE="\033[1;34m"   ; export ANSI_BOLD_BLUE
  readonly ANSI_BOLD_MAGENTA="\033[1;35m"; export ANSI_BOLD_MAGENTA
  readonly ANSI_BOLD_CYAN="\033[1;36m"   ; export ANSI_BOLD_CYAN
  readonly ANSI_GRAY="\033[90m"          ; export ANSI_GRAY

  log_attention() {
    echo -e "${ANSI_BOLD_YELLOW}Attention:${ANSI_RESET} $@"
  }
  export -f log_attention

  log_debug() {
    [[ "${VERBOSE_MODE:-}" == true ]] && echo -e "${ANSI_GRAY}$@${ANSI_RESET}"
  }
  export -f log_debug

  log_error() {
    echo -e "${ANSI_BOLD_RED}Error:${ANSI_RESET} $@" >&2
  }
  export -f log_error

  log_info() {
    echo -e "${ANSI_BOLD_BLUE}Info:${ANSI_RESET} $@"
  }
  export -f log_info

  log_success() {
    echo -e "${ANSI_BOLD_GREEN}Success:${ANSI_RESET} $@"
  }
  export -f log_success

  # Default options
  export FORCE_MODE=${FORCE_MODE:-false}
  export MINIMAL_MODE=${MINIMAL_MODE:-false}
  export VERBOSE_MODE=${VERBOSE_MODE:-false}

  parse_setup_options() {
    local USAGE=(
      "Usage: $0 [OPTIONS]"
      "Options:"
      " -h, --help     You're looking at it"
      " -f, --force    Force overwriting of files"
      " -m, --minimal  Perform minimal setup (for already provisioned systems)"
      " -v, --verbose  Print additional log_debug messages"
    )

    while [[ $# -gt 0 ]]; do
      case $1 in
        -h | --help   ) printf >&1 '%s\n' "${USAGE[@]}" && exit 0;;
        -f | --force  ) FORCE_MODE=true;;
        -m | --minimal) MINIMAL_MODE=true;;
        -v | --verbose) VERBOSE_MODE=true;;
        *             ) log_error "Invalid option: $1"
                        printf >&1 '%s\n' "${USAGE[@]}"
                        exit 1;;
      esac
      shift
    done

    log_debug "Options processed successfully"
  }

  log_debug "Helpers loaded"
  readonly HELPERS_LOADED=true
  export HELPERS_LOADED

  # Main script execution
  parse_setup_options "$@"
  log_debug "FORCE_MODE: $FORCE_MODE"
  log_debug "MINIMAL_MODE: $MINIMAL_MODE"
  log_debug "VERBOSE_MODE: $VERBOSE_MODE"
  log_debug "HELPERS_LOADED: $HELPERS_LOADED"
fi
