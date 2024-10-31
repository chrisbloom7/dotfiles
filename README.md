# Introduction

This repository contains my personal dotfiles. It was originally forked from [driesvints/dotfiles](https://github.com/driesvints/dotfiles). The upstream repository has diverged significantly since I first forked it and I've made a number of changes to better suit my own preferences and development environment. I'll occasionally go through and manually merged in upstream changes that I find useful, but this repository should not be considered a direct fork of the upstream repository at this point.

This repo serves a number of functions:

- a record of my configuration and development preferences over time[^bash-abilities]
- a way to quickly and consistently setup a new development environment when I upgrade or replace my laptop[^macos]
- a way to ensure [devcontainers](https://containers.dev/) (e.g. Codespaces) are configured consistently with my local development environment[^codespaces]
- a way to preserve my current configuration and preferences in case of catastrophic failure
- a way to help others learn about configuring their own dotfiles, the same way that I learned from others

Please feel free to explore, learn, copy parts from, and fork this repo for [your own dotfiles](#your-own-dotfiles), or check out the original inspiration for this repository: [driesvints/dotfiles#your-own-dotfiles](https://github.com/driesvints/dotfiles?tab=readme-ov-file#your-own-dotfiles).

## A Fresh macOS Setup

These instructions are for when you've already set up your dotfiles. If you want to get started with your own dotfiles you can [find instructions below](#your-own-dotfiles).

> [!NOTE]
> The installation steps here are intended to be idempotent, so you can run them as often as you like as you're making adjustments to them. However, note that they won't roll back previous setup steps, even if an error occurs, so you may need to manually unset/uninstall things back to their previous state before trying again.
>
> Also note that this process probably cannot run unattended - you'll likely be prompted for your password several times.

> [!WARNING]
> As of this writing, `mackup` [does not work on MacOS 14
> (Sonoma)][mackup-sonoma] due to changes in the way the OS handles file
> permissions. Using it could result in data loss. There is a
> [workaround][workaround] that some folks have found success with, but you
> should be aware of the risks before proceeding. You can always skip the
> `mackup` steps if you're not comfortable with the risk.
>
> Secondly, if you do choose to use `mackup`, I would strongly recommend using a
> [storage provider][storages] that supports versioning, i.e. not iCloud, in
> case you need to recover from a bad `mackup backup` or `mackup restore`.

### 1. Backup your data

If you're migrating from an existing Mac, you should first make sure to backup all of your existing data. Go through the checklist below to make sure you didn't forget anything before you migrate.

- Did you commit and push any changes/branches to your local git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you backup all important files which aren't synced through iCloud, such as Dropbox, Google Drive, Adobe Cloud, etc?
- Did you remember to export important data from your local database?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and have you already run `mackup backup --force && mackup uninstall --force`? (See warning above!)

### 2. Setting up your Mac

After backing up your old Mac you may now follow these install instructions to setup a new one.

1. Update macOS to the latest version through system preferences
2. Setup an SSH key by using one of the two following methods
   2.1. If you use 1Password, install it with the 1Password [SSH agent](https://developer.1password.com/docs/ssh/get-started/#step-3-turn-on-the-1password-ssh-agent) and sync your SSH keys locally.
   2.2. Otherwise [generate a new public and private SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) by running:

   ```zsh
   curl https://raw.githubusercontent.com/chrisbloom7/dotfiles/HEAD/ssh.sh | sh -s "<your-email-address>"
   ```

3. Clone this repo to `~/.dotfiles` with:

    ```zsh
    git clone --recursive git@github.com:chrisbloom7/dotfiles.git ~/.dotfiles
    ```

4. Run the installation with:

    ```zsh
    cd ~/.dotfiles && ./fresh.sh
    ```

5. After mackup is synced with your cloud storage provider, restore preferences by running `mackup restore --force && mackup uninstall --force` followed by `script/relink-files`. (See warning above!)
6. Restart your computer to finalize the process

Your Mac is now ready to use!

> [!NOTE]
> You can use a different location than `~/.dotfiles` if you want. Make sure you also update the references in the [`.zshrc`](./.zshrc) and [`fresh.sh`](./fresh.sh) files.

### 3. Cleaning your old Mac (optionally)

After you've set up your new Mac you may want to wipe and clean install your old Mac. Follow [this article](https://support.apple.com/guide/mac-help/erase-and-reinstall-macos-mh27903/mac) to do that. Remember to [backup your data](#backup-your-data) first!

## Your Own Dotfiles

> [!IMPORTANT]
> Please note that the instructions below assume you already have set up Oh My Zsh so make sure to first [install Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started) before you continue.

If you want to start with your own dotfiles from this setup, it's pretty easy to do so. First of all you'll need to fork this repo. After that you can tweak it the way you want.

Go through the [`.macos`](./.macos) file and adjust the settings to your liking. You can find much more settings at [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/MacOS-Defaults).

Check out the [`Brewfile`](./Brewfile) file and adjust the apps you want to install for your machine. Use `brew search` or [their search page](https://formulae.brew.sh/cask/) to check if the app you want to install is available.

Check out the [`aliases.zsh`](./aliases.zsh) file and add your own aliases. If you need to tweak your `$PATH` check out the [`path.zsh`](./path.zsh) file. These files get loaded in because the `$ZSH_CUSTOM` setting points to the `.dotfiles` directory. You can adjust the [`.zshrc`](./.zshrc) file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization).

When installing these dotfiles for the first time you'll need to backup all of your settings with Mackup. Install Mackup and backup your settings with the commands below. Your settings will be synced to iCloud so you can use them to sync between computers and reinstall them when reinstalling your Mac. If you want to save your settings to a different directory or different storage than iCloud, [checkout the documentation](https://github.com/lra/mackup/blob/master/doc/README.md#storage). Also make sure your `.zshrc` file is symlinked from your dotfiles repo to your home directory.

```zsh
brew install mackup
mackup backup
```

You can tweak the shell theme, the Oh My Zsh settings and much more. Go through the files in this repo and tweak everything to your liking.

Enjoy your own Dotfiles!

## Thanks

Thanks first and foremost to [Dries Vints](https://github.com/driesvints) who's own dotfiles repository was the inspiration for this one, and from which I've borrowed liberally.

In addition to [Vints' own sentiments](https://github.com/driesvints/dotfiles?tab=readme-ov-file#thanks-to), which I enthusiastically `+1` & 👍, thank you to anyone who has open-sourced their own projects, dotfiles or otherwise, present, past, or future, for contributing something to the open-source community. It's often a thankless job, but I appreciate everyone who has and will pay it forward. 🙏

[^bash-abilities]: I'm not a bash expert, so there are likely better ways to do some of the things I've done here. I'm always open to suggestions for improvement!
[^macos]: The "fresh" setup scripts in this repo are built around setting up MacOS laptops specifically, which are my preferred choice for development machines. YMMV if you're using a different OS.
[^codespaces]: I tend to use [GitHub Codespaces](https://github.com/features/codespaces) for most of my development these days, so having a local development environment where I [INSTALL ALL THE THINGS](https://web.archive.org/web/20240807175656if_/https://www.simplybusiness.co.uk/wp-content/uploads/sites/3/2024/05/things.webp) is much less important than it used to be. As such, the "fresh" setup scrips are focused on installing daily productivity tools and configuration rather than the more resource intensive development services that I would have installed in the past, like databases, memcache servers, etc.

[mackup-sonoma]: https://github.com/lra/mackup/issues/1924
[workaround]: https://github.com/lra/mackup/issues/1924#issuecomment-1756330534
[storages]: https://github.com/lra/mackup?tab=readme-ov-file#supported-storages
