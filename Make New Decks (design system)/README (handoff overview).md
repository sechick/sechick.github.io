# Handoff: INBM HTML Slide System

## Overview

A complete, working HTML slide system for the course **Identifying New
Business Models** (INSEAD MBA / Georgia Tech — Prof. Andre Calmon), designed
to replace PowerPoint. Decks are presented directly from a browser (keyboard
navigation, scaling, transitions, morphs) and printed to PDF via the
browser's print dialog as student handouts.

**Purpose of this bundle:** seed a Claude Code repository where agents
produce the remaining session decks (Sessions 03–07 and beyond) in this
design system. Unlike a typical design handoff, the HTML here is **not just
a reference — it is the production format**. New decks should be built as
HTML files in exactly this pattern.

## Fidelity

**High-fidelity.** `Session 01 - Myths and Tournament.html` is the finished,
approved reference deck — colors, type scale, motion timings, and slide
archetypes are final. New decks must match it. The two markdown files turn
the system into instructions:

- `DESIGN_GUIDE.md` — the design contract: tokens, type scale, the 13 slide
  archetypes, motion system (entrances, dissolve/zoom, morph), content
  rules, print behavior, per-slide quality checklist.
- `CLAUDE.md` — operational instructions for Claude Code agents: repo
  layout, how to start a new session deck, hard constraints, verification
  steps. Drop it at the repo root so every agent session inherits it.

## Files

| File | Role |
|---|---|
| `CLAUDE.md` | Agent instructions — put at repo root |
| `DESIGN_GUIDE.md` | The design system contract |
| `Session 01 - Myths and Tournament.html` | Approved reference deck (15 slides) — template for all new decks |
| `deck-stage.js` | Deck shell web component: scaling/letterboxing to any viewport, ←/→ + number-key nav, slide counter, thumbnail rail, print-to-PDF (one page per slide), `slidechange` events. Presenting: **F** = fullscreen (rail + nav overlay auto-hide; macOS green-button fullscreen also detected), **T** = toggle thumbnail rail. Click-gated reveals: mark elements `data-reveal="1|2|3…"` — → reveals step-by-step before advancing, ← un-reveals; print/PDF shows everything revealed. Treat as a library; don't modify. |
| `deck-morph.js` | PowerPoint-Morph-style shared-element transitions. Tag elements on two slides with the same `data-morph="key"`. Treat as a library. |
| `tweaks-panel.jsx` | In-page design-tweaks panel (paper tone, accent pair, reveal pace, page numbers). Requires the React UMD + Babel script tags already present at the tail of the reference deck. Optional per deck. |
| `images/` | Course imagery extracted from the professor's previous PPT decks (Zocor compounds, Pixar pitches, Oral-B prototypes, American Idol, question tiles, desert search). Low/medium resolution — replace with higher-res versions when available. |

## How to use with Claude Code

```bash
unzip handoff_inbm_slides.zip -d inbm-slides && cd inbm-slides
git init && claude
```

Then prompt, for example:

> Build "Session 05 - Customer Discovery.html" from the attached outline,
> following CLAUDE.md and DESIGN_GUIDE.md. Use the Session 01 deck as the
> skeleton.

Suggested workflow per deck: paste the session outline (or the old PPT's
extracted text) → have the agent propose a slide-by-slide plan (archetype
per slide) → approve the plan → generate → run the verification steps in
CLAUDE.md → review in the browser.

## Design tokens (quick reference)

- Paper `#FBFBFA` · Ink `#131312` · Muted `#71716A` · Hairline `#E4E4DE`
- Semantic red (myth/risk) `#C8361F` · Semantic green (evidence/survival) `#1E7A4F`
- Type: Helvetica Neue; weights 400/500/700; hero 150–230px, body 30–58px, floor 24px
- Canvas 1920×1080; motion gated on `[data-deck-active]` + reduced-motion; `--pace` multiplier

Full detail in `DESIGN_GUIDE.md`.

## Presenting & exporting

- **Present:** open the HTML file in any browser, F11 for fullscreen. ←/→ to
  navigate, number keys to jump, **B** for blackout (discussion mode),
  R to reset.
- **Student PDF:** browser Print → Save as PDF. One page per slide,
  animations resolved to end state, blackout/tweaks hidden.

## Known gaps / notes

- Images are extracted from old PPTX files at modest resolution — fine on a
  projector, soft on retina. Swap in originals when found.
- The Tweaks panel persists values via the design-tool host when present;
  in a plain browser it falls back gracefully (defaults apply).
- The American Idol and Pixar images are third-party media the professor
  already uses in teaching; rights are the course's responsibility.
