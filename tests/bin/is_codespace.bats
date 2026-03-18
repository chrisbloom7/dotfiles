bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
}

teardown() {
  _teardown_common
}

@test "is_codespace: outputs false when CODESPACES is not set" {
  unset CODESPACES
  run "${DOTFILES_BIN}/is_codespace"
  [ "${status}" -eq 0 ]
  [ "${output}" = "false" ] || {
    echo "Expected output 'false' when CODESPACES is unset; got '${output}'"
    return 1
  }
}

@test "is_codespace: outputs true when CODESPACES is set" {
  CODESPACES=true run "${DOTFILES_BIN}/is_codespace"
  [ "${status}" -eq 0 ]
  [ "${output}" = "true" ] || {
    echo "Expected output 'true' when CODESPACES is set; got '${output}'"
    return 1
  }
}
