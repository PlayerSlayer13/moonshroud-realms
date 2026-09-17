<#
  Updates the campaign date across playerslayer.net and syncs the
  GM reference site to match. Run this after each session.

  Usage:
    .\update-campaign-date.ps1 -MonthName "Frostwatch" -Day 12
    .\update-campaign-date.ps1 -MonthName "Wintermark" -Day 1 -Year 701
#>

param(
  [Parameter(Mandatory=$true)][string]$MonthName,
  [Parameter(Mandatory=$true)][int]$Day,
  [int]$Year
)

$ErrorActionPreference = "Stop"

$publicRepo = "C:\Projects\moonshroud-realms"
$gmRepo     = "C:\Projects\moonshroud-realms-gm"
$dateFile   = Join-Path $publicRepo "static\js\campaign-date.js"
$calFile    = Join-Path $publicRepo "static\calendar.html"
$indexFile  = Join-Path $publicRepo "content\_index.md"

$monthNames = @(
  "Wintermark","Dawnsreach","Brightening","Rainmoot","Bloomtide",
  "Goldmantle","Highsun","Emberwane","Harvestide","Frostwatch",
  "Redleaf","Long Dusk","Wandering"
)

$monthIndex = $monthNames.IndexOf($MonthName)
if ($monthIndex -eq -1) {
  Write-Host "ERROR: '$MonthName' isn't a recognized month name. Valid options:" -ForegroundColor Red
  $monthNames | ForEach-Object { Write-Host "  $_" }
  exit 1
}

if (-not $Year) {
  $existing = Get-Content $dateFile -Raw
  if ($existing -match 'year:\s*(\d+)') {
    $Year = [int]$Matches[1]
  } else {
    Write-Host "ERROR: Couldn't detect the current year automatically. Pass -Year explicitly." -ForegroundColor Red
    exit 1
  }
}

Write-Host "Setting campaign date to: $MonthName, Day $Day, ${Year}AG" -ForegroundColor Cyan

# --- 1. Update campaign-date.js (the single source of truth) ---
$content = Get-Content $dateFile -Raw
$content = $content -replace 'year:\s*\d+,', "year:  $Year,"
$content = $content -replace 'month:\s*\d+,\s*//[^\r\n]*', "month: $monthIndex,    // 0-indexed — $MonthName"
$content = $content -replace 'day:\s*\d+', "day:   $Day"
Set-Content $dateFile $content -NoNewline

# --- 2. Bump the cache-busting version on both files that load it ---
#     (adds ?v= automatically the first time it runs, updates it every time after)
$versionTag = "$Year-$monthIndex-$Day"
foreach ($file in @($calFile, $indexFile)) {
  $c = Get-Content $file -Raw
  $c = $c -replace 'campaign-date\.js(\?v=[^"]*)?', "campaign-date.js?v=$versionTag"
  Set-Content $file $c -NoNewline
}

# --- 3. Show what changed, and stop for confirmation before anything goes live ---
Set-Location $publicRepo
Write-Host "`n--- Changes staged for commit ---" -ForegroundColor Yellow
git diff --stat $dateFile $calFile $indexFile
Read-Host "`nPress Enter to commit and push both repos, or Ctrl+C to abort"

# --- 4. Commit and push the public repo ---
git add $dateFile $calFile $indexFile
git commit -m "Update campaign date to $MonthName Day $Day, ${Year}AG"
git push

# --- 5. Sync the GM assembly repo's submodule pointer ---
Set-Location (Join-Path $gmRepo "main-site")
git pull origin main
Set-Location $gmRepo
git add main-site
git commit -m "Update main-site submodule to latest (date sync)"
git push

Write-Host "`nDone. Both sites should reflect $MonthName Day $Day, ${Year}AG once Actions finishes building." -ForegroundColor Green
