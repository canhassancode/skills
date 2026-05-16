# Skills

A personal library of Claude Code skills that keep an engineer in the loop through the SDLC, rather than letting AI run off and "complete" things that don't survive contact with reality.

## Language

**Skill**:
A named, invocable workflow defined by a `SKILL.md` file. Invoked via the Skill tool (e.g. `/grill-me`) and never inlined into other skills' procedures.

**Triage**:
The state-machine move that classifies an incoming ticket and prepares it for execution. Operates at the issue tracker level — not in the editor.

**Pickup**:
The moment a session opens on a ticket that triage has already moved to `ready-for-human`. Distinct from triage (which produced the brief) and from planning (which produced the spec). Pickup verifies, it does not re-grill.
_Avoid_: "start", "kick off" — those are ambiguous about whether intent is still open.

**Agent brief**:
The structured comment posted when a ticket reaches `ready-for-anything`. The contract that downstream execution works from. The issue body is context; the brief is canon.

**Surface**:
A concrete code location a piece of work claims to touch — a function, endpoint, resolver, type. Concrete enough to open in an editor. Branches (feature flags, env gates, A/B switches) that gate a surface are part of the surface, not separate from it.

**Consumer**:
A concrete code location that reads a field, type, or behaviour being changed. Found by grep, not by trusting the author's mental model.

**Four-pass discipline**:
The verification work `/grill-with-docs` must complete before declaring a plan ready: (1) trace request paths, don't list modules; (2) grep for consumers; (3) sketch `CONTEXT.md` if missing; (4) check for feature flags / branches that hide parallel surfaces. All four must run; "the agent had judgment" is not a substitute.

## Relationships

- A **triage** session produces an **agent brief** when it moves a ticket to `ready-for-human` or `ready-for-agent`
- An **agent brief** names **surfaces** and **consumers** so that **pickup** can verify against current code
- **Pickup** applies only to `ready-for-human`; agents skip pickup verification but require *stricter* **four-pass discipline** at triage time
- **Four-pass discipline** is what makes an **agent brief** verifiable — without it, pickup has nothing to check against

## Flagged ambiguities

- "Grilling" was used to mean both *planning a fresh piece of work* and *re-opening intent at pickup* — resolved: grilling lives at planning/triage time; pickup is verification, not grilling.
