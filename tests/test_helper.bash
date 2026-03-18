#!/usr/bin/env bash
# test_helper.bash - shared setup/teardown for dotfiles BATS test suite

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "${TESTS_DIR}/.." && pwd)"
DOTFILES_BIN="${DOTFILES_ROOT}/bin"

# _setup_common
# Call at the top of each test file's setup() function.
# Creates an isolated temp directory, mocks `sleep` to be a no-op (so tests
# are fast), and clears env vars that influence script behavior.
_setup_common() {
  TEST_TMPDIR="$(mktemp -d)"

  # Mock bin: override commands that would slow tests or have side effects.
  # Prepend mock_bin to PATH so these take precedence over system binaries.
  # Scripts that do `PATH="${PWD}:${PATH}"` (putting bin/ first) won't shadow
  # mock_bin entries for commands that don't live in bin/ (like sleep, uname).
  mkdir -p "${TEST_TMPDIR}/mock_bin"

  # Mock sleep: no-op so tests don't take 0.5s per log call
  cat > "${TEST_TMPDIR}/mock_bin/sleep" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/sleep"

  export PATH="${TEST_TMPDIR}/mock_bin:${PATH}"

  # Initialize env vars that scripts depend on (mirrors what runtime.sh does).
  # Unsetting them would trigger set -u failures since scripts reference them
  # without defaults (e.g. "${FORCE_MODE}" not "${FORCE_MODE:-}").
  export FORCE_MODE=false
  export VERBOSE_MODE=false
  export QUIET_MODE=false
  unset CODESPACES || true
}

# _teardown_common
# Call at the bottom of each test file's teardown() function.
# Removes the isolated temp directory created by _setup_common.
_teardown_common() {
  if [[ -n "${TEST_TMPDIR:-}" && -d "${TEST_TMPDIR}" ]]; then
    rm -rf "${TEST_TMPDIR}"
  fi
}
