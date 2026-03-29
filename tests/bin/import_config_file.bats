bats_require_minimum_version 1.5.0

load "../test_helper"

TOOL_NAME="_bats_import_file_test"
NEW_TOOL_NAME="_bats_import_file_new"

setup() {
  _setup_common
  SOURCE_DIR="${HOME}/.${TOOL_NAME}"
  CONFIG_DIR="${DOTFILES_ROOT}/configs/${TOOL_NAME}"
  SYMLINK_SCRIPT="${CONFIG_DIR}/symlink_${TOOL_NAME}"
  mkdir -p "${SOURCE_DIR}"
  mkdir -p "${CONFIG_DIR}"

  # Seed a pre-existing file and a standard-format symlink script
  echo "existing content" > "${CONFIG_DIR}/existing.conf"
  _write_symlink_script "${SYMLINK_SCRIPT}" "${TOOL_NAME}" "existing.conf"

  # Mock fzf: reads its input list from stdin, outputs the line that exactly
  # matches FZF_MOCK_SELECTION, then exits 0. If no match (or the env var is
  # unset), exits 1 — simulating the user pressing Escape to cancel.
  cat > "${TEST_TMPDIR}/mock_bin/fzf" <<'EOF'
#!/usr/bin/env bash
while IFS= read -r line; do
  [[ "${line}" == "${FZF_MOCK_SELECTION:-}" ]] && { echo "${line}"; exit 0; }
done
exit 1
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/fzf"
}

teardown() {
  rm -rf "${DOTFILES_ROOT}/configs/${TOOL_NAME}"
  rm -rf "${DOTFILES_ROOT}/configs/${NEW_TOOL_NAME}"
  rm -rf "${HOME}/.${TOOL_NAME}"
  rm -rf "${HOME}/.${NEW_TOOL_NAME}"
  _teardown_common
}

# Write a standard generated symlink_<tool> script into $1 for tool $2
# listing any additional file entries passed as $3+.
_write_symlink_script() {
  local script_path="$1" tool="$2"
  shift 2
  local files=("$@")

  cat > "${script_path}" <<SCRIPT
#!/usr/bin/env bash
cd "\$(dirname "\$0")"
source ../../scripts/helpers/runtime.sh
source ../../bin/helpers/trap_and_trace.sh

log_info "Symlinking ${tool} configs"

TARGET="\${HOME}/.${tool}"
mkdir -p "\${TARGET}"
clean_broken_symlinks "\${TARGET}"

configs=(
$(printf "  \"%s\"\n" "${files[@]}")
)
for config in "\${configs[@]}"; do
  mkdir -p "\$(dirname "\${TARGET}/\${config}")"
  symlink_config "\${PWD}/\${config}" "\${TARGET}/\${config}"
done
SCRIPT
  chmod +x "${script_path}"
}

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

@test "import_config_file: fails when no arguments given" {
  run "${DOTFILES_BIN}/import_config_file"
  [ "${status}" -ne 0 ]
}

@test "import_config_file: fails when tool given but source file is missing" {
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}"
  [ "${status}" -ne 0 ]
}

@test "import_config_file: fails when source file does not exist (tool + path form)" {
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/nonexistent.conf"
  [ "${status}" -ne 0 ]
}

@test "import_config_file: fails when source file does not exist (path-only form)" {
  run "${DOTFILES_BIN}/import_config_file" "${SOURCE_DIR}/nonexistent.conf"
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Symlink script must exist (config dir exists but script is missing)
# ---------------------------------------------------------------------------

@test "import_config_file: fails when symlink script does not exist" {
  rm "${SYMLINK_SCRIPT}"
  echo "content" > "${SOURCE_DIR}/new.conf"
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# New config folder — confirmation prompt
# ---------------------------------------------------------------------------

@test "import_config_file: aborts without creating dir when user declines" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run bash -c "printf 'n\n' | '${DOTFILES_BIN}/import_config_file' '${NEW_TOOL_NAME}' '${SOURCE_DIR}/new.conf'"
  [ "${status}" -eq 0 ]
  [ ! -d "${DOTFILES_ROOT}/configs/${NEW_TOOL_NAME}" ] || {
    echo "Expected no config dir to be created after declining"
    return 1
  }
}

@test "import_config_file: creates config dir when user confirms" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run bash -c "printf 'y\n' | '${DOTFILES_BIN}/import_config_file' '${NEW_TOOL_NAME}' '${SOURCE_DIR}/new.conf'"
  [ "${status}" -eq 0 ]
  [ -d "${DOTFILES_ROOT}/configs/${NEW_TOOL_NAME}" ] || {
    echo "Expected config dir to be created after confirming"
    return 1
  }
}

@test "import_config_file: generates executable symlink script for new config dir" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run bash -c "printf 'y\n' | '${DOTFILES_BIN}/import_config_file' '${NEW_TOOL_NAME}' '${SOURCE_DIR}/new.conf'"
  [ "${status}" -eq 0 ]
  [ -x "${DOTFILES_ROOT}/configs/${NEW_TOOL_NAME}/symlink_${NEW_TOOL_NAME}" ] || {
    echo "Expected executable symlink script to be generated"
    return 1
  }
}

@test "import_config_file: generated script uses \${HOME} not a hardcoded path" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run bash -c "printf 'y\n' | '${DOTFILES_BIN}/import_config_file' '${NEW_TOOL_NAME}' '${SOURCE_DIR}/new.conf'"
  [ "${status}" -eq 0 ]
  local script="${DOTFILES_ROOT}/configs/${NEW_TOOL_NAME}/symlink_${NEW_TOOL_NAME}"
  grep -q '${HOME}' "${script}" || {
    echo "Expected \${HOME} in generated script"
    return 1
  }
  ! grep -qF "${HOME}" "${script}" || {
    echo "Expected generated script NOT to contain hardcoded path ${HOME}"
    return 1
  }
}

@test "import_config_file: moves file and creates symlink when confirming new dir" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run bash -c "printf 'y\n' | '${DOTFILES_BIN}/import_config_file' '${NEW_TOOL_NAME}' '${SOURCE_DIR}/new.conf'"
  [ "${status}" -eq 0 ]
  [ -f "${DOTFILES_ROOT}/configs/${NEW_TOOL_NAME}/new.conf" ] || {
    echo "Expected file in new config dir"
    return 1
  }
  [ -L "${SOURCE_DIR}/new.conf" ] || {
    echo "Expected symlink created at original source location"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Interactive tool selection via fzf (source file as first argument)
# Tests use a mock fzf (in mock_bin) controlled by FZF_MOCK_SELECTION.
# ---------------------------------------------------------------------------

@test "import_config_file: selects an existing folder via fzf" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  FZF_MOCK_SELECTION="${TOOL_NAME}" \
    run "${DOTFILES_BIN}/import_config_file" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/new.conf" ] || {
    echo "Expected file in ${CONFIG_DIR} after fzf selection"
    return 1
  }
}

@test "import_config_file: creates symlink after interactive fzf selection" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  FZF_MOCK_SELECTION="${TOOL_NAME}" \
    run "${DOTFILES_BIN}/import_config_file" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  [ -L "${SOURCE_DIR}/new.conf" ] || {
    echo "Expected symlink at source location after fzf selection"
    return 1
  }
}

@test "import_config_file: choosing new folder then an existing name uses that existing folder" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  # fzf selects "[New config folder]"; stdin provides the conflicting tool name
  FZF_MOCK_SELECTION="[New config folder]" \
    run bash -c "printf '%s\n' '${TOOL_NAME}' | '${DOTFILES_BIN}/import_config_file' '${SOURCE_DIR}/new.conf'"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/new.conf" ] || {
    echo "Expected file in ${CONFIG_DIR} (existing folder) when a conflicting name is entered"
    return 1
  }
}

@test "import_config_file: choosing new folder and a fresh name creates that folder" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  # fzf selects "[New config folder]"; stdin provides new name then confirm "y"
  FZF_MOCK_SELECTION="[New config folder]" \
    run bash -c "printf '%s\ny\n' '${NEW_TOOL_NAME}' | '${DOTFILES_BIN}/import_config_file' '${SOURCE_DIR}/new.conf'"
  [ "${status}" -eq 0 ]
  [ -d "${DOTFILES_ROOT}/configs/${NEW_TOOL_NAME}" ] || {
    echo "Expected new config dir to be created via interactive fzf menu"
    return 1
  }
}

@test "import_config_file: fails when fzf is cancelled with no selection" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  # FZF_MOCK_SELECTION unset → mock fzf exits 1 (simulates Escape)
  run "${DOTFILES_BIN}/import_config_file" "${SOURCE_DIR}/new.conf"
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Happy path — tool and symlink script already exist
# ---------------------------------------------------------------------------

@test "import_config_file: moves file from source into config dir" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/new.conf" ] || {
    echo "Expected ${CONFIG_DIR}/new.conf to exist after import"
    return 1
  }
}

@test "import_config_file: creates symlink at source location pointing to config dir" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  [ -L "${SOURCE_DIR}/new.conf" ] || {
    echo "Expected ${SOURCE_DIR}/new.conf to be a symlink"
    return 1
  }
  link_dest="$(readlink "${SOURCE_DIR}/new.conf")"
  [ "${link_dest}" = "${CONFIG_DIR}/new.conf" ] || {
    echo "Expected symlink to point to ${CONFIG_DIR}/new.conf but got ${link_dest}"
    return 1
  }
}

@test "import_config_file: adds file to configs array in symlink script" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  grep -qF '"new.conf"' "${SYMLINK_SCRIPT}" || {
    echo "Expected new.conf to appear in ${SYMLINK_SCRIPT}"
    return 1
  }
}

@test "import_config_file: preserves existing entries in the configs array" {
  echo "content" > "${SOURCE_DIR}/new.conf"
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  grep -qF '"existing.conf"' "${SYMLINK_SCRIPT}" || {
    echo "Expected existing.conf to still appear in ${SYMLINK_SCRIPT}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Optional dest-name argument
# ---------------------------------------------------------------------------

@test "import_config_file: accepts an explicit dest-name" {
  echo "content" > "${SOURCE_DIR}/source.conf"
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/source.conf" "renamed.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/renamed.conf" ] || {
    echo "Expected file stored as renamed.conf in config dir"
    return 1
  }
  grep -qF '"renamed.conf"' "${SYMLINK_SCRIPT}" || {
    echo "Expected renamed.conf in symlink script"
    return 1
  }
}

@test "import_config_file: handles dest-name with subdirectory component" {
  mkdir -p "${SOURCE_DIR}/sub"
  echo "content" > "${SOURCE_DIR}/sub/nested.conf"
  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/sub/nested.conf" "sub/nested.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/sub/nested.conf" ] || {
    echo "Expected ${CONFIG_DIR}/sub/nested.conf to exist"
    return 1
  }
  grep -qF '"sub/nested.conf"' "${SYMLINK_SCRIPT}" || {
    echo "Expected sub/nested.conf in symlink script"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Idempotency / already-managed cases
# ---------------------------------------------------------------------------

@test "import_config_file: skips and exits 0 when dest already exists in config dir" {
  echo "managed content" > "${CONFIG_DIR}/new.conf"
  echo "source content" > "${SOURCE_DIR}/new.conf"

  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]

  [ -f "${SOURCE_DIR}/new.conf" ] || {
    echo "Expected source file to remain untouched when dest already exists"
    return 1
  }
  [ "$(cat "${CONFIG_DIR}/new.conf")" = "managed content" ] || {
    echo "Expected config dir file to be unchanged"
    return 1
  }
}

@test "import_config_file: skips array update when file already listed in script" {
  echo "content" > "${SOURCE_DIR}/existing.conf"
  # existing.conf is already in the script from setup; dest also already exists in config dir

  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/existing.conf"
  [ "${status}" -eq 0 ]

  count=$(grep -c '"existing.conf"' "${SYMLINK_SCRIPT}" || true)
  [ "${count}" -eq 1 ] || {
    echo "Expected exactly one 'existing.conf' entry in script; found ${count}"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Non-standard symlink script
# ---------------------------------------------------------------------------

@test "import_config_file: warns and still exits 0 when symlink script lacks configs array" {
  printf '#!/usr/bin/env bash\n# hand-written script, no configs=() array\n' > "${SYMLINK_SCRIPT}"
  chmod +x "${SYMLINK_SCRIPT}"
  echo "content" > "${SOURCE_DIR}/new.conf"

  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"does not use the standard configs=()"* ]] || {
    echo "Expected warning about non-standard script format; got: ${output}"
    return 1
  }
}

@test "import_config_file: still moves file even when symlink script lacks configs array" {
  printf '#!/usr/bin/env bash\n# hand-written script, no configs=() array\n' > "${SYMLINK_SCRIPT}"
  chmod +x "${SYMLINK_SCRIPT}"
  echo "content" > "${SOURCE_DIR}/new.conf"

  run "${DOTFILES_BIN}/import_config_file" "${TOOL_NAME}" "${SOURCE_DIR}/new.conf"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/new.conf" ] || {
    echo "Expected file to be moved even when script format is non-standard"
    return 1
  }
}
