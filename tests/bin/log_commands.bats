bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
}

teardown() {
  _teardown_common
}

# ---------------------------------------------------------------------------
# Note on output matching:
# The log commands emit ANSI escape codes, so we use glob-style partial
# matching ([[ "$output" == *"pattern"* ]]) rather than exact equality.
#
# Note on log_error:
# log_error writes to stderr. We redirect stderr to stdout inside a `bash -c`
# subshell so that `run` captures it in $output.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# log_info
# ---------------------------------------------------------------------------

@test "log_info: output contains 'Info:' and the message" {
  run "${DOTFILES_BIN}/log_info" "hello from log_info"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Info:"* ]] || {
    echo "Expected 'Info:' in output; got: ${output}"
    return 1
  }
  [[ "${output}" == *"hello from log_info"* ]] || {
    echo "Expected message in output; got: ${output}"
    return 1
  }
}

@test "log_info: produces no output when QUIET_MODE=true" {
  QUIET_MODE=true run "${DOTFILES_BIN}/log_info" "should be silent"
  [ "${status}" -eq 0 ]
  [ -z "${output}" ] || {
    echo "Expected no output when QUIET_MODE=true; got: ${output}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# log_error
# ---------------------------------------------------------------------------

@test "log_error: output contains 'Error:' and the message" {
  # Redirect stderr->stdout so `run` captures it
  run bash -c "${DOTFILES_BIN}/log_error 'hello from log_error' 2>&1"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Error:"* ]] || {
    echo "Expected 'Error:' in output; got: ${output}"
    return 1
  }
  [[ "${output}" == *"hello from log_error"* ]] || {
    echo "Expected message in output; got: ${output}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# log_success
# ---------------------------------------------------------------------------

@test "log_success: output contains 'Success:' and the message" {
  run "${DOTFILES_BIN}/log_success" "hello from log_success"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Success:"* ]] || {
    echo "Expected 'Success:' in output; got: ${output}"
    return 1
  }
  [[ "${output}" == *"hello from log_success"* ]] || {
    echo "Expected message in output; got: ${output}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# log_attention
# ---------------------------------------------------------------------------

@test "log_attention: output contains 'Attention:' and the message" {
  run "${DOTFILES_BIN}/log_attention" "hello from log_attention"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Attention:"* ]] || {
    echo "Expected 'Attention:' in output; got: ${output}"
    return 1
  }
  [[ "${output}" == *"hello from log_attention"* ]] || {
    echo "Expected message in output; got: ${output}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# log_verbose
# ---------------------------------------------------------------------------

@test "log_verbose: produces no output without VERBOSE_MODE" {
  unset VERBOSE_MODE
  run "${DOTFILES_BIN}/log_verbose" "should be silent"
  [ "${status}" -eq 0 ]
  [ -z "${output}" ] || {
    echo "Expected no output when VERBOSE_MODE is unset; got: ${output}"
    return 1
  }
}

@test "log_verbose: outputs message when VERBOSE_MODE=true" {
  VERBOSE_MODE=true run "${DOTFILES_BIN}/log_verbose" "hello from log_verbose"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"hello from log_verbose"* ]] || {
    echo "Expected message in output when VERBOSE_MODE=true; got: ${output}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# log_debug
# ---------------------------------------------------------------------------

@test "log_debug: produces no output without DEBUG" {
  unset DEBUG
  run "${DOTFILES_BIN}/log_debug" "should be silent"
  [ "${status}" -eq 0 ]
  [ -z "${output}" ] || {
    echo "Expected no output when DEBUG is unset; got: ${output}"
    return 1
  }
}

@test "log_debug: produces no output when only VERBOSE_MODE=true" {
  unset DEBUG
  VERBOSE_MODE=true run "${DOTFILES_BIN}/log_debug" "should be silent"
  [ "${status}" -eq 0 ]
  [ -z "${output}" ] || {
    echo "Expected no output when only VERBOSE_MODE=true; got: ${output}"
    return 1
  }
}

@test "log_debug: outputs message when DEBUG is set" {
  DEBUG=1 run "${DOTFILES_BIN}/log_debug" "hello from log_debug"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"hello from log_debug"* ]] || {
    echo "Expected message in output when DEBUG is set; got: ${output}"
    return 1
  }
}
