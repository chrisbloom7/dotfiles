# .zshenv is sourced for ALL zsh invocations (interactive, non-interactive, login, non-login).
# Keep this file minimal — only things that must be available in every zsh context.

# Add mise shims to PATH so mise-managed tools (e.g. aws-vault, ruby, node) are
# available in non-interactive shells, scripts, and processes that don't source
# .zprofile or .zshrc (e.g. make targets using /bin/sh, cron jobs using zsh).
export PATH="${HOME}/.local/share/mise/shims:${PATH}"
