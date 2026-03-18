bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
}

teardown() {
  _teardown_common
}

# ---------------------------------------------------------------------------
# Helper: write a mock uname into mock_bin for this test.
# is_linux calls `uname -a`; since mock_bin is prepended to PATH and is_linux
# does NOT override PATH itself, our mock is found first.
# ---------------------------------------------------------------------------

_mock_uname() {
  local output="$1"
  cat > "${TEST_TMPDIR}/mock_bin/uname" <<EOF
#!/usr/bin/env bash
echo "${output}"
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/uname"
}

@test "is_linux: outputs true when uname contains Linux" {
  _mock_uname "Linux hostname 5.15.0-generic #1 SMP x86_64 GNU/Linux"
  run "${DOTFILES_BIN}/is_linux"
  [ "${status}" -eq 0 ]
  [ "${output}" = "true" ] || {
    echo "Expected 'true' when uname contains Linux; got '${output}'"
    return 1
  }
}

@test "is_linux: outputs false when uname does not contain Linux" {
  _mock_uname "Darwin Kernel Version 23.0.0"
  run "${DOTFILES_BIN}/is_linux"
  [ "${status}" -eq 0 ]
  [ "${output}" = "false" ] || {
    echo "Expected 'false' when uname does not contain Linux; got '${output}'"
    return 1
  }
}

@test "is_linux: smoke test against actual platform" {
  # Run the real script without any mock uname override.
  # On Linux this must return 'true'; on macOS 'false'.
  # The test passes on either platform — it just verifies the script exits
  # cleanly and produces a boolean string.
  run "${DOTFILES_BIN}/is_linux"
  [ "${status}" -eq 0 ]
  [[ "${output}" == "true" || "${output}" == "false" ]] || {
    echo "Expected 'true' or 'false'; got '${output}'"
    return 1
  }
  if [[ "$(uname -a)" =~ "Linux" ]]; then
    [ "${output}" = "true" ] || {
      echo "Running on Linux but is_linux returned '${output}'"
      return 1
    }
  else
    skip "Not running on Linux; skipping Linux-specific assertion"
  fi
}
