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
#    brew bundle dump --all --describe --file=-
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

# Set arguments for installing casks
# https://github.com/homebrew/homebrew-cask/blob/master/USAGE.md#options
# Tip: Use `force: true` to override `require_sha: true` on individual casks
cask_args require_sha: true, no_quarantine: true

## Taps
tap "buo/cask-upgrade"  # A command line tool for upgrading every outdated app installed by Homebrew Cask

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
brew "aom"               # Codec library for encoding and decoding AV1 video streams
brew "awscli"            # Official Amazon AWS command-line interface
brew "bat"               # Clone of cat(1) with syntax highlighting and Git integration
brew "devcontainer"      # Reference implementation for the Development Containers specification
brew "httpie"            # User-friendly cURL replacement (command-line HTTP client)
brew "imagemagick"       # Tools and libraries to manipulate images in many formats
brew "lynx"              # Text-based web browser
brew "notify"            # Stream the output of any CLI and publish it to a variety of supported platforms
brew "pandoc"            # Swiss-army knife of markup format conversion
brew "pkg-config"        # Manage compile and link flags for libraries
brew "putty"             # Implementation of Telnet and SSH
brew "railway"           # Develop and deploy code with zero configuration
brew "telnet"            # User interface to the TELNET protocol
brew "terminal-notifier" # Send macOS User Notifications from the command-line
brew "tmux"              # Terminal multiplexer
brew "watch"             # Executes a program periodically, showing output fullscreen
brew "wget"              # Internet file retriever

## Services
# brew "mysql", restart_service: true      # Open source relational database management system
# brew "postgresql", restart_service: true # Object-relational database system
# brew "redis", restart_service: true      # Persistent key-value database, with built-in net interface

## Casks
cask "adobe-acrobat-reader"   # View, print, and comment on PDF documents
cask "chatgpt"                # OpenAI's official ChatGPT desktop app
cask "chromedriver"           # Automated testing of webapps for Google Chrome
cask "clamxav"                # Anti-virus and malware scanner
cask "cleanmymac"             # Tool to remove unnecessary files and folders from disk
cask "cursor"                 # Write, edit, and chat about your code with AI
cask "cyberduck"              # Server and cloud storage browser
cask "drawio"                 # Online diagram software
cask "drivethrurpg"           # Sync DriveThruRPG libraries to compatible devices
cask "figma"                  # Collaborative team software
cask "firefox"                # Web browser
# cask "flotato"                # Tool to turn any web page into a desktop app
# cask "fluid"                  # Tool to turn a website into a desktop app
cask "freeze"                 # Amazon Glacier file transfer client
cask "garmin-express"         # Update maps and software, sync with Garmin Connect and register your device
cask "gemini"                 # Disk space cleaner that finds and deletes duplicated and similar files
cask "graphiql"               # Light, Electron-based Wrapper around GraphiQL
cask "lm-studio"              # Discover, download, and run local LLMs
cask "microsoft-edge"         # Multi-platform web browser
cask "monofocus"              # Keep all tasks from your todo apps on your menu bar
cask "ngrok"                  # Reverse proxy, secure introspectable tunnels to localhost
# cask "postgres-unofficial"    # App wrapper for PostgreSQL with support for multiple versions and databases
cask "raycast"                # Control your tools with a few keystrokes
cask "screenfocus"            # Tool to manage multiple screens
cask "script-debugger"        # Integrated development environment focused entirely on AppleScript
cask "scriptql"               # AppleScript Quick Look plugin
# cask "sequel-pro"             # MySQL/MariaDB database management platform
cask "shutter-encoder"        # Video, audio and image converter
cask "steam"                  # Video game digital distribution service
cask "transmit"               # File transfer application
cask "versions"               # Subversion client
cask "voodoopad"              # Notes organiser
cask "wavebox"                # Web browser
cask "yubico-yubikey-manager" # Application for configuring any YubiKey

## Fonts
cask "font-0xproto-nerd-font"             # 0xproto Nerd font
cask "font-0xproto"                       # 0xproto font
cask "font-bungee-color"                  # Bungee Color font
cask "font-bungee-hairline"               # Bungee Hairline font
cask "font-bungee-inline"                 # Bungee Inline font
cask "font-bungee-outline"                # Bungee Outline font
cask "font-bungee-shade"                  # Bungee Shade font
cask "font-bungee-spice"                  # Bungee Spice font
cask "font-bungee"                        # Bungee font
cask "font-creepster-caps"                # Creepster Caps font
cask "font-creepster"                     # Creepster font
cask "font-space-grotesk"                 # Space Grotesk font
cask "font-space-mono-nerd-font"          # Space Mono Nerd font
cask "font-space-mono"                    # Space Mono font
cask "font-sudo"                          # Sudo font
cask "font-texturina"                     # Texturina font
cask "font-tilt-warp"                     # Tilt Warp font

## Apps from the Mac App Store
mas "AnySwitch", id: 6_444_313_776
mas "Encrypto", id: 935_235_287
mas "one sec | screen time + focus", id: 1_532_875_441
mas "Photomator", id: 1_444_636_541
mas "QuikFlow", id: 1_626_354_390
mas "Speedtest", id: 1_153_157_709
mas "Video Editor Movavi", id: 1_388_868_440
mas "Microsoft Word", id: 586_447_913
mas "Microsoft Excel", id: 462_058_435
# mas "Window Focus", id: 1142625137 # License purchased directly from developer. Download from https://fiplab.com/

## VS code extensions
vscode "alefragnani.bookmarks"
vscode "assisrMatheus.sidebar-markdown-notes"       # Take notes in your sidebar using markdown
vscode "castwide.solargraph"
vscode "ciarant.vscode-structurizr"                 # Structurizr DSL syntax highlighting
vscode "emilast.logfilehighlighter"
vscode "erikphansen.vscode-toggle-column-selection" # Turn a selection into a column selection à la TextMate
vscode "GraphQL.vscode-graphql-syntax"              # Adds syntax highlighting support for .graphql & embedded support for javascript, typescript, vue, markdown, python, php, reason, ocaml and rescript
vscode "loginspector.loginspector"
vscode "mechatroner.rainbow-csv"                    # Highlight CSV and TSV files, Run SQL-like queries
vscode "MermaidChart.vscode-mermaid-chart"          # The Mermaid Chart extension for Visual Studio Code enables developers to view and edit diagrams stored in Mermaid charts within the Visual Studio Code. With integration to the Mermaid Chart service, this extension allows users to attach diagrams to their code. Gain quick access to edit diagrams.
vscode "mikestead.dotenv"
vscode "ms-vscode-remote.remote-containers"         # Open any folder or repository inside a Docker container and take advantage of Visual Studio Code's full feature set.
vscode "ms-vscode.azure-repos"
vscode "ms-vscode.remote-repositories"              # Remotely browse and edit git repositories
vscode "ms-vscode.vscode-github-issue-notebooks"    # GitHub Issue Notebooks for VS Code
vscode "ms-vscode.wordcount"                        # Markdown Word Count Example - a status bar contribution that reports out the number of works in a Markdown document as you interact with it.
vscode "nextfaze.json-parse-stringify"              # Quickly flick between stringified JSON and POJOs
vscode "phoihos.csv-to-md-table"                    # Convert CSV/TSV/PSV text to GitHub Flavored Markdown table
vscode "rubocop.vscode-rubocop"                     # VS Code extension for the RuboCop linter and code formatter.
vscode "Shopify.ruby-lsp"                           # VS Code plugin for connecting with the Ruby LSP
vscode "streetsidesoftware.code-spell-checker"      # Spelling checker for source code
vscode "tamagui.batsignal"                          # A color theme for bats

## Extension Packs
#
# Brew bundle doesn't do a good job of managing extension packs. Currently you
# must specify the extension pack name and the individual extensions, otherwise
# `brew bundle install --cleanup` will remove any extensions in the pack that
# are not explicitly listed in the Brewfile.

### Jupyter Notebooks
vscode "ms-toolsai.jupyter-keymap"                  # Jupyter keymaps for notebooks
vscode "ms-toolsai.jupyter-renderers"               # Renderers for Jupyter Notebooks (with plotly, vega, gif, png, svg, jpeg and other such outputs)
vscode "ms-toolsai.jupyter"                         # Jupyter notebook support, interactive programming and computing that supports Intellisense, debugging and more.
vscode "ms-toolsai.vscode-jupyter-cell-tags"        # Jupyter Cell Tags support for VS Code
vscode "ms-toolsai.vscode-jupyter-slideshow"        # Jupyter Slide Show support for VS Code
