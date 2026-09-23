# Worked build comments

The comment `/build` leaves on the ticket — one per session, appended, never edited — worked twice:
a run that finished, and a run the stop rule ended. Both follow [SKILL.md](SKILL.md) §6 verbatim.
The ticket is #232, the slice `/cut` cut from [cut/EXAMPLES.md](../cut/EXAMPLES.md).

## A single-session build

Two units, both gated, the pull request opened at the end.

````markdown
### Build — session 1, 2026-09-24

**Loop**  `mix format --check-formatted` · `mix test <file>` · `mix test` · CI green — proven at `4e7a1c9`
**Units**  `a1b2c3d` emit one SearchMatchEvent per matching commit → a committed listing matching one saved search emits one event · `e4f5a6b` render the listing once in the digest → the next daily digest carries the listing once
**Gate**  one event per match → red · digest carries it once → red · findings: behaviour P1 ×0 · claim P1 ×1 (resolved) · test P1 ×0 · shape P2 ×1 (riding)
**Blocked**  —
**Resume**  nothing — complete
````

The pull request it opened:

````markdown
## Summary

- A committed listing matching one saved search emits one `SearchMatchEvent`
- The next daily digest carries that listing once

## Criteria

| criterion | command | result |
| --- | --- | --- |
| a committed listing matching one saved search emits one event | `mix test test/saved_search/match_test.exs` | green — 1 test, 0 failures |
| the next daily digest carries the listing once | `mix test test/digest/search_alert_test.exs` | green — 1 test, 0 failures |

## How to see it running

`mix phx.server`, then save a search for `croydon` and run `mix run priv/repo/commit_listing.exs croydon`; the next digest preview shows the listing once.

Closes #232
````

## A stop-rule hand-back

The parent's window filled during the second unit, so what was green was committed and the remainder became a unit of its own.

````markdown
### Build — session 1, 2026-09-24

**Loop**  `mix format --check-formatted` · `mix test <file>` · `mix test` · CI green — proven at `4e7a1c9`
**Units**  `b2c3d4e` suppress the digest entry for a search whose fingerprint already matched → a search that matches nothing stays quiet
**Gate**  stays quiet → red · findings: behaviour P1 ×0 · claim P1 ×0 · test P1 ×0 · shape P2 ×1 (riding)
**Blocked**  —
**Resume**  unit 2b — `SavedSearch.Notifier` must suppress the digest when the fingerprint repeats, not only when the query returns nothing; `mix test test/digest/quiet_test.exs` is red
````

Small print: one line per field, `—` for nothing blocked, `nothing — complete` for nothing left. The resume line is read by a cold session, so it names the file, the behaviour and the command that is still red — never "continue where I left off".
</content>
</invoke>
