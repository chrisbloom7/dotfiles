bats_require_minimum_version 1.5.0

load "../test_helper"

# Covers the fzf menu in scripts/helpers/runtime.sh (_choose_setup_options).
# A fake fzf answers each prompt from FZF_MODE, FZF_SCOPE and FZF_OPTIONS
# (a space-separated list of flags to tick), or cancels when set to CANCEL.
# Every fzf call is appended to ${TEST_TMPDIR}/fzf.log.

setup() {
  _setup_common
  export DOTFILES="${TEST_TMPDIR}/dotfiles" # no Brewfile.work here
  mkdir -p "${DOTFILES}"
  cat > "${TEST_TMPDIR}/mock_bin/fzf" <<'EOF2'
#!/usr/bin/env bash
input="$(cat)"
answer=""
case "$*" in
  *"Mode >"*)    answer="${FZF_MODE:-}"; prompt=mode ;;
  *"Scope >"*)   answer="${FZF_SCOPE:-}"; prompt=scope ;;
  *"Options >"*) answer="${FZF_OPTIONS:-}"; prompt=options ;;
esac
{ echo "prompt=${prompt}"; echo "${input}"; } >> "${TEST_TMPDIR}/fzf.log"
[[ "${answer}" == "CANCEL" ]] && exit 130
if [[ "${prompt}" == "options" ]]; then
  for flag in ${answer}; do grep -F -- "${flag} " <<<"${input}"; done
else
  echo "${answer}"
fi
EOF2
  chmod +x "${TEST_TMPDIR}/mock_bin/fzf"
  export TEST_TMPDIR
}

teardown() {
  _teardown_common
}

# Source runtime.sh (menu skipped: $0 is not `setup`) and run the picker.
_menu() {
  run bash -c "export PATH='${DOTFILES_BIN}':\"\$PATH\"; source '${DOTFILES_ROOT}/scripts/helpers/runtime.sh' --quiet; _choose_setup_options"
}

@test "menu: full setup with personal scope and extras emits flags" {
  FZF_MODE="Full setup" FZF_SCOPE="Common + personal" FZF_OPTIONS="--force --verbose" _menu
  [ "${status}" -eq 0 ]
  [ "${output}" = $'--personal\n--force\n--verbose' ]
}

@test "menu: minimal skips the scope prompt" {
  FZF_MODE="Minimal setup" FZF_OPTIONS="" _menu
  [ "${status}" -eq 0 ]
  [ "${output}" = "--minimal" ]
  ! grep -q "prompt=scope" "${TEST_TMPDIR}/fzf.log"
}

@test "menu: cancelling the mode prompt aborts setup" {
  FZF_MODE="CANCEL" _menu
  [ "${status}" -eq 1 ]
}

@test "menu: cancelling the options prompt means no extra options" {
  FZF_MODE="Bootstrap only (prerequisites)" FZF_OPTIONS="CANCEL" _menu
  [ "${status}" -eq 0 ]
  [ "${output}" = "--bootstrap" ]
}

@test "menu: work scopes are offered only when Brewfile.work exists" {
  FZF_MODE="Full setup" FZF_SCOPE="Common packages only" _menu
  ! grep -q "work" "${TEST_TMPDIR}/fzf.log"
  touch "${DOTFILES}/Brewfile.work"
  rm "${TEST_TMPDIR}/fzf.log"
  FZF_MODE="Full setup" FZF_SCOPE="Common + work" _menu
  [ "${output}" = "--work" ]
}

@test "menu: every flag it can emit is accepted by the option parser" {
  # Keeps the menu aligned with _parse_setup_options and --help.
  for flag in --minimal --bootstrap --update --personal --work --force --dry-run --skip-local --quiet --verbose; do
    run bash -c "export PATH='${DOTFILES_BIN}':\"\$PATH\"; source '${DOTFILES_ROOT}/scripts/helpers/runtime.sh' ${flag}"
    [ "${status}" -eq 0 ] || { echo "rejected: ${flag}"; false; }
  done
}

@test "menu: every extra option listed in the menu is in --help" {
  run bash -c "export PATH='${DOTFILES_BIN}':\"\$PATH\"; source '${DOTFILES_ROOT}/scripts/helpers/runtime.sh' --help"
  help="${output}"
  for flag in --force --dry-run --skip-local --quiet --verbose --minimal --bootstrap --update --personal --work; do
    [[ "${help}" == *"${flag}"* ]] || { echo "missing from --help: ${flag}"; false; }
  done
}
