#!/usr/bin/env sh
set -eu

echo "Setting up your Mac..."

# Run setup steps that apply both locally and in devcontainers
script/bootstrap

echo "Setting ZSH is the default shell..."
chsh -s $(command -v zsh)

# Symlink the Mackup config files to the home directory.
# Make sure Mackup is excluded from backing itself up
[ -s "$HOME/.mackup.cfg" ] && rm -rf "$HOME/.mackup.cfg"
ln -s "$HOME/.dotfiles/.mackup.cfg" "$HOME/.mackup.cfg"

# Symlink the Mackup custom app config files to the home directory.
[ -s "$HOME/.mackup" ] && rm -rf "$HOME/.mackup"
ln -s "$HOME/.dotfiles/.mackup" "$HOME/.mackup"

# Check for Homebrew and install if we don't have it
if [ -z $(command -v brew 2>/dev/null) ]; then
  /usr/bin/env bash -c "$(wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Homebrew recipes
brew update --force --quiet

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file ./Brewfile
brew services cleanup

# Set default MySQL root password and auth type
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install latest Ruby version using rbenv
# rbenv was installed via Brewfile
rbenv init bash || echo "bash shell not found for rbenv to init"
rbenv init zsh || echo "zsh shell not found for rbenv to init"
eval "$(rbenv init -)"
export RBENV_VERSION="$(rbenv install -l | grep -E '^\s+(\d|\.)+$' | tail -n 1 | sed -e 's/^[ \t]*//')"
export RBENV_ROOT="$HOME/.rbenv"
[ -s "$RBENV_ROOT/default-gems" ] && rm -rf "$RBENV_ROOT/default-gems"
ln -s "$HOME/.dotfiles/default-gems" "$RBENV_ROOT/default-gems"
rbenv install "$RBENV_VERSION" && rbenv global "$RBENV_VERSION" && rbenv rehash

# Install Node Version Manager - Make sure to update the version as new versions are published
if [ -z $(command -v nvm 2>/dev/null) ]; then
  /usr/bin/env bash -c "$(wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh)"

  # Make sure NPM is available
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# Install NPM packages and global packages
nvm install --latest-npm --lts
nvm use --lts
npm install --global yarn
npm install --global @devcontainers/cli

# Install Elixir Version Manager
# curl -Lqs https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s

# Clone project repositories
scripts/clone-projects

# Install iTerm2 shell integration for Zsh
curl -L https://iterm2.com/misc/install_shell_integration.sh | zsh

# Codespaces has issues when GPG commit signing is enabled on the containers as
# well as in gitconfig. Since our global gitconfig gets synced to dotfiles and
# thus to codespaces, we can set some system level config here instead.
git config --system user.signingkey B8BB552ABFFDAE06
git config --system commit.gpgsign true
git config --system gpg.program $(which gpg)

# Install Rosetta 2 on M1 Macs to bridge the gap between Intel and Apple processors
softwareupdate --install-rosetta --agree-to-license

echo "Done. Note that some of these changes require a logout/restart to take effect, and you may still need to set fonts manually in your iTerm2 profile"
