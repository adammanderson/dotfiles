# bootstrap.ps1
# Windows dotfiles bootstrap script
# No admin required. Run remotely with:
# irm https://raw.githubusercontent.com/adammanderson/dotfiles/main/windows/bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"
$rawRepo    = "https://raw.githubusercontent.com/adammanderson/dotfiles/main"
$configDir  = "$env:LOCALAPPDATA\dotfiles"

function Write-Step($msg)    { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg)    { Write-Host "    [!!] $msg" -ForegroundColor Yellow }

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

function Download($url, $dest) {
    Invoke-WebRequest -Uri $url -OutFile $dest
}

# ── 1. Create config dir ─────────────────────────────────────────────────────
New-Item -Path $configDir -ItemType Directory -Force | Out-Null

# ── 2. Install Starship ──────────────────────────────────────────────────────
Write-Step "Checking for Starship..."

$starshipInstalled = Get-Command starship -ErrorAction SilentlyContinue
if ($starshipInstalled) {
    Write-Warn "Starship already installed at $($starshipInstalled.Source), skipping"
} else {
    Write-Step "Installing Starship (no admin required)..."

    $starshipDir = "$env:LOCALAPPDATA\Programs\starship"
    New-Item -Path $starshipDir -ItemType Directory -Force | Out-Null
    Download "https://github.com/starship/starship/releases/latest/download/starship-x86_64-pc-windows-msvc.zip" "$starshipDir\starship.zip"
    Expand-Archive "$starshipDir\starship.zip" -DestinationPath $starshipDir -Force
    Remove-Item "$starshipDir\starship.zip"
    Add-ToPath $starshipDir
    Write-Success "Starship installed at $starshipDir"
}

# ── 3. Download Starship config ──────────────────────────────────────────────
Write-Step "Downloading Starship config..."
Download "$rawRepo/starship.toml" "$configDir\starship.toml"
Write-Success "Starship config saved to $configDir\starship.toml"

# ── 4. Download git aliases ──────────────────────────────────────────────────
Write-Step "Downloading git aliases..."
Download "$rawRepo/windows/git-aliases.ps1" "$configDir\git-aliases.ps1"
Write-Success "Git aliases saved to $configDir\git-aliases.ps1"

# ── 5. Apply git config ──────────────────────────────────────────────────────
Write-Step "Applying git config..."
Download "$rawRepo/windows/.gitconfig" "$env:USERPROFILE\.gitconfig"
Write-Success "Git config applied"

# ── 6. Install Vim ───────────────────────────────────────────────────────────
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
        Write-Warn "Could not find Vim x64 zip in latest release — skipping"
    } else {
        Download $vimAsset.browser_download_url $vimZip
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

# ── 7. Set up PowerShell profile ─────────────────────────────────────────────
Write-Step "Setting up PowerShell profile..."

$profileDir = Split-Path $PROFILE
New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
if (-not (Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force | Out-Null }

$existing = Get-Content $PROFILE -Raw

$linesToAdd = @()

if ($existing -notlike "*starship*") {
    $linesToAdd += "# Starship"
    $linesToAdd += "`$env:STARSHIP_CONFIG = `"$configDir\starship.toml`""
    $linesToAdd += "Invoke-Expression (&starship init powershell)"
} else {
    Write-Warn "Starship already in profile, skipping"
}

if ($existing -notlike "*git-aliases*") {
    $linesToAdd += ""
    $linesToAdd += "# Git aliases"
    $linesToAdd += ". `"$configDir\git-aliases.ps1`""
} else {
    Write-Warn "Git aliases already in profile, skipping"
}

if ($linesToAdd.Count -gt 0) {
    Add-Content -Path $PROFILE -Value ("`n" + ($linesToAdd -join "`n"))
    Write-Success "Profile updated at $PROFILE"
} else {
    Write-Warn "Profile already up to date, nothing to add"
}

# ── 8. Done ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Bootstrap complete!" -ForegroundColor Green
Write-Host "Restart PowerShell to apply all changes." -ForegroundColor Yellow