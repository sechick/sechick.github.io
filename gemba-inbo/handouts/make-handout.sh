#!/usr/bin/env bash
# Builds 2-slides-per-page PDF handouts with headless Chrome/Edge (Mac/Linux).
#   ./make-handout.sh inbo-08            ->  handouts/inbo-08-slides-handout.pdf
#   ./make-handout.sh inbo-08 inbo-09
#   NOTES=1 PAPER=letter ./make-handout.sh inbo-08
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
paper="${PAPER:-a4}"
for b in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
         "$(command -v google-chrome || true)" "$(command -v chromium || true)" "$(command -v microsoft-edge || true)"; do
  [ -n "$b" ] && [ -x "$b" ] && browser="$b" && break
done
[ -n "${browser:-}" ] || { echo "Chrome/Edge not found"; exit 1; }
[ $# -gt 0 ] || { echo "usage: $0 inbo-08 [inbo-09 ...]"; exit 1; }
for d in "$@"; do
  d="${d%.html}"
  qs="deck=$d&paper=$paper"; [ "${NOTES:-0}" = "1" ] && qs="$qs&notes=1"
  out="$here/$d-slides-handout.pdf"; rm -f "$out"
  echo "Building $d ..."
  "$browser" --headless=new --disable-gpu --no-first-run --user-data-dir="$(mktemp -d)" \
    --allow-file-access-from-files --no-pdf-header-footer --run-all-compositor-stages-before-draw \
    --virtual-time-budget=90000 --print-to-pdf="$out" "file://$here/handout.html?$qs" 2>/dev/null || true
  [ -f "$out" ] && echo "  -> $out" || echo "  FAILED"
done
