#!/usr/bin/env sh
set -euxo pipefail

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Run setup steps that apply both locally and in devcontainers
script/bootstrap

# Now for the Mac stuff
echo "Setting up your Mac..."

# Symlink Mackup config files to the home directory
script/symlink-mackup-files

# Check for Homebrew and install if we don't have it
script/homebrew-install
echo 'eval "$('$(command -v brew)' shellenv)"' >> $HOME/.zprofile
eval "$($(command -v brew) shellenv)"

# Update Homebrew recipes
brew update --force --verbose 2>&1 | tee /tmp/brew-update.log

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
set +e # Disable halt on failures
brew bundle --file ./Brewfile --force --verbose --no-lock 2>&1 | tee /tmp/brew-bundle.log
set -e # Reenable halt on failures
brew services cleanup

# Uninstall default Mac apps
# mas uninstall 408981434 || true # iMovie
# mas uninstall 409183694 || true # Keynote
# mas uninstall 409201541 || true # Pages
# mas uninstall 409203825 || true # Numbers

# Set default MySQL root password and auth type
if [ -n "$(command -v mysql 2>/dev/null)" ]; then
  echo Setting a blank root password for MySQL...
  brew services start mysql
  mysql -u root -e "ALTER USER root@localhost IDENTIFIED BY ''; FLUSH PRIVILEGES;"
  brew services stop mysql
fi

# # rbenv was installed via Brewfile
# echo Installing latest Ruby version using rbenv...
# rbenv init bash || echo "bash shell not found for rbenv to init"
# rbenv init zsh || echo "zsh shell not found for rbenv to init"
# eval "$(rbenv init -)"
# script/symlink-rbenv-files
#
# # Install Ruby and global gems
# export RBENV_VERSION="$(rbenv install -l | grep -E '^\s+(\d|\.)+$' | tail -n 1 | sed -e 's/^[ \t]*//')"
# rbenv install "$RBENV_VERSION" && rbenv global "$RBENV_VERSION" && rbenv rehash
#
# # Install Node Version Manager - Make sure to update the version as new versions are published
# if [ -z $(command -v nvm 2>/dev/null) ]; then
#   /usr/bin/env bash -c "$(wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh)"
# fi
#
# # Make sure NVM is available
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#
# # Install Elixir Version Manager
# # curl -Lqs https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s
#
# # Install NPM packages and global packages
# nvm install --latest-npm --lts
# nvm use --lts
# npm install --global yarn
# npm install --global @devcontainers/cli

# Let's try mise instead, which was installed via our Brewfile
echo 'eval "$(~/.local/bin/mise activate bash)"' >> $HOME/.bash_profile
echo 'eval "$(~/.local/bin/mise completion bash"' >> $HOME/.bash_completion
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> $HOME/.zprofile
echo 'eval "$(~/.local/bin/mise completion zsh"' > /usr/local/share/zsh/site-functions/_mise
eval "$(~/.local/bin/mise activate bash)"
script/symlink-mise-files

mise use --cd $HOME --env local --verbose --yes \
  go \
  java \
  node \
  python \
  ruby \
  rust
mise reshim --cd $HOME --profile local --verbose --yes

# Clone project repositories
script/clone-projects

# Install iTerm2 shell integration for Zsh
curl -L https://iterm2.com/misc/install_shell_integration.sh | zsh

# Install Rosetta 2 on M1 Macs to bridge the gap between Intel and Apple processors
softwareupdate --install-rosetta --agree-to-license || true

# Set macOS preferences - we run this last because this will reload the shell
source ./.macos

echo "Done. Note that some of these changes require a logout/restart to take effect, and you may still need to set fonts manually in your iTerm2 profile"
