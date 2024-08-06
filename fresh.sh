#!/bin/sh
set -euo pipefail

echo "Setting up your Mac..."

script/setup

# Check for Homebrew and install if we don't have it
if [[ -z $(command -v brew) ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Agree to Xcode licenses if necessary
# sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle
brew services cleanup

# Set default MySQL root password and auth type
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Make ZSH the default shell environment
chsh -s $(which zsh)

# Install latest Ruby version using rbenv
# rbenv was installed via Brewfile
eval "$(rbenv init -)"
export RBENV_VERSION="$(rbenv install -l | grep -E '^\s+(\d|\.)+$' | tail -n 1 | sed -e 's/^[ \t]*//')"

# Install Node Version Manager - Make sure to update the version as new versions are published
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Install Elixir Version Manager
# curl -Lqs https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s

# Make sure NPM is available now
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install --latest-npm

# Install global NPM packages
npm install --global yarn

# Create a source directory and fold for personal projects
mkdir $HOME/src
mkdir $HOME/src/chrisbloom7
mkdir $HOME/src/sandbox

# TODO: Checkout common repos to src
git clone git@github.com:chrisbloom7/enumpath.git $HOME/src/chrisbloom7/enumpath
git clone git@github.com:chrisbloom7/enumpath.io.git $HOME/src/chrisbloom7/enumpath.io
git clone git@github.com:chrisbloom7/improved-initiative.git $HOME/src/chrisbloom7/improved-initiative
git clone git@github.com:chrisbloom7/robinina.art.git $HOME/src/chrisbloom7/robinina.art
git clone git@github.com:chrisbloom7/statblock-shop.git $HOME/src/chrisbloom7/statblock-shop

# Install iTerm2 shell integration for Zsh
curl -L https://iterm2.com/misc/install_shell_integration.sh | zsh

# Symlink .oh-my-zsh custom files
[ -s "$HOME/.oh-my-zsh/custom/aliases.zsh" ] && rm -rf "$HOME/.oh-my-zsh/custom/aliases.zsh"
ln -s "$HOME/.dotfiles/aliases.zsh" "$HOME/.oh-my-zsh/custom/aliases.zsh"
[ -s "$HOME/.oh-my-zsh/custom/agnoster.zsh-theme" ] && rm -rf "$HOME/.oh-my-zsh/custom/agnoster.zsh-theme"
ln -s "$HOME/.dotfiles/agnoster.zsh-theme" "$HOME/.oh-my-zsh/custom/agnoster.zsh-theme"
[ -s "$HOME/.oh-my-zsh/custom/path.zsh" ] && rm -rf "$HOME/.oh-my-zsh/custom/path.zsh"
ln -s "$HOME/.dotfiles/path.zsh" "$HOME/.oh-my-zsh/custom/path.zsh"

# Symlink .zshrc
[ -s "$HOME/.zshrc" ] && rm -rf "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"

# Symlink .gitconfig
[ -s "$HOME/.gitconfig" ] && rm -rf "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"

# Codespaces has issues when GPG commit signing is enabled on the containers as
# well as in gitconfig. Since our global gitconfig gets synced to dotfiles and
# thus to codespaces, we can set some system level config here instead.
git config --system user.signingkey B8BB552ABFFDAE06
git config --system commit.gpgsign true
git config --system gpg.program $(which gpg)

# Symlink .gitignore_global
[ -s "$HOME/.gitignore_global" ] && rm -rf "$HOME/.gitignore_global"
ln -s "$HOME/.dotfiles/.gitignore_global" "$HOME/.gitignore_global"

# Symlink the Mackup config files to the home directory.
# Make sure Mackup is excluded from backing itself up
[ -s "$HOME/.mackup.cfg" ] && rm -rf "$HOME/.mackup.cfg"
ln -s "$HOME/.dotfiles/.mackup.cfg" "$HOME/.mackup.cfg"

# Symlink the Mackup custom app config files to the home directory.
[ -s "$HOME/.mackup" ] && rm -rf "$HOME/.mackup"
ln -s "$HOME/.dotfiles/.mackup" "$HOME/.mackup"

export RBENV_ROOT="$HOME/.rbenv"
[ -s "$RBENV_ROOT/default-gems" ] && rm -rf "$RBENV_ROOT/default-gems"
ln -s "$HOME/.dotfiles/default-gems" "$RBENV_ROOT/default-gems"
rbenv install "$RBENV_VERSION" && rbenv global "$RBENV_VERSION" && rbenv rehash

echo "Done. Note that some of these changes require a logout/restart to take effect, and you may still need to set fonts manually in your iTerm2 profile"
