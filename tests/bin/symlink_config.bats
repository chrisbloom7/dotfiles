bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
  # Convenience variables used throughout the tests
  SUBJECT_FILE="${TEST_TMPDIR}/subject_file"
  TARGET_FILE="${TEST_TMPDIR}/target_file"
}

teardown() {
  _teardown_common
}

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

@test "symlink_config: fails when subject argument is missing" {
  run "${DOTFILES_BIN}/symlink_config"
  [ "${status}" -ne 0 ]
}

@test "symlink_config: fails when target argument is missing" {
  echo "content" > "${SUBJECT_FILE}"
  run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}"
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Subject does not exist
# ---------------------------------------------------------------------------

@test "symlink_config: exits 0 and skips when subject does not exist" {
  run "${DOTFILES_BIN}/symlink_config" "${TEST_TMPDIR}/nonexistent" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  [ ! -e "${TARGET_FILE}" ] || {
    echo "Expected target not to be created but it was"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Target does not exist — happy path
# ---------------------------------------------------------------------------

@test "symlink_config: creates symlink to subject when target does not exist" {
  echo "content" > "${SUBJECT_FILE}"
  run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  [ -L "${TARGET_FILE}" ] || {
    echo "Expected ${TARGET_FILE} to be a symlink but it is not"
    return 1
  }
}

@test "symlink_config: the created symlink points to the subject path" {
  echo "content" > "${SUBJECT_FILE}"
  run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  link_dest="$(readlink "${TARGET_FILE}")"
  [ "${link_dest}" = "${SUBJECT_FILE}" ] || {
    echo "Expected symlink to point to ${SUBJECT_FILE} but got ${link_dest}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Target is an existing symlink
# ---------------------------------------------------------------------------

@test "symlink_config: replaces an existing symlink pointing elsewhere" {
  echo "content" > "${SUBJECT_FILE}"
  other="${TEST_TMPDIR}/other_file"
  echo "other" > "${other}"
  ln -s "${other}" "${TARGET_FILE}"

  run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  [ -L "${TARGET_FILE}" ] || {
    echo "Expected ${TARGET_FILE} to still be a symlink"
    return 1
  }
  link_dest="$(readlink "${TARGET_FILE}")"
  [ "${link_dest}" = "${SUBJECT_FILE}" ] || {
    echo "Expected symlink to point to ${SUBJECT_FILE} but got ${link_dest}"
    return 1
  }
}

@test "symlink_config: is idempotent when symlink already points to subject" {
  echo "content" > "${SUBJECT_FILE}"
  ln -s "${SUBJECT_FILE}" "${TARGET_FILE}"

  run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  link_dest="$(readlink "${TARGET_FILE}")"
  [ "${link_dest}" = "${SUBJECT_FILE}" ] || {
    echo "Expected symlink to still point to ${SUBJECT_FILE} but got ${link_dest}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Target is a regular file — different content
# ---------------------------------------------------------------------------

@test "symlink_config: skips when target is a different regular file without FORCE_MODE" {
  echo "subject content" > "${SUBJECT_FILE}"
  echo "different content" > "${TARGET_FILE}"

  run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]
  # Target must remain a regular file (not replaced with a symlink)
  [ ! -L "${TARGET_FILE}" ] || {
    echo "Expected target to remain a regular file but it became a symlink"
    return 1
  }
  [ "$(cat "${TARGET_FILE}")" = "different content" ] || {
    echo "Expected target content to be unchanged"
    return 1
  }
}

@test "symlink_config: backs up different file and creates symlink with FORCE_MODE" {
  echo "subject content" > "${SUBJECT_FILE}"
  echo "different content" > "${TARGET_FILE}"

  FORCE_MODE=true run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]

  # Target is now a symlink pointing to subject
  [ -L "${TARGET_FILE}" ] || {
    echo "Expected ${TARGET_FILE} to be a symlink after FORCE_MODE backup"
    return 1
  }
  link_dest="$(readlink "${TARGET_FILE}")"
  [ "${link_dest}" = "${SUBJECT_FILE}" ] || {
    echo "Expected symlink to point to ${SUBJECT_FILE} but got ${link_dest}"
    return 1
  }

  # Original file was backed up
  backup="${TARGET_FILE}.symlink_config_backup"
  [ -f "${backup}" ] || {
    echo "Expected backup file ${backup} to exist"
    return 1
  }
  [ "$(cat "${backup}")" = "different content" ] || {
    echo "Expected backup to contain original content"
    return 1
  }
}

@test "symlink_config: second backup gets .00001 suffix" {
  echo "subject content" > "${SUBJECT_FILE}"

  # Create the first backup manually to simulate a previous run
  echo "first original" > "${TARGET_FILE}"
  backup="${TARGET_FILE}.symlink_config_backup"
  echo "already backed up" > "${backup}"

  # Now run with a second different file — should create .00001 backup
  echo "second original" > "${TARGET_FILE}"

  FORCE_MODE=true run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]

  backup2="${TARGET_FILE}.symlink_config_backup.00001"
  [ -f "${backup2}" ] || {
    echo "Expected second backup ${backup2} to exist"
    return 1
  }
  [ "$(cat "${backup2}")" = "second original" ] || {
    echo "Expected second backup to contain 'second original'"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Target is a regular file — identical content
# ---------------------------------------------------------------------------

@test "symlink_config: replaces existing identical regular file with symlink (no FORCE_MODE needed)" {
  echo "same content" > "${SUBJECT_FILE}"
  echo "same content" > "${TARGET_FILE}"

  run "${DOTFILES_BIN}/symlink_config" "${SUBJECT_FILE}" "${TARGET_FILE}"
  [ "${status}" -eq 0 ]

  [ -L "${TARGET_FILE}" ] || {
    echo "Expected ${TARGET_FILE} to be a symlink after replacing identical file"
    return 1
  }
  link_dest="$(readlink "${TARGET_FILE}")"
  [ "${link_dest}" = "${SUBJECT_FILE}" ] || {
    echo "Expected symlink to point to ${SUBJECT_FILE} but got ${link_dest}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Subject is a directory
# ---------------------------------------------------------------------------

@test "symlink_config: works when subject is a directory" {
  subject_dir="${TEST_TMPDIR}/subject_dir"
  target_dir="${TEST_TMPDIR}/target_dir"
  mkdir -p "${subject_dir}"
  echo "file inside" > "${subject_dir}/inner.txt"

  run "${DOTFILES_BIN}/symlink_config" "${subject_dir}" "${target_dir}"
  [ "${status}" -eq 0 ]

  [ -L "${target_dir}" ] || {
    echo "Expected ${target_dir} to be a symlink"
    return 1
  }
  link_dest="$(readlink "${target_dir}")"
  [ "${link_dest}" = "${subject_dir}" ] || {
    echo "Expected symlink to point to ${subject_dir} but got ${link_dest}"
    return 1
  }
}
