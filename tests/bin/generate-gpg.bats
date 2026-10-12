bats_require_minimum_version 1.5.0

load "../test_helper"

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------

NEW_FPR="AAAA1111BBBB2222CCCC3333DDDD4444EEEE5555"
OLD_FPR="1111222233334444555566667777888899990000"
NEWER_FPR="9999888877776666555544443333222211110000"
USER_ID="Test User <test@example.com>"

setup() {
  _setup_common

  GPG_LOG="${TEST_TMPDIR}/gpg_calls.log"
  KEYS_FIXTURE="${TEST_TMPDIR}/secret_keys"
  : > "${KEYS_FIXTURE}"

  # Real git, isolated from the user's global config
  export GIT_CONFIG_GLOBAL="${TEST_TMPDIR}/gitconfig"
  : > "${GIT_CONFIG_GLOBAL}"

  # Mock gpg: --list-secret-keys serves KEYS_FIXTURE (colon format);
  # --quick-generate-key reports NEW_FPR on the status fd. Logs every call.
  cat > "${TEST_TMPDIR}/mock_bin/gpg" <<EOF
#!/usr/bin/env bash
echo "gpg \$*" >> "${GPG_LOG}"
for arg in "\$@"; do
  case "\$arg" in
    --list-secret-keys)
      [[ -s "${KEYS_FIXTURE}" ]] || { echo "gpg: error reading key: No secret key" >&2; exit 2; }
      cat "${KEYS_FIXTURE}"
      exit 0 ;;
    --quick-generate-key)
      echo "[GNUPG:] KEY_CREATED B ${NEW_FPR}"
      exit 0 ;;
  esac
done
exit 0
EOF
  chmod +x "${TEST_TMPDIR}/mock_bin/gpg"
}

teardown() {
  _teardown_common
}

# Adds a secret key for USER_ID to the mock keyring
add_existing_key() {
  local fpr="$1" created="$2"
  cat >> "${KEYS_FIXTURE}" <<EOF
sec:u:3072:1:${fpr:24}:${created}:::u:::scESC:::+:::23::0:
fpr:::::::::${fpr}:
uid:u::::${created}::HASH::${USER_ID}::::::::::0:
ssb:u:3072:1:0000000000000000:${created}::::::e:::+:::23:
fpr:::::::::FFFF${fpr:4}:
EOF
}

# Runs the script, answering the prompts with the given lines
invoke() {
  local answers
  answers="$(printf '%s\n' "$@")"
  run env PATH="${TEST_TMPDIR}/mock_bin:${PATH}" \
    "${DOTFILES_BIN}/generate-gpg" <<< "${answers}"
}

git_global() {
  git config get --global "$1"
}

# ---------------------------------------------------------------------------
# New key
# ---------------------------------------------------------------------------

@test "generate-gpg: generates a key and configures git when gpg.format is unset" {
  invoke "Test User" "test@example.com" y
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  grep -q -- "--quick-generate-key ${USER_ID}" "${GPG_LOG}"
  [ "$(git_global user.signingkey)" = "${NEW_FPR}" ]
  [ "$(git_global commit.gpgsign)" = "true" ]
  [ "$(git_global tag.gpgsign)" = "true" ]
  [ "$(git_global push.gpgsign)" = "if-asked" ]
  [ "$(git_global gpg.program)" = "${TEST_TMPDIR}/mock_bin/gpg" ]
}

@test "generate-gpg: removes an existing gpg.format setting" {
  git config set --global gpg.format ssh
  invoke "Test User" "test@example.com" y
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  run git config get --global gpg.format
  [ "${status}" -eq 1 ]
}

@test "generate-gpg: re-prompts for name and email until confirmed" {
  invoke "Wrong Name" "wrong@example.com" n "Test User" "test@example.com" y
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  grep -q -- "--quick-generate-key ${USER_ID}" "${GPG_LOG}"
}

# ---------------------------------------------------------------------------
# Existing key
# ---------------------------------------------------------------------------

@test "generate-gpg: reuses an existing key when asked" {
  add_existing_key "${OLD_FPR}" 1700000000
  invoke "Test User" "test@example.com" y y
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  ! grep -q -- "--quick-generate-key" "${GPG_LOG}"
  [ "$(git_global user.signingkey)" = "${OLD_FPR}" ]
}

@test "generate-gpg: reuses the newest of several existing keys" {
  add_existing_key "${NEWER_FPR}" 1800000000
  add_existing_key "${OLD_FPR}" 1700000000
  invoke "Test User" "test@example.com" y y
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  [ "$(git_global user.signingkey)" = "${NEWER_FPR}" ]
}

@test "generate-gpg: generates a new key when existing key is declined" {
  add_existing_key "${OLD_FPR}" 1700000000
  invoke "Test User" "test@example.com" y n
  [ "${status}" -eq 0 ] || { echo "${output}"; return 1; }
  grep -q -- "--yes .*--quick-generate-key ${USER_ID}" "${GPG_LOG}"
  [ "$(git_global user.signingkey)" = "${NEW_FPR}" ]
}

# ---------------------------------------------------------------------------
# Failures
# ---------------------------------------------------------------------------

@test "generate-gpg: fails when the new key's fingerprint can't be determined" {
  cat > "${TEST_TMPDIR}/mock_bin/gpg" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  invoke "Test User" "test@example.com" y
  [ "${status}" -ne 0 ]
  run git config get --global user.signingkey
  [ "${status}" -ne 0 ]
}
