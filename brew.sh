#!/bin/bash

# Install command-line tools using Homebrew

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install moreutils

# GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
brew install findutils

# Install development binaries
brew install git
brew install node
brew install yarn
brew install nginx
brew install postgresql
brew install rbenv

# Install other useful binaries
brew install imagemagick --with-webp
brew install the_silver_searcher
brew install wifi-password
brew install tree
brew install ffmpeg --with-libvpx
brew install terminal-notifier

brew install zsh

# Remove outdated versions from the cellar
brew cleanup

