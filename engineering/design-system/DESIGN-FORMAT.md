# DESIGN.md Format

## Structure

```md
# {Brand} — Design

{One or two sentences: what this brand is and the feeling it is going for.}

Governed by the system in `design-system/SYSTEM.md`. This file holds intent only —
every value lives in the token layer.

## Stack

- **Framework** — Vite + React
- **Styling** — Tailwind v4, CSS-variable theme
- **Components** — shadcn/ui
- **Motion** — GSAP for orchestration, CSS for state transitions

Chosen because {reasoning}. Hard to reverse — see `docs/adr/0003-design-stack.md`.

Tokens: `src/styles/tokens.css`. Primitives: `src/components/ui/`.

## Shared

- **Primary** — amber. Chosen because {reasoning}; the ramp derives from it.
- **Typeface** — Geist for UI, Geist Mono for data readouts (permitted by the
  monospace-readouts motif).
- **Radius** — small. The scale derives from it.
- **Mode** — dark default, light supported.
- **Motion vocabulary** — things boot rather than fade. Durations are short and
  staggered rather than long and simultaneous.

## Surfaces

| Surface | Path | Density profile | Type-scale ceiling |
|---|---|---|---|
| Marketing | `apps/web` | marketing | 6 sizes, wide range |
| App | `apps/admin` | dashboard | nothing above 24px |

## Motifs

- **Surfaces boot in rather than fade in** — GSAP timeline, staggered 40ms,
  `packages/ui/motion/boot.ts`
- **Data readouts are monospace** — token, no code
- **Route entrance sweep, 600ms, once per session** — GSAP, bespoke
- **Command palette is the primary navigation** — shadcn `<Command>`, unmodified

## Amendments

- Empty states: no rule covered them at ticket 12 — resolved as icon plus one line
  plus a single primary action, never an illustration.
```

## Rules

- **Never write a value that exists in code.** No hex codes, no pixel values, no durations. Name the token or the file that holds them. Prose that duplicates a value loses to the code and rots.
- **Every decision carries its reasoning.** "Amber" is a fact the stylesheet already knows. "Amber because the product is a night-time tool and blue reads clinical" is why this file exists.
- **`Motifs` may be empty.** After pass 1 it should be. Motifs are earned from a prototype, not imagined in an interview.
- **A motif has two fields — the rule and the build route.** The build route is CSS, GSAP, an off-the-shelf component, or bespoke, and names the file when one exists. A motif without a build route is not finished being designed.
- **Motifs are falsifiable.** "Data readouts are monospace" can be checked against a screen. "Flashy" cannot, and does not go in this file.
- **`Surfaces` is how density varies.** A second `DESIGN.md` is for a second brand, never a second density.
- **`Amendments` is append-only.** It records what was undecided and what it resolved to, so the same question is never asked twice.

## One file per brand

`DESIGN.md` sits at the highest point governing every surface it covers.

**Monorepo** — repo root, with the `Surfaces` table naming each app:

```
/
├── DESIGN.md
└── apps/
    ├── web/
    └── admin/
```

**Single app** — the app root, which may also be the repo root:

```
/
├── DESIGN.md
└── src/
```

A second brand earns a second file, listed in `CONTEXT-MAP.md` alongside the contexts so consumers can resolve which one governs a diff. With only one, the map entry is ceremony — the nearest file upward is unambiguous.

The one exception is a React Native app, which gets its own `DESIGN.md` transforming the CSS tokens into mobile ones. Until that app exists, it is not a case worth designing for.
