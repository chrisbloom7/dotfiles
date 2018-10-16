#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Agree to Xcode licenses
#sudo xcodebuild -license

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Make ZSH the default shell environment
chsh -s $(which zsh)

# Install Ruby Version Manager and get the lastest Ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --rails

# Install Node Version Manager - Make sure to update the version as new versions are published
\curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# Make sure NPM is available now
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Install global NPM packages
nvm install --latest-npm
npm install --global yarn

# Create a source directory
mkdir $HOME/src

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
[ -s "$HOME/.zshrc" ] && rm -rf "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"

# Symlink the Mackup config file to the home directory
ln -s "$HOME/.dotfiles/.mackup.cfg" "$HOME/.mackup.cfg"

# Set macOS preferences
# We will run this last because this will reload the shell
source .macos

# Install Oh-My-Zsh - If you've run `mackup restore` or installed OMZ previously this step will fail
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Done. Note that some of these changes require a logout/restart to take effect."
