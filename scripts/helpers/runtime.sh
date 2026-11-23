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

# https://gist.github.com/TekWizely/c0259f25e18f2368c4a577495cd566cd
# Serializes a bash array to a string, with a configurable seperator.
#
# $1 = source varname ( contains array to be serialized )
# $2 = target varname ( will contian the serialized string )
# $3 = seperator ( optional, defaults to $'\x01' )
#
# example:
#
#    my_arry=( one "two three" four )
#    serialize_array my_array my_string '|'
#    declare -p my_string
#
# result:
#
#    declare -- my_string="one|two three|four"
#
function serialize_array() {
	declare -n _array="${1}" _str="${2}" # _array, _str => local reference vars
	local IFS="${3:-$'\x01'}"
	# shellcheck disable=SC2034 # Reference vars assumed used by caller
	_str="${_array[*]}" # * => join on IFS
}

# https://gist.github.com/TekWizely/c0259f25e18f2368c4a577495cd566cd
# Deserializes a string into a bash array, with a configurable seperator.
#
# $1 = source varname ( contains string to be deserialized )
# $2 = target varname ( will contain the deserialized array )
# $3 = seperator ( optional, defaults to $'\x01' )
#
# example:
#
#    my_string="one|two three|four"
#    deserialize_array my_string my_array '|'
#    declare -p my_array
#
# result:
#
#    declare -a my_array=([0]="one" [1]="two three" [2]="four")
#
function deserialize_array() {
	IFS="${3:-$'\x01'}" read -r -a "${2}" <<<"${!1}" # -a => split on IFS
}

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
  export ADDITIONAL_DEPENDENCIES_SERIALIZED=${ADDITIONAL_DEPENDENCIES_SERIALIZED:-"common|common.vscode"}
  export BOOTSTRAP_MODE=${BOOTSTRAP_MODE:-false}
  # Dry run mode is not implemented yet; see TODO.md
  export DRY_RUN_MODE=${DRY_RUN_MODE:-false}
  export FORCE_MODE=${FORCE_MODE:-false}
  export MINIMAL_MODE=${MINIMAL_MODE:-false}
  export QUIET_MODE=${QUIET_MODE:-false}
  export SKIP_LOCAL_MODE=${SKIP_LOCAL_MODE:-false}
  export UPDATE_MODE=${UPDATE_MODE:-false}
  export VERBOSE_MODE=${VERBOSE_MODE:-false}

  # Always enable verbose mode in Codespaces
  [[ -n "${CODESPACES:-}" ]] && VERBOSE_MODE=true

  # Export mode functions for rest of setup
  is_verbose_mode() { [[ "${VERBOSE_MODE:-}" == true ]]; }       ; export -f is_verbose_mode
  is_bootstrap_mode() { [[ ${BOOTSTRAP_MODE:-} == true ]]; }     ; export -f is_bootstrap_mode
  is_dry_run_mode() { [[ ${DRY_RUN_MODE:-} == true ]]; }         ; export -f is_dry_run_mode
  is_force_mode() { [[ ${FORCE_MODE:-} == true ]]; }             ; export -f is_force_mode
  is_minimal_mode() { [[ ${MINIMAL_MODE:-} == true ]]; }         ; export -f is_minimal_mode
  is_quiet_mode() { [[ "${QUIET_MODE:-}" == true ]]; }           ; export -f is_quiet_mode
  is_skip_local_mode() { [[ "${SKIP_LOCAL_MODE:-}" == true ]]; } ; export -f is_skip_local_mode
  is_update_mode() { [[ "${UPDATE_MODE:-}" == true ]]; }         ; export -f is_update_mode
  is_verbose_mode() { [[ "${VERBOSE_MODE:-}" == true ]]; }       ; export -f is_verbose_mode

  # Option validation functions (no export needed for these functions)
  _can_use_dry_run_mode() { ! is_force_mode; }
  _can_use_minimal_mode() { ! is_bootstrap_mode; }
  _can_use_update_mode() { ! is_bootstrap_mode; }
  _can_use_quiet_mode() { ! is_verbose_mode; }
  _can_use_skip_local_mode() { ! is_bootstrap_mode && ! is_minimal_mode; }

  # Parse script options
  _parse_setup_options() {
    local USAGE=(
      "Usage: $0 [OPTIONS]"
      "Options:"
      " -b, --bootstrap   Install only the prerequsites. Only applies to \`setup\`."
      " -d, --dry-run     [LIMITED IMPLEMENTATION - USE WITH CAUTION] Only print status messages; do not make any changes."
      "                   (ignored if --force is set)"
      " -f, --force       Replace regular files and directories with symlinks as necessary."
      "                   Existing files and directories will be suffixed with \`.symlink_config_backup\`."
      " -h, --help        You're looking at it. Print this help message and exit."
      " -m, --minimal     Install bare minimum packages. Only applies to \`setup\`."
      "                   (ignored if --bootstrap is set)"
      " -n                Same as -d for compatibility with other scripts."
      " -p, --personal    Install additional dependencies from \`Brewfile.personal\` for a personal workstation."
      "                   Only applies to \`setup\`. (ignored if --bootstrap or --minimal is set)"
      " -q, --quiet       Print fewer status messages. (ignored if --verbose is set)."
      "     --skip-local  Skip installation of any dependencies defined in Brewfile*.local files. Only applies"
      "                   to \`setup\`. (implied if --bootstrap or --minimal is set)"
      " -u, --update      Update existing packages, but don't install anything. (ignored if --bootstrap is set)"
      "                   Combine with --force to also regenerate symlinks afterward."
      "                   Can also be used with --minimal to only update the bare minimum packages."
      " -v, --verbose     Print additional status messages."
      " -w, --work        Install additional dependencies from \`Brewfile.work\` for a work workstation."
      "                   Only applies to \`setup\`. (ignored if --bootstrap or --minimal is set)"
      ""
      "With no options, \`setup\` offers an fzf menu to choose the mode, scope and other options"
      "when fzf is installed (\`setup --bootstrap\` installs it) and the shell is interactive."
    )

    deserialize_array ADDITIONAL_DEPENDENCIES_SERIALIZED ADDITIONAL_DEPENDENCIES '|'

    while [[ $# -gt 0 ]]; do
      case $1 in
        -h | --help             ) printf >&1 '%s\n' "${USAGE[@]}" && exit 0
                                  ;;
        -b | --bootstrap        ) BOOTSTRAP_MODE=true && MINIMAL_MODE=false
                                  ;;
        -f | --force            ) FORCE_MODE=true && DRY_RUN_MODE=false
                                  ;;
        -m | --minimal          ) _can_use_minimal_mode && MINIMAL_MODE=true
                                  ;;
        -d | --dry-run          ) _can_use_dry_run_mode && DRY_RUN_MODE=true
                                  ;;
        -p | --personal         ) ADDITIONAL_DEPENDENCIES+=( personal personal.vscode )
                                  ;;
        --skip-local            ) _can_use_skip_local_mode && SKIP_LOCAL_MODE=true
                                  ;;
        -q | --quiet            ) _can_use_quiet_mode && QUIET_MODE=true
                                  ;;
        -u | --update           ) _can_use_update_mode && UPDATE_MODE=true
                                  ;;
        -v | --verbose          ) VERBOSE_MODE=true && QUIET_MODE=false
                                  ;;
        -w | --work | --business) ADDITIONAL_DEPENDENCIES+=( work )
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

    serialize_array ADDITIONAL_DEPENDENCIES ADDITIONAL_DEPENDENCIES_SERIALIZED '|'

  }

  # Interactively choose options with fzf when `setup` is run with no arguments.
  # Skipped when fzf is missing (first run, before --bootstrap installs it), when
  # not attached to a terminal, in Codespaces, or for any script but `setup`.
  # Prints the chosen flags, one per line. Exits if the user cancels.
  _choose_setup_options() {
    local mode scope extras choice
    local flags=()

    mode="$(printf '%s\n' \
      "Full setup" \
      "Minimal setup" \
      "Bootstrap only (prerequisites)" \
      "Update packages" \
      "Update minimal packages" |
      fzf --prompt="Mode > " --height=~10 --reverse \
        --header="Choose a setup mode (Esc to cancel)")" || { log_attention "Setup cancelled" >&2; exit 1; }

    case "${mode}" in
      "Minimal setup"          ) flags+=( --minimal ) ;;
      "Bootstrap only"*        ) flags+=( --bootstrap ) ;;
      "Update packages"        ) flags+=( --update ) ;;
      "Update minimal packages") flags+=( --update --minimal ) ;;
    esac

    # Scope only matters when installing the full set of packages
    if [[ "${mode}" == "Full setup" ]]; then
      local scopes=( "Common packages only" "Common + personal" )
      # Brewfile.work is private, so only offer work scopes where it exists
      if [[ -f "${DOTFILES}/Brewfile.work" ]]; then
        scopes+=( "Common + work" "Common + personal + work" )
      fi
      scope="$(printf '%s\n' "${scopes[@]}" |
        fzf --prompt="Scope > " --height=~10 --reverse \
          --header="Which Brewfiles to install (Esc to cancel)")" || { log_attention "Setup cancelled" >&2; exit 1; }

      case "${scope}" in
        "Common + personal"        ) flags+=( --personal ) ;;
        "Common + work"            ) flags+=( --work ) ;;
        "Common + personal + work" ) flags+=( --personal --work ) ;;
      esac
    fi

    # Other options are optional, so cancelling here means "none"
    extras="$(printf '%s\n' \
      "--force        Replace regular files with symlinks (backs up originals)" \
      "--dry-run      Only print status messages (limited implementation)" \
      "--skip-local   Skip Brewfile*.local packages" \
      "--quiet        Print fewer status messages" \
      "--verbose      Print additional status messages" |
      fzf --multi --prompt="Options > " --height=~12 --reverse \
        --header="Tab to toggle, Enter to confirm (none is fine)")" || extras=""

    while IFS= read -r choice; do
      [[ -n "${choice}" ]] && flags+=( "${choice%% *}" )
    done <<<"${extras}"

    [[ ${#flags[@]} -gt 0 ]] && printf '%s\n' "${flags[@]}"
    return 0
  }

  _setup_args=( "$@" )
  if [[ ${#_setup_args[@]} -eq 0 && "$(basename "$0")" == "setup" && -z "${CODESPACES:-}" ]] \
    && [[ -t 0 && -t 1 ]] && command -v fzf >/dev/null 2>&1; then
    while IFS= read -r _flag; do
      _setup_args+=( "${_flag}" )
    done < <(_choose_setup_options)
    log_info "Running with options: ${_setup_args[*]:-(defaults)}"
  fi

  _parse_setup_options ${_setup_args[@]+"${_setup_args[@]}"}
  unset _setup_args _flag

  # Mark helpers script as loaded
  log_verbose "Helpers loaded"
  readonly HELPERS_LOADED=true
  export HELPERS_LOADED
else
  log_verbose "Helpers script is already loaded; skipping"
fi

# Debugging output
log_debug "Parsed options:"
log_debug "  ADDITIONAL_DEPENDENCIES: ${ADDITIONAL_DEPENDENCIES_SERIALIZED:?Not set!}"
log_debug "  BOOTSTRAP_MODE:          ${BOOTSTRAP_MODE:?Not set!}"
log_debug "  DRY_RUN_MODE:            ${DRY_RUN_MODE:?Not set!}"
log_debug "  FORCE_MODE:              ${FORCE_MODE:?Not set!}"
log_debug "  MINIMAL_MODE:            ${MINIMAL_MODE:?Not set!}"
log_debug "  QUIET_MODE:              ${QUIET_MODE:?Not set!}"
log_debug "  UPDATE_MODE:             ${UPDATE_MODE:?Not set!}"
log_debug "  VERBOSE_MODE:            ${VERBOSE_MODE:?Not set!}"
log_debug "  DOTFILES:                ${DOTFILES:?Not set!}"
