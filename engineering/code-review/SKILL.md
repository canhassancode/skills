---
name: code-review
description: >
  Review a GitHub pull request and post inline review comments in Hassan's voice
  (warm, casual, collaborative, terse). Accepts full URLs, short forms like
  brushfeed#4, or reviews the current branch diff against main. Use when the user
  asks to review a PR, check a pull request, do a code review, or mentions
  /review with a PR reference.
---

# Code Review

Reviews a pull request and posts findings as a grouped GitHub review with
inline comments — same as "Start a review" on the GitHub UI. Always confirms
with Hassan before posting.

## Quick start

```
/review brushfeed#4
/review https://github.com/acme-corp/api/pull/425
/review                   → reviews current branch diff against main
```

## Input resolution

Resolve the PR target in this order:

1. Full GitHub PR URL → extract owner, repo, number.
2. Short form `repo#N` →
   - Try `gh pr view N --repo hassan/repo` first.
   - Then try `gh pr view N --repo acme-corp/repo`.
   - Then try `gh pr view N --repo` with the current working-directory repo.
3. Bare `#N` in a repo working directory → current repo's PR N.
4. No argument → review `git diff main...HEAD` (or `master...HEAD`).

Use `gh pr view <number> --repo <owner>/<repo> --json title,headRefOid,baseRefOid,body,files` to
fetch metadata, and `gh pr diff <number> --repo <owner>/<repo>` for the diff.

## Review workflow

1. **Gather context.** Before reviewing a single line, collect everything the
   reviewers will need (exact commands in [REFERENCE.md](REFERENCE.md)):

   - **PR description** — what the author intended. Read linked issues too.
   - **PR diff** — the full unified diff.
   - **Existing review threads** — every review comment and author reply. Never
     repeat a point already made. If the author replied "this is intentional
     because X" or "will fix in follow-up", respect it.
   - **Domain docs** — `CLAUDE.md`, `AGENTS.md`, `CONTEXT.md` from the repo root
     (fetch from GitHub if not on disk).
   - **Surrounding file context** — read enough of each changed file to understand
     the change in context. Reviewers need more than the ±3 lines the diff shows.

2. **Review from independent perspectives.** Launch two review passes with distinct
   angles. Each pass receives the full context bundle from step 1. Use whatever
   delegation mechanism is available — parallel subagents, sequential passes, or a
   single combined pass for diffs under ~50 lines.

   | Angle | Focus |
   |-------|-------|
   | **Correctness & security** | Logic bugs, edge cases, race conditions, null handling, injection, auth gaps, error swallowing, does the code achieve what the PR description says it should |
   | **Patterns & maintainability** | TypeScript conventions, alignment with CLAUDE.md/AGENTS.md, codebase consistency, naming, obvious nits, British English |

   Reviewers do not edit code. Each finding includes: file path, line number, and a
   Hassan-voiced comment ready to post as-is.

3. **Synthesise.** Deduplicate overlapping findings. Drop anything contradicted by an
   author reply. Decide the verdict:
   - **No blocking issues** → APPROVE.
   - **Blocking issues present** → COMMENT (never REQUEST_CHANGES).

4. **Confirm with Hassan.** Present the review body and all inline comments. Hassan may
   tweak wording, drop findings, or change the verdict. Do not post until he says so.
   See [REFERENCE.md](REFERENCE.md) for confirmation format.

5. **Post.** Use the GitHub Reviews API:
   ```bash
   gh api repos/<owner>/<repo>/pulls/<number>/reviews \
     --method POST \
     --input /tmp/review-payload.json
   ```
   Payload shape and line-number computation are in [REFERENCE.md](REFERENCE.md).

## Tone

Write inline comments the way Hassan writes them — not a robot, not a report.

- **Warm and casual.** "Nice work on x" opens the review body. Comments read like a
  colleague pointing at a line, not a checklist item.
- **Terse, no fluff.** No "I suggest", no "you might consider", no severity tags.
  The severity is implied by the review event (APPROVE vs COMMENT) and what the
  comment actually says.
- **British English.**
- **Compliments freely.** "Noice", "well done 👏", "👌 on this", "clean" — use them
  when you mean them.
- **Collaborative on changes.** "Push back on anything that doesn't align." Let the
  author decide.

Full examples in [REFERENCE.md](REFERENCE.md).

## Confirmation gate

Never post without confirmation. Present the verdict, review body, and every
inline comment. Hassan may change anything — wording, verdict, which findings to
post or drop. Only call the API after explicit approval ("send it", "post it",
"looks good", etc.).

If there are zero findings and the diff is trivial (typofix, config change,
dependency bump), say so explicitly and ask whether to still post an APPROVE or
skip the review.
