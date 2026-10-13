bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
  MACKUP_BIN="$(command -v mackup)" || skip "mackup is not installed"
  export MACKUP_PYTHON="$(head -1 "${MACKUP_BIN}" | sed -n 's/^#!//p')"

  export HOME="${TEST_TMPDIR}/home"
  export DOTFILES_CONFIGS="${TEST_TMPDIR}/configs"
  unset XDG_CONFIG_HOME
  STORAGE="${TEST_TMPDIR}/storage/Mackup"
  mkdir -p "${HOME}/.mackup" "${DOTFILES_CONFIGS}" "${STORAGE}"

  # A custom app safe to link, and one that must be copied
  _app linkapp .linkrc
  _app copyapp Library/Preferences/com.example.copyapp.plist
  echo "link" > "${HOME}/.linkrc"
  mkdir -p "${HOME}/Library/Preferences"
  echo "copy" > "${HOME}/Library/Preferences/com.example.copyapp.plist"

  _write_cfgs copyapp copyapp
}

teardown() {
  _teardown_common
}

# Writes a custom Mackup app named $1 covering the files $2+
_app() {
  local name="$1"
  shift
  {
    printf '[application]\nname = %s\n\n[configuration_files]\n' "${name}"
    printf '%s\n' "$@"
  } > "${HOME}/.mackup/${name}.cfg"
}

# Writes ~/.mackup.cfg ignoring "mackup" plus the space-separated apps in $1,
# and ~/.mackup-copy.cfg syncing the space-separated apps in $2
_write_cfgs() {
  local storage="[storage]
engine = file_system
path = ${TEST_TMPDIR}/storage
directory = Mackup"
  printf '%s\n\n[applications_to_ignore]\nmackup\n' "${storage}" > "${HOME}/.mackup.cfg"
  printf '%s\n' $1 >> "${HOME}/.mackup.cfg"
  printf '%s\n\n[applications_to_sync]\n' "${storage}" > "${HOME}/.mackup-copy.cfg"
  printf '%s\n' $2 >> "${HOME}/.mackup-copy.cfg"
}

# ---------------------------------------------------------------------------
# Passing configs
# ---------------------------------------------------------------------------

@test "mackup_audit: passes when the configs are consistent" {
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
}

@test "mackup_audit: fails on unknown options" {
  run "${DOTFILES_BIN}/mackup_audit" --bogus
  [ "${status}" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------

@test "mackup_audit: fails when the configured storage folder is missing" {
  rm -rf "${STORAGE}"
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"${STORAGE} not found"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_audit: fails when the configs use different storage folders" {
  sed -i '' 's/^directory = Mackup$/directory = Other/' "${HOME}/.mackup-copy.cfg"
  mkdir -p "${TEST_TMPDIR}/storage/Other"
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"different storage folders"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_audit: fails when a config file is missing" {
  rm "${HOME}/.mackup-copy.cfg"
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
}

@test "mackup_audit: --storage-only ignores problems other than storage" {
  _write_cfgs "" copyapp
  run "${DOTFILES_BIN}/mackup_audit" --storage-only
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
}

# ---------------------------------------------------------------------------
# App lists
# ---------------------------------------------------------------------------

@test "mackup_audit: fails when a config names an unknown app" {
  _write_cfgs "copyapp nosuchapp" copyapp
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"unknown app 'nosuchapp'"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_audit: fails when an app is in both link and copy mode" {
  _write_cfgs "copyapp" "copyapp linkapp"
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"'linkapp' is in both link and copy mode"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_audit: fails when a link-mode app has files macOS can't symlink" {
  _write_cfgs "" ""
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"'copyapp' can't be linked"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_audit: ignores apps with no files in \$HOME or storage" {
  _app absentapp Library/Preferences/com.example.absent.plist
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
}

@test "mackup_audit: fails when a synced app covers a file linked from configs/" {
  mkdir -p "${DOTFILES_CONFIGS}/tool"
  echo "repo" > "${DOTFILES_CONFIGS}/tool/.linkrc"
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"'linkapp' covers ~/.linkrc"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_audit: fails when a synced app's files contain a broken symlink" {
  _app dirapp .dirapp
  mkdir -p "${HOME}/.dirapp"
  ln -s "${TEST_TMPDIR}/missing" "${HOME}/.dirapp/config"
  run "${DOTFILES_BIN}/mackup_audit"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *".dirapp/config is a broken symlink"* ]] || { echo "${output}"; return 1; }
}

# ---------------------------------------------------------------------------
# --links
# ---------------------------------------------------------------------------

@test "mackup_audit: --links reports link-mode files that aren't linked" {
  run "${DOTFILES_BIN}/mackup_audit" --links
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"~/.linkrc is not linked"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_audit: --links passes when link-mode files are linked" {
  mv "${HOME}/.linkrc" "${STORAGE}/.linkrc"
  ln -s "${STORAGE}/.linkrc" "${HOME}/.linkrc"
  run "${DOTFILES_BIN}/mackup_audit" --links
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
}
