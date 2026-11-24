# Retro ledger

| Date | Ticket | Change | Signal |
| --- | --- | --- | --- |
| 2026-11-15 | brigade#172 | shepherd §2 watches each round with `scripts/watch-round.sh` (marker or bot 👍 at the head, failed check, base conflict, 15-minute cap) in place of the 👀/👍 prose and hand-written loops | next shepherd run: no operator turn reports a conflict or a closed round before the agent does, and the agent writes no watch loop of its own |
| 2026-11-15 | brigade#172 | home `AGENTS.md` sends brigade's `## Verify` runs to `canhassancode/brigade-fixture` | builds of brigade#175–177: no operator turn redirecting Verify to the fixture, and no Verify run against `canhassancode/brigade` |
| 2026-11-16 | brigade#176 | build step 8 opens the pull request ready only when no `fix` finding is open, a draft otherwise | next build whose second crucible pass leaves a `fix` open keeps its pull request a draft |
| 2026-11-16 | brigade#176 | verifier brief closes every issue and pull request it opened once done | after the next Verify run, the fixture has no new open issues, and the pull request's hand-back has no side-effect line about claimed throwaways |
| 2026-11-16 | brigade#176 | build's 120k stop moves from prose to a PostToolUse hook (`scripts/context-budget.sh`) that reads the transcript's usage and tells the main session when it passes 120k | next build that passes 120k pushes a Resume line and stops within a few tool calls; no build peaks far past 120k |
| 2026-11-18 | work run | cut's blocking edges also link children that change the same function or type, not only children one needs | next cut: no blocking edge added by hand after publish because two children overlapped in code |
| 2026-11-18 | work run | build step 6 and shepherd §4 fix a second-pass `fix` finding test-first instead of handing it back; shepherd's re-review vets it | next build or shepherd hand-back lists no `fix`-routed finding, and no reviewer raises one that was on a hand-back list |
| 2026-11-18 | work run | verifier brief starts the app on a free port | next Verify run: no step reports a result served by another checkout's server |
| 2026-11-18 | work run | crucible's Consumers step flags a new call to an existing function that drops an option or gate its other callers pass | next reviewer finds no dropped flag or option on a reused client |
| 2026-11-18 | work run | dotfiles `guard.sh` lets curl writes to localhost run unprompted (outside this repo) | next build's local Verify queries raise no curl prompt |
| 2026-11-18 | work run | workspace docs name which local database the dev server's Verify runs use (outside this repo) | next Verify run in that workspace: no operator turn correcting which database to use |
| 2026-11-19 | work run | cut step 3: the child that should move the parent's Done measure runs it in Verify | next cut of a parent with a Done measure: a child's Verify carries it, and no operator turn asks whether the metric was tested |
| 2026-11-19 | work run | shepherd §7 asks spec-change escalations in one grilling round, answers going into the spec's Decisions; the `/align` hand-off line is gone | next shepherd run with a spec change: the operator runs no `/align` to settle it |
| 2026-11-19 | work run | shepherd's two-re-review cap counts per review that sent fixes, the bot's or a colleague's | next shepherd that fixes a colleague's review asks the bot to re-review those fixes without an operator turn prompting it |
| 2026-11-19 | work run | dotfiles `worktree-include.sh` PostToolUse hook copies `.worktreeinclude` files into worktrees made with `git worktree add` (outside this repo) | next runs: no operator turn copying `.env` into a worktree |
| 2026-11-19 | work run | workspace docs say how Verify mints a local API key (outside this repo) | next Verify that needs a key mints it with no operator turn |
| 2026-11-24 | CAR-1829 | build EXAMPLES Summary leads with before and now, so the hand-back states the uplift | next build hand-back: no operator turn asking what the ticket achieved or whether there is an uplift |
| 2026-11-24 | CAR-1829 | dotfiles gitconfig `branch.autoSetupMerge = false`: branches cut from `origin/main` no longer track it, so bare `git push` opens their own branch (outside this repo) | next build: no guard.sh "push landing on main/master" block |
