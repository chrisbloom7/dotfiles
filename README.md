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
  - [`bin/restore_symlinks_after_mackup_uninstall`](./bin/restore_symlinks_after_mackup_uninstall) A utility script to help workaround a bug in Mackup commands on macOS Sonoma and up.[^mackup-sonoma]
- [`configs/`](./configs) A directory containing program specific configuration files that will be symlinked to your home directory as necessary. Because they are symlinked, they can be treated like any other config file and changes will be reflected here in this repo to commit. If you find that you are frequently discarding these changes without commiting them, that's likely a sign that config file shouldn't be managed by this repo. A few notable config files are:
  - `configs/**/symlink*` (Example: [configs/zsh/symlink_zsh](./configs/zsh/symlink_zsh)) Scripts that handle symlinking the config files in the parent directory to their typical home. These scripts are run automatically by the setup scripts and do not need to be called manually, though you can if you want to. Each of these files' names must start with `symlink` but may include any suffix for identification purposes, and must be marked as executable. If you add a new directory to the `configs` directory, be sure to include a symlink script for it. If you modify the contents of a directory, you may need to update the symlink script to reflect those changes.
  - [`configs/mackup/.mackup.cfg`](./configs/mackup/.mackup.cfg) A configuration file for [Mackup][mackup], the program used to backup configuration settings on macOS and Linux. The file specifies the storage provider where settings will be backed up to and restored from, as well as a list of applications to ignore when backing up. You can adjust this file to your liking, but at a minimum it must include an entry for `mackup` under the `[applications_to_ignore]` section.
  - [`configs/zsh/aliases.zsh`](./configs/zsh/aliases.zsh) A list of aliases that will be loaded into zsh by Oh My Zsh.
  - [`configs/zsh/path.zsh`](./configs/zsh/path.zsh) A list of directories that will be added to the zsh `$PATH` by Oh My Zsh.
- [`scripts`](./scripts) A directory containing various scripts that are used during the setup process. They are called automatically by the `setup` script as needed, but can also be run manually if necessary. A few of the most important files are:
  - `scripts/bootstrap-*`s: (Example: [scripts/bootstrap-common](./scripts/bootstrap-common)) Subscripts that run common and platform specific setup steps.
  - [`scripts/configure-macos`](./scripts/configure-macos) Updates various settings on macOS to my preferred configuration. (This tends to be the most brittle of the setup scripts as it relies on specific settings and paths that may change between macOS versions.)
  - [`scripts/install-prerequisites`](./scripts/install-prerequisites) A script that installs several prerequisite applications. These will be installed automatically by the `setup` script, but you can also run it anytime before that if necessary or if you just need a bare bones setup. (Running `./script --bootstrap` is equivalent to running this script.)
- `Brewfile*`s: a set of files that tell Homebrew what applications to install.
  - [`Brewfile`](./Brewfile) Non-essential applications that I like to have installed on my development machines. This file will be skipped if the `--minimal` flag is passed to `setup`.
  - [`Brewfile.minimal`](./Brewfile.minimal) A list of applications I consider to be essential. If the `--minimal` flag is passed to `setup` then only these programs will be installed.
- [`setup`](./setup) The main entry point for setting up development environments.

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
> While Mackup isn't required, if you do choose to use it then I would strongly recommend using a [storage provider][storages] that supports versioning, i.e. *not iCloud*, in case you need to recover from a bad backup or restore operation.

> [!CAUTION]
> See this footnote[^mackup-sonoma] about a bug in Mackup that affects macOS 14 (Sonoma) and later versions.

Did you...

- [ ] commit and push any changes to locally checked out git repositories?
- [ ] backup all important files that aren't automatically synced to iCloud, Dropbox, Google Drive, Adobe Cloud, etc?
- [ ] export important data from locally running databases and other services?
- [ ] make sure [Mackup][mackup] is installed and updated to the latest version?
- [ ] run `mackup backup --force && mackup uninstall --force`?[^mackup-sonoma]

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

      > [!TIP]
      > You can pass the `--help` flag to the setup script to see all available options.

      ```shell
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

      > [!TIP]
      > As with the `setup` script, use the `--help` with any file in the `scripts/` directory to see available options.

      ```shell
      ./scripts/configure-macos
      ```

5. If you use a password manager like 1Password, set it up now and sync your passwords.
6. Setup the sync utility for whatever cloud storage provider you use with Mackup (iCloud, Dropbox, Google Drive, etc.). Be sure your Mackup backup folder is available locally.
7. Run `mackup restore --dry-run` to verify your setup. You should see a list of files to be restored matching the files you backed up in the previous section.
8. Once your Mackup cloud storage provider is ready, restore preferences by running `mackup restore --force && mackup uninstall --force && bin/restore_symlinks_after_mackup_uninstall`.[^mackup-sonoma]
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
- Check out the [`Brewfile`](./Brewfile) and [`Brewfile.minimal`](./Brewfile.minimal) files and adjust the apps you want to install for your machine. Use `brew search` or [their search page](https://formulae.brew.sh/cask/) to check if the app you want to install is available. You can generate a Brewfile of your currently installed formulae, casks, etc., with `brew bundle dump --all --describe --file="Brewfile.local"` then manually copy/paste the apps you want to keep into `Brewfile` and `Brewfile.minimal`.
- Go hrough the subfolders in [`configs`](./configs) to add your own dotfiles. Don't forget to update the accompanying `symlink` scripts as you add and remove files, and if you add any new folders besure to include a symlink script and make it executable.
- You can adjust the [`.zshrc`](./configs/zsh/.zshrc) file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization). Make sure your `~/.zshrc` file is symlinked from your dotfiles repo to your home directory.

When installing these dotfiles for the first time you'll need to backup all of your settings with Mackup.[^mackup-sonoma] Install Mackup and backup your settings with the commands below. Your settings will be synced to iCloud so you can use them to sync between computers and reinstall them when reinstalling your Mac. If you want to save your settings to a different directory or different storage than iCloud, [checkout the documentation](https://github.com/lra/mackup/blob/master/doc/README.md#storage).

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
[^codespaces]: I tend to use [devcontainers][devcontainers] such as [GitHub Codespaces][codespaces] for most of my development these days, so having a local development environment where I install "[all the things!](https://web.archive.org/web/20240807175656if_/https://www.simplybusiness.co.uk/wp-content/uploads/sites/3/2024/05/things.webp)" is much less important than it used to be. As a result, the local setup scrips are focused on daily use and productivity tools. The more intensive development tools like databases, caches, servers, compilers, etc, are offloaded to containers.
[^mackup-sonoma]: As of this writing, `mackup backup` and `mackup restore` commands [have a bug][mackup-sonoma] that affects macOS 14 (Sonoma) and later versions due to changes in the way macOS handles file permissions. **The [workaround][mackup-sonoma-workaround] is to run `mackup backup --force` or `mackup restore --force` and then immediately run `mackup uninstall --force`.** Normally, when Mackup runs `backup` or `restore` it places symlinks for tracked config files in their original location and keeps the real file in whatever storage provider you've configered. In macOS 14+ the symlinking part fails so it looks like all your configs have been lost. The workaround works by forcing Mackup to complete the `backup` or `restore` operations, overwriting anything in the destination and ignoring failed symlinks. Then the `uninstall` command undoes the symlinking that Mackup thought it performed and replaces the symlinks with copies of the real files. Note however that the workaround does not comes without a little risk so be sure you are using a backup storage provider that supports rolling back changes. You can always skip the Mackup steps if you're not comfortable assuming that risk.
[^target-envs]: The setup scripts in this repo have been tested on macOS and Ubuntu systems. YMMV on other platforms.

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
