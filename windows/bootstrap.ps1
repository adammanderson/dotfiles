# bootstrap.ps1
# Windows dotfiles bootstrap script
# Installs Starship, Vim (no admin required) and sets up PowerShell profile and git aliases
# Usage: irm https://raw.githubusercontent.com/adammanderson/dotfiles/main/windows/bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"
$dotfilesRepo    = "https://raw.githubusercontent.com/adammanderson/dotfiles/main"
$dotfilesWin     = "$dotfilesRepo/windows"
$dotfilesDir     = "$env:USERPROFILE\dev\dotfiles"
$dotfilesDirWin  = "$dotfilesDir\windows"

function Write-Step($msg) {
    Write-Host "`n==> $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "    [OK] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "    [!!] $msg" -ForegroundColor Yellow
}

function Add-ToPath($dir) {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$dir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$dir", "User")
        $env:PATH += ";$dir"
        Write-Success "Added $dir to PATH"
    } else {
        Write-Warn "$dir already in PATH, skipping"
    }
}

# ── 1. Install Starship ──────────────────────────────────────────────────────
Write-Step "Checking for Starship..."

$starshipInstalled = Get-Command starship -ErrorAction SilentlyContinue
if ($starshipInstalled) {
    Write-Warn "Starship already installed at $($starshipInstalled.Source), skipping"
} else {
    Write-Step "Installing Starship (no admin required)..."

    $starshipDir = "$env:LOCALAPPDATA\Programs\starship"
    New-Item -Path $starshipDir -ItemType Directory -Force | Out-Null

    Invoke-WebRequest `
        -Uri "https://github.com/starship/starship/releases/latest/download/starship-x86_64-pc-windows-msvc.zip" `
        -OutFile "$starshipDir\starship.zip"

    Expand-Archive "$starshipDir\starship.zip" -DestinationPath $starshipDir -Force
    Remove-Item "$starshipDir\starship.zip"

    Add-ToPath $starshipDir
    Write-Success "Starship installed at $starshipDir"
}

# ── 2. Download Starship config ──────────────────────────────────────────────
Write-Step "Downloading Starship config..."

New-Item -Path $dotfilesDir -ItemType Directory -Force | Out-Null

Invoke-WebRequest `
    -Uri "$dotfilesRepo/starship.toml" `
    -OutFile "$dotfilesDir\starship.toml"

Write-Success "Starship config saved to $dotfilesDir\starship.toml"

# ── 3. Download git aliases ──────────────────────────────────────────────────
Write-Step "Downloading git aliases..."

New-Item -Path $dotfilesDirWin -ItemType Directory -Force | Out-Null

Invoke-WebRequest `
    -Uri "$dotfilesWin/git-aliases.ps1" `
    -OutFile "$dotfilesDirWin\git-aliases.ps1"

Write-Success "Git aliases saved to $dotfilesDirWin\git-aliases.ps1"

# ── 4. Set up PowerShell profile ────────────────────────────────────────────
Write-Step "Setting up PowerShell profile..."

$profileDir = Split-Path $PROFILE
New-Item -Path $profileDir -ItemType Directory -Force | Out-Null

$profileDir = Split-Path $PROFILE
New-Item -Path $profileDir -ItemType Directory -Force | Out-Null

# Read existing profile or start fresh
$existing = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { "" }

$linesToAdd = @()

if ($existing -notlike "*starship*") {
    $linesToAdd += "# Starship"
    $linesToAdd += "`$env:STARSHIP_CONFIG = `"`$env:USERPROFILE\dev\dotfiles\starship.toml`""
    $linesToAdd += "Invoke-Expression (&starship init powershell)"
} else {
    Write-Warn "Starship already in profile, skipping"
}

if ($existing -notlike "*git-aliases*") {
    $linesToAdd += ""
    $linesToAdd += "# Git aliases"
    $linesToAdd += ". `"`$env:USERPROFILE\dev\dotfiles\windows\git-aliases.ps1`""
} else {
    Write-Warn "Git aliases already in profile, skipping"
}

if ($linesToAdd.Count -gt 0) {
    $toAppend = "`n" + ($linesToAdd -join "`n")
    Add-Content $PROFILE $toAppend
}

Write-Success "Profile updated at $PROFILE"

# ── 5. Install Vim ───────────────────────────────────────────────────────────
Write-Step "Checking for Vim..."

$vimInstalled = Get-Command vim -ErrorAction SilentlyContinue
if ($vimInstalled) {
    Write-Warn "Vim already installed at $($vimInstalled.Source), skipping"
} else {
    Write-Step "Installing Vim (no admin required)..."

    $vimDir = "$env:LOCALAPPDATA\Programs\vim"
    $vimZip = "$vimDir\vim.zip"

    New-Item -Path $vimDir -ItemType Directory -Force | Out-Null

    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/vim/vim-win32-installer/releases/latest"
    $vimAsset = $releaseInfo.assets | Where-Object { $_.name -match "^gvim_[\d.]+_x64\.zip$" } | Select-Object -First 1

    if (-not $vimAsset) {
        Write-Warn "Could not find Vim x64 zip in latest release — skipping Vim install"
    } else {
        Invoke-WebRequest -Uri $vimAsset.browser_download_url -OutFile $vimZip
        Expand-Archive $vimZip -DestinationPath $vimDir -Force
        Remove-Item $vimZip

        $vimExe = Get-ChildItem $vimDir -Recurse -Filter "vim.exe" | Select-Object -First 1
        if ($vimExe) {
            Add-ToPath $vimExe.DirectoryName
            git config --global core.editor "vim"
            Write-Success "Vim installed at $($vimExe.DirectoryName) and set as git editor"
        } else {
            Write-Warn "Could not find vim.exe after extraction — check $vimDir manually"
        }
    }
}

# ── 6. Apply git config ──────────────────────────────────────────────────────
Write-Step "Applying git config..."

Invoke-WebRequest `
    -Uri "$dotfilesWin/.gitconfig" `
    -OutFile "$env:USERPROFILE\.gitconfig"

Write-Success "Git config applied"

# ── 7. Done ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Bootstrap complete!" -ForegroundColor Green
Write-Host "Restart PowerShell to apply all changes." -ForegroundColor Yellow