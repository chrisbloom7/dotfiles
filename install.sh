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
## Prefer rbenv from homebrew
## gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
## \curl -sSL https://get.rvm.io | bash -s stable --rails --auto-dotfiles --with-default-gems="bundler"
## rvm autolibs homebrew
## rvm default ruby

# Install latest Ruby version using rbenv
eval "$(rbenv init -)"
export RBENV_VERSION="$(rbenv install -l | grep -E '^\s+(\d|\.)+$' | tail -n 1 | sed -e 's/^[ \t]*//')"

# Install Node Version Manager - Make sure to update the version as new versions are published
\curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

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

export RBENV_ROOT="$HOME/.rbenv"
[ -s "$RBENV_ROOT/default-gems" ] && rm -rf "$RBENV_ROOT/default-gems"
ln -s "$HOME/.dotfiles/default-gems" "$RBENV_ROOT/default-gems"
rbenv install "$RBENV_VERSION" && rbenv global "$RBENV_VERSION" && rbenv rehash

# Removes .autobin from $HOME (if it exists) and symlinks the .autobin file from the .dotfiles
[ -s "$HOME/.autobin" ] && rm -rf "$HOME/.autobin"
ln -s "$HOME/.dotfiles/.autobin" "$HOME/.autobin"

# Set macOS preferences
# source .macos

# Mojave changed the location of header files necessary for compiling C extensions. You might need to run the
# following command to install pg, nokogiri, or other gems that require C extensions:
# sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /

echo "Done. Note that some of these changes require a logout/restart to take effect, and you may still need to set fonts manually in your iTerm2 profile"
