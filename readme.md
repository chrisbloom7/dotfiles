# My Dotfiles

This repository is an attempt to make setting up new Macbooks a bit less painful by being selective about which settings and apps are restored. It's a bit more effort than letting the Apple transfer agent do it magically, but the end result is also more clean. It will be in a constant state of progress as my preferences change and I refine the process. You are free to fork this for your own purposes (this project is itself a fork of [driesvints/dotfiles](https://github.com/driesvints/dotfiles) [setup files](https://driesvints.com/blog/getting-started-with-dotfiles)), but I strongly encourage you to read through each file (especially the remainder of this README) before running it on your own machine.

The install script is intended to be idempotent, so you can run it as often as you like as you're making adjustments to it. Note that it won't roll back previous setup steps though, so you may need to unset/uninstall things manually if you're removing apps or macos configuration settings. Also note that the script cannot run unattended - you'll be prompted for your password several times.

## A Fresh macOS Setup

These instructions are for when you've already set up your dotfiles. If you want to get started with your own dotfiles you can [find instructions below](#your-own-dotfiles).

### Before you re-install

First, go through the checklist below to make sure you didn't forget anything before you wipe your hard drive.

- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you save all of your work from apps which aren't synced through iCloud?
- Did you remember to export important data from your local database?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and run `mackup backup`?

### Installing macOS cleanly

After going to our checklist above and making sure you backed everything up, we're going to cleanly install macOS with the latest release. Follow [this article](https://www.imore.com/how-do-clean-install-macos) to cleanly install the latest macOS.

### Setting up your Mac

If you did all of the above you may now follow these install instructions to setup a new Mac.

1. Make sure you've updated macOS to the latest version via the App Store
2. Make sure you're signed into the App Store
3. Install Xcode from the App Store, open it and accept the license agreement
4. Install macOS Command Line Tools by running `xcode-select --install`
5. Copy your public and private SSH keys to `~/.ssh` and make sure they're set to `600`
6. Clone this repo to `~/.dotfiles`
7. Append `/usr/local/bin/zsh` to the end of your `/etc/shells` file
8. Run `install.sh` to start the installation
9. Restore preferences by running `mackup restore`
10. Restart your computer to finalize the process

Your Mac is now ready to use!

> Note: you can use a different location than `~/.dotfiles` if you want. Just make sure you also update the reference in the [`.zshrc`](./.zshrc) file.

## Your Own Dotfiles

If you want to start with your own dotfiles from this setup, it's pretty easy to do so. First of all you'll need to fork this repo. After that you can tweak it the way you want.

**Please note that the instructions below assume you already have set up Oh My Zsh so make sure to first [install Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started) before you continue.**

Go through the [`.macos`](./.macos) file and adjust the settings to your liking. You can find much more settings at [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/MacOS-Defaults).

Check out the [`Brewfile`](./Brewfile) file and adjust the apps you want to install for your machine. Use `brew search` to check if the app you want to install is available.

Check out the [`aliases.zsh`](./aliases.zsh) file and add your own aliases. If you need to tweak your `$PATH` check out the [`path.zsh`](./path.zsh) file. These files get loaded in because the `$ZSH_CUSTOM` setting points to the `.dotfiles` directory. You can adjust the [`.zshrc`](./.zshrc) file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization).

When installing these dotfiles for the first time you'll need to backup all of your settings with Mackup. Install Mackup and backup your settings with the commands below. Your settings will be synced to iCloud so you can use them to sync between computers and reinstall them when reinstalling your Mac. If you want to save your settings to a different directory or different storage than iCloud, [checkout the documentation](https://github.com/lra/mackup/blob/master/doc/README.md#storage).

```zsh
brew install mackup
mackup backup
```

You can tweak the shell theme, the Oh My Zsh settings and much more. Go through the files in this repo and tweak everything to your liking.

Enjoy your own Dotfiles!

## Thanks

- [Dries Vints](https://github.com/driesvints/)
- [Github dotfiles project](https://dotfiles.github.io/)
- [Zach Holman](https://github.com/holman/dotfiles)
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [Mackup](https://github.com/lra/mackup)
