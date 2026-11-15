# Retro ledger

| Date | Ticket | Change | Signal |
| --- | --- | --- | --- |
| 2026-11-15 | brigade#172 | shepherd §2 watches each round with `scripts/watch-round.sh` (marker or bot 👍 at the head, failed check, base conflict, 15-minute cap) in place of the 👀/👍 prose and hand-written loops | next shepherd run: no operator turn reports a conflict or a closed round before the agent does, and the agent writes no watch loop of its own |
| 2026-11-15 | brigade#172 | home `AGENTS.md` sends brigade's `## Verify` runs to `canhassancode/brigade-fixture` | builds of brigade#175–177: no operator turn redirecting Verify to the fixture, and no Verify run against `canhassancode/brigade` |
