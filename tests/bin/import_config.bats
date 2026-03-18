bats_require_minimum_version 1.5.0

load "../test_helper"

TOOL_NAME="_bats_import_test"

setup() {
  _setup_common
  SOURCE_DIR="${HOME}/.${TOOL_NAME}"
  CONFIG_DIR="${DOTFILES_ROOT}/configs/${TOOL_NAME}"
  SYMLINK_SCRIPT="${CONFIG_DIR}/symlink_${TOOL_NAME}"
  mkdir -p "${SOURCE_DIR}"
}

teardown() {
  rm -rf "${DOTFILES_ROOT}/configs/${TOOL_NAME}"
  rm -rf "${HOME}/.${TOOL_NAME}"
  _teardown_common
}

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

@test "import_config: fails when tool name is missing" {
  run "${DOTFILES_BIN}/import_config"
  [ "${status}" -ne 0 ]
}

@test "import_config: fails when source_dir is missing" {
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}"
  [ "${status}" -ne 0 ]
}

@test "import_config: fails when no files are given" {
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}"
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Source file not found
# ---------------------------------------------------------------------------

@test "import_config: skips and exits 0 when source file does not exist" {
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "nonexistent.txt"
  [ "${status}" -eq 0 ]
  [ ! -f "${CONFIG_DIR}/nonexistent.txt" ] || {
    echo "Expected config file not to be created for missing source"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Happy path — single file
# ---------------------------------------------------------------------------

@test "import_config: moves file from source dir into config dir" {
  echo "content" > "${SOURCE_DIR}/test.conf"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "test.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/test.conf" ] || {
    echo "Expected ${CONFIG_DIR}/test.conf to exist after import"
    return 1
  }
}

@test "import_config: creates symlink at target pointing to config dir file" {
  echo "content" > "${SOURCE_DIR}/test.conf"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "test.conf"
  [ "${status}" -eq 0 ]
  [ -L "${SOURCE_DIR}/test.conf" ] || {
    echo "Expected ${SOURCE_DIR}/test.conf to be a symlink after import"
    return 1
  }
  link_dest="$(readlink "${SOURCE_DIR}/test.conf")"
  [ "${link_dest}" = "${CONFIG_DIR}/test.conf" ] || {
    echo "Expected symlink to point to ${CONFIG_DIR}/test.conf but got ${link_dest}"
    return 1
  }
}

@test "import_config: generates an executable symlink script" {
  echo "content" > "${SOURCE_DIR}/test.conf"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "test.conf"
  [ "${status}" -eq 0 ]
  [ -x "${SYMLINK_SCRIPT}" ] || {
    echo "Expected ${SYMLINK_SCRIPT} to exist and be executable"
    return 1
  }
}

@test "import_config: generated symlink script uses \${HOME} variable not a hardcoded path" {
  echo "content" > "${SOURCE_DIR}/test.conf"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "test.conf"
  [ "${status}" -eq 0 ]
  grep -q '${HOME}' "${SYMLINK_SCRIPT}" || {
    echo "Expected symlink script to reference \${HOME}"
    return 1
  }
  # The literal home path must not appear in the script
  ! grep -qF "${HOME}" "${SYMLINK_SCRIPT}" || {
    echo "Expected symlink script NOT to contain hardcoded path ${HOME}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Happy path — multiple files
# ---------------------------------------------------------------------------

@test "import_config: moves all files and creates symlinks for multiple files" {
  echo "one" > "${SOURCE_DIR}/a.conf"
  echo "two" > "${SOURCE_DIR}/b.conf"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "a.conf" "b.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/a.conf" ] || { echo "Expected a.conf in config dir"; return 1; }
  [ -f "${CONFIG_DIR}/b.conf" ] || { echo "Expected b.conf in config dir"; return 1; }
  [ -L "${SOURCE_DIR}/a.conf" ] || { echo "Expected a.conf symlink at target"; return 1; }
  [ -L "${SOURCE_DIR}/b.conf" ] || { echo "Expected b.conf symlink at target"; return 1; }
}

# ---------------------------------------------------------------------------
# File already in config dir
# ---------------------------------------------------------------------------

@test "import_config: skips move when file already exists in config dir" {
  echo "source content" > "${SOURCE_DIR}/test.conf"
  mkdir -p "${CONFIG_DIR}"
  echo "existing content" > "${CONFIG_DIR}/test.conf"

  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "test.conf"
  [ "${status}" -eq 0 ]

  # Source file must remain untouched (not moved)
  [ -f "${SOURCE_DIR}/test.conf" ] || {
    echo "Expected source file to remain since config dir already had the file"
    return 1
  }
  # Config dir file must be unchanged
  [ "$(cat "${CONFIG_DIR}/test.conf")" = "existing content" ] || {
    echo "Expected config dir file content to be unchanged"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Symlink script already exists
# ---------------------------------------------------------------------------

@test "import_config: does not overwrite existing symlink script" {
  echo "content" > "${SOURCE_DIR}/test.conf"
  mkdir -p "${CONFIG_DIR}"
  cp "${SOURCE_DIR}/test.conf" "${CONFIG_DIR}/test.conf"

  # Pre-create a symlink script with a known sentinel
  printf '#!/usr/bin/env bash\n# sentinel\n' > "${SYMLINK_SCRIPT}"
  chmod +x "${SYMLINK_SCRIPT}"

  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "test.conf"
  [ "${status}" -eq 0 ]

  grep -q '# sentinel' "${SYMLINK_SCRIPT}" || {
    echo "Expected existing symlink script content to be preserved"
    return 1
  }
}

# ---------------------------------------------------------------------------
# File with subdirectory path
# ---------------------------------------------------------------------------

@test "import_config: handles nested file paths by creating subdirectory in config dir" {
  mkdir -p "${SOURCE_DIR}/subdir"
  echo "content" > "${SOURCE_DIR}/subdir/nested.conf"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${SOURCE_DIR}" "subdir/nested.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/subdir/nested.conf" ] || {
    echo "Expected ${CONFIG_DIR}/subdir/nested.conf to exist"
    return 1
  }
  [ -L "${SOURCE_DIR}/subdir/nested.conf" ] || {
    echo "Expected ${SOURCE_DIR}/subdir/nested.conf to be a symlink"
    return 1
  }
}
