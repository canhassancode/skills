---
name: build
description: Make a child ticket's locked tests green through fresh builder subagents, one unit and one commit at a time, then vet with crucible, verify on the running app and mark a pull request for each branch in the spec's header line ready — or stop and say which locked test is wrong. Use when a child ticket is ready-to-build.
argument-hint: <child-ticket-ref>
disable-model-invocation: true
---

# Build

Turn a child's locked failing tests green without touching them, prove the change on the running app, and hand back a pull request a human can check in minutes.

Origin: TDFlow (human-owned tests as the oracle, 94.3% vs 68.0%), ImpossibleBench (read-only tests plus "stop and say so" took cheating from 54% to 9%) and Anthropic's long-running harness (fresh sessions carried by commits; end-to-end checks before "done").

This session is the **Delegator**: it holds the spec, the unit list and the results, never a diff, so it stays small however big the child is. Every unit is a fresh subagent, one at a time; one writer per checkout. The briefs are in [references/briefs.md](references/briefs.md).

## Steps

1. **Read** the ticket, whose body is the spec, and the `test: lock` commit on `feat/<capability>`. Bring the branch up to date with the base — merge it in once the branch is pushed, never rebase — then run [the lock check](../tester/scripts/check-locked-tests.sh) and the locked tests: every one red for the reason tester reported. Anything green, or red for another reason, stops the build.
2. **Fit** the loop from the repo, not memory: typecheck, lint, the locked command, the full suite and the spec's `## Verify` start command. Run each once at the base. A missing command is recorded as absent; a missing service or credential is a stop (step 6).
3. **Plan units.** Group the locked tests into units a fresh child can turn green, ordered so each starts from the last one's green tree. A child that needs more than a few units goes back to `/cut`.
4. **Build each unit** with a fresh builder. It commits once, on a real green, and hands back the commit and the command's output. Check that output yourself before the next unit.
5. **Vet and verify**, both in fresh subagents and neither the builder:
   - `/crucible` over `<lock-sha>...HEAD` with the ticket. Delete the scratch tests on its prune list in one commit, `test: prune scratch tests`.
   - The verifier with the spec's `## Verify` steps only, never the diff or the tests.

   Each behaviour line gets one fix round, counted in the pull request's `## Fix rounds` table, which you read before any fix. A finding counts against its `caused by` fix's line; with no `caused by`, or one from a `none` round, it counts against its own `line`; a failed or changed verify step counts against the line it checks. A line with no round yet sends its acting findings and failed steps to one fix round in a fresh builder, which commits on top; log the row `| <line> | <sha> (<source>) | — |`, then re-run the lock check, the suite, the verifier's failed steps and crucible over the fix commit.

   A finding on a line that already has a round stops that line: no fix. Write the date and the finding in its Stopped cell, then put one rule question to the user: the finding, every survivor crucible raised on that line, and a single sentence that quotes the stopped line word for word and ends in a question mark. Survivors alone never stop a build. A finding that would change a behaviour line goes to the user the same way. Carry on with the other lines and units; a question still unanswered at hand-back goes in step 7's escalation.

   A ruling that leaves every behaviour line's wording unchanged is answered here: add it to the ticket's `## Decisions` as `- <date> Q: <the rule question> → A: <the ruling>` and carry on, with the ruling as spec, in this session — never `/align`. A ruling that rewrites a line sends the ticket to `/align` to relock that line (step 6).

   A finding with `line none` gets one fix round of its own, logged as `| none | <sha> (<source>) | — |`. Still open after it, it goes on the hand-back list (step 7) and stops nothing.
6. **Stop instead of working around** — a locked test that looks wrong, an interface that can't satisfy a line, missing access, or a fix that would change the spec. Post the stop report from [EXAMPLES.md](EXAMPLES.md); a wrong test or interface moves the ticket to `needs-alignment`, missing access leaves it at `ready-to-build`.
7. **Hand back** a pull request for each branch in the spec's header line, opening any `/align` didn't, and keep each a draft. Update each body in place as [EXAMPLES.md](EXAMPLES.md) does — behaviour lines with their tests, a ticked Verify box with its evidence for each step run, an unchecked box with the reason for each step not run in session, Decided limits, Fix rounds, what was pruned, and the header's merge order where it gives one. Then put every unchecked step and every unanswered rule question to the operator as one escalation, each step with why it wasn't run and the question it needs answered, and wait. Report the hand-back list in the same message — each open finding that stops nothing, with its `file:line` and evidence. A ruling goes under its step, which stays unchecked. Once every Verify step is ticked or ruled and every rule question answered, mark each pull request ready, drop `ready-to-build`, post the session comment, and name `/shepherd <pr>` as next.

When this window fills, the green units are already committed: push, write the Resume line and stop. A session that ends with a step still awaiting a ruling stops the same way: the pull request stays a draft, the ticket stays `ready-to-build`, and the Resume line names the steps and stopped lines awaiting a ruling. A fresh `/build` reads the comment and starts where it left off — the next unit, or the ruling.

## Never

Edit a locked file · give a behaviour line a second fix round without a ruling · run two writers in one checkout · read `.env`, `.mcp.json` or production credentials · mark a pull request ready with a failing locked test, a changed lock, an acting finding neither fixed, ruled nor on the hand-back list, or an unchecked Verify step with no ruling · put criterion codes in commits or test names.
