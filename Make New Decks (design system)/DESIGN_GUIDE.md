# INBM Slide System — Design Guide

The design system for **Identifying New Business Models** (Andre Calmon, INSEAD / Georgia Tech).
HTML decks presented from a browser, printed to PDF for students.

This guide is the contract: every new deck must follow it. The reference
implementation is `Session 01 - Myths and Tournament.html`.

---

## 1 · Design philosophy

1. **The slide is a backdrop for the professor, not a record of the lecture.**
   Near-zero chrome. No logos, no footers, no course name repeated on every
   slide. Only a faint page number (students cite "slide 7" in discussion).
2. **Dynamic range, like a lecture.** A deck alternates between near-empty
   statement slides (one thought, enormous), quiet workhorse slides, and at
   most one or two dense "photograph this" reference slides. Never let every
   slide be "medium loud."
3. **Affect precedes cognition.** Every session needs emotional anchors:
   real photographs, concrete stories (Zocor, Pixar, Oral-B), pop-culture
   analogies, and at least one direct question to the room.
4. **Assertion–evidence headlines.** Slide titles are full-sentence claims
   ("Nemo was found, not struck"), never topic labels ("Pixar Case Study").
5. **Questions before answers.** Open sessions with a warm-up prompt the
   students discuss in pairs before any content lands.
6. **Color is information, never decoration.** See §3.

## 2 · Canvas & type

- Canvas: **1920 × 1080**, scaled by `<deck-stage>`.
- Font: `"Helvetica Neue", Helvetica, "Arial Nova", Arial, sans-serif`. One family; hierarchy comes from size + weight (400 / 500 / 700 only).
- Scale (slide px):
  - Hero statements: 150–230px, weight 700, letter-spacing −0.03 to −0.04em, line-height 0.96–1.12
  - Section headlines: 76–124px
  - Supporting/lede text: 36–58px
  - Dense-slide body: 30–35px
  - Kickers/labels: 26–30px, uppercase, letter-spacing 0.18–0.24em
  - **Absolute floor: 24px.** Nothing smaller, ever.
- Body copy max-width ≈ 1280–1500px. `text-wrap: pretty` welcome.

## 3 · Color tokens

```css
--paper: #FBFBFA;  /* background; warm-ivory alt #F7F3EA via Tweaks */
--ink:   #131312;  /* text, dark slides' background */
--muted: #71716A;  /* secondary text */
--hair:  #E4E4DE;  /* hairlines, list dividers */
--false: #C8361F;  /* SEMANTIC: myths, risk, "or not", the Z assumption */
--true:  #1E7A4F;  /* SEMANTIC: evidence, process, survivors, targets */
```

Rules:
- `--false` and `--true` appear **only when they mean something**. A slide
  with no claim about risk/evidence is pure ink-on-paper.
- **Colorblind redundancy**: color is never the only signal. Red myths are
  also struck through and tagged "MYTH"; the green survivor dot is also the
  largest and labeled "1".
- Dark slides (`class="dark"`): `--ink` background, `--paper` text,
  `#8B8B84` for muted. Use for section dividers, the end slide, and at most
  one image exhibit per deck.
- Photographs carry the color. Don't tint or duotone them.

## 4 · Slide archetypes

Every slide is one of these. Don't invent new layouts casually — reuse and
vary. (Class names refer to the reference deck.)

| Archetype | Class | Use | Notes |
|---|---|---|---|
| Title | `.s-title` | once, first | kicker + huge title + name. Quiet. |
| Warm-up ask | `.s-ask` | once, early | full-bleed photo, dark veil, one question + "turn to your neighbor" instruction |
| Statement | `.s-startup` | 2–4 per deck | centered, enormous; optional delayed definition (`.late`) with `<em>` keywords |
| Section divider | `.s-myths` | per part | dark, "Part N" kicker, huge bottom-anchored headline |
| Myth / claim-strike | `.s-myth1` | per myth | red tag → sentence → animated red strike → green truth (`.later`) |
| Exhibit | `.s-exhibit` | story slides | kicker + assertion headline + one-line evidence + large centered image |
| Dark exhibit | `.s-oralb` | 1 per deck max | photo glowing on ink, caption beneath |
| Diagram | `.s-flow` | frameworks | living diagrams (e.g. flowing-dots funnel); labels inside the diagram, counts ≥44px |
| Juxtapose | `.s-idol` | analogy slides | text column + photo card, kicker connects to students' world |
| Statement + reversal | `.s-ornot` | turning points | big claim, delayed "…or not." in red |
| Framework sentence | `.s-thesis` | formulas | one nowrap sentence with colored underlines + small caps labels |
| Activity | `.s-act` | per exercise | the ONE dense slide: 4px ink border frame, "DO NOW · N MIN" ghost tag, numbered steps + a green-bar goal block. Must be self-sufficient in a photo. |
| Homework | `.s-hw` | once, near end | ghost tag, 3 cards with top rules, due line |
| End | `.s-end` | once, last | dark, two-word imperative ("Go generate."), contact line |

### Session 02 additions (12 Jun 2026)

| Archetype | Class | Use | Notes |
|---|---|---|---|
| Formula sentence | `.s-thesis` | the X·Y·Z business thesis | one nowrap 112px sentence, ink underlines on X/Y/Z, legend row + worked example |
| Theory of a business | `.s-theory` | profit formula / risk / timeline | two bordered blocks + a chip-chain timeline |
| Exemplar pair | `.s-cards` + `.card.bad/.good` | bad-vs-good contrast | semantic top borders with text labels (`.chiplab`) for colorblind redundancy; `.subex` variant tightens for long copy |

`.s-exh2` and `.s-act2` in the S2 deck are the prior S2 deck's exhibit/activity archetypes imported under renamed selectors (S1's `.s-exhibit`/`.s-act` differ). `.foot` is the print-only source-footnote class used by S2 slides (S1 uses `.pnote`).

## 5 · Motion system

All motion is gated on `[data-deck-active]` and
`@media (prefers-reduced-motion: no-preference)`, and the **base state is
always the visible end state** — print/PDF and reduced-motion show finished
slides. All within-slide durations/delays multiply by `--pace` (Tweaks:
0.7 / 1 / 1.45).

- **Entrance** (`.rise`, `.rise.d1/.d2/.d3`): fade-up 1.05s, staggered 0.25s.
- **Pedagogical beats** (`.late` ≈2.2s, `.later` ≈3.4s): delayed reveals for
  the second half of a thought — set it up verbally, then let it land.
- **Click-gated reveals** (`data-reveal`): elements marked
  `data-reveal="1"`, `"2"`, … stay hidden until the presenter advances
  (→ / space / click); equal numbers land together; ← re-hides the last
  step before leaving the slide. Use when the beat must wait for the room
  (a question's answer, a punchline) — `.late`/`.later` stay the default
  for routine second-half-of-thought reveals. Print/PDF and the thumbnail
  rail always show everything revealed. Don't combine `data-reveal` with
  `.rise`/`.late` on the same element (their opacity rules fight).
- **Strike** (`.strike-anim`): red strike draws at ≈1.9s.
- **Slide transitions**: 0.7s film dissolve on every slide;
  `data-fx="zoom"` adds a subtle scale-through — use it on statements and
  bookends, **never on slides containing `data-morph` elements** (morph
  geometry must stay transform-free).
- **Morph** (`deck-morph.js`): tag an element on two slides with the same
  `data-morph="key"` → it glides/scales across the boundary (same content =
  true morph; different = crossfade glide). Use for narrative continuity:
  question→question, tag→tag, exhibit art→exhibit art, diagram
  survivor→photo of a winner. 2–5 morph pairs per deck; more gets gimmicky.
- **Looping motion** only when the loop IS the concept (the idea-factory
  river). Never decorative loops.
- **Blackout**: B key fades to black for discussion; Esc/click returns.

## 6 · Content rules

- One idea per slide. If a slide needs two paragraphs, it's two slides.
- Lecture slides slim; activity/homework slides may be dense (they're the
  handout) — but still ≥24px and inside a frame that marks them as "do".
- No bullets-as-prose. Lists are numbered steps (activities) or bold-lead
  inline items ("**Get your product** — each group receives…").
- No filler: no stock metaphors, no decorative icons, no stat soup, no emoji.
- INSEAD audience is global: plain words, explain idioms with the visual.
- Speaker doesn't read slides; slides don't read the speaker.

## 7 · Print / PDF

Browser Print → Save as PDF = one page per slide, animations at end state,
blackout and Tweaks hidden. This is the student handout. `@media print` may
ADD material (references, footnotes) that doesn't show on screen.

## 8 · Quality checklist (run on every slide)

1. All text ≥ 24px slide-space; hero text earns its size.
2. Content clears the bottom: nothing below y ≈ 980 except the page number.
3. Statement sentences that must not wrap: check at 1920px (`white-space: nowrap` + fit).
4. Squint test: exactly one focal element per slide.
5. Accents only where semantic; redundancy for colorblind readers.
6. Print preview: nothing hidden, nothing mid-animation.
7. Photograph test on dense slides: instructions complete without the professor.
