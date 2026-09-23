---
name: build
description: Build a cut ticket as a sequential loop of fresh-child units, gated by crucible, ended by its pull request.
argument-hint: <ticket-ref>
disable-model-invocation: true
---

# Build

Stage 3. `/build <ticket-ref>` reads a cut ticket's **contract**, fits the repo's own loop, and builds the ticket as a **sequential** loop of **Units** — each one in a fresh **Builder** child, each vetted by the **Review** in a child of its own, each green and committed before the next begins. It ends with the branch pushed and the pull request open, its table showing every criterion's command and result.

The parent session — the **Delegator** — holds the contract, the unit list and the run's one comment, never a diff. Code in this window is the failure this skill closes: the parent delegates every unit and never edits the tree. One writer per checkout, always — a Builder and the Review never hold the tree at the same time.

Fresh children come from the harness, named in one line: pi's `subagent` with the `Builder` and `Reviewer` agents, Claude Code's `Agent` tool. A harness that cannot spawn one is an **unavailable** dependency like any other, and the run stops before writing (§2).

Run it against a ticket at `ready-to-build`; with no ticket there is nothing to build. Tickets are read through the tracker adapter — run `/bootstrap` if `docs/agents/issue-tracker.md` is missing.

## 1. Read the contract

Fetch the ticket and read its body: the scenarios and their outcomes, the acceptance criteria, the interfaces it owns and consumes, the decisions that bind it, what it decided against, and its blocking edges. The ticket is read-only to this run; the one comment in §6 is all this skill writes to it.

Every criterion carries the command that decides it and the evidence that counts as passing. The fit pairs each with its **witness** — the test or observable that shows it. A criterion the fit cannot pair is a **gap** (§2), never a hand-back.

**Done when** every criterion traces to a scenario and names its command.

## 2. Fit the repo, then prove the loop at the base

Derive the mechanics from the repo on every run, never from a cache — a cache applies yesterday's mechanics to today's repo. Read `CONTEXT.md` and `CLAUDE.md`, the CI config, the scripts in `package.json` / `Makefile` / `justfile`, lockfiles, `.env.example`, and the tests that already exist. One pass: what is not there is *absent*.

| field | what it holds |
| --- | --- |
| **loop** | typecheck, focused tests, the suite — the commands every unit runs |
| **criteria** | one command per criterion, each with its witness |
| **secrets** | the path a secret lives at, never the value |
| **children** | the harness's two spawn calls, probed once before the loop |
| **proven** | the base commit and the tooling hash the commands ran against — lockfiles and tool config, hashed with the shell's own tool |

Then run them at the base commit. One of three honest outcomes comes back:

- **Absent** — no suite, no typecheck, no CI. Absence is a recorded fact and the run proceeds: the operator's own run at hand-back is the verification such a repo has left.
- **Unavailable** — a command, a service, a secret or the harness's spawn call is missing. **Stop before writing anything to the tree**: name what is needed and where it lives (a secret's path, never its value), ask the operator, and leave the block on the ticket as §6's comment. An unavailable dependency is never worked around, and once it is supplied a fresh session resumes here.
- **Green** — record the base commit and the suite's duration: the baseline every unit is measured against.

A witness is derived from the criterion.

A criterion the fit cannot pair is a **gap**. The run collects every gap — from the fit or from the cut — and puts the set to the operator once, in session, with a proposition: proceed and record it open, or stop. On a yes the criterion is **accepted open** — owned by no unit, recorded `accepted open — <why>` in §6's Gate line and in the pull request's table; on a no the run stops with the gap on the ticket as §6's comment. The run never refuses on contract shape; the operator may.

**Done when** every criterion is paired with a witness and a command, both run at the base, or is a gap put to the operator — and the outcome is one of the three.

## 3. Cut the ticket into units

The run owns one checkout for the whole ticket — a worktree off the base, or the session's own — where the units, the Review and the push all happen. Create its branch before the first unit: `feat/<n>-<slug>`, off the trunk or off the branch the ticket was cut against.

A **Unit** is a criterion, or a coherent group of them, that one fresh Builder can hold end to end. Cut by coherence, never horizontally: work that cannot name the criterion it makes pass is not a unit, and the window is a stop-rule rather than a cutter.

Order the units so each begins from the last one's green tree — a schema before its consumers, a shared type before the code that calls it. Every criterion that is not a gap belongs to exactly one unit.

A ticket that will not cut into units one Builder can hold is not this run's to shrink: cut what cuts, and put the remainder to the operator as a gap, on §2's terms.

**Done when** every criterion that is not a gap has exactly one unit, in an order where each unit starts from a green tree.

## 4. Run the loop

One unit at a time, in order. The moves below repeat until the units are done.

### 4.1 Brief a fresh Builder

Spawn a fresh child with the brief below. It carries the contract by reference and the unit's material verbatim — never a restatement of the whole contract — and its first line is the unit's identity, so every surface names the unit rather than repeating the agent.

```text
Unit <n> of <m> — <one line> · Ticket: #<n>

<builder-brief>

You build one unit of this ticket. Read the contract on the ticket; the criteria below are yours, verbatim.

Owns: <criterion>, <criterion>
Witness and command: <criterion> → <witness> → <command>
The loop: <typecheck>, <focused tests>, <suite> — proven green at <commit>.
Secrets live at: <paths> — never a value. If one is unreadable, stop and say so.

TDD the unit — /tdd, or the project's equivalent — and commit once, when every criterion you own is
green and its command has run. One unit, one commit: its subject names the criteria it makes pass, and
that commit is your hand-back. A fix round adds one on top (§4.4) — three commits at most for one unit.
Commit on a real green, never on your say-so. Where the fit recorded absence there is no cycle to run
and the unit still closes on one commit — the operator's run is the verification.

Change only what this unit's criteria need. End at a clean tree with your commits in hand: the parent
pushes and opens, and the Review is a separate child.

If your window fills before the unit is done, commit what is green, leave the tree clean, and hand back
what is done and what remains.

Hand back: the commit, the criterion's command with its output quoted, the loop's results, and
confirmation the tree is clean.
</builder-brief>
```

A Builder ends when it judges the unit done — green, committed, tree clean, the criterion's command run and quoted. Any other hand-back is a brief that failed: re-brief a fresh child rather than resuming that one.

**Done when** the unit's commit is in and the tree is clean.

### 4.2 Vet the unit with the Review

Launch `/crucible` in a fresh `Reviewer` child — never in this window — giving it the unit's diff range `<base>...<head>` (the previous unit's head, or the branch point for the first unit), the ticket's contract, and the witness and command of every criterion the unit owns. It falsifies every owned witness with one hand-placed mutation, and it never posts.

It returns **Findings** — class, severity, where it was found, the unit it belongs to, its resolution — and the **verified list**: one line per owned criterion, `criterion → mutation → red`. Without that list the unit is not vetted: a green suite and a Builder's word are not the gate. A review that could not mutate the tree says so, and the unit stays open.

**Done when** every criterion the unit owns carries a falsification result and the findings are in hand.

### 4.3 Route the findings

| finding | route |
| --- | --- |
| behaviour · claim · test — P0/P1 | a fresh fix child, §4.4 |
| shape — P2 | recorded in the comment, never a fix round |
| an out-of-scope row | suppressed, citing the row |
| a scenario the contract never named | a contract change: `/align`, never a fix round |
| a product call | asked in session; the answer recorded as a decision row or an out-of-scope entry |

**Done when** every finding has a route and none is left unplaced.

### 4.4 Fix, twice at most

A fix is a new Builder child carrying the findings as its brief, never a resumed one:

```text
<fix-brief>

Unit <n> of <m> · Ticket: #<n> · Round <n> of 2 — <the finding this round answers>

The Review returned findings against this unit. Each is a question with its evidence; answer it in the
code — the fix lands wherever the finding lives, which may be outside this unit's diff.

<the findings verbatim>

Same boundary as the unit brief: /tdd where a test is the answer, one commit for the round, tree clean, no
push. Round two varies the route: a second attempt that repeats the first one's failed route is not a
second attempt. Do not widen scope — a finding that adds a scenario is not yours to fix; say so and stop.
</fix-brief>
```

Commit the round, then re-vet only the criterion the round touched: a round that does not turn that mutation red did not close the finding, and a round that widens scope is a contract change wearing a fix's clothes. Each finding gets two rounds at most — a round answers one finding, or several answered by the same change — and a finding still open after its second goes to the operator in session: the finding, what was tried, and a proposition with the route it would take.

**Done when** every acting finding is closed by a red mutation, escalated with a proposition, or recorded as accepted open.

### 4.5 Close the unit

A unit closes when the tree is clean, its commits are in, and every criterion it owns is red-mutated in the verified list or explicitly accepted by the operator. A criterion accepted open is named as accepted in the comment and in the pull request's table.

### 4.6 The stop rule

When a window fills mid-unit — the Delegator's or a Builder's — what is green is committed, the tree is left clean, the comment (§6) records the resume point, and the remainder becomes a unit of its own for a fresh session. Push the branch so the green commits are on the remote, and open nothing.

## 5. Push and open the pull request

Once every unit is closed, push the branch and open the pull request:

```sh
git push -u origin <branch>
gh pr create --title "<subject> (#<n>)" --body-file -
```

The body carries every criterion, the command that decides it, and the result that was actually run:

```markdown
## Summary

- <what the branch does, in the contract's language>

## Criteria

| criterion | command | result |
| --- | --- | --- |
| <the criterion, short> | `<the command>` | <green — n tests · accepted open> |

## How to see it running

<the server or container command, the screens — or "no runnable surface">

Closes #<n>
```

The rows are the run's own evidence: one per criterion, each with the command that was actually run. The pull request opens when the loop has finished — never with a P0, or a P1 neither closed nor explicitly accepted, still standing — and never as a force push.

**Done when** the pull request is open and its table has a row for every criterion in the contract.

## 6. Write the run's one comment

One comment per session, appended to the ticket and never edited. It is the run's durable memory: a fresh session reads it and resumes from it.

```markdown
### Build — session <n>, <date>

**Loop**  <typecheck> · <focused> · <suite> · CI <status | absent> — proven at `<commit>`, tooling `<hash>`
**Units**  `<sha>` <subject> → <criterion> · `<sha>` <subject> → <criterion>
**Gate**  <criterion> → red · <criterion> → accepted open — <why> · findings: behaviour P0 ×0 · claim P1 ×1 (resolved) · test P1 ×0 · shape P2 ×2 (riding)
**Blocked**  —
**Resume**  <the next unit, or `nothing — complete`>
```

Every field keeps its line: nothing blocked writes `—`, nothing left writes `nothing — complete`, and a criterion accepted open is written `→ accepted open — <why>`. The resume line names the next unit, or its remainder, precisely enough that a fresh session starts there without reading the diff. Worked comments are in [EXAMPLES.md](./EXAMPLES.md).

**Done when** the comment is on the ticket and it is the only one this session wrote.

## 7. Hand back

Give the operator the pull request and, per criterion, the command they can run to see the work. Where the change has a runnable surface, name the server, container or screen to start, so the ticket is seen rather than asserted — "it works" is not a hand-back.

**Done when** the pull request, the per-criterion commands and the running thing are in the operator's hands.

## Boundaries

**Always** — read the contract before writing · prove the loop at the base · one writer per checkout · commit on a real green · leave the tree clean · escalate with a proposition.
**Ask first** — an unavailable loop dependency · a fix that would change the contract · a finding unclosed after two rounds · anything the out-of-scope rows do not cover.
**Never** — a second writer in the checkout · a witness invented to fit the code · working around a missing service · writing to the ticket beyond one comment per session · a commit tagged with a criterion id · a pull request opened while a P0 or an unaccepted P1 stands · a done without the command's output.

## Related

- `/crucible` — the **Review** every unit passes through.
- `/tdd` — the cycles inside a unit.
- `/commit` — one per unit; a round's commit rides on top.
- `/align` — where a finding that names a scenario goes, and where a ticket that will not cut into units goes.
- `/cut` — the stage before this one.
