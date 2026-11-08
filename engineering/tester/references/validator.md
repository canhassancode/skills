# Validator

Red shows a test runs, not that it can pass. A stub throws on its first call, so nothing after that throw has executed when a test locks, and a test that can never pass is red too. The validator runs the tests against real code before the lock: a fresh agent writes throwaway code from the spec and the interface, and whatever stays red is looked at.

`/align` runs it after `/tester` reports no gaps. It is a subagent of its own, never `/tester` itself, and it never reads the build's code, because none exists yet.

## Set up

The tests aren't committed yet, so the scratch worktree gets a copy of them:

```sh
scratch="$TMPDIR/validator-<short-sha>"
git worktree add --detach "$scratch" HEAD
{ git diff --name-only --diff-filter=d HEAD; git ls-files -o --exclude-standard; } > "$scratch.files"
tar -cf - -T "$scratch.files" | tar -xf - -C "$scratch"
```

Install the repo's dependencies in the scratch worktree, then send the brief.

## The brief

Send exactly this, filled in.

```text
You are checking tests written before any implementation exists.

Scratch copy: <scratch path>. Use absolute paths or cd there in each command.
Spec: <the ticket body>
Locked command: <the command from tester's report>

Write quick, throwaway code from the spec and the interface that turns these tests green honestly. It will be deleted, so quality doesn't matter, only that it does what the spec says. Then report what stays red.

- Never edit a file matching .acceptance., .properties., .contract. or e2e/, nor any fake, harness or fixture. Never special-case a test's fixture values.
- Stay inside the scratch copy. No gh, no issues or pull requests, no network. Never read .env, .mcp.json or credentials. A test needing a real service is reported as not run.
- Don't commit.
- 15 minutes. Run date -Is at the start and before each test run; wrap each command in timeout 120. At the limit, stop and report what you have, with Finished: timed out.
- Call a test impossible only with a reproduction: the assertion, the actual value, and the smallest evidence that no correct implementation could satisfy it. Without one, it is unproven.

Return exactly:
Finished: <time> | timed out
Tests: <green>/<total>, <n> not run
Blockers, or none:
- red — <file:line> <title> — <assertion, actual> — <why no correct implementation passes, command and output>
- outside interface — <title> — <what passing needed that the approved interface doesn't carry>
Unproven: <titles, or none>
```

Anything else the agent notices, such as a detail the spec left undecided, stays out of the report.

## Act on the report

Before removing the scratch worktree, compare every copied file with the original. A difference voids the run:

```sh
while read -r file; do cmp "$file" "$scratch/$file"; done < "$scratch.files"
```

| Result | Route |
|---|---|
| `red` | `/tester` gets the test, the assertion, the actual value and the reasoning, never the throwaway code, and makes one fix. The validator then re-runs only the fixed tests, under the same limit, from fresh code. |
| Still `red` after that fix | The user: the test and its evidence. Nothing locks. |
| `outside interface` | Align's interface step: the approved interface can't carry the line. Nothing locks. |
| `timed out`, or a void run | The user. Running out of time is never a pass. Nothing locks. |
| No blockers | Commit `test: lock <capability> tests` with no approval question. `Unproven` titles go in the session comment. |

Finish with `git worktree remove --force "$scratch"`, then delete `$scratch.files`.

## Evidence

- Replay on brigade's lock commits: throwaway code exposed the known defect on the exact tests for 3 of 4 tickets, and named the fourth as a gap in the interface; no other test was flagged across the 175 run, at about 88k tokens and 2:39–4:53 per ticket (#185).
- Validity is the variable: TDFlow, 68.0% with unvalidated LLM tests, 93.3% where every LLM test was valid, and "no correction mechanism" named as the main weakness, https://arxiv.org/abs/2510.23761.
- Refining test oracles against a generated implementation helped on every benchmark, and agent deliberation alone did nothing on the hard one: Nexus, https://arxiv.org/abs/2510.26423.
- Reading can't catch this: all six test defects in brigade's build stops passed the operator's review (#185). Authors of independent versions share misreadings of one specification (Knight & Leveson, 1986), so a clean run proves one reading can pass, not that the tests are right.
