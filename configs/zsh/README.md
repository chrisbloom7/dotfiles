# zsh

<https://www.freecodecamp.org/news/how-do-zsh-configuration-files-work/>

- `.zshenv`: Loaded for all types of shell sessions (interactive or non-interactive, login or non-login). It is the only configuration file loaded for non-interactive, non-login scripts like cron jobs. However, macOS overrides this for `PATH` settings for interactive shells.
- `.zprofile`: Loaded for login shells. macOS uses this to set up the shell for any new terminal window. Subshells inherit its settings but don't load it again.
- `.zshrc`: Loaded only for interactive shell sessions, whenever a new terminal window or subshell is opened.
- `.zlogin`: Only used for login shells, loaded after `.zprofile`.
- `.zlogout`: Only used for login shells, loaded whenever a login shell exits.

Use `~/.zprofile` to set `PATH` and `EDITOR`. Use `~/.zshrc` for aliases, a custom prompt, and other interactive tweaks.
