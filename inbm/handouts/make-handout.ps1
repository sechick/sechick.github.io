<#
  INBM: builds 2-slides-per-page PDF handouts from the INBM session decks, automatically,
  using headless Microsoft Edge (or Chrome) - nothing to install on Windows 11.
  PDFs are written into inbm\handouts\.

  Usage (PowerShell):
    .\make-handout.ps1 -Deck session-02             # -> inbm\handouts\session-02-slides-handout.pdf
    .\make-handout.ps1 -Deck session-01,session-02
    .\make-handout.ps1 -All                         # every inbm\session-*.html
    .\make-handout.ps1 -Deck session-02 -Notes      # ruled note lines under each slide
  Output: A4 portrait, exactly two slides per page (top and bottom), no source/speaker notes.
#>
param(
  [string[]]$Deck,
  [switch]$All,
  [switch]$Notes
)
$ErrorActionPreference = 'Stop'
$here  = Split-Path -Parent $MyInvocation.MyCommand.Path
$decks = Split-Path -Parent $here            # the inbm folder

# powershell -File passes "a,b" as ONE string, so split on commas ourselves
if ($Deck) { $Deck = @($Deck | ForEach-Object { $_ -split ',' } | Where-Object { $_ }) }

if ($All) {
  $Deck = Get-ChildItem $decks -Filter 'session-*.html' | ForEach-Object { $_.BaseName } | Sort-Object
}
if (-not $Deck) { Write-Host 'Specify -Deck session-02 (or -All).'; exit 1 }

$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { Write-Host 'Google Chrome not found (this script uses Chrome, not Edge).'; exit 1 }
Write-Host "Using $browser"

foreach ($d in $Deck) {
  $d = $d -replace '\.html$',''
  if (-not (Test-Path (Join-Path $decks "$d.html"))) { Write-Host "skip $d (no such deck)"; continue }

  $qs  = "deck=$d" + $(if ($Notes) { '&notes=1' } else { '' })
  $url = ([System.Uri](Join-Path $here 'handout.html')).AbsoluteUri + '?' + $qs
  $pdf = Join-Path $here "$d-slides-handout.pdf"
  if (Test-Path $pdf) { Remove-Item $pdf -Force }

  Write-Host "Building $d ..."
  $tmpProfile = Join-Path $env:TEMP ("inbm-handout-" + [guid]::NewGuid().ToString('N'))
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
  # the PDF is written just before exit; allow a few seconds for the file to land
  for ($i = 0; $i -lt 30 -and -not (Test-Path $pdf); $i++) { Start-Sleep -Seconds 1 }
  Remove-Item $tmpProfile -Recurse -Force -ErrorAction SilentlyContinue
  if (Test-Path $pdf) { Remove-Item $log -Force -ErrorAction SilentlyContinue }
  else { Write-Host "  browser exit code $($p.ExitCode); see $log" }

  if (Test-Path $pdf) { Write-Host ("  -> {0} ({1:N1} MB)" -f $pdf, ((Get-Item $pdf).Length/1MB)) }
  else { Write-Host "  FAILED - no PDF produced for $d" }
}
