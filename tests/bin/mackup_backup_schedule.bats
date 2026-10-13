bats_require_minimum_version 1.5.0

load "../test_helper"

LABEL="local.dotfiles.mackup-backup"

setup() {
  _setup_common
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
  PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"

  # Mock launchctl: records each invocation; `print` succeeds only when the
  # plist exists, standing in for "loaded"
  LAUNCHCTL_LOG="${TEST_TMPDIR}/launchctl.log"
  cat > "${TEST_TMPDIR}/mock_bin/launchctl" <<EOF
#!/usr/bin/env bash
echo "\$*" >> "${LAUNCHCTL_LOG}"
[[ "\$1" != "print" || -f "${PLIST}" ]]
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/launchctl"

  cat > "${TEST_TMPDIR}/mock_bin/mackup" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/mackup"
}

teardown() {
  _teardown_common
}

plist_value() {
  plutil -extract "$1" raw "${PLIST}"
}

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------

@test "mackup_backup_schedule: fails without a command" {
  run "${DOTFILES_BIN}/mackup_backup_schedule"
  [ "${status}" -ne 0 ]
}

@test "mackup_backup_schedule: fails on an unknown argument" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" bogus
  [ "${status}" -ne 0 ]
}

@test "mackup_backup_schedule: add rejects an out-of-range time without writing a plist" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" add --hour 24
  [ "${status}" -ne 0 ]
  [ ! -e "${PLIST}" ]
  run "${DOTFILES_BIN}/mackup_backup_schedule" add --weekday x
  [ "${status}" -ne 0 ]
  [ ! -e "${PLIST}" ]
}

# ---------------------------------------------------------------------------
# add
# ---------------------------------------------------------------------------

@test "mackup_backup_schedule: add writes a valid plist that runs mackup_sync backup --force" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" add
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  plutil -lint -s "${PLIST}"
  [ "$(plist_value Label)" = "${LABEL}" ]
  [ "$(plist_value ProgramArguments.0)" = "${DOTFILES_BIN}/mackup_sync" ]
  [ "$(plist_value ProgramArguments.1)" = "backup" ]
  [ "$(plist_value ProgramArguments.2)" = "--force" ]
  [[ "$(plist_value EnvironmentVariables.PATH)" == "${TEST_TMPDIR}/mock_bin:"* ]] || {
    echo "Expected PATH to start with mackup's directory; got $(plist_value EnvironmentVariables.PATH)"
    return 1
  }
}

@test "mackup_backup_schedule: add defaults to Sundays at noon" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" add
  [ "${status}" -eq 0 ]
  [ "$(plist_value StartCalendarInterval.Weekday)" = "0" ]
  [ "$(plist_value StartCalendarInterval.Hour)" = "12" ]
  [ "$(plist_value StartCalendarInterval.Minute)" = "0" ]
}

@test "mackup_backup_schedule: add accepts a custom schedule" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" add --weekday 3 --hour 9 --minute 30
  [ "${status}" -eq 0 ]
  [ "$(plist_value StartCalendarInterval.Weekday)" = "3" ]
  [ "$(plist_value StartCalendarInterval.Hour)" = "9" ]
  [ "$(plist_value StartCalendarInterval.Minute)" = "30" ]
}

@test "mackup_backup_schedule: add reloads the job in launchd" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" add
  [ "${status}" -eq 0 ]
  expected="bootout gui/$(id -u)/${LABEL}
bootstrap gui/$(id -u) ${PLIST}"
  [ "$(cat "${LAUNCHCTL_LOG}")" = "${expected}" ] || { cat "${LAUNCHCTL_LOG}"; return 1; }
}

@test "mackup_backup_schedule: add fails when mackup is not installed" {
  rm "${TEST_TMPDIR}/mock_bin/mackup"
  PATH="${TEST_TMPDIR}/mock_bin:/usr/bin:/bin" run "${DOTFILES_BIN}/mackup_backup_schedule" add
  [ "${status}" -ne 0 ]
  [ ! -e "${PLIST}" ]
}

# ---------------------------------------------------------------------------
# remove
# ---------------------------------------------------------------------------

@test "mackup_backup_schedule: remove unloads the job and deletes the plist" {
  "${DOTFILES_BIN}/mackup_backup_schedule" add
  : > "${LAUNCHCTL_LOG}"
  run "${DOTFILES_BIN}/mackup_backup_schedule" remove
  [ "${status}" -eq 0 ]
  [ ! -e "${PLIST}" ]
  [ "$(cat "${LAUNCHCTL_LOG}")" = "bootout gui/$(id -u)/${LABEL}" ]
}

@test "mackup_backup_schedule: remove succeeds when nothing is scheduled" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" remove
  [ "${status}" -eq 0 ]
}

# ---------------------------------------------------------------------------
# status
# ---------------------------------------------------------------------------

@test "mackup_backup_schedule: status reports the schedule" {
  "${DOTFILES_BIN}/mackup_backup_schedule" add --weekday 5 --hour 8 --minute 5
  run "${DOTFILES_BIN}/mackup_backup_schedule" status
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"weekday 5, 08:05"* ]] || { echo "${output}"; return 1; }
  [[ "${output}" == *"Loaded in launchd"* ]] || { echo "${output}"; return 1; }
}

@test "mackup_backup_schedule: status reports when nothing is scheduled" {
  run "${DOTFILES_BIN}/mackup_backup_schedule" status
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No scheduled Mackup backup"* ]] || { echo "${output}"; return 1; }
}
