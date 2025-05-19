# Minimal bundle
# Minimal tooling necessary to start using a new workstation

## Homebrew bundle info:
# https://github.com/Homebrew/homebrew-bundle?tab=readme-ov-file#usage
#
# Tips: https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f
#
### Usage:
#
#    brew bundle [install]
#    brew bundle [install] --cleanup
#    brew bundle [install] --file=~/.private/Brewfile
#
### Generate a Brewfile from your currently installed packages:
#
#    brew bundle dump
#    brew bundle dump --force
#    brew bundle dump --file=~/.private/Brewfile
#    brew bundle dump --all --describe --file=-
#
### Ways to control which formulae and casks are selected:
#
#### Install only on specified OS:
#
#    brew "gnupg" if OS.mac?
#    brew "glibc" if OS.linux?
#
#### Install only if a command succeeds or fails fails:
#
#    cask "java" unless system "/usr/libexec/java_home", "--failfast"
#
#### Options for formulae and casks:
#
#    args            : array[string]
#    conflicts_with  : array[string]
#    link            : boolean
#    restart_service : boolean
#    start_service   : boolean

# Set arguments for installing casks
# https://github.com/homebrew/homebrew-cask/blob/master/USAGE.md#options
# Tip: Use `force: true` to override `require_sha: true` on individual casks
cask_args require_sha: true, no_quarantine: true

## Taps
tap "buo/cask-upgrade"  # A command line tool for upgrading every outdated app installed by Homebrew Cask

## Formulae
brew "bash-completion"              # Programmable completion for Bash 3.2
brew "bash"                         # Bourne-Again SHell, a UNIX command interpreter
brew "bats-core"                    # Bash Automated Testing System
brew "coreutils"                    # GNU File, Shell, and Text utilities
brew "fzf"                          # Command-line fuzzy finder
brew "gh"                           # GitHub command-line tool
brew "git"                          # Distributed revision control system
brew "github-keygen"                # Bootstrap GitHub SSH configuration
brew "grep"                         # GNU grep, egrep and fgrep
brew "mas"                          # Mac App Store command-line interface
brew "mise"                         # Polyglot runtime manager (asdf rust clone)
brew "mpg123"                       # Fast console MPEG Audio Player and decoder library
brew "php"                          # General-purpose scripting language
brew "pinentry-mac"                 # Pinentry for GPG on Mac
brew "ruby-build"                   # Install various Ruby versions and implementations
brew "vsce"                         # Tool for packaging, publishing and managing VS Code extensions
brew "watchman"                     # Watches files and records when they change
brew "zsh-autosuggestions"          # Fish-like fast/unobtrusive autosuggestions for zsh
brew "zsh-completions"              # Additional completion definitions for zsh
brew "zsh-git-prompt"               # Informative git prompt for zsh
brew "zsh-history-substring-search" # Zsh port of Fish shell's history search
brew "zsh-syntax-highlighting"      # Fish shell like syntax highlighting for zsh
brew "zsh"                          # UNIX shell (command interpreter)
brew "wget"                         # Internet file retriever

## Casks
cask "google-chrome"                          # Web browser
cask "gpg-suite"                              # Tools to protect your emails and files
cask "iterm2"                                 # Terminal emulator as alternative to Apple's Terminal app
cask "logi-options+", force: true             # Software for Logitech devices
# cask "obsbot-center"                          # Configuration and firmware update utility for OBSBOT Tiny and Meet series ! Cask is often out of date; prefer downloading directly from publisher
cask "qlcolorcode"                            # Quick Look plug-in that renders source code with syntax highlighting
cask "qlmarkdown"                             # Quick Look generator for Markdown files
cask "qlstephen"                              # Quick Look plugin for plaintext files without an extension
cask "qlvideo"                                # Thumbnails, static previews, cover art and metadata for video files
cask "qlzipinfo"                              # List out the contents of a zip file in the QuickLook preview
cask "quicklook-csv"                          # Quick Look plugin for CSV files
cask "quicklook-json"                         # Quick Look plugin for JSON files
cask "visual-studio-code"                     # Open-source code editor
cask "warp"                                   # Rust-based terminal
cask "webpquicklook"                          # Quick Look plugin for webp files
cask "zoom"                                   # Video communication and virtual meeting platform

## Fonts
cask "font-mona-sans"                     # Mona-Sans font
cask "font-monaspace-nerd-font"           # Monospace Nerd font
cask "font-monaspace"                     # Monospaced font
cask "font-open-sans"                     # Open Sans font
cask "font-powerline-symbols"             # Powerline Symbols font
cask "font-source-code-pro-for-powerline" # Source Code Pro for Powerline font
cask "font-source-code-pro"               # Source Code Pro font
cask "font-source-sans-3"                 # Source Sans 3 font
cask "font-source-serif-4"                # Source Serif 4 font
