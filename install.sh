#!/bin/sh

# Make ZSH the default shell environment
chsh -s $(which zsh)

# Install Oh-My-Zsh
curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | zsh

cp ".gitconfig" "$HOME/.gitconfig"
cp ".gitconfig" "$HOME/.gitconfig"
