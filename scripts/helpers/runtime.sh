#!/usr/bin/env bash
set -o errexit  # Exit on error. Same as -e.
set -o nounset  # Error on unset variables. Same as -u.
set -o pipefail # Pipes return last non-zero status.

# Check if the script is being sourced and if not, exit with an error message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo -e "\033[1;31mError:\033[0m This script must be sourced, not executed" >&2
  exit 1
fi

# Enable debugging mode if the DEBUG environment variable is set
if [[ -n "${DEBUG:-}" ]]; then
  VERBOSE_MODE=true # Enable verbose mode
  set -o verbose    # Print shell input lines as they are read. Same as -v.
  set -o xtrace     # Print a trace of simple commands. Same as -x.
fi

# Load helpers script if it's not already loaded
if [[ -z "${HELPERS_LOADED:-}" ]]; then
  # Detect location of dotfiles directory
  if [[ -n "${CODESPACES:-}" ]]; then
    # Always use the persisted dotfiles directory in Codespaces
    export DOTFILES="${DOTFILES:-"/workspaces/.codespaces/.persistedshare/dotfiles"}"
  else
    # Complicated because this file is sourced from other files that may not be in this directory
    export DOTFILES="${DOTFILES:-"${PWD%/}/$(dirname "${BASH_SOURCE[0]}")/..}"
  fi

  # Add setup bin directory to PATH
  export PATH="${DOTFILES}/bin:${PATH}"

  # Options defaults
  export FORCE_MODE=${FORCE_MODE:-false}
  export NO_INSTALL_MODE=${NO_INSTALL_MODE:-false}
  export MINIMAL_MODE=${MINIMAL_MODE:-false}
  export QUIET_MODE=${QUIET_MODE:-false}
  export VERBOSE_MODE=${VERBOSE_MODE:-false}

  # Export mode functions for rest of setup
  is_force_mode() { [[ ${FORCE_MODE:-} == true ]]; }        ; export -f is_force_mode
  is_install_mode() { [[ ${NO_INSTALL_MODE:-} == false ]]; }; export -f is_install_mode
  is_minimal_mode() { [[ ${MINIMAL_MODE:-} == true ]]; }    ; export -f is_minimal_mode
  is_quiet_mode() { [[ "${QUIET_MODE:-}" == true ]]; }      ; export -f is_quiet_mode
  is_verbose_mode() { [[ "${VERBOSE_MODE:-}" == true ]]; }  ; export -f is_verbose_mode

  # Option validation functions (no export needed for these functions)
  _can_use_minimal_mode() { is_install_mode; }
  _can_use_quiet_mode() { ! is_verbose_mode; }
  _can_use_verbose_mode() { ! is_quiet_mode; }

  # Parse script options
  _parse_setup_options() {
    local USAGE=(
      "Usage: $0 [OPTIONS]"
      "Options:"
      " -h, --help        You're looking at it"
      " -f, --force       Replace regular files and directories with symlinks as necessary."
      "                   Files and directories will be renamed with a '.setup' extension."
      " -m, --minimal     Install bare minimum packages (ignored if --no-install is set)"
      " -n, --no-install  Skip installation steps, only run config and symlink steps"
      " -q, --quiet       Print fewer status messages (ignored if --verbose is set)"
      " -v, --verbose     Print additional status messages (ignored if --quiet is set)"
    )

    while [[ $# -gt 0 ]]; do
      case $1 in
        -h | --help      ) printf >&1 '%s\n' "${USAGE[@]}"
                           exit 0
                           ;;
        -f | --force     ) FORCE_MODE=true
                           ;;
        -m | --minimal   ) _can_use_minimal_mode && MINIMAL_MODE=true
                           ;;
        -n | --no-install) NO_INSTALL_MODE=true
                           MINIMAL_MODE=false
                           ;;
        -q | --quiet     ) _can_use_quiet_mode && QUIET_MODE=true
                           ;;
        -v | --verbose   ) _can_use_verbose_mode && VERBOSE_MODE=true
                           ;;
        *                ) if [[ "$1" =~ "^-[:alpha:][:alpha:]" ]]; then
                             args=""
                             for (( i=1; i<${#1}; i++ )); do
                               args="${args} -${1:$i:1}"
                             done
                             _parse_setup_options $args
                           else
                             log_error "Invalid option: $1"
                             printf >&1 '%s\n' "${USAGE[@]}"
                             exit 1
                           fi
                           ;;
      esac
      shift
    done

    log_debug "Options processed successfully"
  }
  _parse_setup_options "$@"

  # Mark helpers script as loaded
  log_debug "Helpers loaded"
  readonly HELPERS_LOADED=true
  export HELPERS_LOADED
else
  log_debug "Helpers script is already loaded; skipping"
fi

# Debugging output
log_debug "Parsed options:"
log_debug "  FORCE_MODE:      ${FORCE_MODE:?Not set!}"
log_debug "  MINIMAL_MODE:    ${MINIMAL_MODE:?Not set!}"
log_debug "  NO_INSTALL_MODE: ${NO_INSTALL_MODE:?Not set!}"
log_debug "  QUIET_MODE:      ${QUIET_MODE:?Not set!}"
log_debug "  VERBOSE_MODE:    ${VERBOSE_MODE:?Not set!}"
log_debug "  DOTFILES:        ${DOTFILES:?Not set!}"
