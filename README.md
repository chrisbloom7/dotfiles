# chrisbloom7/dotfiles

My personal [dotfiles][dotfiles] for setting and configuring workstations and development containers.

This repo serves a number of functions:

- record my configuration and development preferences over time
- preserve my current configuration and preferences in case of catastrophic failure
- quickly setup a new development environment[^target-envs]
- keep important files synced between local development workstations
- ensure a consistent experience on GitHub Codespaces[^codespaces] and other transient development environments
- practice my bash scripting skills
- help others learn about configuring their own dotfiles, the same way that I learned from others before me

Please feel free to explore, learn from, copy portions of, or fork this repo for [your own dotfiles](#your-own-dotfiles).

## Usage

### macOS And Linux Workstations

See the [Preparing your Workspace](#preparing-your-workspace) section below for detailed instructions on backing up, synchronizing, and setting up Mac or Linux workstation.

### Github Codespaces

[GitHub Codespaces][codespaces] are a great way to quickly spin up fully functional remote Linux-based development environments for any GitHub repository you have access to. You can use your dotfiles to personalize your Codespaces environment by following these steps:

1. [Enable Codespaces][codespaces-enablement] for your account.
2. Enable [adding you dotfiles repository][codespaces-dotfiles] for Codespaces.
3. Create a new Codespace in a repository that you have enabled Codespaces for.
4. Codespaces will run the `setup` script [automatically][codespaces-script-names] to configure your Codespace.

### Transient Containers

You can use these dotfiles to configure transient development environments such as [devcontainers][devcontainers], Dockerfiles, and other transient containers.[^target-envs] Here's how:

1. Perform a [shallow clone][shallow-clone] of this repository into your container.

   ```shell
   git clone -–depth -1 https://github.com/chrisbloom7/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the `setup` script in this repository to configure your devcontainer.

   ```shell
   # Use `./setup --help` to see all available options
   ./setup
   ```

## Contents

A brief overview of some of the most important files and directories in this repository:

- [`bin`](./bin) A directory containing various utility programs that are used during the setup process and elsewhere in these dotfiles.
  - [`bin/generate-ssh`](./bin/generate-ssh) A script that generates an SSH key and walks you through the process of adding it to your GitHub account.
  - [`bin/generate-gpg`](./bin/generate-gpg) A script that generates a GPG key to use for signing commits, and walks you through the process of adding it to your GitHub account.
  - [`bin/import_config`](./bin/import_config) A utility script to import existing config files into the dotfiles repo. It moves each file from `$HOME` into `configs/<tool>/` at the same relative path, then immediately links it back into place. Usage: `bin/import_config [<tool-name>] <path> [<path> ...]`. For example: `bin/import_config claude ~/.claude/settings.json`. Omit the tool name to pick a folder interactively with `fzf`.
  - [`bin/link_configs`](./bin/link_configs) Links every file in `configs/<tool>/` to the same relative path under `$HOME`. Run automatically by the setup scripts; pass tool names to link only those.
  - [`bin/mackup_sync`](./bin/mackup_sync) Runs [Mackup][mackup] in link mode where macOS allows it and copy mode elsewhere.[^mackup-modes] `install` moves local settings into the Mackup folder and links them (first machine), `restore` brings them back on a new machine, `backup` refreshes the copy-mode backups, and `check` reports anything that should be linked but isn't.
  - [`bin/mackup_audit`](./bin/mackup_audit) Checks the Mackup configs before `mackup_sync` changes anything: the storage folder exists, no app is in both modes, no linked app has files macOS won't let it symlink, no synced app covers a file linked from `configs/`, and no synced files contain broken symlinks.
  - [`bin/mackup_backup_schedule`](./bin/mackup_backup_schedule) Adds, removes, or shows a weekly `launchd` job that runs `mackup_sync backup`. Usage: `bin/mackup_backup_schedule add [--weekday 0-7] [--hour 0-23] [--minute 0-59]`.
- [`run-tests`](./run-tests) A convenience script that runs the full BATS test suite (`tests/`). Requires `bats-core` to be installed (included in the prerequisites). Run with `./run-tests` or pass BATS flags directly, e.g. `./run-tests --filter symlink_config`.
- [`configs/`](./configs) A directory containing program specific configuration files that will be symlinked to your home directory as necessary. Because they are symlinked, they can be treated like any other config file and changes will be reflected here in this repo to commit. If you find that you are frequently discarding these changes without commiting them, that's likely a sign that config file shouldn't be managed by this repo. A few notable config files are:
  - Each `configs/<tool>/` folder mirrors your home directory: `configs/mise/.config/mise/config.toml` is linked to `~/.config/mise/config.toml`, and so on. Add a file to a folder and it will be linked the next time the setup scripts (or [`bin/link_configs`](./bin/link_configs)) run; remove it and its stale link is cleaned up. Files ending in `.template` are copied instead of linked, a top-level `README.md` is not linked, and an executable `hooks/post-link` runs after the folder is linked for any special cases.
  - [`configs/mackup/`](./configs/mackup) Configuration for [Mackup][mackup], which syncs settings that don't belong in this repo through Dropbox (or another [storage provider][storages]). This repo manages config files shared by every development environment, including Codespaces and containers, and ones worth tracking changes to over time. Mackup manages everything else: non-development apps, apps without a simple config file, machine-specific settings, and secrets that can't go in a public repo (e.g. `~/.aliases`, `~/.netrc`, `~/.aws`). The two must never manage the same file; [`bin/mackup_audit`](./bin/mackup_audit) enforces this.
    - [`.mackup.cfg`](./configs/mackup/.mackup.cfg) Link mode, used for every app that isn't ignored. Ignores apps managed by this repo, apps that are never synced, and copy-mode apps.
    - [`.mackup-copy.cfg`](./configs/mackup/.mackup-copy.cfg) Copy mode, for apps with files where macOS 14+ doesn't support symlinks (`~/Library/Preferences`, `~/Library/Containers`, `~/Library/Group Containers`), or that replace or corrupt linked files. Every app here must also be ignored in `.mackup.cfg`.
    - [`.mackup/`](./configs/mackup/.mackup) Custom app definitions. A file named after one of Mackup's built-in apps replaces it; `bash.cfg`, `ruby.cfg`, and `claude-code.cfg` do this to leave out files linked from this repo.
  - [`configs/omz/.oh-my-zsh/custom/aliases.zsh`](./configs/omz/.oh-my-zsh/custom/aliases.zsh) A list of aliases that will be loaded into zsh by Oh My Zsh.
  - [`configs/omz/.oh-my-zsh/custom/paths.zsh`](./configs/omz/.oh-my-zsh/custom/paths.zsh) A list of directories that will be added to the zsh `$PATH` by Oh My Zsh.
  - [`configs/zsh/.zshenv`](./configs/zsh/.zshenv) Sourced for *all* zsh invocations (interactive, non-interactive, login, and non-login). Kept intentionally minimal — currently only adds the mise shims directory to `$PATH` so that mise-managed tools are available in scripts and cron jobs that don't source `.zprofile` or `.zshrc`.
- [`assets/`](./assets) Files kept with these dotfiles but never linked, such as iTerm2 color schemes and profiles to import by hand.
- [`scripts`](./scripts) A directory containing various scripts that are used during the setup process. They are called automatically by the `setup` script as needed, but can also be run manually if necessary. A few of the most important files are:
  - `scripts/bootstrap-*`s: (Example: [`scripts/bootstrap-common`](./scripts/bootstrap-common)) Subscripts that run common and platform specific setup steps.
  - [`scripts/configure-macos`](./scripts/configure-macos) Updates various settings on macOS to my preferred configuration. (This tends to be the most brittle of the setup scripts as it relies on specific settings and paths that may change between macOS versions.)
  - [`scripts/install-prerequisites`](./scripts/install-prerequisites) A script that installs several prerequisite applications. These will be installed automatically by the `setup` script, but you can also run it anytime before that if necessary or if you just need a bare bones setup. (Running `./script --bootstrap` is equivalent to running this script.)
- `Brewfile*`s: a set of files that tell Homebrew what applications to install.
- [`setup`](./setup) The main entry point for setting up development environments.

> [!NOTE]
> `~/.aws/config` is intentionally *not* tracked in this repo. It typically contains account-specific SSO profiles and role ARNs that are too environment-specific (and potentially sensitive) for a public repository. Manage it separately and back it up via your preferred secure storage.

> [!TIP]
> All of the setup scripts are designed to be idempotent, meaning they can be run multiple times without causing problems.

## Preparing your Workspace

These steps will guide you through setting up a new Mac or Linux workstation with these dotfiles. If you're setting up a Codespace or other transient development environment, refer to the [Usage](#usage) section above.

> [!NOTE]
> These instructions assume you're satisfied with how I've configured *these* dotfiles. If you'd prefer to configure your own dotfiles you will [find those instructions below](#your-own-dotfiles).

> [!IMPORTANT]
> The installation steps here are idempotent, so you can run them as often as you like as you're making adjustments to the scripts. Note however that they won't *roll back* previous setup steps, even if an error occurs, so you may need to manually unset/uninstall things back to their previous state before trying again.

### 1. Backup Your Data

If you're migrating from an existing Mac or Linux workstation, you should first make sure to backup all of your existing data. Go through the checklist below to make sure you didn't forget anything before you migrate.

> [!CAUTION]
> While Mackup isn't required, if you do choose to use it then I would strongly recommend using a [storage provider][storages] that supports versioning, i.e. *not iCloud*, in case you need to recover from a bad backup or restore operation. Never run a plain `mackup restore` with these configs; it replaces every linked file with a copy. Use [`bin/mackup_sync`](./bin/mackup_sync) instead.[^mackup-modes]

Did you...

- [ ] commit and push any changes to locally checked out git repositories?
- [ ] incorporate any important differences in the config files that will be symlinked from the the [`configs`](./configs) into this repo?
- [ ] cross-check the list of currently installed Homebrew formulae and casks against the Brewfiles?
- [ ] backup all important files that aren't automatically synced to iCloud, Dropbox, Google Drive, Adobe Cloud, etc?
- [ ] export important data from locally running databases and other services that you might need on the new workstation?
- [ ] install or update to the latest version of [Mackup][mackup]?
- [ ] configure Mackup to use your preferred storage provider and exclude `mackup` from backing up itself?
- [ ] run `bin/mackup_sync check`, fix anything it reports, then run `bin/mackup_sync backup`?[^mackup-modes]

### 2. Setting Up Your New Workstation

After backing up your old workstation you may now follow these install instructions to setup a new one.

> [!NOTE]
> This process cannot run unattended - you may be prompted for your password several times in addition to other system prompts.

> [!TIP]
> While you can technically use a different location than `~/.dotfiles`, I strongly recommend you don't due to how many references you'd need to update throughout the scripts.

1. Update your OS to the latest version through system preferences
2. Install `git` if it's not already installed
3. Clone this repo to `~/.dotfiles`:

   ```shell
   git clone https://github.com/chrisbloom7/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

4. Run the installation:

   1. To run a full setup:

      ```shell
      # Tip: You can pass the `--help` flag to the setup script to see available options.
      ./setup
      ```

   2. If you'd prefer to start with only a minimal set of applications:

      ```shell
      ./setup --minimal
      ```

      You can always run the full `./setup` later. This has the advantage of giving you a stable development environment to tinker with the remaining setup scripts before proceeding, and is my preferred approach when setting up a new workstation.
   3. Since the setup scripts are idempotent, you can perform the setup in phases if you prefer. For example:

      ```shell
      # Install prerequisites
      ./setup --bootstrap

      # Perform any manual steps, e.g. editing, setup, testing, etc., then install the minimal set of applications
      ./setup --minimal

      # Perform any additional steps, then install the remaining applications
      ./setup
      ```

   4. You can also run the individual scripts in the `scripts` directory if you prefer a more granular approach. For example, to perform only the configuration settings for macOS:

      ```shell
      # Tip: Use the `--help` option with any file in the `scripts/` directory to see available options.
      ./scripts/configure-macos
      ```

5. If you use a password manager like 1Password, set it up now and sync your passwords.
6. Setup the sync utility for whatever cloud storage provider you use with Mackup (Dropbox, Google Drive, etc.). Wait for the Mackup folder to finish syncing, and mark it as available offline so linked files are never online-only. Mackup must only run after `./setup`, which links the Mackup configs that keep it away from files managed by this repo.
7. Run `bin/mackup_sync --dry-run restore` to verify your setup. You should see the copy-mode files to be restored, then the link-mode files to be linked.
8. Restore your settings by running `bin/mackup_sync restore`.[^mackup-modes] Optionally, schedule weekly copy-mode backups with `bin/mackup_backup_schedule add`.
9. Restart your workstation to ensure all changes take effect.
10. Open any applications that you expect to run on startup like 1Password, Dropbox, etc. and make sure they're configured correctly.
11. [Optional] Setup an SSH key.
    1. You can either use an existing SSH key or create a new one:
       1. Sync an existing SSH key from another machine, such as via 1Password's [SSH agent](https://developer.1password.com/docs/ssh/get-started/#step-3-turn-on-the-1password-ssh-agent), etc.
       2. [Generate a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) by running the following script and following the prompts:

          ```shell
          bin/generate-ssh
          ```

    2. [Add your SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
12. [Optional] Setup a GPG key.
    1. You can either use an existing GPG key or create a new one:
       1. Sync an existing GPG key from another machine
       2. [Generate a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) by running the following script and following the prompts:

          ```shell
          bin/generate-gpg
          ```

          Follow the prompts to enter a passphrase and generate the key.
    2. [Add your GPG key to your GitHub account](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)

🎉 **Your workstation is now ready to use!**

### 3. Cleaning Your Old Workstation

After you've set up a new workstation you may want to wipe your old one.

- For macOS: Follow [this article](https://support.apple.com/guide/mac-help/erase-and-reinstall-macos-mh27903/mac) to do that.
- For Linux: Try [this article](https://www.cyberciti.biz/faq/how-do-i-permanently-erase-hard-disk/).

## Your Own Dotfiles

> [!IMPORTANT]
> Please note that the instructions below assume you are using zsh as your default shell and are using it with [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started). If you are using a different shell or are not using Oh My Zsh, you will need to adjust the instructions accordingly.

> [!CAUTION]
> Pay special attention to the names of the files and directories in your dotfiles repo. While they may not matter so much for setting up a local development environment, they can be important when it comes to setting up a Codespace or other devcontainer where [assumptions are made][codespaces-script-names] about the location and names of certain files that may be run automatically.

If you want to start with your own dotfiles from this setup, it's pretty easy to do so. First of all you'll need to fork this repo. Then you'll want to go through and update any references to `chrisbloom7` and `chrisbloom7/dotfiles` to use your own username and dotfiles repo name. After that you can tweak the scripts any way you want. See the [contents](#contents) section above for info about notable files and folders you may want to explore. Here are some additional steps you may want to take:

- Go through the [`scripts/configure-macos`](./scripts/configure-macos) file and adjust the settings to your liking. You may find it useful to reference [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) as well as [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/macOS-Defaults).
- Check out the `Brewfile.*` files and adjust the apps you want to install for your machine. Use `brew search` or [their search page](https://formulae.brew.sh/cask/) to check if the app you want to install is available.
  - You can generate a Brewfile of your currently installed formulae, casks, etc., with `brew bundle dump --all --describe --file="Brewfile.${$(uname -n)%.local}.local"` then manually copy/paste the apps you want to keep into the appropriate `Brewfile.*` file.
  - Files named `Brewfile*.local` are ignored by git so your local Brewfile packages will remain private and separate from the repo.
  - Packages listed in any `Brewfile*.local` files in the root of the dotfiles directory **will** be installed by the `setup` script by default. This allows you to use these files to install packages that are specific to your local machine, such as those that you don't want to share with others or that are not available on other platforms. You can suppress this feature by specifying the `--skip-local` option, which is also implied with the `--bootstrap` or `--minimal` options.
- Go through the subfolders in [`configs`](./configs) to add your own config files. Each folder mirrors your home directory, so a file's path in the folder is where it will be linked.
- You can adjust the [`zsh` config files](./configs/zsh) to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization). Make sure your `~/.zshrc` file is symlinked *from* your dotfiles repo *to* your home directory first so you can commit any changes to it.

When installing these dotfiles for the first time you'll need to move your settings into Mackup.[^mackup-modes] Your settings will be synced to Dropbox so you can use them to sync between computers and reinstall them when reinstalling your Mac. If you want to save your settings to a different directory or different storage than Dropbox, update the `[storage]` section in both [Mackup configs](./configs/mackup) ([documentation](https://github.com/lra/mackup/blob/master/doc/README.md#storage)). Then check the configs and move your settings with the commands below:

```zsh
brew install mackup
bin/mackup_sync check
bin/mackup_sync --dry-run install
bin/mackup_sync install
```

You can tweak the shell theme, the Oh My Zsh settings and much more. Go through the files in this repo and tweak everything to your liking.

Enjoy your own Dotfiles!

## Acknowledgements

Thanks first and foremost to [@driesvints](https://github.com/driesvints), whose own [dotfiles repo](https://github.com/driesvints/dotfiles?tab=readme-ov-file#your-own-dotfiles) was the inspiration for this one. While this repository should not be considered a direct fork of @driesvints upstream repository at this point due to the significant changes I've made to it, I do still occasionally go back to read through the changelog and manually merge in upstream changes that I find useful. I've also borrowed liberally from his README structure and content, so thank you for that!

In addition to [Vints' own sentiments](https://github.com/driesvints/dotfiles?tab=readme-ov-file#thanks-to), which I enthusiastically `+1` & 👍, thank you to anyone who has open-sourced their own projects, dotfiles or otherwise, present, past, or future, for contributing something to the open-source community. It's often a thankless job, but I appreciate everyone who has and will pay it forward. 🙏

<!-- Footnotes -->
[^codespaces]: I tend to use [devcontainers][devcontainers] such as [GitHub Codespaces][codespaces] for most of my development these days, so having a local development environment where I install "[all the things!](https://web.archive.org/web/20240807175656if_/https://www.simplybusiness.co.uk/wp-content/uploads/sites/3/2024/05/things.webp)" is much less important than it used to be. As a result, the local setup scrips are focused on daily use and productivity tools. The more intensive development tools like databases, caches, servers, compilers, etc, are offloaded to containers.
[^mackup-modes]: Before macOS 14 (Sonoma), Mackup always moved settings into its storage folder and replaced them with symlinks, so every machine shared one live copy. macOS 14+ [doesn't support symlinked preferences][mackup-link-mode], so Mackup 0.9 made `backup` and `restore` copy files instead and moved symlinking to `mackup link install`, `mackup link`, and `mackup link uninstall`. `mackup uninstall` no longer exists. These dotfiles use link mode wherever macOS allows it and copy mode for the rest; [`bin/mackup_sync`](./bin/mackup_sync) runs both with the right config. Copy-mode settings are only as current as the last `mackup_sync backup`, so consider scheduling it with [`bin/mackup_backup_schedule`](./bin/mackup_backup_schedule).
[^target-envs]: The setup scripts in this repo have been tested on macOS and Ubuntu systems. YMMV on other platforms.

<!-- Anchors -->
[codespaces]: https://github.com/features/codespaces
[codespaces-dotfiles]: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#enabling-your-dotfiles-repository-for-codespaces
[codespaces-enablement]: https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/enabling-or-disabling-github-codespaces-for-your-organization
[codespaces-script-names]: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles
[devcontainers]: https://containers.dev/
[dotfiles]: https://dotfiles.github.io/
[mackup]: https://github.com/lra/mackup
[mackup-link-mode]: https://github.com/lra/mackup/issues/2035
[shallow-clone]: https://github.blog/open-source/git/get-up-to-speed-with-partial-clone-and-shallow-clone/#user-content-shallow-clones
[storages]: https://github.com/lra/mackup?tab=readme-ov-file#supported-storages
