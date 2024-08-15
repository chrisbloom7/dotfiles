# Homebrew bundle
# https://github.com/Homebrew/homebrew-bundle?tab=readme-ov-file#usage
#
# Tips: https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f
#
## Usage:
#
#    brew bundle [install]
#    brew bundle [install] --cleanup
#    brew bundle [install] --file=~/.private/Brewfile
#
## Generate a Brewfile from your currently installed packages:
#
#    brew bundle dump
#    brew bundle dump --force
#    brew bundle dump --file=~/.private/Brewfile
#
## Ways to control which formulae and casks are selected:
#
### Install only on specified OS:
#
#    brew "gnupg" if OS.mac?
#    brew "glibc" if OS.linux?
#
### Install only if a command succeeds or fails fails:
#
#    cask "java" unless system "/usr/libexec/java_home", "--failfast"
#
### Options for formulae and casks:
#
#    args            : array[string]
#    conflicts_with  : array[string]
#    link            : boolean
#    restart_service : boolean
#    start_service   : boolean

# Set arguments for all 'brew install --cask' commands
cask_args appdir: "~/Applications"

## Taps
tap "buo/cask-upgrade"  # A command line tool for upgrading every outdated app installed by Homebrew Cask
tap "homebrew/bundle"   # Bundler for non-Ruby dependencies from Homebrew, Homebrew Cask and the Mac App Store.
tap "homebrew/services" # Manage background services using the daemon manager launchctl on macOS or systemctl on Linux.

## Docker on MacOS without Docker Desktop
# This might not work after all, at least not for work...
#
# https://gist.github.com/juancsr/5927e6660d6ba5d2a34c61802d26e50a
# https://how.wtf/how-to-use-docker-without-docker-desktop-on-macos.html
# https://dev.to/elliotalexander/how-to-use-docker-without-docker-desktop-on-macos-217m
#
# brew "colima", restart_service: true                   # Container runtimes on MacOS (and Linux) with minimal setup
# brew "docker-compose"                                  # Isolated development environments using Docker
# brew "docker-credential-helper"                        # Platform keystore credential helper for Docker
# brew "docker"                                          # Pack, ship and run any application as a lightweight container
# brew "hyperkit" unless system "test $(uname -p) = arm" # Toolkit for embedding hypervisor capabilities in your application
# brew "minikube"                                        # Run a Kubernetes cluster locally
# brew "qemu" if system "test $(uname -p) = arm"         # Generic machine emulator and virtualizer

## Desktop Docker
cask "docker"                   # App to build and share containerised applications and microservices
brew "docker-buildx"            # Docker CLI plugin for extended build capabilities with BuildKit
brew "docker-clean"             # Clean Docker containers, images, networks, and volumes
brew "docker-completion"        # Bash, Zsh and Fish completion for Docker
brew "docker-compose"           # Isolated development environments using Docker
brew "docker-credential-helper" # Platform keystore credential helper for Docker
brew "docker-ls"                # Tools for browsing and manipulating docker registries
brew "docker-slim"              # Minify and secure Docker images

## Formulae
brew "aom"                          # Codec library for encoding and decoding AV1 video streams
brew "awscli"                       # Official Amazon AWS command-line interface
brew "bash-completion"              # Programmable completion for Bash 3.2
brew "bash"                         # Bourne-Again SHell, a UNIX command interpreter
brew "bat"                          # Clone of cat(1) with syntax highlighting and Git integration
brew "coreutils"                    # GNU File, Shell, and Text utilities
brew "gh"                           # GitHub command-line tool
brew "git"                          # Distributed revision control system
brew "github-keygen"                # Bootstrap GitHub SSH configuration
brew "gnupg"                        # GNU Pretty Good Privacy (PGP) package
brew "gnutls"                       # GNU Transport Layer Security (TLS) Library
brew "grep"                         # GNU grep, egrep and fgrep
brew "httpie"                       # User-friendly cURL replacement (command-line HTTP client)
brew "imagemagick"                  # Tools and libraries to manipulate images in many formats
brew "lynx"                         # Text-based web browser
brew "mackup"                       # Keep your Mac's application settings in sync
brew "mas"                          # Mac App Store command-line interface
brew "notify"                       # Stream the output of any CLI and publish it to a variety of supported platforms
brew "pandoc"                       # Swiss-army knife of markup format conversion
brew "pinentry-mac"                 # Pinentry for GPG on Mac
brew "pkg-config"                   # Manage compile and link flags for libraries
brew "putty"                        # Implementation of Telnet and SSH
brew "python@3.10"                  # Interpreted, interactive, object-oriented programming language
brew "rbenv-default-gems"           # Auto-installs gems for Ruby installs
brew "rbenv"                        # Ruby version manager
brew "ruby-build"                   # Install various Ruby versions and implementations
brew "telnet"                       # User interface to the TELNET protocol
brew "terminal-notifier"            # Send macOS User Notifications from the command-line
brew "tmux"                         # Terminal multiplexer
brew "vsce"                         # Tool for packaging, publishing and managing VS Code extensions
brew "watch"                        # Executes a program periodically, showing output fullscreen
brew "wget"                         # Internet file retriever
brew "zsh-autosuggestions"          # Fish-like fast/unobtrusive autosuggestions for zsh
brew "zsh-completions"              # Additional completion definitions for zsh
brew "zsh-git-prompt"               # Informative git prompt for zsh
brew "zsh-history-substring-search" # Zsh port of Fish shell's history search
brew "zsh-syntax-highlighting"      # Fish shell like syntax highlighting for zsh
brew "zsh"                          # UNIX shell (command interpreter)

## Casks
cask "1password"                    # Password manager that keeps all passwords secure behind one password
cask "adobe-acrobat-reader"         # View, print, and comment on PDF documents
cask "alfred"                       # Application launcher and productivity software
cask "beyond-compare"               # Compare files and folders
cask "chatgpt"                      # OpenAI's official ChatGPT desktop app
cask "chromedriver"                 # Automated testing of webapps for Google Chrome
cask "clamxav"                      # Anti-virus and malware scanner
cask "cleanmymac"                   # Tool to remove unnecessary files and folders from disk
cask "cyberduck"                    # Server and cloud storage browser
cask "deckset"                      # Presentations from Markdown
cask "discord"                      # Voice and text chat software
cask "divvy"                        # Application window manager focusing on simplicity
cask "drivethrurpg"                 # Sync DriveThruRPG libraries to compatible devices
cask "dropbox"                      # Client for the Dropbox cloud storage service
cask "figma"                        # Collaborative team software
cask "freeze"                       # Amazon Glacier file transfer client
cask "garmin-express"               # Update maps and software, sync with Garmin Connect and register your device
cask "gemini"                       # Disk space cleaner that finds and deletes duplicated and similar files
cask "google-chrome"                # Web browser
cask "google-drive"                 # Client for the Google Drive storage service
cask "gpg-suite"                    # Tools to protect your emails and files
cask "graphiql"                     # Light, Electron-based Wrapper around GraphiQL
cask "imageoptim"                   # Tool to optimise images to a smaller size
cask "iterm2"                       # Terminal emulator as alternative to Apple's Terminal app
cask "logi-options-plus"            # Software for Logitech devices
cask "macdown"                      # Open-source Markdown editor
cask "mailplane"                    # Gmail client
cask "microsoft-edge"               # Web browser
cask "monitorcontrol"               # Tool to control external monitor brightness & volume
cask "monodraw"                     # Tool to create text-based art
cask "ngrok"                        # Reverse proxy, secure introspectable tunnels to localhost
cask "obsbot-center"                # Configuration and firmware update utility for OBSBOT Tiny and Meet series
cask "qlcolorcode"                  # Quick Look plug-in that renders source code with syntax highlighting
cask "qlimagesize"                  # Display image info and preview unsupported formats in QuickLook
cask "qlmarkdown"                   # Quick Look generator for Markdown files
cask "qlstephen"                    # Quick Look plugin for plaintext files without an extension
cask "qlvideo"                      # Thumbnails, static previews, cover art and metadata for video files
cask "qlzipinfo"                    # List out the contents of a zip file in the QuickLook preview
cask "quicklook-csv"                # Quick Look plugin for CSV files
cask "quicklook-json"               # Quick Look plugin for JSON files
cask "raycast"                      # Control your tools with a few keystrokes
cask "screenfocus"                  # Tool to manage multiple screens
cask "script-debugger"              # Integrated development environment focused entirely on AppleScript
cask "scriptql"                     # AppleScript Quick Look plugin
cask "shutter-encoder"              # Video, audio and image converter
cask "slack"                        # Team communication and collaboration software
cask "spotify"                      # Music streaming service
cask "steam"                        # Video game digital distribution service
cask "the-unarchiver"               # Unpacks archive files
cask "transmit"                     # File transfer application
cask "viscosity"                    # OpenVPN client with AppleScript support
cask "visual-studio-code"           # Open-source code editor
cask "voodoopad"                    # Notes organiser
cask "warp"                         # Rust-based terminal
cask "wavebox"                      # Web browser
cask "webpquicklook"                # Quick Look plugin for webp files
cask "yubico-yubikey-manager"       # Application for configuring any YubiKey
cask "zoom"                         # Video communication and virtual meeting platform

## Fonts
cask "font-0xproto"                       # 0xproto font
cask "font-0xproto-nerd-font"             # 0xproto Nerd font
cask "font-bungee-color"                  # Bungee Color font
cask "font-bungee-hairline"               # Bungee Hairline font
cask "font-bungee-inline"                 # Bungee Inline font
cask "font-bungee-outline"                # Bungee Outline font
cask "font-bungee-shade"                  # Bungee Shade font
cask "font-bungee-spice"                  # Bungee Spice font
cask "font-bungee"                        # Bungee font
cask "font-creepster-caps"                # Creepster Caps font
cask "font-creepster"                     # Creepster font
cask "font-mona-sans"                     # Mona-Sans font
cask "font-monaspace"                     # Monospaced font
cask "font-monaspace-nerd-font"           # Monospace Nerd font
cask "font-open-sans"                     # Open Sans font
cask "font-powerline-symbols"             # Powerline Symbols font
cask "font-source-code-pro-for-powerline" # Source Code Pro for Powerline font
cask "font-source-code-pro"               # Source Code Pro font
cask "font-source-sans-3"                 # Source Sans 3 font
cask "font-source-serif-4"                # Source Serif 4 font
cask "font-space-grotesk"                 # Space Grotesk font
cask "font-space-mono-nerd-font"          # Space Mono Nerd font
cask "font-space-mono"                    # Space Mono font
cask "font-sudo"                          # Sudo font
cask "font-texturina"                     # Texturina font
cask "font-tilt-warp"                     # Tilt Warp font

## Apps from the Mac App Store
mas "1Password for Safari",          id: 1569813296
mas "AnySwitch - Powerful switches", id: 6444313776
mas "Bear: Markdown Notes",          id: 1091189122
mas "Encrypto: Secure Your Files",   id: 935235287
mas "one sec | screen time + focus", id: 1532875441
mas "Photomator - Photo Editor",     id: 1444636541
mas "Pixelmator Pro",                id: 1289583905
mas "QuikFlow",                      id: 1626354390
mas "Speedtest by Ookla",            id: 1153157709
mas "TestFlight",                    id: 899247664
mas "Xcode",                         id: 497799835

## VS code extensions
vscode "AlanWalk.markdown-navigation"               # Auto genreate markdown navigation panel to the activity bar.                                                                                                                                                                                                                                            # 'vscode --install-extension'
vscode "assisrMatheus.sidebar-markdown-notes"       # Take notes in your sidebar using markdown
vscode "bierner.github-markdown-preview"            # Extension pack of VS Code markdown preview extensions
vscode "castwide.solargraph"                        # A Ruby language server featuring code completion, intellisense, and inline documentation
vscode "ciarant.vscode-structurizr"                 # Structurizr DSL syntax highlighting
vscode "CraigMaslowski.erb"                         # Syntax Highlighting for Ruby ERB files
vscode "DavidAnson.vscode-markdownlint"             # Markdown linting and style checking for Visual Studio Code
vscode "dbaeumer.vscode-eslint"                     # Integrates ESLint JavaScript into VS Code.
vscode "deaniusolutions.deckset"                    # Make Deckset files in VSCode splendiferously.
vscode "DrMerfy.overtype"                           # Provides insert/overtype mode.
vscode "dustinsanders.an-old-hope-theme-vscode"     # vscode theme inspired by a galaxy far far away...
vscode "eamodio.gitlens"                            # Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more
vscode "erikphansen.vscode-toggle-column-selection" # Turn a selection into a column selection à la TextMate
vscode "esbenp.prettier-vscode"                     # Code formatter using prettier
vscode "foxundermoon.shell-format"                  # A formatter for shell scripts, Dockerfile, gitignore, dotenv, /etc/hosts, jvmoptions, and other file types
vscode "GitHub.codespaces"                          # Your instant dev environment
vscode "GitHub.copilot-chat"                        # AI chat features powered by Copilot
vscode "GitHub.copilot"                             # Your AI pair programmer
vscode "GitHub.remotehub"                           # Remotely browse and edit any GitHub repository
vscode "github.vscode-github-actions"               # GitHub Actions workflows and runs for github.com hosted repositories in VS Code
vscode "GitHub.vscode-pull-request-github"          # Pull Request and Issue Provider for GitHub
vscode "golang.go"                                  # Rich Go language support for Visual Studio Code
vscode "GraphQL.vscode-graphql-syntax"              # Adds syntax highlighting support for .graphql & embedded support for javascript, typescript, vue, markdown, python, php, reason, ocaml and rescript
vscode "howardzuo.vscode-git-tags"                  # quick manage tags for a git repo
vscode "IBM.output-colorizer"                       # Syntax highlighting for log files
vscode "itarato.byesig"                             # Hide Ruby Sorbet signatures
vscode "janjoerke.align-by-regex"                   # Aligns selected lines of text by a regular expression.
vscode "jnbt.vscode-rufo"                           # VS Code plugin for ruby-formatter/rufo
vscode "mechatroner.rainbow-csv"                    # Highlight CSV and TSV files, Run SQL-like queries
vscode "MermaidChart.vscode-mermaid-chart"          # The Mermaid Chart extension for Visual Studio Code enables developers to view and edit diagrams stored in Mermaid charts within the Visual Studio Code. With integration to the Mermaid Chart service, this extension allows users to attach diagrams to their code. Gain quick access to edit diagrams.
vscode "ms-azuretools.vscode-docker"                # Makes it easy to create, manage, and debug containerized applications.
vscode "ms-toolsai.jupyter"                         # Jupyter notebook support, interactive programming and computing that supports Intellisense, debugging and more.
vscode "ms-vscode-remote.remote-containers"         # Open any folder or repository inside a Docker container and take advantage of Visual Studio Code's full feature set.
vscode "ms-vscode.remote-repositories"              # Remotely browse and edit git repositories
vscode "ms-vscode.vscode-github-issue-notebooks"    # GitHub Issue Notebooks for VS Code
vscode "ms-vscode.wordcount"                        # Markdown Word Count Example - a status bar contribution that reports out the number of works in a Markdown document as you interact with it.
vscode "nextfaze.json-parse-stringify"              # Quickly flick between stringified JSON and POJOs
vscode "phoihos.csv-to-md-table"                    # Convert CSV/TSV/PSV text to GitHub Flavored Markdown table
vscode "PKief.material-icon-theme"                  # Material Design Icons for Visual Studio Code
vscode "redhat.vscode-yaml"                         # YAML Language Support by Red Hat, with built-in Kubernetes syntax support
vscode "rubocop.vscode-rubocop"                     # VS Code extension for the RuboCop linter and code formatter.
vscode "shardulm94.trailing-spaces"                 # Highlight trailing spaces and delete them in a flash!
vscode "shd101wyy.markdown-preview-enhanced"        # Markdown Preview Enhanced ported to vscode
vscode "Shopify.ruby-lsp"                           # VS Code plugin for connecting with the Ruby LSP
vscode "sorbet.sorbet-vscode-extension"             # Ruby IDE features, powered by Sorbet.
vscode "stkb.rewrap"                                # Hard word wrapping for comments and other text at a given column.
vscode "streetsidesoftware.code-spell-checker"      # Spelling checker for source code
vscode "stripe.endsmart"                            # A modern version of endwise that relies on more recent VSCode APIs.
vscode "Tyriar.sort-lines"                          # Sorts lines of text
vscode "yzhang.markdown-all-in-one"                 # All you need to write Markdown (keyboard shortcuts, table of contents, auto preview and more)

## Extension Packs
#
# Brew bundle doesn't do a good job of managing extension packs. Currently you
# must specify the extension pack name and the individual extensions, otherwise
# `brew bundle install --cleanup` will remove any extensions in the pack that
# are not explicitly listed in the Brewfile.

### GitHub Markdown Preview
vscode "bierner.github-markdown-preview"        # [Extension Pack] Changes VS Code's built-in markdown preview to match GitHub
vscode "bierner.markdown-checkbox"              # Adds checkbox support to the built-in markdown preview
vscode "bierner.markdown-emoji"                 # Adds emoji syntax support to VS Code's built-in markdown preview and markdown cells in notebook
vscode "bierner.markdown-footnotes"             # Adds [^footnote] syntax support to VS Code's built-in markdown preview
vscode "bierner.markdown-mermaid"               # Adds Mermaid diagram and flowchart support to VS Code's builtin markdown preview
vscode "bierner.markdown-preview-github-styles" # Changes VS Code's built-in markdown preview to match Github's style
vscode "bierner.markdown-yaml-preamble"         # Renders yaml front matter as a table in the built-in markdown preview

### Jupyter Notebooks
vscode "ms-toolsai.jupyter-keymap"              # Jupyter keymaps for notebooks
vscode "ms-toolsai.jupyter-renderers"           # Renderers for Jupyter Notebooks (with plotly, vega, gif, png, svg, jpeg and other such outputs)
vscode "ms-toolsai.jupyter"                     # Jupyter notebook support, interactive programming and computing that supports Intellisense, debugging and more.
vscode "ms-toolsai.vscode-jupyter-cell-tags"    # Jupyter Cell Tags support for VS Code
vscode "ms-toolsai.vscode-jupyter-slideshow"    # Jupyter Slide Show support for VS Code

## Preferred but currently uninstalled formulae and casks:
# brew "heroku"                            # Everything you need to get started with Heroku
# brew "mysql", restart_service: true      # Open source relational database management system
# brew "postgresql", restart_service: true # Object-relational database system
# brew "redis", restart_service: true      # Persistent key-value database, with built-in net interface
# cask "brave-browser"                     # Web browser focusing on privacy
# cask "db-browser-for-sqlite"             # Browser for SQLite databases
# cask "docker"                            # App to build and share containerised applications and microservices
# cask "drawio"                            # Online diagram software
# cask "firefox"                           # Web browser
# cask "flotato"                           # Tool to turn any web page into a desktop app
# cask "postgres"                          # No longer hosted on homebrew; download from https://postgresapp.com/        # Multi-version Postgres.app
# cask "sequel-pro"                        # MySQL/MariaDB database management platform
# cask "stack-stack"                       # Prefer v4 beta version from https://stackbrowser.com/                       # Workspace to manage all your productivity apps from one place
# cask "tableplus"                         # Native GUI tool for relational databases
# mas "Window Focus", id: 1142625137       # License purchased directly from developer. Download from https://fiplab.com/
