<#
  Builds 2-slides-per-page PDF handouts from the decks, fully automatically,
  using headless Microsoft Edge (or Chrome) - nothing to install on Windows 11.

  Usage (PowerShell, from anywhere):
    .\make-handout.ps1 -Deck inbo-08              # -> handouts\inbo-08-slides-handout.pdf
    .\make-handout.ps1 -Deck inbo-08,inbo-09      # several decks
    .\make-handout.ps1 -All                       # every decks\inbo-*.html (skips placeholder decks)
    .\make-handout.ps1 -Deck inbo-08 -Notes       # add ruled note lines under each slide
    .\make-handout.ps1 -Deck inbo-08 -Paper letter
#>
param(
  [string[]]$Deck,
  [switch]$All,
  [switch]$Notes
)
$ErrorActionPreference = 'Stop'
$here  = Split-Path -Parent $MyInvocation.MyCommand.Path
$root  = Split-Path -Parent $here
$decks = Join-Path $root 'decks'

# powershell -File passes "a,b" as ONE string, so split on commas ourselves
if ($Deck) { $Deck = @($Deck | ForEach-Object { $_ -split ',' } | Where-Object { $_ }) }

if ($All) {
  $Deck = Get-ChildItem $decks -Filter 'inbo-*.html' | ForEach-Object { $_.BaseName } | Sort-Object
}
if (-not $Deck) { Write-Host 'Specify -Deck inbo-08 (or -All).'; exit 1 }

$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { Write-Host 'Google Chrome not found (this script uses Chrome, not Edge).'; exit 1 }
Write-Host "Using $browser"

foreach ($d in $Deck) {
  $d = $d -replace '\.html$',''
  $deckFile = Join-Path $decks "$d.html"
  if (-not (Test-Path $deckFile)) { Write-Host "skip $d (no such deck)"; continue }
  if ((Get-Content $deckFile -Raw) -match 'Slides in preparation') { Write-Host "skip $d (placeholder deck)"; continue }

  $qs  = "deck=$d" + $(if ($Notes) { '&notes=1' } else { '' })
  $url = ([System.Uri](Join-Path $here 'handout.html')).AbsoluteUri + '?' + $qs
  $pdf = Join-Path $here "$d-slides-handout.pdf"
  if (Test-Path $pdf) { Remove-Item $pdf -Force }

  Write-Host "Building $d ..."
  $tmpProfile = Join-Path $env:TEMP ("inbo-handout-" + [guid]::NewGuid().ToString('N'))
  # Edge/Chrome are GUI-subsystem programs: '&' does not wait for them, and paths with spaces
  # (e.g. "Stephen CHICK") need explicit quotes. Start-Process -Wait + a quoted argument string fixes both.
  $log  = Join-Path $here "$d-build.log"
  $argv = @(
    '--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
    '--force-device-scale-factor=1', '--hide-scrollbars',
    ('--user-data-dir="{0}"' -f $tmpProfile),
    '--allow-file-access-from-files', '--no-pdf-header-footer',
    '--run-all-compositor-stages-before-draw', '--virtual-time-budget=90000',
    ('--print-to-pdf="{0}"' -f $pdf),
    ('"{0}"' -f $url)
  ) -join ' '
  $p = Start-Process -FilePath $browser -ArgumentList $argv -Wait -PassThru -WindowStyle Hidden -RedirectStandardError $log
  for ($i = 0; $i -lt 30 -and -not (Test-Path $pdf); $i++) { Start-Sleep -Seconds 1 }
  Remove-Item $tmpProfile -Recurse -Force -ErrorAction SilentlyContinue
  if (Test-Path $pdf) { Remove-Item $log -Force -ErrorAction SilentlyContinue }
  else { Write-Host "  browser exit code $($p.ExitCode); see $log" }

  if (Test-Path $pdf) { Write-Host ("  -> {0} ({1:N1} MB)" -f $pdf, ((Get-Item $pdf).Length/1MB)) }
  else { Write-Host "  FAILED - no PDF produced for $d" }
}
