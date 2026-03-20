# bootstrap.ps1
# Windows dotfiles bootstrap script
# Installs Oh My Posh (no admin required) and sets up PowerShell profile, theme and git aliases
# Usage: irm https://raw.githubusercontent.com/adammanderson/dotfiles/main/windows/bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"
$dotfilesRepo = "https://raw.githubusercontent.com/adammanderson/dotfiles/main/windows"
$ompBinDir    = "$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
$ompExe       = "$ompBinDir\oh-my-posh.exe"
$ompConfig    = "$env:USERPROFILE\.oh-my-posh.omp.json"

function Write-Step($msg) {
    Write-Host "`n==> $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "    [OK] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "    [!!] $msg" -ForegroundColor Yellow
}

# ── 1. Install Oh My Posh ────────────────────────────────────────────────────
Write-Step "Checking for Oh My Posh..."

$ompInstalled = Get-Command oh-my-posh -ErrorAction SilentlyContinue
if ($ompInstalled) {
    Write-Warn "Oh My Posh already installed at $($ompInstalled.Source), skipping download"
} elseif (Test-Path $ompExe) {
    Write-Warn "oh-my-posh.exe already exists at $ompExe, skipping download"
} else {
    Write-Step "Installing Oh My Posh (no admin required)..."

    New-Item -Path $ompBinDir -ItemType Directory -Force | Out-Null

    Invoke-WebRequest `
        -Uri "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-windows-amd64.exe" `
        -OutFile $ompExe

    Write-Success "oh-my-posh.exe downloaded to $ompBinDir"
}

# ── 2. Add Oh My Posh to user PATH ──────────────────────────────────────────
Write-Step "Adding Oh My Posh to user PATH..."

$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$ompBinDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$ompBinDir", "User")
    $env:PATH += ";$ompBinDir"
    Write-Success "Added to PATH"
} else {
    Write-Warn "Already in PATH, skipping"
}

# ── 3. Download Oh My Posh theme ────────────────────────────────────────────
Write-Step "Downloading Oh My Posh theme..."

Invoke-WebRequest `
    -Uri "$dotfilesRepo/.oh-my-posh.omp.json" `
    -OutFile $ompConfig

Write-Success "Theme saved to $ompConfig"

# ── 4. Download git aliases ─────────────────────────────────────────────────
Write-Step "Downloading git aliases..."

$gitAliasesDir  = "$env:USERPROFILE\dev\dotfiles\windows"
$gitAliasesFile = "$gitAliasesDir\git-aliases.ps1"

New-Item -Path $gitAliasesDir -ItemType Directory -Force | Out-Null

Invoke-WebRequest `
    -Uri "$dotfilesRepo/git-aliases.ps1" `
    -OutFile $gitAliasesFile

Write-Success "Git aliases saved to $gitAliasesFile"

# ── 5. Set up PowerShell profile ────────────────────────────────────────────
Write-Step "Setting up PowerShell profile..."

$profileDir = Split-Path $PROFILE
New-Item -Path $profileDir -ItemType Directory -Force | Out-Null

$profileContent = @"
# Oh My Posh
oh-my-posh init pwsh --config "`$env:USERPROFILE\.oh-my-posh.omp.json" | Invoke-Expression

# Git aliases
. "`$env:USERPROFILE\dev\dotfiles\windows\git-aliases.ps1"
"@

if (Test-Path $PROFILE) {
    $existing = Get-Content $PROFILE -Raw

    if ($existing -like "*oh-my-posh*") {
        Write-Warn "oh-my-posh already in profile, skipping that line"
        $profileContent = $profileContent -replace "(?m)^# Oh My Posh\r?\noh-my-posh.*\r?\n", ""
    }

    if ($existing -like "*git-aliases*") {
        Write-Warn "git-aliases already in profile, skipping that line"
        $profileContent = $profileContent -replace "(?m)^# Git aliases\r?\n.*git-aliases.*\r?\n", ""
    }

    if ($profileContent.Trim()) {
        Add-Content $PROFILE "`n$profileContent"
    }
} else {
    Set-Content $PROFILE $profileContent
}

Write-Success "Profile updated at $PROFILE"

# ── 6. Install Vim ──────────────────────────────────────────────────────────
Write-Step "Checking for Vim..."

$vimInstalled = Get-Command vim -ErrorAction SilentlyContinue
if ($vimInstalled) {
    Write-Warn "Vim already installed at $($vimInstalled.Source), skipping"
} else {
    Write-Step "Installing Vim (no admin required)..."

    $vimDir = "$env:LOCALAPPDATA\Programs\vim"
    $vimZip = "$vimDir\vim.zip"

    New-Item -Path $vimDir -ItemType Directory -Force | Out-Null

    # Resolve latest release dynamically via GitHub API
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/vim/vim-win32-installer/releases/latest"
    $vimAsset = $releaseInfo.assets | Where-Object { $_.name -match "^gvim_[\d.]+_x64\.zip$" } | Select-Object -First 1

    if (-not $vimAsset) {
        Write-Warn "Could not find Vim x64 zip in latest release — skipping Vim install"
    } else {
        Invoke-WebRequest -Uri $vimAsset.browser_download_url -OutFile $vimZip

        Expand-Archive $vimZip -DestinationPath $vimDir -Force
        Remove-Item $vimZip

        # Find vim.exe under the extracted folder
        $vimExe = Get-ChildItem $vimDir -Recurse -Filter "vim.exe" | Select-Object -First 1
        if ($vimExe) {
            $vimBinDir = $vimExe.DirectoryName

            # Add to user PATH
            $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            if ($currentPath -notlike "*$vimBinDir*") {
                [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$vimBinDir", "User")
                $env:PATH += ";$vimBinDir"
            }

            # Set as git editor
            git config --global core.editor "vim"

            Write-Success "Vim installed at $vimBinDir and set as git editor"
        } else {
            Write-Warn "Could not find vim.exe after extraction — check $vimDir manually"
        }
    }
}

# ── 7. Done ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Bootstrap complete!" -ForegroundColor Green
Write-Host "Restart PowerShell to apply all changes." -ForegroundColor Yellow