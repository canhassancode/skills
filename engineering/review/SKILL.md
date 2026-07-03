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
  voice, **reconcile with any review Hassan already has in flight, confirm, then
  post**. If Hassan already has a pending review on the PR, the skill **merges**
  its comments into that pending review and submits it as one combined review;
  otherwise it posts a fresh grouped review.

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
3. **Gather context.** PR description and linked issues; **existing published
   review threads** (never repeat a point already made — if the author replied
   "this is intentional because X" or "fixing in follow-up", respect it);
   `CLAUDE.md` / `AGENTS.md` / `CONTEXT.md`; the changed files in full via the
   worktree. Also detect **Hassan's own pending review**: check for a `PENDING`
   review by Hassan on this PR and read its draft inline comments and body
   (commands in [REFERENCE.md](REFERENCE.md)). This decides the posting path
   (merge vs fresh) and is one more thing to dedupe against — never re-flag a
   point Hassan has already drafted.
4. **Review** (see "Review passes" below). In the worktree you can run tests and
   grep — use that.
5. **Draft & decide — independently.** Draft the review body + inline comments in
   Hassan's voice ([VOICE.md](VOICE.md)) and form the skill's **own** verdict from
   the skill's findings alone. Hassan's pending draft comments do **not** feed
   this decision — the skill reaches its conclusion blind to them, so the two can
   be compared honestly.
6. **Reconcile & confirm.** Present, side by side: the skill's verdict + its new
   inline comments, and Hassan's existing pending comments (plus any pending
   body). **Call out contradictions explicitly** (e.g. the skill found a blocker
   on a line Hassan was about to approve). Then **agree the final event and body
   together** — Hassan may reword, drop findings, override the verdict, or keep
   his own line. Never submit or post without explicit approval.
7. **Post.**
   - **Pending review exists** → **merge**: append each agreed new comment to
     Hassan's pending review, then **submit that review** with the agreed event +
     body. One combined review (his drafts + the skill's) goes out.
   - **No pending review** → post a fresh grouped review via the Reviews API.
   Then **clean up** the worktree / temp clone. Merge/submit commands are in
   [REFERENCE.md](REFERENCE.md).

## Review passes

Run two passes with distinct angles, each over the full context bundle. Use
parallel subagents when available, sequential passes otherwise, or a single
combined pass for diffs under ~50 lines.

| Angle                          | Focus                                                                                                                                                       |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Correctness & security**     | Logic bugs, edge cases, race conditions, null handling, injection, auth gaps, error swallowing — and does the code actually do what the PR description says |
| **Patterns & maintainability** | TypeScript conventions, alignment with CLAUDE.md/AGENTS.md, codebase consistency, naming, obvious nits, British English                                     |

Passes do not edit code. Each finding carries: file path, line number, and a
ready-to-post comment in Hassan's voice. Then **synthesise**: deduplicate across
passes, drop anything an author reply — or one of Hassan's own pending draft
comments — already settled, and decide the skill's **independent** verdict.
Hassan's pending comments don't sway this verdict; reconciling the two is the
confirmation gate's job, not the synthesis step's:

- **No blocking issues** → `APPROVE`.
- **Anything worth flagging** → `COMMENT`. Never `REQUEST_CHANGES`.

## Reconciliation & confirmation gate (Mode B only)

Never post or submit without confirmation. Present (format in
[REFERENCE.md](REFERENCE.md)):

- the skill's **independent verdict** and its new inline comments;
- if Hassan has a pending review, **his existing draft comments and body**, shown
  separately so it's clear what's already his;
- **any contradiction** between the two, stated plainly — don't quietly resolve
  it. The skill's verdict and Hassan's in-flight stance can disagree; surface it
  and let Hassan settle the final event.

Then agree the final event and body **together**. Only call the API after
explicit approval — "send it", "post it", "looks good", "yep". On a merge, that
single approval both appends the agreed comments to Hassan's pending review and
submits it.

If the diff is trivial (typofix, config, dependency bump) with zero findings, say
so and ask whether to post an `APPROVE` (or, with a pending review, just submit
his as-is) or skip the review entirely.

## Log the review (if `~/Obsidian/` exists)

Mandatory closing step, not optional: append one line to today's daily log via the
`/log` convention — what was reviewed, the verdict, and the most significant
finding or decision. Skip silently if the vault is absent.
