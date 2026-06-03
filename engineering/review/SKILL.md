---
name: review
description: >
  Review code in Hassan's voice. Two modes: self-review of the current branch
  (prints to the terminal, never posts), or review a named GitHub PR (checks the
  branch out locally, drafts inline comments, confirms, then posts). Accepts full
  URLs, short forms like brushfeed#4, or no argument for the current branch. Use
  when the user asks to review a PR, check a pull request, do a code review, or
  mentions /review.
---

# Code Review

Reviews code with real local context and writes findings in Hassan's voice. The
output path depends on the mode:

- **Mode A — Self-review** (current branch, or no argument): review `HEAD`
  against `main` using the working tree on disk. **Print to the terminal. Never
  post.** This is the pre-PR self-review — there may be no PR to comment on yet.
- **Mode B — Named PR** (`brushfeed#4`, a URL, `#N` in a repo): check the PR
  branch out locally, review with full context, draft inline comments in Hassan's
  voice, **confirm with Hassan, then post** a grouped GitHub review.

Voice rules live in [VOICE.md](VOICE.md) — load it before writing any comment.
API and git commands live in [REFERENCE.md](REFERENCE.md).

## Quick start

```
/review                   → Mode A: self-review current branch vs main, terminal only
/review brushfeed#4       → Mode B: review the PR, draft + confirm + post
/review https://github.com/carpata-ltd/api/pull/425
```

## Input resolution

1. **No argument** → Mode A. Review `git diff main...HEAD` (or `master...HEAD`)
   in the current working directory.
2. **Full GitHub PR URL** → Mode B. Extract owner, repo, number.
3. **Short form `repo#N`** → Mode B. Resolve the owner:
   - Try `gh pr view N --repo hassan/repo` first.
   - Then `gh pr view N --repo carpata-ltd/repo`.
   - Then the current working-directory repo.
4. **Bare `#N`** in a repo working directory → Mode B against the current repo.

Resolution table and existence checks are in [REFERENCE.md](REFERENCE.md).

## When NOT to use this skill

For heavyweight, high-stakes, or deep multi-agent review (money flows, auth,
production migrations, large diffs), defer to `/review ultra` — the cloud
pipeline — rather than duplicating it here. This skill is the fast local layer
and the voice/posting layer; it is not a replacement for the cloud pipeline.

## Mode A — Self-review (current branch)

1. **Refresh the base.** `git fetch origin main` so the diff is against the real
   `origin/main`, not a stale local copy.
2. **Gather context.** Read `CLAUDE.md` / `AGENTS.md` / `CONTEXT.md` from the
   repo root. Read enough of each changed file — the working tree is right here,
   so navigate freely, grep call-sites, and run the test command if one is
   obvious.
3. **Review** (see "Review passes" below).
4. **Print to the terminal.** Lead with the verdict (looks good / things to look
   at), then findings as `file:line — comment` in Hassan's voice. **Do not post
   anything.** If Hassan then says "post this on PR #N", switch to Mode B's
   confirm-and-post step.

## Mode B — Named PR

1. **Fetch metadata.** `gh pr view <n> --repo <owner>/<repo> --json
title,headRefOid,baseRefOid,body,files,number,headRefName,baseRefName`.
2. **Locate the repo on disk and check the branch out** (commands in
   [REFERENCE.md](REFERENCE.md)):
   - If a local clone exists, `git fetch origin`, then add a **throwaway git
     worktree** at the PR head SHA. Never `checkout`/`pull` on Hassan's existing
     working tree — the worktree keeps his current branch and uncommitted work
     untouched.
   - If no local clone is found, shallow-clone into a temp dir.
   - Only if neither works, fall back to diff-only review via `gh pr diff` plus
     GitHub file fetches, and note the reduced context to Hassan.
3. **Gather context.** PR description and linked issues; **existing review
   threads** (never repeat a point already made — if the author replied "this is
   intentional because X" or "fixing in follow-up", respect it); `CLAUDE.md` /
   `AGENTS.md` / `CONTEXT.md`; the changed files in full via the worktree.
4. **Review** (see "Review passes" below). In the worktree you can run tests and
   grep — use that.
5. **Draft** the review body + inline comments in Hassan's voice ([VOICE.md](VOICE.md)).
6. **Confirm.** Present verdict, body, and every inline comment. Wait for explicit
   approval — Hassan may reword, drop findings, or change the verdict.
7. **Post** via the Reviews API. Then **clean up** the worktree / temp clone.

## Review passes

Run two passes with distinct angles, each over the full context bundle. Use
parallel subagents when available, sequential passes otherwise, or a single
combined pass for diffs under ~50 lines.

| Angle                          | Focus                                                                                                                                                       |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Correctness & security**     | Logic bugs, edge cases, race conditions, null handling, injection, auth gaps, error swallowing — and does the code actually do what the PR description says |
| **Patterns & maintainability** | TypeScript conventions, alignment with CLAUDE.md/AGENTS.md, codebase consistency, naming, obvious nits, British English                                     |

Passes do not edit code. Each finding carries: file path, line number, and a
ready-to-post comment in Hassan's voice. Then **synthesise**: deduplicate, drop
anything an author reply already settled, and decide the verdict:

- **No blocking issues** → `APPROVE`.
- **Anything worth flagging** → `COMMENT`. Never `REQUEST_CHANGES`.

## Confirmation gate (Mode B only)

Never post without confirmation. Present the verdict, review body, and every
inline comment (format in [REFERENCE.md](REFERENCE.md)). Only call the API after
explicit approval — "send it", "post it", "looks good", "yep".

If the diff is trivial (typofix, config, dependency bump) with zero findings, say
so and ask whether to post an `APPROVE` or skip the review entirely.
