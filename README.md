# chrisbloom7/dotfiles

My personal [dotfiles][dotfiles] for setting and configuring workstations and development containers.

This repo serves a number of functions:

- record my configuration and development preferences over time
- preserve my current configuration and preferences in case of catastrophic failure
- quickly setup a new development environment[^target-envs]
- keep important files synced between local development workstations
- ensure a consistent experience on [GitHub Codespaces][^codespaces] and other transient development environments
- practice my bash scripting skills[^bash-abilities]
- help others learn about configuring their own dotfiles, the same way that I learned from others before me

Please feel free to explore, learn from, copy portions of, or fork this repo for [your own dotfiles](#your-own-dotfiles).

## Usage

### Macos And Linux Workstations

See the [Setting up your Workspace](#setting-up-your-workspace) section below for detailed instructions on backing up, synchronizing, and setting up Mac or Linux workstation.

### Github Codespaces

[GitHub Codespaces][codespaces] are a great way to quickly spin up fully functional remote Linux-based development environments for any GitHub repository you have access to. You can use your dotfiles to personalize your Codespaces environment by following these steps:

1. [Enable Codespaces][codespaces-enablement] for your account.
2. Enable [adding you dotfiles repository][codespaces-dotfiles] for Codespaces.
3. Create a new Codespace in a repository that you have enabled Codespaces for.
4. Codespaces will run the `setup` script [automatically][codespaces-script-names] to configure your Codespace.

### Transient Containers

You can use these dotfiles to configure transient development environments such as [devcontainers][devcontainers], Dockerfiles, and other transient containers[^target-envs]. Here's how:

1. Perform a [shallow clone][shallow-clone] of this repository into your container.

   ```shell
   git clone -–depth -1 https://github.com/chrisbloom7/dotfiles.git ~/.dotfiles
   ```

2. Run the `setup` script in this repository to configure your devcontainer.

   ```shell
   cd ~/.dotfiles
   ./setup
   ```

## Contents

A brief overview of some of the most important files and directories in this repository:

- `Brewfile*`s: a set of files tell Homebrew what applications to install.
  - [`Brewfile`](./Brewfile) Non-essential applications that I like to have installed on my development machines. This file will be skipped unless the `--minimal` flag is passed to `setup`.
  - [`Brewfile.minimal`](./Brewfile.minimal) A list of applications I consider to be essential. If the `--minimal` flag is passed to `setup` then only these programs will be installed.
- [`configs/`](./configs) A directory containing program specific configuration files that will be symlinked to your home directory as necessary. A few of the most important files are:
  - `configs/**/symlink` ([Example](./configs/zsh/symlink)) Scripts that symlink the files in their directory to the home directory. These scripts are run by the bootstrap scripts and typically do not need to be called manually, though you can if you want to.
  - [`configs/mackup/.mackup.cfg`](./configs/mackup/.mackup.cfg) A configuration file for [Mackup][mackup], the program used to backup configuration settings on macOS and Linux. The file specifies the storage provider where settings will be backed up to and restored from, as well as a list of applications to ignore when backing up. You can adjust this file to your liking.
  - [`configs/zsh/aliases.zsh`](./configs/zsh/aliases.zsh) A list of aliases that will be loaded into zsh by Oh My Zsh.
  - [`configs/zsh/path.zsh`](./configs/zsh/path.zsh) A list of directories that will be added to the zsh `$PATH` by Oh My Zsh.
- [`scripts`](./scripts) A directory containing various scripts that are used during the setup process.
  - `scripts/bootstrap-*`s Subscripts that run common and application specific setup steps. Called automatically by the `setup` script.
  - `scripts/configure-macos`s Updates various ssettings on MacOSX to my preferred configuration. Called automatically by the `setup` script.
  - [`scripts/install-prerequisites`](./scripts/install-prerequisites) A script that installs several prerequisite applications before the full `setup` script can be run. [More details](#2-setting-up-your-workstation).
  - [`scripts/generate-ssh`](./scripts/generate-ssh) A script that generates an SSH key and walks you through the process of adding it to your GitHub account. Must be run manually as needed.  [More details](#2-setting-up-your-workstation).
  - [`scripts/generate-gpg`](./scripts/generate-gpg) A script that generates a GPG key to use for signing commits, and walks you through the process of adding it to your GitHub account. Must be run manually as needed. [More details](#2-setting-up-your-workstation).
  - [`scripts/restore-symlinks-after-mackup-uninstall`](./scripts/restore-symlinks-after-mackup-uninstall) A utility script that addresses a bug in `mackup` commands on macOS Sonoma and up. [^mackup-sonoma]
- [`setup`](./setup) The main entry point for setting up development environments.

> [!TIP]
> All of the scripts[^bash-abilities] in this repository are designed to be idempotent, meaning they can be run multiple times without causing problems.

## Runtime Options

All of the scripts in this repository accept a number of options that can be used to customize their behavior.

| Option | Description | Applies To |
|---|---|---|
| -h, --help | Display this list | All scripts |
| -m, --minimal | Install bare minimum packages (ignored if --no-install or --prerequisites is set) | `setup` |
| -n, --no-install | Skip installation steps, only run config and symlink steps (ignored if --prerequisites is set) | `setup` |
| -p, --prerequisites | Install prerequisites then exit | `setup` |
| -q, --quiet | Print fewer status messages (ignored if --verbose is set) | All scripts |
| -v, --verbose | Print additional status messages (ignored if --quiet is set) | All scripts |

## Setting Up Your Workspace

These steps will guide you through setting up a new Mac or Linux workstation with these dotfiles. If you're setting up a Codespace or other transient development environment, refer to the [Usage](#usage) section above.

> [!NOTE]
> These instructions are for when you've already set up your dotfiles. If you want to get started with your own dotfiles you can [find instructions below](#your-own-dotfiles).

> [!IMPORTANT]
> The installation steps here are idempotent, so you can run them as often as you like as you're making adjustments to the scripts. Note however that they won't *roll back* previous setup steps, even if an error occurs, so you may need to manually unset/uninstall things back to their previous state before trying again.

### 1. Backup Your Data

> [!TIP]
> While `mackup` isn't required, if you do choose to use it then I would strongly recommend using a [storage provider][storages] that supports versioning, i.e. *not iCloud*, in case you need to recover from a bad backup or restore operation.

> [!CAUTION]
> See this footnote [^mackup-sonoma] about a bug in `mackup` that affects macOS 14 (Sonoma) and later versions.

If you're migrating from an existing Mac or Linux workstation, you should first make sure to backup all of your existing data. Go through the checklist below to make sure you didn't forget anything before you migrate.

Did you...

- [ ] commit and push any changes to locally checked out git repositories?
- [ ] backup all important files that aren't automatically synced to iCloud, Dropbox, Google Drive, Adobe Cloud, etc?
- [ ] export important data from locally running databases and other services?
- [ ] make sure [Mackup][mackup] is installed and updated to the latest version?
- [ ] run `mackup backup --force && mackup uninstall --force`? [^mackup-sonoma]

### 2. Setting Up Your Mac

> [!NOTE]
> This process cannot run unattended - you may be prompted for your password several times.

> [!TIP]
> While you can technically use a different location than `~/.dotfiles`, I strongly recommend you don't due to how many references you'd need to update throughout the scripts.

After backing up your old workstation you may now follow these install instructions to setup a new one.

1. Update your OS to the latest version through system preferences
2. Install `git` if it's not already installed
3. Clone this repo to `~/.dotfiles`:

   ```shell
   git clone git@github.com:chrisbloom7/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

4. Install the prerequisites:

   ```shell
   ./setup --prerequisites
   ```

   This script will install the following tools:

   - [GPG Suite](https://gpgtools.org)
   - [Homebrew](https://brew.sh) and core utilities
   - [Mac App Store CLI](https://github.com/mas-cli/mas) (macOS only)
   - [Xcode Command Line Tools](https://developer.apple.com/downloads) (macOS only)

5. Run the installation with:

   ```shell
   ./setup
   ```

6. If you use a password manager like 1Password, set it up now and sync your passwords.
7. Setup whatever cloud storage provider you use with Mackup (iCloud, Dropbox, Google Drive, etc.). Be sure your Mackup backup folder is available locally. Run `mackup restore --dry-run` to see what files will be restored.
8. Once your Mackup cloud storage provider is ready, restore preferences by running `mackup restore --force && mackup uninstall --force && scripts/restore-symlinks-after-mackup-uninstall`. [^mackup-sonoma]
9. Restart your workstation to ensure all changes take effect.
10. Open any applications that you expect to run on startup like 1Password, Dropbox, etc. and make sure they're configured correctly.
11. Setup an SSH key. You can either use an existing SSH key or create a new one.
    1. Sync an existing SSH key from another machine, such as via 1Password's [SSH agent](https://developer.1password.com/docs/ssh/get-started/#step-3-turn-on-the-1password-ssh-agent), etc.
    2. [Generate a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) by running the following script and following the prompts:

       ```shell
       scripts/generate-ssh
       ```

12. [Add your SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
13. Setup a GPG key. You can either use an existing GPG key or create a new one.
    1. Sync an existing GPG key from another machine
    2. [Generate a new GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) by running the following script and following the prompts:

       ```shell
       scripts/generate-gpg
       ```

    Follow the prompts to enter a passphrase and generate the key.
14. [Add your GPG key to your GitHub account](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)

🎉 **Your workstation is now ready to use!**

### 3. Cleaning Your Old Workstation

After you've set up a new workstation you may want to wipe your old one.

- For macOS: Follow [this article](https://support.apple.com/guide/mac-help/erase-and-reinstall-macos-mh27903/mac) to do that.
- For Linux: Try [this article](https://www.cyberciti.biz/faq/how-do-i-permanently-erase-hard-disk/).

## Your Own Dotfiles

> [!IMPORTANT]
> Please note that the instructions below assume you already have set up Oh My Zsh so make sure to first [install Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started) before you continue.

> [!TIP]
> Pay special attention to the names of the files and directories in this repository. While they may not matter so much for setting up a local development environment, they can be important when setting up a Codespace or other devcontainer where [assumptions are made][codespaces-script-names] about the location and names of certain files and directories.

If you want to start with your own dotfiles from this setup, it's pretty easy to do so. First of all you'll need to fork this repo. After that you can tweak it the way you want.

Go through the [`.macos`](./.macos) file and adjust the settings to your liking. You can find much more settings at [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/macOS-Defaults).

Check out the [`Brewfile`](./Brewfile) file and adjust the apps you want to install for your machine. Use `brew search` or [their search page](https://formulae.brew.sh/cask/) to check if the app you want to install is available.

Check out the [`aliases.zsh`](./configs/zsh/aliases.zsh) file and add your own aliases. If you need to tweak your `$PATH` check out the [`path.zsh`](./configs/zsh/path.zsh) file. These files get loaded in because the `$ZSH_CUSTOM` setting points to the `.dotfiles/configs/zsh` directory. You can adjust the [`.zshrc`](./configs/zsh/.zshrc) file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization). Make sure your `~/.zshrc` file is symlinked from your dotfiles repo to your home directory.

When installing these dotfiles for the first time you'll need to backup all of your settings with Mackup. [^mackup-sonoma] Install Mackup and backup your settings with the commands below. Your settings will be synced to iCloud so you can use them to sync between computers and reinstall them when reinstalling your Mac. If you want to save your settings to a different directory or different storage than iCloud, [checkout the documentation](https://github.com/lra/mackup/blob/master/doc/README.md#storage).

```zsh
brew install mackup
mackup backup --force && mackup uninstall --force
```

You can tweak the shell theme, the Oh My Zsh settings and much more. Go through the files in this repo and tweak everything to your liking.

Enjoy your own Dotfiles!

## Acknowledgements

Thanks first and foremost to [@driesvints](https://github.com/driesvints), whose own [dotfiles repo](https://github.com/driesvints/dotfiles?tab=readme-ov-file#your-own-dotfiles) was the inspiration for this one. While this repository should not be considered a direct fork of @driesvints upstream repository at this point due to the significant changes I've made to it, I do still occasionally go back to read through the changelog and manually merge in upstream changes that I find useful. I've also borrowed liberally from his README structure and content, so thank you for that!

In addition to [Vints' own sentiments](https://github.com/driesvints/dotfiles?tab=readme-ov-file#thanks-to), which I enthusiastically `+1` & 👍, thank you to anyone who has open-sourced their own projects, dotfiles or otherwise, present, past, or future, for contributing something to the open-source community. It's often a thankless job, but I appreciate everyone who has and will pay it forward. 🙏

<!-- Footnotes -->
[^bash-abilities]: I would not consider not a bash expert, so there are likely better ways to do some of the things I've done here. I'm always open to suggestions for improvement!
[^codespaces]: I tend to use [devcontainers][devcontainers] such as [GitHub Codespaces][codespaces] for most of my development these days, so having a local development environment where I install [all the things](https://web.archive.org/web/20240807175656if_/https://www.simplybusiness.co.uk/wp-content/uploads/sites/3/2024/05/things.webp) is much less important than it used to be. As a result, the local setup scrips are focused on daily use and productivity tools, and the more intensive development tools like databases, memcache servers, compilers, etc, are offloaded to containers.
[^mackup-sonoma]: As of this writing, `mackup backup` and `mackup restore` commands [have a bug][mackup-sonoma] that affects macOS 14 (Sonoma) and later versions due to changes in the way macOS handles file permissions. There is an accepted [workaround][mackup-sonoma-workaround] that some folks have found success with, but you should be aware of the risks before proceeding. You can always skip the `mackup` steps if you're not comfortable with the risk.
[^target-envs]: The setup scripts in this repo primarily target setting up full development environments on local macOS machines (my preferred choice for development machines), and lightweight Linux development containers. YMMV on other platforms.

<!-- Anchors -->
[codespaces]: https://github.com/features/codespaces
[codespaces-dotfiles]: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#enabling-your-dotfiles-repository-for-codespaces
[codespaces-enablement]: https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/enabling-or-disabling-github-codespaces-for-your-organization
[codespaces-script-names]: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles
[devcontainers]: https://containers.dev/
[dotfiles]: https://dotfiles.github.io/
[mackup]: https://github.com/lra/mackup
[mackup-sonoma]: https://github.com/lra/mackup/issues/1924
[mackup-sonoma-workaround]: https://github.com/lra/mackup/issues/1924#issuecomment-1756330534
[shallow-clone]: https://github.blog/open-source/git/get-up-to-speed-with-partial-clone-and-shallow-clone/#user-content-shallow-clones
[storages]: https://github.com/lra/mackup?tab=readme-ov-file#supported-storages
