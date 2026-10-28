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

1. **Read** the ticket, whose body is the spec, and the `test: lock` commit on `feat/<capability>`. Rebase onto the base branch, then run [the lock check](../tester/scripts/check-locked-tests.sh) and the locked tests: every one red for the reason tester reported. Anything green, or red for another reason, stops the build.
2. **Fit** the loop from the repo, not memory: typecheck, lint, the locked command, the full suite and the spec's `## Verify` start command. Run each once at the base. A missing command is recorded as absent; a missing service or credential is a stop (step 6).
3. **Plan units.** Group the locked tests into units a fresh child can turn green, ordered so each starts from the last one's green tree. A child that needs more than a few units goes back to `/cut`.
4. **Build each unit** with a fresh builder. It commits once, on a real green, and hands back the commit and the command's output. Check that output yourself before the next unit.
5. **Vet and verify**, both in fresh subagents and neither the builder:
   - `/crucible` over `<lock-sha>...HEAD` with the ticket. Delete the scratch tests on its prune list in one commit, `test: prune scratch tests`.
   - The verifier with the spec's `## Verify` steps only, never the diff or the tests.

   Send every acting finding and failed verify step to one fix round in a fresh builder, which commits on top. Re-run the lock check, the suite, the verifier's failed steps and crucible over the fix commit. Anything still open, or that would change a behaviour line, goes to the user as one list.
6. **Stop instead of working around** — a locked test that looks wrong, an interface that can't satisfy a line, missing access, or a fix that would change the spec. Post the stop report from [EXAMPLES.md](EXAMPLES.md); a wrong test or interface moves the ticket to `needs-alignment`, missing access leaves it at `ready-to-build`.
7. **Hand back** a pull request for each branch in the spec's header line, opening any `/align` didn't: rewrite each body as [EXAMPLES.md](EXAMPLES.md) does — behaviour lines with their tests, the Verify checklist with its evidence and an unchecked box for each step not run in session, Decided limits, what was pruned, and the header's merge order where it gives one — then mark each ready. Drop `ready-to-build`, post the session comment, and name `/shepherd <pr>` as next.

When this window fills, the green units are already committed: push, write the Resume line and stop. A fresh `/build` reads the comment and starts at the next unit.

## Never

Edit a locked file · run two writers in one checkout · read `.env`, `.mcp.json` or production credentials · mark a pull request ready with a failing locked test, a changed lock or an unanswered acting finding · put criterion codes in commits or test names.
