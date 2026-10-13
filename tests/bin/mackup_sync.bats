bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
  MACKUP_BIN="$(command -v mackup)" || skip "mackup is not installed"
  # mackup_audit runs for real against mackup's Python; only the CLI is mocked
  export MACKUP_PYTHON="$(head -1 "${MACKUP_BIN}" | sed -n 's/^#!//p')"

  export HOME="${TEST_TMPDIR}/home"
  export DOTFILES_CONFIGS="${TEST_TMPDIR}/configs"
  unset XDG_CONFIG_HOME
  STORAGE="${TEST_TMPDIR}/storage/Mackup"
  mkdir -p "${HOME}/.mackup" "${DOTFILES_CONFIGS}" "${STORAGE}"

  local storage="[storage]
engine = file_system
path = ${TEST_TMPDIR}/storage
directory = Mackup"
  printf '%s\n\n[applications_to_ignore]\nmackup\ncopyapp\n' "${storage}" > "${HOME}/.mackup.cfg"
  printf '%s\n\n[applications_to_sync]\ncopyapp\n' "${storage}" > "${HOME}/.mackup-copy.cfg"
  printf '[application]\nname = copyapp\n\n[configuration_files]\n.copyapprc\n' > "${HOME}/.mackup/copyapp.cfg"

  # Mock mackup: records each invocation's arguments, one line per call
  MACKUP_LOG="${TEST_TMPDIR}/mackup.log"
  cat > "${TEST_TMPDIR}/mock_bin/mackup" <<EOF
#!/usr/bin/env bash
echo "\$*" >> "${MACKUP_LOG}"
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/mackup"
}

teardown() {
  _teardown_common
}

calls() {
  cat "${MACKUP_LOG}" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------

@test "mackup_sync: fails without a command" {
  run "${DOTFILES_BIN}/mackup_sync"
  [ "${status}" -ne 0 ]
}

@test "mackup_sync: fails on an unknown argument" {
  run "${DOTFILES_BIN}/mackup_sync" bogus
  [ "${status}" -ne 0 ]
}

@test "mackup_sync: fails when given two commands" {
  run "${DOTFILES_BIN}/mackup_sync" backup restore
  [ "${status}" -ne 0 ]
  [ -z "$(calls)" ]
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

@test "mackup_sync: install links with the link config, then backs up with the copy config" {
  run "${DOTFILES_BIN}/mackup_sync" install
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  expected="--config-file=${HOME}/.mackup.cfg link install
--config-file=${HOME}/.mackup-copy.cfg backup"
  [ "$(calls)" = "${expected}" ] || { echo "Got:"; calls; return 1; }
}

@test "mackup_sync: restore restores with the copy config, then links with the link config" {
  run "${DOTFILES_BIN}/mackup_sync" restore
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  expected="--config-file=${HOME}/.mackup-copy.cfg restore
--config-file=${HOME}/.mackup.cfg link"
  [ "$(calls)" = "${expected}" ] || { echo "Got:"; calls; return 1; }
}

@test "mackup_sync: backup only backs up with the copy config" {
  run "${DOTFILES_BIN}/mackup_sync" backup
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  [ "$(calls)" = "--config-file=${HOME}/.mackup-copy.cfg backup" ] || { echo "Got:"; calls; return 1; }
}

@test "mackup_sync: passes --dry-run and --force through to mackup" {
  run "${DOTFILES_BIN}/mackup_sync" -n --force backup
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  [ "$(calls)" = "--config-file=${HOME}/.mackup-copy.cfg --dry-run --force backup" ] || { echo "Got:"; calls; return 1; }
}

@test "mackup_sync: check runs the audit without calling mackup" {
  run "${DOTFILES_BIN}/mackup_sync" check
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  [ -z "$(calls)" ]
}

# ---------------------------------------------------------------------------
# Audit failures
# ---------------------------------------------------------------------------

@test "mackup_sync: refuses every command when the storage folder is missing" {
  rm -rf "${STORAGE}"
  for cmd in install restore backup; do
    run "${DOTFILES_BIN}/mackup_sync" "${cmd}"
    [ "${status}" -ne 0 ] || { echo "${cmd} succeeded without storage"; return 1; }
  done
  [ -z "$(calls)" ] || { echo "Expected no mackup calls; got:"; calls; return 1; }
}

@test "mackup_sync: install and restore refuse when the audit fails" {
  printf '[application]\nname = badapp\n\n[configuration_files]\nLibrary/Preferences/bad.plist\n' > "${HOME}/.mackup/badapp.cfg"
  mkdir -p "${HOME}/Library/Preferences"
  echo "x" > "${HOME}/Library/Preferences/bad.plist"
  for cmd in install restore; do
    run "${DOTFILES_BIN}/mackup_sync" "${cmd}"
    [ "${status}" -ne 0 ] || { echo "${cmd} succeeded despite audit failure"; return 1; }
  done
  [ -z "$(calls)" ] || { echo "Expected no mackup calls; got:"; calls; return 1; }
}

@test "mackup_sync: backup still runs when only non-storage checks fail" {
  printf '[application]\nname = badapp\n\n[configuration_files]\nLibrary/Preferences/bad.plist\n' > "${HOME}/.mackup/badapp.cfg"
  mkdir -p "${HOME}/Library/Preferences"
  echo "x" > "${HOME}/Library/Preferences/bad.plist"
  run "${DOTFILES_BIN}/mackup_sync" backup
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  [ "$(calls)" = "--config-file=${HOME}/.mackup-copy.cfg backup" ]
}
