# Retro ledger

| Date | Ticket | Change | Signal |
| --- | --- | --- | --- |
| 2026-11-15 | brigade#172 | shepherd §2 watches each round with `scripts/watch-round.sh` (marker or bot 👍 at the head, failed check, base conflict, 15-minute cap) in place of the 👀/👍 prose and hand-written loops | next shepherd run: no operator turn reports a conflict or a closed round before the agent does, and the agent writes no watch loop of its own |
| 2026-11-15 | brigade#172 | home `AGENTS.md` sends brigade's `## Verify` runs to `canhassancode/brigade-fixture` | builds of brigade#175–177: no operator turn redirecting Verify to the fixture, and no Verify run against `canhassancode/brigade` |
| 2026-11-16 | brigade#176 | build step 8 opens the pull request ready only when no `fix` finding is open, a draft otherwise | next build whose second crucible pass leaves a `fix` open keeps its pull request a draft |
| 2026-11-16 | brigade#176 | verifier brief closes every issue and pull request it opened once done | after the next Verify run, the fixture has no new open issues, and the pull request's hand-back has no side-effect line about claimed throwaways |
| 2026-11-16 | brigade#176 | build's Context drops the 60–110k estimate and 120k stop; a compaction alone triggers the Resume line | next build that compacts writes a Resume line and stops, and no build quotes a token estimate |
