# bash

<https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html>

- `/etc/profile`: System-wide initialization file executed during login. Provides initial environment variables and initial `PATH` locations.
- `/etc/bashrc`: System-wide initialization file executed each time a Bash shell is opened. Values can be overridden by `~/.bashrc`.
- `~/.bash_profile`: Executed after `/etc/profile` during login. Only executed once at login and normally then runs `~/.bashrc`.
- `~/.bash_login`: Executed at login if `~/.bash_profile` does not exist.
- `~/.profile`: Executed at login if neither `~/.bash_profile` nor `~/.bash_login` exist.
- `~/.bashrc`: Read at login and each time a new Bash shell is started. Ideally, this is where aliases go.
- `~/.bash_logout`: Executed automatically during logout.
- `~/.inputrc`: Customizes key bindings.
- `~/.bash_aliases`: Keeps aliases tidy. Source it in `.bashrc` with `if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi`.
