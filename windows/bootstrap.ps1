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

# ── 6. Done ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Bootstrap complete!" -ForegroundColor Green
Write-Host "Restart PowerShell to apply all changes." -ForegroundColor Yellow