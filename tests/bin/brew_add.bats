bats_require_minimum_version 1.5.0

load "../test_helper"

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------

setup() {
  _setup_common

  BREWFILE_DIR="${TEST_TMPDIR}/dotfiles"
  mkdir -p "${BREWFILE_DIR}"

  cat > "${BREWFILE_DIR}/Brewfile.test" <<'EOF'
## Formulae
brew "git" # Distributed revision control system
brew "wget" # Internet file retriever

## Casks
cask "iterm2" # Terminal emulator
EOF

  # Mock brew: canned info JSON for "fzf"; no-op install
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "info" ]]; then
  echo '{"formulae":[{"name":"fzf","desc":"Fuzzy finder"}],"casks":[]}'
  exit 0
fi
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/brew"

  # Mock git: always succeeds
  cat > "${TEST_TMPDIR}/mock_bin/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/git"

  # Mock fzf: non-interactive — returns the first line piped to it
  cat > "${TEST_TMPDIR}/mock_bin/fzf" <<'EOF'
#!/usr/bin/env bash
head -1
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/fzf"
}

teardown() {
  _teardown_common
}

# Convenience wrapper: runs brew_add with the fixture DOTFILES_ROOT
invoke() {
  run env \
    PATH="${TEST_TMPDIR}/mock_bin:${DOTFILES_BIN}:${PATH}" \
    DOTFILES_ROOT="${BREWFILE_DIR}" \
    "${DOTFILES_BIN}/brew_add" "$@"
}

# ---------------------------------------------------------------------------
# Argument / early-exit validation
# ---------------------------------------------------------------------------

@test "brew_add: fails when no packages specified" {
  invoke --brewfile-suffix=test --skip-commit --skip-install
  [ "${status}" -ne 0 ]
}

@test "brew_add: fails when --brewfile-suffix names a non-existent Brewfile" {
  invoke --brewfile-suffix=doesnotexist --skip-commit --skip-install fzf
  [ "${status}" -ne 0 ]
}

@test "brew_add: --help exits 0 and prints usage" {
  invoke --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage"* ]] || {
    echo "Expected usage output, got: ${output}"; return 1
  }
}

@test "brew_add: fails on unknown option" {
  invoke --brewfile-suffix=test --skip-commit --skip-install --invalid-flag fzf
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Brewfile selection via fzf
# ---------------------------------------------------------------------------

@test "brew_add: selects Brewfile via fzf when --brewfile-suffix not given" {
  invoke --skip-commit --skip-install fzf
  [ "${status}" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Successful add
# ---------------------------------------------------------------------------

@test "brew_add: adds a new package to the Brewfile" {
  invoke --brewfile-suffix=test --skip-commit --skip-install fzf
  [ "${status}" -eq 0 ]
  grep -q '"fzf"' "${BREWFILE_DIR}/Brewfile.test" || {
    echo "Expected fzf in Brewfile.test"
    cat "${BREWFILE_DIR}/Brewfile.test"
    return 1
  }
}

@test "brew_add: reports the added package on stdout" {
  invoke --brewfile-suffix=test --skip-commit --skip-install fzf
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"fzf"* ]] || {
    echo "Expected fzf in output, got: ${output}"; return 1
  }
}

# ---------------------------------------------------------------------------
# Already-present package
# ---------------------------------------------------------------------------

@test "brew_add: reports skipped when package already present" {
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "info" ]]; then
  echo '{"formulae":[{"name":"git","desc":"Distributed revision control system"}],"casks":[]}'
  exit 0
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-install git
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Skipped"* ]] || [[ "${output}" == *"already present"* ]] || {
    echo "Expected 'Skipped' or 'already present', got: ${output}"; return 1
  }
}

# ---------------------------------------------------------------------------
# --skip-install
# ---------------------------------------------------------------------------

@test "brew_add: does not call brew install when --skip-install is set" {
  install_log="${TEST_TMPDIR}/install_called"
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "info" ]]; then
  echo '{"formulae":[{"name":"fzf","desc":"Fuzzy finder"}],"casks":[]}'
  exit 0
fi
if [[ "\$1" == "install" ]]; then
  touch "${install_log}"
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-install fzf
  [ ! -f "${install_log}" ] || {
    echo "brew install was called despite --skip-install"; return 1
  }
}

@test "brew_add: calls brew install when --skip-install is not set" {
  install_log="${TEST_TMPDIR}/install_called"
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "info" ]]; then
  echo '{"formulae":[{"name":"fzf","desc":"Fuzzy finder"}],"casks":[]}'
  exit 0
fi
if [[ "\$1" == "install" ]]; then
  touch "${install_log}"
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit fzf
  [ -f "${install_log}" ] || {
    echo "Expected brew install to be called"; return 1
  }
}

# ---------------------------------------------------------------------------
# --skip-commit
# ---------------------------------------------------------------------------

@test "brew_add: does not call git commit when --skip-commit is set" {
  commit_log="${TEST_TMPDIR}/commit_called"
  cat > "${TEST_TMPDIR}/mock_bin/git" <<EOF
#!/usr/bin/env bash
if [[ "\$1 \$2" == "-C ${BREWFILE_DIR}" && "\$3" == "commit" ]]; then
  touch "${commit_log}"
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-install fzf
  [ ! -f "${commit_log}" ] || {
    echo "git commit was called despite --skip-commit"; return 1
  }
}

# ---------------------------------------------------------------------------
# brew info failure
# ---------------------------------------------------------------------------

@test "brew_add: exits non-zero when brew info fails" {
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "info" ]]; then
  echo "Error: No available formula" >&2
  exit 1
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-install nonexistent-pkg
  [ "${status}" -ne 0 ]
}
