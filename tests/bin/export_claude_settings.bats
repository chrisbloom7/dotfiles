bats_require_minimum_version 1.5.0

load "../test_helper"

setup() {
  _setup_common
  export HOME="${TEST_TMPDIR}/home"
  mkdir -p "${HOME}/.claude"
  SOURCE="${TEST_TMPDIR}/source.json"
  OUTPUT="${TEST_TMPDIR}/out/settings.json"

  # Synthetic fixture: every private-looking name is fake
  cat > "${SOURCE}" <<'JSON'
{
  "model": "sonnet",
  "theme": "auto",
  "skipWorkflowUsageWarning": true,
  "acmeUnknownKey": "acme-private-value",
  "feedbackDrafts": "acme-private-draft",
  "env": { "CLAUDE_CODE_DISABLE_MOUSE": "1", "ACME_PRIVATE_TOKEN": "acme-private-secret" },
  "autoMode": { "environment": ["Trusted path: /srv/acme-private-vendor"] },
  "statusLine": { "type": "command", "command": "~/.claude/statusline-command.sh" },
  "permissions": {
    "allow": [
      "Bash(git fetch)",
      "Bash(wt list *)",
      "Bash(acme-private-vendor status)",
      "mcp__acme-private-vendor__list-things"
    ],
    "ask": ["Bash(git push *main*)", "Bash(acme-private-vendor deploy)"]
  },
  "enabledPlugins": {
    "superpowers@anthropic-plugin-directory": true,
    "acme-tool@acme-private-marketplace": true
  },
  "extraKnownMarketplaces": {
    "ai-tools": { "source": { "source": "github", "repo": "chrisbloom7/ai-tools" } },
    "acme": { "source": { "source": "github", "repo": "acme-private-org/plugins" } }
  },
  "hooks": {
    "Stop": [
      { "hooks": [
        { "type": "command", "command": "/Users/someone/.config/iterm2/cc-status" },
        { "type": "command", "command": "/opt/acme-private-vendor/bin/notify" }
      ] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "\"$HOME/.claude/hooks/check.sh\"" }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "/opt/acme-private-vendor/bin/archive" }] }
    ]
  }
}
JSON
}

teardown() {
  _teardown_common
}

@test "export_claude_settings: keeps allowlisted keys, rules, plugins and hooks" {
  run "${DOTFILES_BIN}/export_claude_settings" "${SOURCE}" "${OUTPUT}"
  [ "${status}" -eq 0 ]
  [ "$(jq -r '.model, .theme, .skipWorkflowUsageWarning' "${OUTPUT}" | paste -sd, -)" = "sonnet,auto,true" ]
  [ "$(jq -c '.permissions.allow' "${OUTPUT}")" = '["Bash(git fetch)","Bash(wt list *)"]' ]
  [ "$(jq -c '.permissions.ask' "${OUTPUT}")" = '["Bash(git push *main*)"]' ]
  [ "$(jq -c '.enabledPlugins | keys' "${OUTPUT}")" = '["superpowers@anthropic-plugin-directory"]' ]
  [ "$(jq -c '.extraKnownMarketplaces | keys' "${OUTPUT}")" = '["ai-tools"]' ]
  [ "$(jq -r '.statusLine.command' "${OUTPUT}")" = "~/.claude/statusline-command.sh" ]
  [ "$(jq -r '.hooks.PostToolUse[0].matcher' "${OUTPUT}")" = "Edit|Write" ]
}

@test "export_claude_settings: rewrites an absolute home prefix to \$HOME in hooks" {
  run "${DOTFILES_BIN}/export_claude_settings" "${SOURCE}" "${OUTPUT}"
  [ "${status}" -eq 0 ]
  [ "$(jq -r '.hooks.Stop[0].hooks[0].command' "${OUTPUT}")" = '$HOME/.config/iterm2/cc-status' ]
}

@test "export_claude_settings: drops unknown keys, rules, plugins, marketplaces and hooks" {
  run "${DOTFILES_BIN}/export_claude_settings" "${SOURCE}" "${OUTPUT}"
  [ "${status}" -eq 0 ]
  [ "$(jq 'has("acmeUnknownKey") or has("feedbackDrafts") or has("autoMode")' "${OUTPUT}")" = "false" ]
  [ "$(jq '.hooks.Stop[0].hooks | length' "${OUTPUT}")" -eq 1 ]
  [ "$(jq '.hooks | has("SessionEnd")' "${OUTPUT}")" = "false" ]
  [ "$(jq -c '.env' "${OUTPUT}")" = '{"CLAUDE_CODE_DISABLE_MOUSE":"1"}' ]
  ! rg -q 'acme|/opt/|someone' "${OUTPUT}" || { echo "Expected no fixture-private text in the output"; return 1; }
}

@test "export_claude_settings: leaves the source byte-identical" {
  before="$(shasum "${SOURCE}")"
  run "${DOTFILES_BIN}/export_claude_settings" "${SOURCE}" "${OUTPUT}"
  [ "${status}" -eq 0 ]
  [ "$(shasum "${SOURCE}")" = "${before}" ]
}

@test "export_claude_settings: is idempotent" {
  run "${DOTFILES_BIN}/export_claude_settings" "${SOURCE}" "${OUTPUT}"
  [ "${status}" -eq 0 ]
  first="$(shasum "${OUTPUT}")"
  run "${DOTFILES_BIN}/export_claude_settings" "${SOURCE}" "${OUTPUT}"
  [ "${status}" -eq 0 ]
  [ "$(shasum "${OUTPUT}")" = "${first}" ]
  # Exporting the snapshot again changes nothing
  run "${DOTFILES_BIN}/export_claude_settings" "${OUTPUT}" "${TEST_TMPDIR}/again.json"
  [ "${status}" -eq 0 ]
  cmp "${OUTPUT}" "${TEST_TMPDIR}/again.json"
}

@test "export_claude_settings: accepts the home settings path as source" {
  cp "${SOURCE}" "${HOME}/.claude/settings.json"
  run "${DOTFILES_BIN}/export_claude_settings" "${HOME}/.claude/settings.json" "${OUTPUT}"
  [ "${status}" -eq 0 ]
  [ -s "${OUTPUT}" ]
}

@test "export_claude_settings: resolves relative paths against the working directory" {
  cd "${TEST_TMPDIR}"
  run "${DOTFILES_BIN}/export_claude_settings" source.json rel-out.json
  [ "${status}" -eq 0 ]
  [ -s "${TEST_TMPDIR}/rel-out.json" ]
}

@test "export_claude_settings: refuses to overwrite its source" {
  run "${DOTFILES_BIN}/export_claude_settings" "${SOURCE}" "${SOURCE}"
  [ "${status}" -ne 0 ]
  jq -e '.autoMode' "${SOURCE}" > /dev/null
}

@test "export_claude_settings: fails when the source is missing" {
  run "${DOTFILES_BIN}/export_claude_settings" "${TEST_TMPDIR}/missing.json" "${OUTPUT}"
  [ "${status}" -ne 0 ]
}
