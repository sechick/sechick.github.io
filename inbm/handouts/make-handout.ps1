<#
  INBM: builds 2-slides-per-page PDF handouts from the INBM session decks, automatically,
  using headless Microsoft Edge (or Chrome) - nothing to install on Windows 11.
  PDFs are written into inbm\handouts\.

  Usage (PowerShell):
    .\make-handout.ps1 -Deck session-02             # -> inbm\handouts\session-02-slides-handout.pdf
    .\make-handout.ps1 -Deck session-01,session-02
    .\make-handout.ps1 -All                         # every inbm\session-*.html
    .\make-handout.ps1 -Deck session-02 -Notes      # ruled note lines under each slide
    .\make-handout.ps1 -Deck session-02 -Paper letter
#>
param(
  [string[]]$Deck,
  [switch]$All,
  [switch]$Notes,
  [ValidateSet('a4','letter')][string]$Paper = 'a4'
)
$ErrorActionPreference = 'Stop'
$here  = Split-Path -Parent $MyInvocation.MyCommand.Path
$decks = Split-Path -Parent $here            # the inbm folder

if ($All) {
  $Deck = Get-ChildItem $decks -Filter 'session-*.html' | ForEach-Object { $_.BaseName } | Sort-Object
}
if (-not $Deck) { Write-Host 'Specify -Deck session-02 (or -All).'; exit 1 }

$browser = @(
  "$env:ProgramFiles (x86)\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "$env:ProgramFiles (x86)\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { Write-Host 'Edge or Chrome not found.'; exit 1 }

foreach ($d in $Deck) {
  $d = $d -replace '\.html$',''
  if (-not (Test-Path (Join-Path $decks "$d.html"))) { Write-Host "skip $d (no such deck)"; continue }

  $qs  = "deck=$d&paper=$Paper" + $(if ($Notes) { '&notes=1' } else { '' })
  $url = ([System.Uri](Join-Path $here 'handout.html')).AbsoluteUri + '?' + $qs
  $pdf = Join-Path $here "$d-slides-handout.pdf"
  if (Test-Path $pdf) { Remove-Item $pdf -Force }

  Write-Host "Building $d ..."
  $tmpProfile = Join-Path $env:TEMP ("inbm-handout-" + [guid]::NewGuid().ToString('N'))
  & $browser --headless=new --disable-gpu --no-first-run --user-data-dir="$tmpProfile" `
      --allow-file-access-from-files --no-pdf-header-footer --run-all-compositor-stages-before-draw `
      --virtual-time-budget=90000 --print-to-pdf="$pdf" "$url" 2>$null | Out-Null
  Remove-Item $tmpProfile -Recurse -Force -ErrorAction SilentlyContinue

  if (Test-Path $pdf) { Write-Host ("  -> {0} ({1:N1} MB)" -f $pdf, ((Get-Item $pdf).Length/1MB)) }
  else { Write-Host "  FAILED - no PDF produced for $d" }
}
