# dotfiles

Personal config files for Windows and Linux.

## Structure

- `windows/` - PowerShell profile, Oh My Posh theme
- `linux/` - Linux dotfiles (.bashrc, .zshrc, etc.)

## Windows Setup

1. Install Oh My Posh manually:

```powershell
   New-Item -Path "`$env:LOCALAPPDATA\Programs\oh-my-posh\bin" -ItemType Directory -Force
   Invoke-WebRequest -Uri "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-windows-amd64.exe" -OutFile "`$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe"
```

2. Copy `windows/Microsoft.PowerShell_profile.ps1` to `$PROFILE`
3. Copy `windows/.oh-my-posh.omp.json` to `~/.oh-my-posh.omp.json`

## Linux Setup

Copy files from `linux/` to your home directory.
