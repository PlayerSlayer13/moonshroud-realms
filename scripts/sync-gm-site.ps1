<#
  Syncs the GM site (gm.playerslayer.net) submodules without requiring a
  campaign date change. update-campaign-date.ps1 already does this for
  main-site as a side effect of updating the date, but never touches
  secrets, and doesn't help if you just want to push a GM-only content
  change with no date change involved. This script covers both cases,
  on their own or together.

  Usage:
    .\sync-gm-site.ps1                  # sync both submodules
    .\sync-gm-site.ps1 -Secrets         # sync just secrets
    .\sync-gm-site.ps1 -MainSite        # sync just main-site
    .\sync-gm-site.ps1 -Message "..."   # custom commit message
#>

param(
  [switch]$MainSite,
  [switch]$Secrets,
  [string]$Message = "Sync GM site submodules"
)

$ErrorActionPreference = "Stop"

$gmRepo = "C:\Projects\moonshroud-realms-gm"

# If neither switch is passed, sync both
$syncMain    = $MainSite -or (-not $MainSite -and -not $Secrets)
$syncSecrets = $Secrets  -or (-not $MainSite -and -not $Secrets)

$submodules = @()
if ($syncMain)    { $submodules += "main-site" }
if ($syncSecrets) { $submodules += "secrets" }

Write-Host "Syncing: $($submodules -join ', ')" -ForegroundColor Cyan

# --- 1. Pull each selected submodule's branch forward ---
foreach ($sub in $submodules) {
  Set-Location (Join-Path $gmRepo $sub)
  git pull origin main
}

# --- 2. Show what changed, and stop for confirmation before anything goes live ---
Set-Location $gmRepo
$status = git status --porcelain -- $submodules
if (-not $status) {
  Write-Host "`nAlready up to date - nothing to commit." -ForegroundColor Green
  exit 0
}

Write-Host "`n--- Changes staged for commit ---" -ForegroundColor Yellow
git status --short -- $submodules
Read-Host "`nPress Enter to commit and push, or Ctrl+C to abort"

# --- 3. Commit and push the GM assembly repo ---
git add $submodules
git commit -m "$Message ($($submodules -join ', '))"
git push

Write-Host "`nDone. GM site should reflect the update once Actions finishes building." -ForegroundColor Green
