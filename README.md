# ✨ dotfiles

> Personal config files for Windows and Linux.

## 📁 Structure

- 🪟 `windows/` - PowerShell profile, Oh My Posh theme, git aliases, bootstrap script
- 🐧 `linux/` - Linux dotfiles (.bashrc, .zshrc, etc.)

## 🚀 Windows Setup

Run this single command in PowerShell (no admin required):

```powershell
irm https://raw.githubusercontent.com/adammanderson/dotfiles/main/windows/bootstrap.ps1 | iex
```

This will:
- ⚡ Install Oh My Posh (skips if already installed)
- 🛤️ Add Oh My Posh to your user PATH
- 🎨 Download the Oh My Posh theme
- 🔧 Download git aliases
- 📝 Set up your PowerShell profile

Then restart PowerShell to apply all changes. 🎉

## 🐧 Linux Setup

Copy files from `linux/` to your home directory.