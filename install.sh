#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Agree to Xcode licenses if necessary
sudo xcodebuild -runFirstLaunch

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle
brew services stop postgresql # prefer Postgres.app services
brew services cleanup

# Make ZSH the default shell environment
chsh -s $(which zsh)

# Install Ruby Version Manager and get the lastest Ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --rails

# Install Node Version Manager - Make sure to update the version as new versions are published
\curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

# Install Elixir Version Manager
curl -Lqs https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s

# Make sure NPM is available now
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install --latest-npm

# Install global NPM packages
npm install --global yarn

# Create a source directory
mkdir $HOME/src

# TODO: Checkout common repos to src

# Install Oh-My-Zsh - If you've run `mackup restore` or installed OMZ previously this step may fail
# TODO: What happens when this fails? Can we detect installation status or catch the error?
curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | zsh

# Install iTerm2 shell integration for Zsh
curl -L https://iterm2.com/misc/install_shell_integration.sh | zsh

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
[ -s "$HOME/.zshrc" ] && rm -rf "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"

# Symlink the Mackup config files to the home directory.
# Make sure Mackup is excluded from backing itself up
[ -s "$HOME/.mackup.cfg" ] && rm -rf "$HOME/.mackup.cfg"
ln -s "$HOME/.dotfiles/.mackup.cfg" "$HOME/.mackup.cfg"

[ -s "$HOME/.mackup" ] && rm -rf "$HOME/.mackup"
ln -s "$HOME/.dotfiles/.mackup" "$HOME/.mackup"

# TODO: Configure for use with RVM instead of rbenv
# [ -s "$RBENV_ROOT/default-gems" ] && rm -rf "$RBENV_ROOT/default-gems"
# ln -s "$HOME/.dotfiles/default-gems" "$RBENV_ROOT/default-gems"

# Set macOS preferences
source .macos

echo "Done. Note that some of these changes require a logout/restart to take effect, and you may still need to set fonts manually in your iTerm2 profile"
