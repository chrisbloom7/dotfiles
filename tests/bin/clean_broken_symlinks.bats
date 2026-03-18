bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
  TARGET_DIR="${TEST_TMPDIR}/target_dir"
  mkdir -p "${TARGET_DIR}"
}

teardown() {
  _teardown_common
}

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

@test "clean_broken_symlinks: fails when no argument provided" {
  run "${DOTFILES_BIN}/clean_broken_symlinks"
  [ "${status}" -ne 0 ]
}

@test "clean_broken_symlinks: fails when argument is not a directory" {
  not_a_dir="${TEST_TMPDIR}/regular_file"
  echo "content" > "${not_a_dir}"
  run "${DOTFILES_BIN}/clean_broken_symlinks" "${not_a_dir}"
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# No broken symlinks present
# ---------------------------------------------------------------------------

@test "clean_broken_symlinks: exits 0 and makes no changes when no broken symlinks exist" {
  # Put a valid symlink and a regular file in the directory
  real_file="${TEST_TMPDIR}/real_file"
  echo "content" > "${real_file}"
  ln -s "${real_file}" "${TARGET_DIR}/valid_link"
  echo "regular" > "${TARGET_DIR}/regular_file"

  run "${DOTFILES_BIN}/clean_broken_symlinks" "${TARGET_DIR}"
  [ "${status}" -eq 0 ]

  # Ensure nothing was removed
  [ -L "${TARGET_DIR}/valid_link" ] || {
    echo "Expected valid_link to still exist"
    return 1
  }
  [ -f "${TARGET_DIR}/regular_file" ] || {
    echo "Expected regular_file to still exist"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Broken symlinks — report mode (no FORCE_MODE)
# ---------------------------------------------------------------------------

@test "clean_broken_symlinks: reports broken symlink without removing (no FORCE_MODE)" {
  broken_link="${TARGET_DIR}/broken_link"
  ln -s "${TEST_TMPDIR}/nonexistent_target" "${broken_link}"

  run "${DOTFILES_BIN}/clean_broken_symlinks" "${TARGET_DIR}"
  [ "${status}" -eq 0 ]

  # Symlink must still be present — not removed
  [ -L "${broken_link}" ] || {
    echo "Expected broken symlink to remain when FORCE_MODE is not set"
    return 1
  }

  # Output should mention the broken link
  [[ "${output}" == *"broken_link"* ]] || {
    echo "Expected output to mention the broken symlink path; got: ${output}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Broken symlinks — removal mode (FORCE_MODE=true)
# ---------------------------------------------------------------------------

@test "clean_broken_symlinks: removes broken symlink with FORCE_MODE=true" {
  broken_link="${TARGET_DIR}/broken_link"
  ln -s "${TEST_TMPDIR}/nonexistent_target" "${broken_link}"

  FORCE_MODE=true run "${DOTFILES_BIN}/clean_broken_symlinks" "${TARGET_DIR}"
  [ "${status}" -eq 0 ]

  [ ! -L "${broken_link}" ] || {
    echo "Expected broken symlink to be removed when FORCE_MODE=true"
    return 1
  }
  [ ! -e "${broken_link}" ] || {
    echo "Expected broken symlink path to no longer exist"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Valid symlinks and regular files are never touched
# ---------------------------------------------------------------------------

@test "clean_broken_symlinks: does not remove a valid symlink pointing to an existing file" {
  real_file="${TEST_TMPDIR}/real_file"
  echo "content" > "${real_file}"
  valid_link="${TARGET_DIR}/valid_link"
  ln -s "${real_file}" "${valid_link}"

  FORCE_MODE=true run "${DOTFILES_BIN}/clean_broken_symlinks" "${TARGET_DIR}"
  [ "${status}" -eq 0 ]

  [ -L "${valid_link}" ] || {
    echo "Expected valid symlink to be preserved even with FORCE_MODE=true"
    return 1
  }
}

@test "clean_broken_symlinks: does not remove regular files" {
  regular_file="${TARGET_DIR}/regular_file"
  echo "content" > "${regular_file}"

  FORCE_MODE=true run "${DOTFILES_BIN}/clean_broken_symlinks" "${TARGET_DIR}"
  [ "${status}" -eq 0 ]

  [ -f "${regular_file}" ] || {
    echo "Expected regular file to be preserved even with FORCE_MODE=true"
    return 1
  }
}
