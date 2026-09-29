---
status: accepted
---

# Align owns the route repertoire, and wayfinder retires

Supersedes [ADR-0005](./0005-align-owns-the-planning-entry.md) in part: its deferral of wayfinder's retirement ("a separate decision"). `/grilling` stays registered and unchanged; its round shape remains the primitive align reads.

## Context

Wayfinder's two apparatuses had already been absorbed. Its fog — the decisions and investigations you can tell are coming but cannot yet phrase — is what an `/align` pass holds in Unresolved across passes; its working session is the pass. What wayfinder still carried was a **repertoire**: a question is settled by research, by prototype, by grilling, or by task, and each has a different owner and artefact. `/align` had one mode for a stuck question — more rounds — and a close that refused every artefact the other modes produce.

The route line was already load-bearing. Fog and thin were discriminated by whether each unresolved entry carried a route, but nothing said what a route could be, so "needs more thinking" passed as one.

Wayfinder also never proved its scale. It was charting apparatus for work larger than one session, but in practice the map's fog landed in one ticket's Unresolved list, and the map's frontier, claim and blocking machinery earns its keep only when a route outlives the pass.

## Decision

**Every Unresolved entry carries a Route from the ladder.** **research** — a fact read from primary sources by a `/research` sub-agent, at most two at a time, landing as a cited note; **prototype** — a shape reacted to via `/prototype`, landing as a throwaway branch linked from the pass comment; **task** — work that must happen before the discussion can move, landing as a fact row; **pass** — more rounds in a fresh session; **decide** — a yes owed outside the room, `/propose`'s. Each entry names its owner and where the artefact lands, and an entry without a route from the ladder is thin, not fog.

**A route is content, not a label.** The state vocabulary is unchanged: a research route marks the ticket `needs-info`, prototype, task and pass stay `needs-alignment`, decide takes `ready-to-propose`. No `route:*` or `wayfinder:*` labels are manufactured.

**Decision-support artefacts are the close's fourth write.** A cited research note or a throwaway prototype branch settles a question rather than delivering the cut. Where it lands is asked like any other repo writing (ADR-0007), and the files a ticket delivers still land after the cut and the readiness check.

**Wayfinder retires.** Its map is align's Unresolved list, and a route that outlives the pass becomes a child of the alignment ticket, using the sub-issue mechanics a spec node already uses. The skill moves to `deprecated/` as a redirect stub, leaves the plugin registry, and its tracker ops (`wayfinder:map`, `wayfinder:<type>`, the frontier query) leave the adapters. Its Synced class retires with it, ending its harvest.

**Grilling stays.** The round shape has three other consumers — `grill-me`, `ingest`, `file` — so its move into align's tree is a separate change; `/align` reads it as the primitive it is.

## Considered options

- **Route labels** (`route:research`, `route:prototype`) — rejected. ADR-0006's precedent: the label set answers what can be taken now, and a route is a content property; `needs-info` already carries the research case.
- **Always creating a child ticket per route** — rejected. Ceremony at pass scale, and a research finding is not takeable work; the child exists only when a route outlives the pass.
- **Keeping wayfinder for map-scale efforts** — rejected. Its scale never showed: the map's fog was one ticket's Unresolved list wearing more nodes.
- **Retiring grilling in the same change** — rejected. The round shape must move into align's tree before `deprecated/` can take its file, and that is its own change.

## Consequences

- Align's close may write a throwaway branch or a research note, and a pass can run `/prototype` mid-round instead of arguing shape in prose.
- Fog has a floor: every unresolved entry names a ladder route with its owner and artefact home, or the verdict is thin.
- `CONTEXT.md` gains **Route**; **Verdict**'s fog and thin definitions read against it.
- The adapters lose their Wayfinding operations; `ingest` and `file` hand ideas to `/align` or `/grilling`.
- `CLAUDE.md`'s Synced list drops wayfinder; the count becomes 30 directories, 29 registered, 15 invoking-disabled.
- The `wayfinder:*` labels already created in repos are inert; the templates stop creating them.
