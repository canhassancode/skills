---
name: spike
description: Answer one question about how something behaves by running the smallest throwaway code that shows it, inside a timebox, and return the answer with its evidence. Use when align routes an unknown to a spike, or the user asks what an API, library or part of our own system actually does when run.
argument-hint: <one-sentence question>
---

# Spike

Run it, don't argue it: one question, the smallest program that answers it, thrown away after.

Origin: XP's spike solution ("expect to throw it away"; its goal is reducing a technical risk), bounded here because this library's own unbounded probes ran 30 minutes and 330K tokens on one question.

## Rules

- **One question, in one sentence**, with the answer's shape named up front: yes or no, a value, or a list. A question that won't fit one sentence goes back to whoever sent it.
- **15 minutes.** Note the start time; check it before each run. Wrap every command in `timeout 120`. At the limit, stop and return what you have.
- **The smallest case.** One call, one repo, one input that decides it. Never a sweep.
- **Scratch only.** Work in `$TMPDIR/spike-<slug>` or a throwaway worktree. Never touch the feature branch, never commit, delete it after.
- **Sandbox credentials only**, from the environment. Never read secrets from `.env`, `.mcp.json` or config files, and never point at production. Missing access is an answer: `needs access: <what>`.
- **Run, don't read.** The evidence is a command and its output. Docs are `/research`'s; a shape the user must see is `/prototype`'s.

## Return

Follow [EXAMPLES.md](EXAMPLES.md): the question, the answer in one line, the command and the output that show it, what it doesn't tell us, and the minutes taken. The answer is for the caller's Decisions as `Q → A (spike)`; the code is not kept.
