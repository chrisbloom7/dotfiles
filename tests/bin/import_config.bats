bats_require_minimum_version 1.5.0

load "../test_helper"

TOOL_NAME="tool"

setup() {
  _setup_common
  export HOME="${TEST_TMPDIR}/home"
  export DOTFILES_CONFIGS="${TEST_TMPDIR}/configs"
  CONFIG_DIR="${DOTFILES_CONFIGS}/${TOOL_NAME}"
  mkdir -p "${HOME}" "${DOTFILES_CONFIGS}"

  # Mock fzf: outputs the input line that exactly matches FZF_MOCK_SELECTION,
  # or exits 1 to simulate the user cancelling.
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
  _teardown_common
}

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

@test "import_config: fails when no arguments are given" {
  run "${DOTFILES_BIN}/import_config"
  [ "${status}" -ne 0 ]
}

@test "import_config: fails when a tool is given without paths" {
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}"
  [ "${status}" -ne 0 ]
}

@test "import_config: fails when a path does not exist" {
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${HOME}/.missingrc"
  [ "${status}" -ne 0 ]
  [ ! -d "${CONFIG_DIR}" ] || { echo "Expected no config folder to be created"; return 1; }
}

@test "import_config: fails when a path is outside \$HOME" {
  echo "content" > "${TEST_TMPDIR}/outside.conf"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${TEST_TMPDIR}/outside.conf"
  [ "${status}" -ne 0 ]
  [ -f "${TEST_TMPDIR}/outside.conf" ] && [ ! -L "${TEST_TMPDIR}/outside.conf" ]
}

# ---------------------------------------------------------------------------
# Happy path
# ---------------------------------------------------------------------------

@test "import_config: moves a top-level file into the tool folder and links it back" {
  echo "content" > "${HOME}/.toolrc"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${HOME}/.toolrc"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/.toolrc" ] && [ ! -L "${CONFIG_DIR}/.toolrc" ] || {
    echo "Expected ${CONFIG_DIR}/.toolrc to be a regular file"
    return 1
  }
  [ "$(readlink "${HOME}/.toolrc")" = "${CONFIG_DIR}/.toolrc" ]
}

@test "import_config: mirrors nested paths relative to \$HOME" {
  mkdir -p "${HOME}/.config/tool"
  echo "content" > "${HOME}/.config/tool/config.toml"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${HOME}/.config/tool/config.toml"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/.config/tool/config.toml" ] || {
    echo "Expected ${CONFIG_DIR}/.config/tool/config.toml to exist"
    return 1
  }
  [ "$(readlink "${HOME}/.config/tool/config.toml")" = "${CONFIG_DIR}/.config/tool/config.toml" ]
}

@test "import_config: accepts paths relative to the current directory" {
  echo "content" > "${HOME}/.toolrc"
  cd "${HOME}"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "./.toolrc"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/.toolrc" ]
}

@test "import_config: imports multiple paths at once" {
  echo "one" > "${HOME}/.arc"
  echo "two" > "${HOME}/.brc"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${HOME}/.arc" "${HOME}/.brc"
  [ "${status}" -eq 0 ]
  [ -L "${HOME}/.arc" ] && [ -L "${HOME}/.brc" ] || {
    echo "Expected both files to be linked"
    return 1
  }
}

@test "import_config: links the files of an imported directory individually" {
  mkdir -p "${HOME}/.toold"
  echo "content" > "${HOME}/.toold/a.cfg"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${HOME}/.toold"
  [ "${status}" -eq 0 ]
  [ -d "${HOME}/.toold" ] && [ ! -L "${HOME}/.toold" ] || {
    echo "Expected ${HOME}/.toold to be a real directory"
    return 1
  }
  [ "$(readlink "${HOME}/.toold/a.cfg")" = "${CONFIG_DIR}/.toold/a.cfg" ]
}

# ---------------------------------------------------------------------------
# Already managed
# ---------------------------------------------------------------------------

@test "import_config: skips a file already in the tool folder" {
  mkdir -p "${CONFIG_DIR}"
  echo "existing" > "${CONFIG_DIR}/.toolrc"
  echo "local" > "${HOME}/.toolrc"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${HOME}/.toolrc"
  [ "${status}" -eq 0 ]
  [ "$(cat "${CONFIG_DIR}/.toolrc")" = "existing" ] || {
    echo "Expected the repo copy to be unchanged"
    return 1
  }
  [ "$(cat "${HOME}/.toolrc")" = "local" ] && [ ! -L "${HOME}/.toolrc" ] || {
    echo "Expected the local file to be left in place"
    return 1
  }
}

@test "import_config: skips a path that already links into configs" {
  mkdir -p "${DOTFILES_CONFIGS}/other"
  echo "content" > "${DOTFILES_CONFIGS}/other/.toolrc"
  ln -s "${DOTFILES_CONFIGS}/other/.toolrc" "${HOME}/.toolrc"
  run "${DOTFILES_BIN}/import_config" "${TOOL_NAME}" "${HOME}/.toolrc"
  [ "${status}" -eq 0 ]
  [ ! -e "${CONFIG_DIR}/.toolrc" ] || { echo "Expected nothing to be moved"; return 1; }
  [ "$(readlink "${HOME}/.toolrc")" = "${DOTFILES_CONFIGS}/other/.toolrc" ]
}

# ---------------------------------------------------------------------------
# Interactive tool selection
# ---------------------------------------------------------------------------

@test "import_config: treats a first argument containing / as a path and prompts for the tool" {
  mkdir -p "${CONFIG_DIR}"
  echo "content" > "${HOME}/.toolrc"
  FZF_MOCK_SELECTION="${TOOL_NAME}" run "${DOTFILES_BIN}/import_config" "${HOME}/.toolrc"
  [ "${status}" -eq 0 ]
  [ -f "${CONFIG_DIR}/.toolrc" ] || { echo "Expected file in selected tool folder"; return 1; }
}

@test "import_config: creates a new tool folder chosen interactively" {
  echo "content" > "${HOME}/.newrc"
  FZF_MOCK_SELECTION="[New config folder]" run "${DOTFILES_BIN}/import_config" "${HOME}/.newrc" <<< "newtool"
  [ "${status}" -eq 0 ]
  [ -f "${DOTFILES_CONFIGS}/newtool/.newrc" ] || { echo "Expected file in new tool folder"; return 1; }
}

@test "import_config: fails and moves nothing when selection is cancelled" {
  echo "content" > "${HOME}/.toolrc"
  run "${DOTFILES_BIN}/import_config" "${HOME}/.toolrc"
  [ "${status}" -ne 0 ]
  [ -f "${HOME}/.toolrc" ] && [ ! -L "${HOME}/.toolrc" ]
}
