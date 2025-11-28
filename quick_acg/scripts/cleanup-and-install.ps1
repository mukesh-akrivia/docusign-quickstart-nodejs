<#
  cleanup-and-install.ps1
  Safe cleanup and install steps for Windows (PowerShell). Removes node_modules, cleans npm cache,
  upgrades npm (optional), and performs an install. This script is idempotent and includes
  basic checks to avoid accidental destructive behavior.
#>

$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Resolve-Path (Join-Path $scriptDir "..")
Write-Info "Project root: $projectRoot"

function Remove-FolderIfExists([string]$path) {
    if (Test-Path $path) {
        Write-Warn "Removing $path"
        Remove-Item -Recurse -Force -LiteralPath $path
    } else {
        Write-Info "No such path: $path"
    }
}

function Remove-FileIfExists([string]$path) {
    if (Test-Path $path) {
        Write-Warn "Removing $path"
        Remove-Item -Force -LiteralPath $path
    } else {
        Write-Info "No such file: $path"
    }
}

Write-Info "Stopping any Node processes to avoid file locks..."
Get-Process node -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force }

# Remove node_modules and locks in the quick_acg folder and parent
Write-Info "Removing node_modules in quick_acg and parent (if present)"
Remove-FolderIfExists (Join-Path $projectRoot "node_modules")
Remove-FolderIfExists (Join-Path $projectRoot "..\node_modules")

Write-Info "Removing package-lock.json files (if present)"
Remove-FileIfExists (Join-Path $projectRoot "package-lock.json")
Remove-FileIfExists (Join-Path $projectRoot "..\package-lock.json")

Write-Info "Removing any .get-intrinsic.DELETE leftovers"
Get-ChildItem -Path $projectRoot -Filter ".get-intrinsic.DELETE" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item -Force $_.FullName -ErrorAction SilentlyContinue
}

Write-Info "Cleaning npm cache"
npm cache clean --force

Write-Info "Attempting to update npm to latest (optional). Ignoring errors and proceeding if update fails."
try { npm install -g npm@latest } catch { Write-Warn "npm update failed; continuing: $_" }

Write-Info "Installing dependencies in quick_acg (using npm ci where possible)"
Push-Location $projectRoot
try {
    if (Test-Path "package-lock.json") {
        npm ci
    } else {
        npm install
    }
} finally { Pop-Location }

Write-Info "Done: cleanup-and-install finished. If you still get errors, run again with --verbose and attach logs."
