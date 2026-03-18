bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
  TARGET_FILE="${TEST_TMPDIR}/dotfile"
}

teardown() {
  _teardown_common
}

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

@test "add_eval_to_dotfile: fails with no arguments" {
  run "${DOTFILES_BIN}/add_eval_to_dotfile"
  [ "${status}" -ne 0 ]
}

@test "add_eval_to_dotfile: fails with only one argument" {
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "some_gate"
  [ "${status}" -ne 0 ]
}

@test "add_eval_to_dotfile: fails with only two arguments (missing target file)" {
  # gate + subject supplied but no target file — the `: ${3:?}` check fires
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "some_gate" "some_command"
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# File creation
# ---------------------------------------------------------------------------

@test "add_eval_to_dotfile: creates target file if it does not exist" {
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "" "my_command" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  [ -f "${TARGET_FILE}" ] || {
    echo "Expected ${TARGET_FILE} to be created"
    return 1
  }
}

@test "add_eval_to_dotfile: creates parent directories for target file if needed" {
  nested_target="${TEST_TMPDIR}/deeply/nested/dir/dotfile"
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "" "my_command" "${nested_target}"
  [ "${status}" -eq 0 ]
  [ -f "${nested_target}" ] || {
    echo "Expected ${nested_target} to be created including parent dirs"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Appending eval line
# ---------------------------------------------------------------------------

@test "add_eval_to_dotfile: appends eval line to target file" {
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "" "my_command" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  expected='eval "$(my_command)"'
  [[ "$(cat "${TARGET_FILE}")" == *"${expected}"* ]] || {
    echo "Expected '${expected}' to appear in ${TARGET_FILE}"
    echo "Got: $(cat "${TARGET_FILE}")"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Idempotency
# ---------------------------------------------------------------------------

@test "add_eval_to_dotfile: skips if eval line already exists (idempotent)" {
  # First invocation writes the line
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "" "my_command" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  line_count_before="$(wc -l < "${TARGET_FILE}")"

  # Second invocation must not append again
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "" "my_command" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  line_count_after="$(wc -l < "${TARGET_FILE}")"

  [ "${line_count_before}" -eq "${line_count_after}" ] || {
    echo "Expected line count to stay at ${line_count_before} but got ${line_count_after} after second run"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Gate wrapping
# ---------------------------------------------------------------------------

@test "add_eval_to_dotfile: prepends gate condition when gate argument is non-empty" {
  run "${DOTFILES_BIN}/add_eval_to_dotfile" "command -v my_tool" "my_command" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  content="$(cat "${TARGET_FILE}")"
  expected='command -v my_tool && eval "$(my_command)" || true'
  [[ "${content}" == *"${expected}"* ]] || {
    echo "Expected gated eval line '${expected}' in ${TARGET_FILE}"
    echo "Got: ${content}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Multiple target files
# ---------------------------------------------------------------------------

@test "add_eval_to_dotfile: handles multiple target files" {
  target1="${TEST_TMPDIR}/dotfile1"
  target2="${TEST_TMPDIR}/dotfile2"
  target3="${TEST_TMPDIR}/dotfile3"

  run "${DOTFILES_BIN}/add_eval_to_dotfile" "" "my_command" "${target1}" "${target2}" "${target3}"
  [ "${status}" -eq 0 ]

  expected='eval "$(my_command)"'
  for t in "${target1}" "${target2}" "${target3}"; do
    [ -f "${t}" ] || {
      echo "Expected ${t} to be created"
      return 1
    }
    [[ "$(cat "${t}")" == *"${expected}"* ]] || {
      echo "Expected '${expected}' in ${t}"
      return 1
    }
  done
}
