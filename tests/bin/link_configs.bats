bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
  export HOME="${TEST_TMPDIR}/home"
  export DOTFILES_CONFIGS="${TEST_TMPDIR}/configs"
  mkdir -p "${HOME}" "${DOTFILES_CONFIGS}/tool"
}

teardown() {
  _teardown_common
}

# ---------------------------------------------------------------------------
# Mirrored layout
# ---------------------------------------------------------------------------

@test "link_configs: links a top-level file into \$HOME" {
  echo "content" > "${DOTFILES_CONFIGS}/tool/.toolrc"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ "$(readlink "${HOME}/.toolrc")" = "${DOTFILES_CONFIGS}/tool/.toolrc" ] || {
    echo "Expected ${HOME}/.toolrc to link to the config file; got: $(readlink "${HOME}/.toolrc")"
    return 1
  }
}

@test "link_configs: creates parent directories for nested files" {
  mkdir -p "${DOTFILES_CONFIGS}/tool/.config/tool"
  echo "content" > "${DOTFILES_CONFIGS}/tool/.config/tool/config.toml"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ -d "${HOME}/.config/tool" ] && [ ! -L "${HOME}/.config/tool" ] || {
    echo "Expected ${HOME}/.config/tool to be a real directory"
    return 1
  }
  [ "$(readlink "${HOME}/.config/tool/config.toml")" = "${DOTFILES_CONFIGS}/tool/.config/tool/config.toml" ]
}

@test "link_configs: only links the tools named as arguments" {
  mkdir -p "${DOTFILES_CONFIGS}/other"
  echo "content" > "${DOTFILES_CONFIGS}/tool/.toolrc"
  echo "content" > "${DOTFILES_CONFIGS}/other/.otherrc"
  run "${DOTFILES_BIN}/link_configs" tool
  [ "${status}" -eq 0 ]
  [ -L "${HOME}/.toolrc" ] || { echo "Expected .toolrc to be linked"; return 1; }
  [ ! -e "${HOME}/.otherrc" ] || { echo "Expected .otherrc not to be linked"; return 1; }
}

@test "link_configs: fails when a named tool does not exist" {
  run "${DOTFILES_BIN}/link_configs" missing
  [ "${status}" -ne 0 ]
}

@test "link_configs: does not link README.md, hooks, or .DS_Store" {
  mkdir -p "${DOTFILES_CONFIGS}/tool/hooks" "${DOTFILES_CONFIGS}/tool/.config"
  echo "docs" > "${DOTFILES_CONFIGS}/tool/README.md"
  echo "junk" > "${DOTFILES_CONFIGS}/tool/.DS_Store"
  echo "junk" > "${DOTFILES_CONFIGS}/tool/.config/.DS_Store"
  printf '#!/usr/bin/env bash\n' > "${DOTFILES_CONFIGS}/tool/hooks/post-link"
  chmod +x "${DOTFILES_CONFIGS}/tool/hooks/post-link"

  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  for path in README.md .DS_Store .config/.DS_Store hooks; do
    [ ! -e "${HOME}/${path}" ] || { echo "Expected ${path} not to be linked"; return 1; }
  done
}

# ---------------------------------------------------------------------------
# Templates
# ---------------------------------------------------------------------------

@test "link_configs: copies .template files without the suffix" {
  echo "template" > "${DOTFILES_CONFIGS}/tool/config.json.template"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ -f "${HOME}/config.json" ] && [ ! -L "${HOME}/config.json" ] || {
    echo "Expected ${HOME}/config.json to be a regular file"
    return 1
  }
  [ "$(cat "${HOME}/config.json")" = "template" ]
  [ ! -e "${HOME}/config.json.template" ]
}

@test "link_configs: does not overwrite an existing file with a template" {
  echo "template" > "${DOTFILES_CONFIGS}/tool/config.json.template"
  echo "local" > "${HOME}/config.json"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ "$(cat "${HOME}/config.json")" = "local" ]
}

@test "link_configs: copies every template even when an earlier one is skipped" {
  echo "template a" > "${DOTFILES_CONFIGS}/tool/a.json.template"
  echo "template b" > "${DOTFILES_CONFIGS}/tool/b.json.template"
  echo "local" > "${HOME}/a.json"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ "$(cat "${HOME}/b.json")" = "template b" ] || {
    echo "Expected b.json to be copied after a.json was skipped"
    return 1
  }
}

@test "link_configs: replaces a symlink with a copy of the template" {
  echo "template" > "${DOTFILES_CONFIGS}/tool/config.json.template"
  ln -s "${DOTFILES_CONFIGS}/tool/config.json.template" "${HOME}/config.json"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ ! -L "${HOME}/config.json" ] || { echo "Expected the symlink to be replaced"; return 1; }
  [ "$(cat "${HOME}/config.json")" = "template" ]
}

# ---------------------------------------------------------------------------
# Hooks
# ---------------------------------------------------------------------------

@test "link_configs: runs an executable hooks/post-link after linking" {
  mkdir -p "${DOTFILES_CONFIGS}/tool/hooks"
  echo "content" > "${DOTFILES_CONFIGS}/tool/.toolrc"
  cat > "${DOTFILES_CONFIGS}/tool/hooks/post-link" <<'EOF'
#!/usr/bin/env bash
[[ -L "${HOME}/.toolrc" ]] && touch "${HOME}/hook-ran"
EOF
  chmod +x "${DOTFILES_CONFIGS}/tool/hooks/post-link"

  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ -f "${HOME}/hook-ran" ] || { echo "Expected post-link hook to run after linking"; return 1; }
}

# ---------------------------------------------------------------------------
# Directory symlinks from the old whole-directory layout
# ---------------------------------------------------------------------------

@test "link_configs: replaces a directory symlink into configs with per-file links" {
  mkdir -p "${DOTFILES_CONFIGS}/tool/.toold"
  echo "content" > "${DOTFILES_CONFIGS}/tool/.toold/a.cfg"
  ln -s "${DOTFILES_CONFIGS}/tool/.toold" "${HOME}/.toold"

  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ -d "${HOME}/.toold" ] && [ ! -L "${HOME}/.toold" ] || {
    echo "Expected ${HOME}/.toold to become a real directory"
    return 1
  }
  [ -L "${HOME}/.toold/a.cfg" ] || { echo "Expected a.cfg to be linked"; return 1; }
  [ -f "${DOTFILES_CONFIGS}/tool/.toold/a.cfg" ] && [ ! -L "${DOTFILES_CONFIGS}/tool/.toold/a.cfg" ] || {
    echo "Expected the source file to remain intact"
    return 1
  }
}

# ---------------------------------------------------------------------------
# Pruning stale links
# ---------------------------------------------------------------------------

@test "link_configs: removes broken links into configs from linked directories" {
  echo "content" > "${DOTFILES_CONFIGS}/tool/.toolrc"
  ln -s "${DOTFILES_CONFIGS}/tool/.removedrc" "${HOME}/.removedrc"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ ! -L "${HOME}/.removedrc" ] || { echo "Expected stale link to be removed"; return 1; }
}

@test "link_configs: leaves broken links that point outside configs" {
  echo "content" > "${DOTFILES_CONFIGS}/tool/.toolrc"
  ln -s "${TEST_TMPDIR}/elsewhere" "${HOME}/.foreignrc"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ -L "${HOME}/.foreignrc" ] || { echo "Expected foreign broken link to be kept"; return 1; }
}

@test "link_configs: leaves stale links in directories it did not link into" {
  echo "content" > "${DOTFILES_CONFIGS}/tool/.toolrc"
  mkdir -p "${HOME}/.untouched"
  ln -s "${DOTFILES_CONFIGS}/gone/file" "${HOME}/.untouched/file"
  run "${DOTFILES_BIN}/link_configs"
  [ "${status}" -eq 0 ]
  [ -L "${HOME}/.untouched/file" ] || { echo "Expected link outside linked dirs to be kept"; return 1; }
}
