# The System

The invariant. These rules are the same on every project, are never interviewed about, and are never copied into a repo — a `DESIGN.md` that restates them has duplicated its source of truth.

They are written as numbers wherever a number exists, because a number is the only part of a design decision an agent can be held to. Where a rule is a judgement, it says so.

## Signifiers

Good UI signifies how it works rather than instructing the user.

- A container around a group means those items are related, and the ones outside it are not.
- A container around one item means it is selected.
- Greyed out means inactive, and clicking will do nothing.
- Every affordance carries at least one signifier: a press state, an active nav highlight, a hover state, or a tooltip.

## Visual hierarchy

Three tools, and only three: **size, position, colour**.

- The most important element is large, bold, and near the top. Supporting detail is smaller and below it.
- Hierarchy *is* the contrast between elements — big against small, coloured against neutral. A layout where everything is the same size has no hierarchy regardless of its spacing.
- Use an image wherever one is available. It adds colour and makes a list scannable.
- A card that reads like a spreadsheet — label-colon-value repeated down the left — has failed, however logical it is.
- It is not an exact science. Two different layouts can both be right; both will still put the important thing at the top and use images where they exist.

## Grid and whitespace

- The 12-column grid is a guideline, not a law. Custom landing pages routinely ignore it and that is normal.
- It earns its keep on repeating content — galleries, blogs, feeds — where it defines responsive behaviour: 12 columns desktop, 8 tablet, 4 mobile.
- **Whitespace matters more than the grid.** Letting things breathe beats aligning them to anything.
- Spacing is a **4-point grid** — every value a multiple of 4. The justification is that everything halves cleanly, which is what keeps the scale consistent. It is not that multiples of 4 look better.
- ~32px between unrelated items. Group related ones tighter: announcement to heading, heading to subtext. **Grouping is itself hierarchy.**

## Typography

- **One UI family.** A second family is permitted only when it is mono and a motif requires it. Two is the ceiling.
- Large text: letter-spacing **−2% to −3%**, line-height **110–120%**. This single adjustment is most of what separates amateur from professional headings.
- Type-scale ceiling by density profile:
  - **marketing** — at most 6 sizes, with a wide range
  - **product** — at most 6 sizes, narrower range
  - **dashboard** — nothing above **24px**; information density inverts the scale
- Body line-height sits well above heading line-height. Tightening applies to large text only.

## Colour

- Start from **one primary**, the brand colour. Lighten it for backgrounds, darken it for text. That is already half a ramp, and it is what stops an otherwise drab design from reading as grey.
- Let the rest of the colour find you rather than designing a palette upfront — an announcement bar, a focus ring, a status chip. Each new colour arrives because something needed it.
- Semantic colours carry fixed meaning: **blue** trust, **red** danger or urgency, **yellow** warning, **green** success.
- Colour is for purpose, never decoration. A colour that signifies nothing is noise.
- **Every foreground/background pair meets WCAG AA.** Computed at token-generation time, not eyeballed.

## Dark mode

Dark mode is not light mode inverted. It has no shadows, so depth is built differently.

- **Depth comes from the card being lighter than the background.** This replaces the shadow entirely.
- Lower border contrast. A border that reads correctly on light is too bright on dark.
- Dim chip saturation and brightness, and invert the relationship for its text, to keep hierarchy legible.
- Deep purples, reds and greens are legitimate dark surfaces. Navy and grey are not the only options.

## Shadows

Light mode only.

- **Low opacity, high blur.** Most shadows are too strong; reducing opacity and increasing blur is almost always the fix.
- Strength scales with elevation: cards need little, popovers and floating content need more.
- Inner and outer shadows together make a raised, tactile button.
- **If the shadow is the first thing you notice, it is wrong.**

## Icons

- Icon size equals the **line-height of the text beside it**. 24px text takes a 24px icon.
- Then tighten the gap between them. Most icons are too large and too far away.

## Buttons

- Horizontal padding ≈ **2× vertical padding**.
- A sidebar link is a **ghost button** — no background until hover. Isolate and centre one and it is a standalone button.
- Primary and secondary CTA side by side is the default pair.
- Icons are optional and do not change the padding rule.

## Feedback

**Every interaction gets a response.** This is the rule with the widest reach and the one most often half-applied.

- Buttons have **four mandatory states**: default, hover, active/pressed, disabled. Plus loading, with a spinner, wherever the action is async.
- Inputs have: focus, error with a red border **and** a message, and warning for non-blocking issues.
- Data fetching shows a loading state. Completed actions show a success state.
- A state that exists in the code and not in the design is a bug, not a gap.

## Micro-interactions

Feedback says *something happened*. A micro-interaction says *this specific thing happened*.

- The canonical case: a copy button with hover and press states still does not tell you it copied. A chip sliding up does.
- They range from purely practical to playful. Which end a project sits at is flavour; having them at all is not.

## Overlays

- Never a flat full-screen scrim over an image — it kills the image and the text still reads poorly.
- Use a **linear gradient** that leaves the image visible and converges into a text-readable background.
- A **progressive blur** layered on top of the gradient is the modern version.

## Motion

- **CSS for state transitions; GSAP for orchestration.** Hover, press, focus, disabled, and a chip sliding up are CSS. Timelines, staggered entrances, scroll-driven sequences, and choreographed boot sequences are GSAP.
- GSAP is the one sanctioned animation dependency. It is still rung 5 of the ladder, so a native CSS transition beats it wherever one applies.
- **Every motion has a `prefers-reduced-motion` branch.** Non-negotiable, and wired once in the primitives rather than per component.
