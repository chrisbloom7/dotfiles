#!/usr/bin/env bash

# Check if the script is being sourced and if not, exit with an error message
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo -e "\033[1;31mError:\033[0m This script must be sourced, not executed" >&2
  exit 1
fi

trap '_trace_on_error $? $LINENO' ERR

# Trap function
function _trace_on_error {
  set +xv # turns off debug logging, just in case
  local error_code=$1
  local line_number=$2
  local command="${BASH_COMMAND}"
  if [[ $- =~ e ]] && [[ "${error_code}" != "0" ]]; then
    local script_name="${BASH_SOURCE[1]}"
    local script_path="${PWD%/}/$(basename "${script_name}")"
    # echo ""
    # echo "caller: $(caller)"
    # echo "PWD caller: ${PWD%/}/$(caller | awk '{print $2}')"
    # echo "PWD basename caller: ${PWD%/}/$(basename "$(caller | awk '{print $2}')")"
    # echo "realpath caller: $(realpath "$(caller | awk '{print $2}')" 2>/dev/null || echo "not found")"
    # echo "realpath -s caller: $(realpath -s "$(caller | awk '{print $2}')" 2>/dev/null || echo "not found")"
    # echo "grealpath caller: $(grealpath "$(caller | awk '{print $2}')" 2>/dev/null || echo "not found")"
    # echo "grealpath -s caller: $(grealpath -s "$(caller | awk '{print $2}')" 2>/dev/null || echo "not found")"
    # echo "dirname caller: $(dirname "$(caller | awk '{print $2}')" || echo "not found")"
    # echo ""
    # echo "BASH_SOURCE[-1]: ${BASH_SOURCE[-1]}"
    # echo "PWD BASH_SOURCE[-1]: ${PWD%/}/${BASH_SOURCE[-1]}"
    # echo "PWD basename BASH_SOURCE[-1]: ${PWD%/}/$(basename "${BASH_SOURCE[-1]}")"
    # echo "realpath BASH_SOURCE[-1]: $(realpath "${BASH_SOURCE[-1]}" 2>/dev/null || echo "not found")"
    # echo "realpath -s BASH_SOURCE[-1]: $(realpath -s "${BASH_SOURCE[-1]}" 2>/dev/null || echo "not found")"
    # echo "grealpath BASH_SOURCE[-1]: $(grealpath "${BASH_SOURCE[-1]}" 2>/dev/null || echo "not found")"
    # echo "grealpath -s BASH_SOURCE[-1]: $(grealpath -s "${BASH_SOURCE[-1]}" 2>/dev/null || echo "not found")"
    # echo "dirname BASH_SOURCE[-1]: $(dirname "${BASH_SOURCE[-1]}" || echo "not found")"
    # echo ""
    # echo "BASH_SOURCE[0]: ${BASH_SOURCE[0]}"
    # echo "PWD BASH_SOURCE[0]: ${PWD%/}/${BASH_SOURCE[0]}"
    # echo "PWD basename BASH_SOURCE[0]: ${PWD%/}/$(basename "${BASH_SOURCE[0]}")"
    # echo "realpath BASH_SOURCE[0]: $(realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "not found")"
    # echo "realpath -s BASH_SOURCE[0]: $(realpath -s "${BASH_SOURCE[0]}" 2>/dev/null || echo "not found")"
    # echo "grealpath BASH_SOURCE[0]: $(grealpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "not found")"
    # echo "grealpath -s BASH_SOURCE[0]: $(grealpath -s "${BASH_SOURCE[0]}" 2>/dev/null || echo "not found")"
    # echo "dirname BASH_SOURCE[0]: $(dirname "${BASH_SOURCE[0]}" || echo "not found")"
    # echo ""
    # echo "BASH_SOURCE[1]: ${BASH_SOURCE[1]}"
    # echo "PWD BASH_SOURCE[1]: ${PWD%/}/${BASH_SOURCE[1]}"
    # echo "PWD basename BASH_SOURCE[1]: ${PWD%/}/$(basename "${BASH_SOURCE[1]}")"
    # echo "realpath BASH_SOURCE[1]: $(realpath "${BASH_SOURCE[1]}" 2>/dev/null || echo "not found")"
    # echo "realpath -s BASH_SOURCE[1]: $(realpath -s "${BASH_SOURCE[1]}" 2>/dev/null || echo "not found")"
    # echo "grealpath BASH_SOURCE[1]: $(grealpath "${BASH_SOURCE[1]}" 2>/dev/null || echo "not found")"
    # echo "grealpath -s BASH_SOURCE[1]: $(grealpath -s "${BASH_SOURCE[1]}" 2>/dev/null || echo "not found")"
    # echo "dirname BASH_SOURCE[1]: $(dirname "${BASH_SOURCE[1]}" || echo "not found")"
    # echo ""
    # echo "\$0: ${0}"
    # echo "PWD \$0: ${PWD%/}/${0}"
    # echo "PWD basename \$0: ${PWD%/}/$(basename "${0}")"
    # echo "realpath \$0: $(realpath "${0}" 2>/dev/null || echo "not found")"
    # echo "realpath -s \$0: $(realpath -s "${0}" 2>/dev/null || echo "not found")"
    # echo "grealpath \$0: $(grealpath "${0}" 2>/dev/null || echo "not found")"
    # echo "grealpath -s \$0: $(grealpath -s "${0}" 2>/dev/null || echo "not found")"
    # echo "dirname \$0: $(dirname "${0}" || echo "not found")"
    # echo ""
    echo -e "\033[1;31mError:\033[0m An error occurred in ${script_path} on line ${line_number}: '${command}' exited with error code ${error_code}" >&2
    if [[ -f "${script_path}" ]]; then
      echo -e "\n${script_path}"
      # pr -tn "${script_path}" | tail -n+$((line_number - 3)) | head -n7 | perl -pe 's/^( +)'$line_number' /(q[>] x ((length $1) - 1)) . q[ '$line_number' ]/ge'
      pr -tn "${script_path}" | tail -n+$((line_number - 3)) | head -n7 | sed -E '4 s/^ />/'
      echo ""
    fi
  fi
}
