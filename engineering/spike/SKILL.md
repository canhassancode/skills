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
- **A sample when the question is about every case**: what forms a field takes, how often a state occurs, whether something always holds. One case can't answer it. Read a bounded sample from where the change will run, at most 500 records, and give the count with the answer: `158 of 405`.
- **Scratch only.** Work in `$TMPDIR/spike-<slug>` or a throwaway worktree. Never touch the feature branch, never commit, delete it after.
- **Production is read, never written.** Reach it only through a read-only route the session's tools or the repo's docs name: a read-only database MCP, a log query, a supplier call that only reads. A database read asks for a count before rows, caps rows with a `LIMIT`, and runs `explain_query` before `execute_sql` where the route offers both. Anything that writes uses sandbox credentials from the environment. Never read secrets from `.env`, `.mcp.json` or config files. Missing access is an answer: `needs access: <what>`.
- **Run, don't read.** The evidence is a command and its output. Docs are `/research`'s; a shape the user must see is `/prototype`'s.

## Return

Follow [EXAMPLES.md](EXAMPLES.md): the question, the answer in one line, the command and the output that show it, what it doesn't tell us, and the minutes taken. The answer is for the caller's Decisions as `Q → A (spike)`; the code is not kept.
