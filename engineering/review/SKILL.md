---
name: review
description: >
  Review a named GitHub PR in Hassan's voice — check the branch out locally, run
  the analysis through /code-review, draft inline comments, confirm, then post.
  Accepts full URLs or short forms like brushfeed#4. Use when the user asks to
  review a PR, check a pull request, or mentions /review with a PR reference.
disable-model-invocation: true
---

Reviews a **named GitHub PR** with real local context and writes the findings in
Hassan's voice: check the PR branch out locally, run the analysis through
`/code-review`, draft inline comments, **reconcile with any review Hassan already
has in flight, confirm, then post**. If Hassan already has a pending review on the
PR, the skill **merges** its comments into that pending review and submits it as
one combined review; otherwise it posts a fresh grouped review.

This skill is the **voice and posting layer**. The analysis is not done here —
`/code-review` owns it, and this skill invokes it.

Voice rules live in [VOICE.md](VOICE.md) — load it before writing any comment.
API and git commands live in [REFERENCE.md](REFERENCE.md).

## Quick start

```
/review brushfeed#4       → review the PR, draft + confirm + post
/review https://github.com/acme-corp/api/pull/425
```

## Input resolution

1. **Full GitHub PR URL** → extract owner, repo, number.
2. **Short form `repo#N`** → resolve the owner:
   - Try `gh pr view N --repo hassan/repo` first.
   - Then `gh pr view N --repo acme-corp/repo`.
   - Then the current working-directory repo.
3. **Bare `#N`** in a repo working directory → the current repo.
4. **No argument** → there is nothing to review here. **`/review` no longer
   self-reviews the current branch** — that is `/code-review` against a fixed
   point (`/code-review main`). Say so and stop.

Resolution table and existence checks are in [REFERENCE.md](REFERENCE.md).

## When NOT to use this skill

For heavyweight, high-stakes, or deep multi-agent review (money flows, auth,
production migrations, large diffs), defer to `/review ultra` — the cloud
pipeline — rather than duplicating it here. This skill is the fast local layer
and the voice/posting layer; it is not a replacement for the cloud pipeline.

## Procedure

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
   "this is intentional because X" or "fixing in follow-up", respect it). Also
   detect **Hassan's own pending review**: check for a `PENDING` review by Hassan
   on this PR and read its draft inline comments and body (commands in
   [REFERENCE.md](REFERENCE.md)). This decides the posting path (merge vs fresh)
   and is one more thing to dedupe against — never re-flag a point Hassan has
   already drafted.
4. **Analyse — invoke `/code-review`** against the PR's base ref as the fixed
   point, from inside the worktree. It runs the Standards, Spec and Structure
   axes in parallel and hands back its findings. Do not re-derive them here.
5. **Draft & decide — independently.** Turn `/code-review`'s findings into a
   review body + inline comments in Hassan's voice ([VOICE.md](VOICE.md)), each
   carrying a file path and line number, and form the skill's **own** verdict from
   those findings alone. Hassan's pending draft comments do **not** feed this
   decision — the skill reaches its conclusion blind to them, so the two can be
   compared honestly.
   - **No blocking issues** → `APPROVE`.
   - **Anything worth flagging** → `COMMENT`. Never `REQUEST_CHANGES`.
6. **Reconcile & confirm.** Present, side by side: the skill's verdict + its new
   inline comments, and Hassan's existing pending comments (plus any pending
   body). **Call out contradictions explicitly** (e.g. a blocker was found on a
   line Hassan was about to approve). Then **agree the final event and body
   together** — Hassan may reword, drop findings, override the verdict, or keep
   his own line. Never submit or post without explicit approval.
7. **Post.**
   - **Pending review exists** → **merge**: append each agreed new comment to
     Hassan's pending review, then **submit that review** with the agreed event +
     body. One combined review (his drafts + the skill's) goes out.
   - **No pending review** → post a fresh grouped review via the Reviews API.
   Then **clean up** the worktree / temp clone. Merge/submit commands are in
   [REFERENCE.md](REFERENCE.md).

## Reconciliation & confirmation gate

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
