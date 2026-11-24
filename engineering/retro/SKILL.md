---
name: retro
description: Run a retrospective over a ticket's pipeline sessions. Read the align, cut, build and crucible transcripts, measure where the time and the operator's turns went, check earlier retro changes against their signals, and propose changes to the skills or the environment. Each change names what it removes or replaces, and accepted ones are applied in the same sitting. Use when the user runs /retro, usually after a ticket merges or stalls.
argument-hint: [ticket-ref | session id]
disable-model-invocation: true
---

# Retro

Improve the environment the next run works in, not the code this one wrote. Every change must earn its words.

Origin: Pocock's retro (read the session's own logs, then improve navigation, checks, standards and information access, not the code), plus the fixes for its open complaints: candidates checked before they reach the user (mattpocock/skills#1173), a ledger that re-checks earlier changes (#1379), and the moments the user had to step in (#1421). This library's pipeline skills grew from 14k to 21k words in 17 days because every failure added a rule and none were removed (ADR-0013).

## Steps

1. **Gather** the sessions for the ticket the user names, or the current session if they name none. That means its align, cut, build and shepherd transcripts under `~/.claude/projects` and `~/.claude-work/projects`, `subagents/` included, plus the ticket, its comments, its pull request and `git log`. Parse transcripts with a script; never read a whole file.
2. **Measure.** Record:
   - wall-clock per stage, and the operator's turns, with how many were bare approvals;
   - each session's peak context;
   - crucible passes, fix commits and Verify failures;
   - escaped defects: anything found after the pull request went ready.
3. **Check the ledger.** For each row in the skills repo's `docs/retro-ledger.md` whose signal this ticket can test, say whether the change worked. One that didn't is a candidate for removal.
4. **Find candidates**, with the step that would have prevented each:
   - a skill step the agent skipped, misread, or paid for in turns without changing the outcome;
   - each moment the user interrupted or corrected the agent, and each scope violation;
   - a mistake an automated check could have caught. A mechanical rule gets a deterministic check (a lint rule, a hook, a CI job), not more prose;
   - a fact the agent couldn't reach, or took long to find;
   - a tool call that cost far more than its answer was worth;
   - an instruction that changes nothing the agent does.
5. **Check each candidate** before showing it. It needs a transcript timestamp and quote, or a `file:line`, that bears it out. Drop any that don't. An empty list is a complete answer.
6. **Budget.** Each candidate that adds instruction names the line it removes or replaces. A skill must not grow over a sitting. Run [writing-great-skills](../../productivity/writing-great-skills/SKILL.md) over each wording change.
7. **Propose**, worst first, in one round following [grilling](../grilling/SKILL.md). Each candidate gives:
   - the evidence;
   - the change, and where it lands;
   - what it removes;
   - the signal that would show it worked.
8. **Apply** each accepted change in this sitting. Skills are edited in this library's source repo, never in the installed copies. Report the words removed as well as the words added, and append one ledger row per change: `| <date> | <ticket, or work run for a work ticket> | <change> | <signal> |`. Create the ledger file on its first row.

## Never

Edit code the run wrote · propose a change with no evidence · add a rule without naming what it replaces · file a ticket for a change that fits this sitting.
