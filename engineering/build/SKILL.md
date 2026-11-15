---
name: build
description: Build one ready-to-build ticket in this session. Find what already exists, build test-first at the spec's seams, prove each criterion on the running app, self-review against the coding rules, then run crucible and hand back a pull request. Use when a ticket is ready-to-build.
argument-hint: <ticket-ref>
disable-model-invocation: true
---

# Build

Each ticket gets one session and one writer. This session writes the code itself. Subagents only read: the reuse search, the Verify run and the review. Each returns a few lines.

Origin: Anthropic's long-running harness (one feature per session, proven end-to-end on the running app before it is called done, carried between sessions by git and a progress note) and Pocock's implement (the build holds no rules of its own; `tdd` and the review do). ADR-0013 has the local evidence.

## Steps

1. **Read** the ticket. Its body is the spec: what to build, the acceptance criteria, the seams and the Verify steps. Check its open blockers with the tracker's operation in `docs/agents/issue-tracker.md`; an open one stops the build here, naming it. If its pull request carries a Resume line, start where that line says. Otherwise cut `feat/<slug>` from the base.
2. **Fit the loop** from the repo, not from memory: typecheck, lint, the test command and the Verify start command, each run once. A missing service or credential stops the build before you write anything (step 7).
3. **Look before writing.** A subagent searches the repo, its installed dependencies and the standard library for anything that already does part of the work. It returns each find with its `file:line` or API name. Use what it finds.
4. **Build** with [tdd](../tdd/SKILL.md) at the spec's seams; they count as already agreed. Write each test by [good-vs-bad](../tdd/good-vs-bad.md), on the layer [layers](../tdd/layers.md) gives it. Start the app as soon as there is something to see, and look at it while you build. Typecheck and run the touched tests after each cycle. Commit on each real green.
5. **Prove it on the running app.** Once every criterion has a green test, a fresh subagent runs the spec's Verify steps with [the verifier brief](references/verifier.md). A failed step is a bug: write a test for it, fix it and rerun that step. A step that can't run in session goes into the pull request as an unchecked box with its reason.
6. **Review.**
   - Re-read your own diff against the Coding Standards and Code style in `~/.claude/CLAUDE.md`, the repo's `CLAUDE.md` and [BASELINES](../crucible/BASELINES.md). Look in particular for duplicate types, casts, comments, and code the reuse search could have replaced. Fix it and commit.
   - Then run `/crucible <base>...HEAD <ticket>` in a fresh subagent. Fix each `fix` finding once, test first, then rerun any Verify step whose path the fix touched.
   - Run crucible once more over the fix commits only, and never a third time. Anything still open, and any finding that would change the spec, goes on the pull request's hand-back list.
7. **Stop instead of working around.** Stop for missing access, a criterion that can't hold as written, or a fix that would change the spec. Post what blocked you, with evidence, on the ticket. Missing access leaves it at `ready-to-build`; a spec problem moves it to `needs-alignment`.
8. **Hand back.** Merge the base in, never rebase, and rerun the suite. Push and open the pull request as [EXAMPLES.md](EXAMPLES.md) shows: ready when every Verify step is ticked, a draft when any is unchecked. Drop `ready-to-build` and name `/shepherd <pr>` as next.

A prose or settings ticket (a skill, docs, config) skips tdd. Step 4 is the change itself, and the rest runs as written.

A ticket that spans repos gets one branch and one pull request per repo, in the merge order its spec names.

## Context

A ticket that fits one session lands around 60–110k tokens. Past about 120k, or after a compaction, commit what is green, push, write a Resume line in the pull request body saying what is done and what is next, and stop. The next `/build <ticket>` starts from it. A ticket that needs a third session was cut too big: say so, and send it to `/cut <parent>`.

## Never

Read `.env`, `.mcp.json` or production credentials · weaken or delete a test to get green · run two writers in one checkout · mark a pull request ready with a red suite, an unticked Verify step or an unmerged base.
