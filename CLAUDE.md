# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run all tests
./run-tests

# Run a single test file
./run-tests tests/bin/symlink_config.bats

# Run tests matching a pattern
./run-tests --filter "creates symlink"

# Apply all config symlinks
./scripts/symlink-config-files

# Link one tool's configs (all tools when no arguments)
bin/link_configs [<tool> ...]

# Move files from $HOME into configs/<tool>/ and link them back
bin/import_config [<tool-name>] <path> [<path> ...]
# e.g. bin/import_config starship ~/.config/starship.toml

# Refresh the sanitized Claude Code settings snapshot (assets/claude/settings.json)
bin/export_claude_settings [<source> [<output>]]

# Full workstation setup
./setup [--bootstrap|--minimal|--help]
```

## Architecture

### How configs are managed

Each `configs/<tool>/` folder mirrors `$HOME`: every file in it is symlinked to the same relative path under `$HOME` by `bin/link_configs` (called from `scripts/symlink-config-files`). For example, `configs/mise/.config/mise/config.toml` links to `~/.config/mise/config.toml`. There are no per-tool scripts or file lists; adding or removing a file in a tool folder is all it takes. Use `bin/import_config` to bring an existing file under management.

Conventions within a tool folder:

- `*.template` files are copied (without the suffix) instead of linked, and only if the destination doesn't exist. Use for tools that can't write through a symlink (e.g. Docker).
- `README.md` at the top of the folder is documentation and is not linked.
- `hooks/post-link`, if executable, runs after the folder is linked. Use it for destinations that depend on the environment (e.g. `configs/ruby/hooks/post-link` for `$(rbenv root)`).
- After linking, symlinks in the destination directories that point into `configs/` but whose source no longer exists are removed.

Files that are kept in the repo but never linked (e.g. iTerm2 color schemes) live in `assets/`, not `configs/`.

### Mackup

[Mackup](https://github.com/lra/mackup) syncs settings this repo doesn't manage (non-development apps, machine-specific settings, secrets) through Dropbox. `configs/mackup/.mackup.cfg` is link mode and `configs/mackup/.mackup-copy.cfg` is copy mode, for apps macOS 14+ won't let it symlink. Run Mackup through `bin/mackup_sync`, never a plain `mackup restore`, which replaces linked files with copies. Mackup and this repo must never manage the same file: when adding files to `configs/`, run `bin/mackup_audit` and ignore any Mackup app it reports in both configs (or override the app in `configs/mackup/.mackup/` to leave the file out).

### Claude Code config

`configs/claude/.claude/` (`CLAUDE.md`, `rules/`, `hooks/`, `skills/`, `statusline-command.sh`) is linked into `~/.claude` file by file like any other tool folder. Edit the files here, and never replace those links with copies. Machine-local state under `~/.claude` (history, caches, the Remember plugin's `.remember/`) is not tracked.

`~/.claude/settings.json` is not linked. `assets/claude/settings.json` is a sanitized snapshot of it, not a link: the live file stays managed by Mackup and keeps its private entries (permission rules, hooks and settings that name private tools or hosts). Refresh the snapshot with `bin/export_claude_settings` and commit the result; never edit it by hand. The script uses an allowlist (known keys, generic permission rules, public plugin marketplaces, portable hook commands) so anything new and unrecognized is dropped by default; widen the lists in the script only for entries that are safe to publish. `~/.claude/settings.local.json` is not a user-level scope and `autoMode` is only read from user or managed settings, so there is no tracked-file-plus-local-override setup for it.

`/shell-script <description>` (`.claude/commands/shell-script.md`, project-level) plans a new `bin/` or `scripts/` script that follows the conventions below.

### Script conventions

All `bin/` and `scripts/` executables follow the same preamble:
```bash
set -euo pipefail
cd "$(dirname "$0")"
source "${PWD}/helpers/trap_and_trace.sh"  # bin/helpers/; scripts/ source helpers/runtime.sh instead
PATH="${PWD}:${PATH}"
```

`scripts/` executables differ: they use `cd "$(dirname "$0")" || exit 1`, then `source ./helpers/runtime.sh` (mode flags and logging) and `source ../bin/helpers/trap_and_trace.sh`. Copy the preamble of a neighboring script rather than mixing the two.

`cd "$(dirname "$0")"` is critical — it ensures relative paths (to helpers, configs) resolve correctly regardless of where the script is invoked from.

### Other `bin/` tools

Besides the config and Mackup commands above, `bin/` holds `clone_project`, `symlink_config` (links a single file; `bin/link_configs` calls it, and `tests/bin/symlink_config.bats` covers it), the `log_*` and `is_*` helpers, and `helpers/` (shared shell code). Run any of them with `--help` where supported.

`scripts/` also holds `clone-projects` (clones the personal project set into `~/src`) and the Codespaces lifecycle scripts `codespaces-post-create` and `codespaces-post-attach`, which are not run by `setup`: wire them into a devcontainer's `postCreateCommand` / `postAttachCommand` by hand.

Interactive Worktrunk cleanup lives outside this repo: `wt-cleanup`, installed from the `chrisbloom7/tap` Homebrew tap (source: `github.com/chrisbloom7/wt-cleanup`).

Brewfile management lives outside this repo too: `brewfile add|remove|audit`, installed from the same tap as `brewfile-tools` (source: `github.com/chrisbloom7/brewfile-tools`). `aliases.zsh` keeps `brew_add`, `brew_remove` and `brew_audit` as aliases and sets `BREWFILE_DIR` to this repo, so they work from any directory. It needs Ruby 2.7+ (the Homebrew install brings its own).

### Environment variables

Scripts reference `FORCE_MODE`, `VERBOSE_MODE`, and `QUIET_MODE` without defaults (`"${FORCE_MODE}"` not `"${FORCE_MODE:-}"`), so callers must initialize them. `scripts/helpers/runtime.sh` does this (defaulting all to `false`). Tests must export these explicitly — see `tests/test_helper.bash`.

### Setup script hierarchy

```
setup                          # entry point; delegates to:
  scripts/install-prerequisites
  scripts/bootstrap-common     # calls bootstrap-workstation or bootstrap-codespaces
  scripts/symlink-config-files
  scripts/configure-macos
```

`runtime.sh` is sourced by setup scripts and initializes all mode flags (`BOOTSTRAP_MODE`, `MINIMAL_MODE`, `FORCE_MODE`, etc.) and logging functions.

### Shell init load order

- `.zprofile` — login shells only: sets `AWS_*` env vars, runs `brew shellenv`
- `.zshrc` — interactive shells: OMZ config, activates mise, loads completions
- `.zprofile.local` — machine-specific overrides (not tracked); sourced at end of `.zprofile`
- `configs/omz/.oh-my-zsh/custom/aliases.zsh` and `paths.zsh` — auto-loaded by OMZ as custom files

mise activation lives in `.zshrc` (not `.zprofile`) so it runs once for all interactive shells.

### Tests

Tests use [bats-core](https://github.com/bats-core/bats-core) (`brew install bats-core`). Structure mirrors the project: `tests/bin/` for `bin/` scripts. Shared setup is in `tests/test_helper.bash` — each test file calls `_setup_common`/`_teardown_common`. A no-op `sleep` mock is injected into PATH to keep tests fast (log commands call `sleep 0.5`).

### Sensitive content

- `~/.aws/config` is intentionally not tracked (contains account IDs/role names)
- `~/.claude/config.json` is not tracked (machine-specific API key approvals)
- `~/.aliases` is managed by Mackup (not in this repo) — may contain tokens/secrets
- `~/.zprofile.local` is not tracked — use for machine/project-specific env vars
- `~/.claude/settings.json` is not tracked either: see "Claude Code config" for the sanitized snapshot
- Company-specific Claude plugins belong in project-level `.claude/settings.local.json`, not in user-level `~/.claude/settings.json`
