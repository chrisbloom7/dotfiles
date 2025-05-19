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
    export DOTFILES="${DOTFILES:-${PWD%/}/$(dirname "${BASH_SOURCE[0]}")/../../}"
  fi

  # Add setup bin directory to PATH
  export PATH="${DOTFILES}/bin:${PATH}"

  # Options defaults
  export ADDITIONAL_DEPENDENCIES=${ADDITIONAL_DEPENDENCIES:-('common')}
  export BOOTSTRAP_MODE=${BOOTSTRAP_MODE:-false}
  export DRY_RUN_MODE=${DRY_RUN_MODE:-false} # TODO: Implement this
  export FORCE_MODE=${FORCE_MODE:-false}
  export MINIMAL_MODE=${MINIMAL_MODE:-false}
  export QUIET_MODE=${QUIET_MODE:-false}
  export UPDATE_MODE=${UPDATE_MODE:-false}
  export VERBOSE_MODE=${VERBOSE_MODE:-false}

  # Always enable verbose mode in Codespaces
  [[ -n "${CODESPACES:-}" ]] && VERBOSE_MODE=true

  # Export mode functions for rest of setup
  is_verbose_mode() { [[ "${VERBOSE_MODE:-}" == true ]]; }  ; export -f is_verbose_mode
  is_bootstrap_mode() { [[ ${BOOTSTRAP_MODE:-} == true ]]; }; export -f is_bootstrap_mode
  is_dry_run_mode() { [[ ${DRY_RUN_MODE:-} == true ]]; }    ; export -f is_dry_run_mode
  is_force_mode() { [[ ${FORCE_MODE:-} == true ]]; }        ; export -f is_force_mode
  is_minimal_mode() { [[ ${MINIMAL_MODE:-} == true ]]; }    ; export -f is_minimal_mode
  is_quiet_mode() { [[ "${QUIET_MODE:-}" == true ]]; }      ; export -f is_quiet_mode
  is_update_mode() { [[ "${UPDATE_MODE:-}" == true ]]; }    ; export -f is_update_mode
  is_verbose_mode() { [[ "${VERBOSE_MODE:-}" == true ]]; }  ; export -f is_verbose_mode

  # Option validation functions (no export needed for these functions)
  _can_use_minimal_mode() { ! is_bootstrap_mode; }
  _can_use_update_mode() { ! is_bootstrap_mode; }
  _can_use_quiet_mode() { ! is_verbose_mode; }

  # Parse script options
  _parse_setup_options() {
    local USAGE=(
      "Usage: $0 [OPTIONS]"
      "Options:"
      " -b, --bootstrap  Install only the prerequsites. Only applies to \`setup\`."
      " -d, --dry-run    [not currently implemented] Only print status messages; do not make any changes."
      " -f, --force      Replace regular files and directories with symlinks as necessary."
      "                  Existing files and directories will be renamed with a \`.presetup\` extension."
      " -h, --help       You're looking at it. Print this help message and exit."
      " -m, --minimal    Install bare minimum packages. Only applies to \`setup\`."
      "                  (ignored if --bootstrap is set)"
      " -n               Same as -d for compatibility with other scripts."
      " -p, --personal   Install additional dependencies for a personal workstation. Only applies to \`setup\`."
      "                  (ignored if --bootstrap or --minimal is set)"
      " -q, --quiet      Print fewer status messages. (ignored if --verbose is set)."
      " -u, --update     Update existing packages, but don't install anything. (ignored if --bootstrap is set)"
      "                  Combine with --force to also regenerate symlinks afterward."
      "                  Can also be used with --minimal to only update the bare minimum packages."
      " -v, --verbose    Print additional status messages."
      " -w, --work       Install additional dependencies for a business workstation. Only applies to \`setup\`."
      "                  (ignored if --bootstrap or --minimal is set)"
    )

    while [[ $# -gt 0 ]]; do
      case $1 in
        -h | --help             ) printf >&1 '%s\n' "${USAGE[@]}" && exit 0
                                  ;;
        -b | --bootstrap        ) BOOTSTRAP_MODE=true && MINIMAL_MODE=false
                                  ;;
        -f | --force            ) FORCE_MODE=true
                                  ;;
        -m | --minimal          ) _can_use_minimal_mode && MINIMAL_MODE=true
                                  ;;
        -d | -n | --dry-run     ) DRY_RUN_MODE=true
                                  ;;
        -p | --personal         ) ADDITIONAL_DEPENDENCIES+=('personal')
                                  ;;
        -q | --quiet            ) _can_use_quiet_mode && QUIET_MODE=true
                                  ;;
        -u | --update           ) _can_use_update_mode && UPDATE_MODE=true
                                  ;;
        -v | --verbose          ) QUIET_MODE=false && VERBOSE_MODE=true
                                  ;;
        -w | --work | --business) ADDITIONAL_DEPENDENCIES+=('work')
                                  ;;
        *                       ) if [[ "$1" =~ ^-[a-z]{2,} ]]; then
                                    # Handle multiple concatenated short options
                                    for (( i=1; i<${#1}; i++ )); do
                                      _parse_setup_options -${1:$i:1}
                                    done
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
log_debug "  ADDITIONAL_DEPENDENCIES: ${ADDITIONAL_DEPENDENCIES:?Not set!}"
log_debug "  BOOTSTRAP_MODE:          ${BOOTSTRAP_MODE:?Not set!}"
log_debug "  DRY_RUN_MODE:            ${DRY_RUN_MODE:?Not set!}"
log_debug "  FORCE_MODE:              ${FORCE_MODE:?Not set!}"
log_debug "  MINIMAL_MODE:            ${MINIMAL_MODE:?Not set!}"
log_debug "  QUIET_MODE:              ${QUIET_MODE:?Not set!}"
log_debug "  UPDATE_MODE:             ${UPDATE_MODE:?Not set!}"
log_debug "  VERBOSE_MODE:            ${VERBOSE_MODE:?Not set!}"
log_debug "  DOTFILES:                ${DOTFILES:?Not set!}"
