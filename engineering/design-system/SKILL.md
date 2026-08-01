---
name: design-system
description: "Interview a repo into a DESIGN.md and a token layer, then amend it as motifs are discovered."
disable-model-invocation: true
---

# Design System

Backend planning works because you can talk in interfaces. Frontend has no equivalent artifact, so look-and-feel survives three tickets and then drifts. This skill writes that artifact.

Everything splits along one asymmetry:

- **The system** is agreed upfront, because it is numbers. It lives in [SYSTEM.md](./SYSTEM.md), inside this skill — never copied into a repo, never interviewed about, never re-litigated. It is what makes every project you build recognisably yours.
- **The flavour** is per repo, and its **motifs** are deferred, because prose cannot hold them. Vibes are discovered by building, not by answering questions. They land in the repo's `DESIGN.md`.

`DESIGN.md` holds intent; code holds values. **A value that exists in code never appears in `DESIGN.md`** — prose that duplicates a hex code loses to the stylesheet and rots silently. `DESIGN.md` records *why 2× padding, why no flat scrim, why amber*. Same division `CONTEXT.md` already keeps against the domain.

## Where DESIGN.md lives

**One `DESIGN.md` per brand, not per app.** It sits at the highest point governing every surface it covers — repo root in a monorepo, app root in a single-app repo. Different density does not earn a second file; the `Surfaces` table handles that. A genuinely different brand does.

The single exception: if a React Native app is ever added, it gets its own `DESIGN.md` that transforms the CSS tokens into mobile ones. Until that app exists, tokens are CSS variables and nothing else.

## Process

### 1. Resolve the mode

Search upward from the web app for a `DESIGN.md`.

- **Found** → **amend**. Go to [Amend](#amend).
- **Not found** → pass 1, below.

Amend is the only re-run mode. Regenerating discards motifs that were earned through a prototype, so a fresh generate requires the user to delete the file and say so.

Done when you can name the mode and the exact path the `DESIGN.md` does or will occupy.

### 2. Pass 1 — interview the knobs

Six questions, one at a time. Read [SYSTEM.md](./SYSTEM.md) first; several answers are constrained by it and you should say so as you go.

1. **Stack.** Propose the base stack — Next, Tailwind v4 with a CSS-variable theme, shadcn/ui, GSAP — as a starting point to argue with, not a default to assume. Component libraries turn over every few months, and a design stack is rarely swapped once chosen, so **recording the choice and its reasoning matters more than which one wins**. Tell the user this is hard to reverse and worth an ADR **in that repo**.
2. **Primary colour.** One brand colour. Lighten it for backgrounds, darken it for text — that is already half a ramp. Semantic colours come from SYSTEM.md, not from taste.
3. **Typeface.** One UI family. A mono is permitted only when a motif needs it, and no motifs exist yet — so ask again in pass 2 rather than granting it now.
4. **Radius.** One value, from which the scale derives.
5. **Surfaces and their density profiles.** Name every app the brand covers and give each a profile: marketing, product, or dashboard. The profile sets the type-scale ceiling — this is the only thing that legitimately differs between siblings.
6. **Light or dark default**, and whether the other is supported at launch.

Done when all six have concrete answers and you can state which SYSTEM.md rules each one activates.

### 3. Emit the artifacts

Write `DESIGN.md` from [DESIGN-FORMAT.md](./DESIGN-FORMAT.md), with `Stack`, `Shared` and `Surfaces` filled and **`Motifs` empty**. An empty `Motifs` section is a correct and expected state — say so to the user so the gap does not read as an omission.

Then write the code:

- The token layer — CSS variables for the palette ramp, semantic colours, spacing scale, radius scale, type scale per surface profile, shadow scale, motion durations.
- Verify every foreground/background pair reaches WCAG AA before writing it. Contrast is computable, so it is the system's job, not the user's.
- The primitives SYSTEM.md makes mandatory: button with its four states, input with focus and error, and the reduced-motion branch wired once.

Done when a screen can be built with no raw hex, no off-scale spacing, and no unhandled state.

### 4. Discover the flavour

Invoke `/prototype` on the **first real screen** — its UI branch, three variants. Every variant obeys SYSTEM.md and the tokens; they differ in structure and in how hard they push the flavour.

This runs on the first screen, and maybe one showcase surface. Not the settings page.

### 5. Pass 2 — distil motifs

Take the winning variant and write its **motifs** into `DESIGN.md`. A motif carries two fields:

- **The rule** — what is always true.
- **The build route** — CSS, GSAP, an off-the-shelf component, or bespoke.

The build route is what makes a motif finished. It forces the feasibility call now rather than at ticket 14.

```md
- **Surfaces boot in rather than fade in** — GSAP timeline, staggered 40ms
- **Data readouts are monospace** — token, no code
- **Route entrance sweep, 600ms, once per session** — GSAP, bespoke
- **Command palette** — shadcn `<Command>`, unmodified
```

**Refuse to write a motif that is not this concrete.** "Flashy", "pops of things", "symbolic of a supercomputer" describe a feeling and cannot be reproduced at ticket 30. Push back and keep pushing until the user names a rule with a number, a token, or a component in it.

Done when every motif has both fields and the losing variants have been deleted per `/prototype`'s own capture step.

### 6. Name the exit test

Flavour discovery is finished when **a new screen can be built without `implement` stopping**. Amendments cluster in the first few screens and tail to near zero.

Tell the user this test rather than handing them a checklist, and re-prototype only when a genuinely new kind of surface appears — never the same screen twice. Re-prototyping a screen means the question was wrong, not that another round is owed.

## Amend

Amend reads what is there, audits the code against it, and interviews only for the gaps.

1. **Understand the intent.** Read `DESIGN.md` end to end, including motifs, before touching anything.
2. **Audit for drift.** Check the code against the [success metric](#success-metric) and report every breach with its file and line.
3. **Interview the gaps only.** Ask about what is genuinely undecided. Settled decisions stay settled.
4. **Treat intent changes as migrations.** "We do not use blue any more" is one token change, not a week of grep — but only because raw hex was banned on day one. That is the whole argument for this skill; make it out loud when it applies.

Done when `DESIGN.md` matches the code and every remaining drift has been named.

## Success metric

The bar a repo is held to, and the same list the `code-review` design axis checks:

- Zero raw hex values outside the token layer
- Zero off-scale spacing
- Zero interactive element missing its four states
- Zero motion without a `prefers-reduced-motion` branch
- Zero GSAP on anything a CSS transition covers

All five are greppable, which is the point — an aesthetic goal you cannot grep is a wish.

## Consumers

These skills read `DESIGN.md`. All of them activate on the same trigger: **the diff touches a path with a `DESIGN.md` at or above it.** The nearest one upward governs, and the path selects which surface profile applies. Backend-only diffs never trip it.

- `implement` and `tdd` read it the way they read `CONTEXT.md`, and **stop and ask** when no rule covers a case, then write the answer back.
- `code-review` runs the design axis against the success metric.
- `bootstrap` invokes this skill when scaffolding a new repo.

## Anti-patterns

- **A value in two places.** A hex in `DESIGN.md` and in the theme is two sources of truth, and the prose one is always the stale one.
- **Interviewing the system.** Buttons have four states. Icons match line-height. Nobody is asked about this on a new project, ever.
- **Motifs written before anything is built.** A motif distilled from a prototype is a rule; a motif imagined in an interview is a wish with a build route bolted on.
- **A second `DESIGN.md` for a different density.** That is what the `Surfaces` table is for. Two files means two palettes eventually.
- **GSAP on a hover state.** A 23kb dependency animating something CSS does natively is the ladder skipped for no gain.

## Reference files

- [SYSTEM.md](./SYSTEM.md) — the invariant. Every rule, with its number
- [DESIGN-FORMAT.md](./DESIGN-FORMAT.md) — the structure and rules for `DESIGN.md`
