# Baselines

Three fixed standards the `shape`, `behaviour` and `claim` classes are checked against when the contract is silent. Ported from `/code-review`, whose Standards, Structure and Design axes were their home; if that skill retires, this file is the survivor.

Three rules bind all three:

- **The repo overrides.** A documented repo standard, or a deliberate exception in `DESIGN.md`, always wins over a baseline; where the repo endorses something a baseline would flag, suppress it.
- **Judgement, always.** Each item is a labelled heuristic — *possible Feature Envy*, *possible missed simplification* — never a hard violation, except where a section says otherwise.
- **Skip what tooling enforces.** A formatter, a linter or a type checker's job is not a review finding.

## Standards

The repo's own documents first — `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `CONTEXT.md`. On top of them, or alone where the repo documents nothing, these smells (*Refactoring*, ch.3) are the baseline:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

## Structure

The question is not "does the diff follow the rules?" but "did it miss a dramatically simpler shape, or leave the structure worse?" Restructurings that preserve behaviour while removing structure outright win:

- **Eliminable structure** — prefer changes that remove entire branches, conditionals, or layers over polishing what's there.
- **File-size growth** — a file the diff pushes from below to above 1,000 lines needs architectural justification.
- **Scattered conditionals** — ad-hoc conditionals threaded through unrelated flows are a design problem wanting a dedicated abstraction, not more branches.
- **Type and boundary clarity** — unnecessary optionality, casts, or loosely-shaped objects where an explicit contract would hold the boundary.
- **Canonical-layer discipline** — feature logic leaking into shared paths; near-duplicates of utilities that already exist.
- **Atomic orchestration** — sequential flows where independent work could run in parallel with clearer structure.
- **The ladder** — every new abstraction, helper, or dependency in the diff must beat each rung above it: an existing in-repo pattern, the standard library, a native platform feature, an already-installed dependency, a one-liner.

Two rules bind it: **diff-confined** — findings apply only to code the diff touches, and opportunities in surrounding code are observations, never prescriptions; and **regressions are hard, the rest is judgement** — a structural regression is a hard finding, a missed simplification is a judgement call.

## Design

Runs only when the diff touches a path with a `DESIGN.md` at or above it: the nearest one upward governs, and the diff's path selects the surface profile its `Surfaces` table names. A backend-only diff has no design baseline.

- **Raw values** — a hex code, rgb value, or off-scale spacing anywhere outside the token layer.
- **Missing states** — an interactive element without all four of default, hover, active/pressed, disabled. Inputs additionally need focus and error-with-message.
- **Unguarded motion** — any animation without a `prefers-reduced-motion` branch.
- **Misrouted animation** — GSAP on something a CSS transition covers (hover, press, focus, a simple slide). GSAP earns its place on timelines, staggered entrances and scroll-driven sequences only.
- **Motif breaches** — code contradicting a motif in `DESIGN.md`, or introducing a look that should have been a motif and wasn't written back.
- **System breaches** — anything contradicting `design-system/SYSTEM.md`: icon size not matching adjacent line-height, type above the surface's ceiling, a flat scrim over an image, shadows that read as strong, dark-mode depth built from shadows instead of a lighter surface.

The first four are hard; the last two are judgement.
