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

  cat > "${BREWFILE_DIR}/Brewfile.other" <<'EOF'
## Formulae
brew "git" # Distributed revision control system
EOF

  # Default mock brew: canned info for "git"; no-op uninstall
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "info" ]]; then
  echo '{"formulae":[{"name":"git","desc":"Distributed revision control system"}],"casks":[]}'
  exit 0
fi
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/brew"

  cat > "${TEST_TMPDIR}/mock_bin/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/git"

  # fzf: returns first option
  cat > "${TEST_TMPDIR}/mock_bin/fzf" <<'EOF'
#!/usr/bin/env bash
head -1
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/fzf"
}

teardown() {
  _teardown_common
}

invoke() {
  run env \
    PATH="${TEST_TMPDIR}/mock_bin:${DOTFILES_BIN}:${PATH}" \
    DOTFILES_ROOT="${BREWFILE_DIR}" \
    "${DOTFILES_BIN}/brew_remove" "$@"
}

# ---------------------------------------------------------------------------
# Argument / early-exit validation
# ---------------------------------------------------------------------------

@test "brew_remove: fails when no packages specified" {
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall
  [ "${status}" -ne 0 ]
}

@test "brew_remove: fails when --brewfile-suffix and --all-brewfiles both given" {
  invoke --brewfile-suffix=test --all-brewfiles --skip-commit --skip-uninstall git
  [ "${status}" -ne 0 ]
}

@test "brew_remove: fails when --brewfile-suffix names a non-existent Brewfile" {
  invoke --brewfile-suffix=doesnotexist --skip-commit --skip-uninstall git
  [ "${status}" -ne 0 ]
}

@test "brew_remove: --help exits 0 and prints usage" {
  invoke --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage"* ]] || {
    echo "Expected usage output, got: ${output}"; return 1
  }
}

# ---------------------------------------------------------------------------
# Successful remove from a single Brewfile
# ---------------------------------------------------------------------------

@test "brew_remove: removes a package from the specified Brewfile" {
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall git
  [ "${status}" -eq 0 ]
  ! grep -q '"git"' "${BREWFILE_DIR}/Brewfile.test" || {
    echo "Expected git to be removed from Brewfile.test"
    cat "${BREWFILE_DIR}/Brewfile.test"
    return 1
  }
}

@test "brew_remove: reports the removed package on stdout" {
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall git
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"git"* ]] || {
    echo "Expected git in output, got: ${output}"; return 1
  }
}

@test "brew_remove: does not remove package from non-targeted Brewfile" {
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall git
  [ "${status}" -eq 0 ]
  grep -q '"git"' "${BREWFILE_DIR}/Brewfile.other" || {
    echo "Expected git to remain in Brewfile.other"
    return 1
  }
}

# ---------------------------------------------------------------------------
# --all-brewfiles
# ---------------------------------------------------------------------------

@test "brew_remove: removes package from all Brewfiles when --all-brewfiles set" {
  invoke --all-brewfiles --skip-commit --skip-uninstall git
  [ "${status}" -eq 0 ]
  ! grep -q '"git"' "${BREWFILE_DIR}/Brewfile.test" || {
    echo "Expected git removed from Brewfile.test"; return 1
  }
  ! grep -q '"git"' "${BREWFILE_DIR}/Brewfile.other" || {
    echo "Expected git removed from Brewfile.other"; return 1
  }
}

# ---------------------------------------------------------------------------
# Not found
# ---------------------------------------------------------------------------

@test "brew_remove: reports skipped when package not in Brewfile" {
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "info" ]]; then
  echo '{"formulae":[{"name":"nonexistent","desc":"Does not exist"}],"casks":[]}'
  exit 0
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall nonexistent
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Skipped"* ]] || [[ "${output}" == *"not found"* ]] || {
    echo "Expected 'Skipped' or 'not found', got: ${output}"; return 1
  }
}

# ---------------------------------------------------------------------------
# --skip-uninstall
# ---------------------------------------------------------------------------

@test "brew_remove: does not call brew uninstall when --skip-uninstall is set" {
  uninstall_log="${TEST_TMPDIR}/uninstall_called"
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "info" ]]; then
  echo '{"formulae":[{"name":"git","desc":"VCS"}],"casks":[]}'
  exit 0
fi
if [[ "\$1" == "uninstall" ]]; then
  touch "${uninstall_log}"
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall git
  [ ! -f "${uninstall_log}" ] || {
    echo "brew uninstall was called despite --skip-uninstall"; return 1
  }
}

@test "brew_remove: calls brew uninstall when --skip-uninstall not set" {
  uninstall_log="${TEST_TMPDIR}/uninstall_called"
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "info" ]]; then
  echo '{"formulae":[{"name":"git","desc":"VCS"}],"casks":[]}'
  exit 0
fi
if [[ "\$1" == "uninstall" ]]; then
  touch "${uninstall_log}"
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit git
  [ -f "${uninstall_log}" ] || {
    echo "Expected brew uninstall to be called"; return 1
  }
}

# ---------------------------------------------------------------------------
# --skip-commit
# ---------------------------------------------------------------------------

@test "brew_remove: does not call git commit when --skip-commit is set" {
  commit_log="${TEST_TMPDIR}/commit_called"
  cat > "${TEST_TMPDIR}/mock_bin/git" <<EOF
#!/usr/bin/env bash
if [[ "\$3" == "commit" ]]; then
  touch "${commit_log}"
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall git
  [ ! -f "${commit_log}" ] || {
    echo "git commit was called despite --skip-commit"; return 1
  }
}

# ---------------------------------------------------------------------------
# brew info failure
# ---------------------------------------------------------------------------

@test "brew_remove: exits non-zero when brew info fails" {
  cat > "${TEST_TMPDIR}/mock_bin/brew" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "info" ]]; then
  echo "Error: No available formula" >&2
  exit 1
fi
exit 0
EOF
  invoke --brewfile-suffix=test --skip-commit --skip-uninstall nonexistent-pkg
  [ "${status}" -ne 0 ]
}
