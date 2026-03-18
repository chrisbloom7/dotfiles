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
# is_macos calls `uname -a`; since mock_bin is prepended to PATH and is_macos
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

@test "is_macos: outputs true when uname contains Darwin" {
  _mock_uname "Darwin Kernel Version 23.0.0"
  run "${DOTFILES_BIN}/is_macos"
  [ "${status}" -eq 0 ]
  [ "${output}" = "true" ] || {
    echo "Expected 'true' when uname contains Darwin; got '${output}'"
    return 1
  }
}

@test "is_macos: outputs false when uname does not contain Darwin" {
  _mock_uname "Linux hostname 5.15.0-generic #1 SMP x86_64 GNU/Linux"
  run "${DOTFILES_BIN}/is_macos"
  [ "${status}" -eq 0 ]
  [ "${output}" = "false" ] || {
    echo "Expected 'false' when uname does not contain Darwin; got '${output}'"
    return 1
  }
}

@test "is_macos: smoke test against actual platform" {
  # Run the real script without any mock uname override.
  # On macOS this must return 'true'; on Linux 'false'.
  # The test passes on either platform — it just verifies the script exits
  # cleanly and produces a boolean string.
  run "${DOTFILES_BIN}/is_macos"
  [ "${status}" -eq 0 ]
  [[ "${output}" == "true" || "${output}" == "false" ]] || {
    echo "Expected 'true' or 'false'; got '${output}'"
    return 1
  }
  if [[ "$(uname -a)" =~ "Darwin" ]]; then
    [ "${output}" = "true" ] || {
      echo "Running on macOS but is_macos returned '${output}'"
      return 1
    }
  else
    skip "Not running on macOS; skipping Darwin-specific assertion"
  fi
}
