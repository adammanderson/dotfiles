# ✨ dotfiles

> Personal config files for Windows and Linux.

## 📁 Structure

- 🪟 `windows/` - PowerShell profile, git aliases, git config, bootstrap script
- 🐧 `linux/` - Linux dotfiles (.bashrc, .zshrc, etc.)
- 🚀 `starship.toml` - Shared Starship prompt config (Windows + Linux)

## 🚀 Windows Setup

Run this single command in PowerShell (no admin required):

```powershell
irm https://raw.githubusercontent.com/adammanderson/dotfiles/main/windows/bootstrap.ps1 | iex
```

This will:
- 🚀 Install Starship prompt (skips if already installed)
- 🎨 Download the Starship config from repo root
- 🔧 Download git aliases
- 📝 Set up your PowerShell profile
- 🐙 Apply git config (Vim editor, autoSetupRemote, main as default branch)
- 📦 Install Vim (skips if already installed)

Then restart PowerShell to apply all changes. 🎉

## 🔧 Git Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Git shorthand |
| `gst` | `git status` | Show working tree status |
| `gss` | `git status -s` | Short status |
| `gaa` | `git add .` | Stage all changes |
| `ga` | `git add` | Stage specific files |
| `gc` | `git commit -v` | Commit with diff |
| `gca` | `git commit -v -a` | Stage all and commit |
| `gcmsg` | `git commit -m` | Commit with message |
| `gc!` | `git commit -v --amend` | Amend last commit |
| `gca!` | `git commit -v -a --amend` | Stage all and amend |
| `gco` | `git checkout` | Checkout branch or file |
| `gcm` | `git checkout master` | Checkout master |
| `gb` | `git branch` | List branches |
| `gba` | `git branch -a` | List all branches |
| `gm` | `git merge` | Merge branch |
| `gl` | `git pull` | Pull from remote |
| `gup` | `git pull --rebase` | Pull with rebase |
| `gpsh` | `git push` | Push to remote |
| `ggpull` | `git pull origin <branch>` | Pull current branch |
| `ggpush` | `git push origin <branch>` | Push current branch |
| `ggpur` | `git pull --rebase origin <branch>` | Rebase pull current branch |
| `ggpnp` | `git pull && git push origin <branch>` | Pull then push |
| `gd` | `git diff` | Show unstaged diff |
| `gdc` | `git diff --cached` | Show staged diff |
| `glo` | `git log --oneline --decorate --color` | Compact log |
| `glog` | `git log --oneline --decorate --color --graph` | Graph log |
| `glg` | `git log --stat --max-count=10` | Log with stats |
| `glgg` | `git log --graph --max-count=10` | Graph log (10) |
| `glgga` | `git log --graph --decorate --all` | Full graph log |
| `gr` | `git remote` | List remotes |
| `grv` | `git remote -v` | List remotes verbose |
| `grup` | `git remote update` | Update remotes |
| `grmv` | `git remote rename` | Rename remote |
| `grrm` | `git remote remove` | Remove remote |
| `gsetr` | `git remote set-url` | Set remote URL |
| `grbi` | `git rebase -i` | Interactive rebase |
| `grbc` | `git rebase --continue` | Continue rebase |
| `grba` | `git rebase --abort` | Abort rebase |
| `grh` | `git reset HEAD` | Unstage changes |
| `grhh` | `git reset HEAD --hard` | Hard reset |
| `gclean` | `git reset --hard && git clean -dfx` | Nuke all changes |
| `gcp` | `git cherry-pick` | Cherry pick commit |
| `gsta` | `git stash` | Stash changes |
| `gstp` | `git stash pop` | Pop stash |
| `gstd` | `git stash drop` | Drop stash |
| `gsts` | `git stash show --text` | Show stash |
| `gcount` | `git shortlog -sn` | Commit count by author |
| `gcl` | `git config --list` | List git config |
| `gwc` | `git whatchanged -p --abbrev-commit --pretty=medium` | What changed |
| `glp` | `git log --pretty=` | Log with custom format |

## 🐧 Linux Setup

Copy files from `linux/` to your home directory. Copy `starship.toml` to `~/.config/starship.toml`.