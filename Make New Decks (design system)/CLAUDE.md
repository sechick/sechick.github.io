# CLAUDE.md — INBM slide-deck agent instructions

You build and maintain HTML slide decks for the course **Identifying New
Business Models** (INSEAD / Georgia Tech, Prof. Andre Calmon). Decks are
presented from a browser and printed to PDF as student handouts.

**Read `DESIGN_GUIDE.md` before any slide work. It is the contract.**
The reference implementation is `Session 01 - Myths and Tournament.html` —
when in doubt, copy its patterns verbatim.

## Repository layout

- `deck-stage.js` — deck shell web component (scaling, keyboard nav, print, thumbnail rail). Do not modify.
- `deck-morph.js` — shared-element morph transitions via `data-morph` keys. Do not modify.
- `tweaks-panel.jsx` — in-page design-tweaks panel (needs React UMD + Babel, see reference deck's tail). Optional per deck.
- `images/` — course imagery. Add new photos here with descriptive kebab-case names.
- `Session NN - <Topic>.html` — one file per session deck.

## Creating a new session deck

1. Copy `Session 01 - Myths and Tournament.html` as the starting skeleton.
   Keep: the `:root` tokens, the shared atoms (`.pg`, `.tag`, `.dark`,
   `.kicker`), the motion blocks, the blackout script, the script tags.
2. Replace the `<section>` slides. Every slide is one **archetype** from
   DESIGN_GUIDE §4 — reuse the existing CSS classes; only add new CSS when
   an archetype genuinely doesn't exist yet (then document it in the guide).
3. Slide `<section>` rules (deck-stage contract):
   - Each slide is a direct child `<section data-label="Short Name">` of `<deck-stage>`.
   - Never set position/inset/width/height on the `<section>` itself.
   - Entrance animations: visible end-state is the base style; animate FROM
     hidden; gate on `[data-deck-active]` + `prefers-reduced-motion`.
   - Click-gated reveals: mark elements `data-reveal="1|2|3…"` — deck-stage
     shows them step-by-step on advance and prints them revealed (no extra
     CSS needed; styles are injected by deck-stage). See DESIGN_GUIDE §5.
   - Presenting: F = browser fullscreen (rail + nav auto-hide), T = toggle
     the thumbnail rail.
4. Write static HTML (no JS-generated slides) so slides stay hand-editable.
   Close every element explicitly; double-quote attributes.

## Authoring rules (hard constraints)

- 1920×1080 design space. **No text below 24px.** Content bottoms above y≈980.
- Headlines are full-sentence assertions, not topic labels.
- `--false` (red) / `--true` (green) only with semantic meaning + a
  non-color redundant cue (tag, strike, size, label).
- Per deck: exactly one warm-up ask slide near the start, ≥1 statement
  slide, ≤2 dense slides (activity/homework), dark slides only for
  dividers / end / one exhibit.
- Morph: 2–5 `data-morph` pairs per deck on adjacent slides telling one
  story. Never put `data-fx="zoom"` on a slide containing `data-morph`.
- Page numbers: `<div class="pg">NN</div>` on all slides except title and
  full-bleed/activity slides where it would intrude.
- No emoji, no decorative icons, no hand-drawn SVG art. Real photographs or
  CSS-geometry diagrams only.

## Verifying your work

After editing, render and check (e.g. with a headless browser or by eye):

1. Open the file; arrow through every slide. No console errors.
2. Overflow check per slide: with animations disabled
   (`*{animation:none!important}`), every element's bottom ≤ 1080 and the
   section's scrollHeight === 1080.
3. Nowrap statements (e.g. formula sentences) fit within their padding at 1920px.
4. Print preview: every slide complete, end-state, one page each.
5. The DESIGN_GUIDE §8 checklist, slide by slide.

## Tone of copy

Confident, spare, warm. Short sentences. Direct address ("turn to your
neighbor", "Go generate."). No consultant-speak, no exclamation marks, no
hedging. The professor's voice carries the content; slides carry the beat.
