# Code Review — Reference

## GitHub API

### Fetching PR metadata

```bash
gh pr view <number> --repo <owner>/<repo> --json title,headRefOid,baseRefOid,body,files,number
```

### Fetching the diff

```bash
gh pr diff <number> --repo <owner>/<repo>
```

### Fetching existing reviews and comments

```bash
# All reviews with their inline comments
gh api repos/<owner>/<repo>/pulls/<number>/reviews

# All review comments (including threads and replies)
gh api repos/<owner>/<repo>/pulls/<number>/comments

# General issue comments on the PR
gh pr view <number> --repo <owner>/<repo> --json comments
```

Read every existing comment before reviewing. Skip any finding already raised.
If the author replied with rationale ("intentional because X", "will fix in
follow-up"), respect it — do not re-flag.

### Posting a review

```bash
gh api repos/<owner>/<repo>/pulls/<number>/reviews \
  --method POST \
  --input /tmp/review-payload.json
```

Payload:

```json
{
  "commit_id": "<headRefOid from PR metadata>",
  "event": "APPROVE",
  "body": "Nice, clean change — cron expression is right and the fallback's sensible. Approved 🚀"
}
```

```json
{
  "commit_id": "<headRefOid>",
  "event": "COMMENT",
  "body": "Nice approach on the multi-code resolver, makes sense. A few things from me — push back on anything that doesn't align.",
  "comments": [
    {
      "path": "src/labour/resolver.ts",
      "line": 142,
      "side": "RIGHT",
      "body": "this'll pass `[null]` if the join produces nulls. `.filter(Boolean)` before the map should sort it."
    }
  ]
}
```

- `event`: `"APPROVE"` for clean PRs, `"COMMENT"` for anything with findings. Never use `"REQUEST_CHANGES"`.
- `line`: the line number in the file (not the diff position). Use the line from the `files` JSON or extract from the diff hunk header.
- `side`: `"RIGHT"` for added/changed lines (the default for PR comments).

### Computing line numbers from the diff

A unified diff hunk header looks like `@@ -old_start,old_count +new_start,new_count @@`.
`new_start` is the first line number on the RIGHT side. Lines prefixed with `+` or
space (context) increment the RIGHT-side counter. Lines prefixed with `-` do not.

When the `gh pr view --json files` output is available, use `additions` and
`deletions` counts per file to locate the hunk.

Simpler approach: pipe the diff through `diff-loc` or parse it manually — the
GitHub Review API needs the **file line number**, not the diff position.

### Short-form resolution

| Input | Resolution |
|-------|-----------|
| `brushfeed#4` | Try `hassan/brushfeed`, then `acme-corp/brushfeed` |
| `api#425` | Try `hassan/api`, then `acme-corp/api`, then current-dir repo |
| `#12` | Current working directory's repo |
| Full URL | Parse directly |
| (nothing) | Current branch diff against `main` |

Use `gh pr view <number> --repo <owner>/<repo> --json number` to test if the PR
exists before fetching the full payload. A non-zero exit means try the next
candidate.

## Confirmation format

Present findings to Hassan like this before posting:

```
Ready to post:

**APPROVE** on acme-corp/api#425 — "Add retry backoff to the sync worker"

Review body:
> Nice approach on the multi-code resolver, makes sense. Approved 🚀

Post this? Or tweak?
```

```
Ready to post:

**COMMENT** on acme-corp/api#425 — "Add retry backoff to the sync worker"

Review body:
> Nice approach on the multi-code resolver, makes sense. A few things from me — push back on anything that doesn't align.

Inline comments:
> src/labour/resolver.ts:142 — this'll pass `[null]` if the join produces nulls. `.filter(Boolean)` before the map should sort it.
>
> src/labour/resolver.ts:156 — `any` return type. Think this is `LabourResult | null`.
>
> src/labour/types.ts:18 — comment says "labor", we're British English in here.
>
> tests/labour.test.ts:89 — worth adding a null-in-array case here, that's the bug you're about to hit.

Post this? Or tweak?
```

Wait for explicit approval: "send it", "post it", "looks good", "yep", etc.

## Tone examples

### Review body — approved

> Nice, clean change — cron expression is right and the fallback's sensible. Approved 🚀

> Great work on getting these new UI changes in, tested it on my local and it looks superb. Noice — approved 🚀

> Well done 👏 approved 🚀

### Review body — comments

> Nice approach on the multi-code resolver, makes sense. A few things from me — push back on anything that doesn't align.

> Nice work on the tab layout and grouping logic. Few things from me — the render loop and silent error swallow are the ones to look at first. Push back on anything.

> Nice work so far, I like how you handled the pagination and the error boundary. Just a few things from me — feel free to push back on anything that doesn't align.

### Inline comments — blocking

No severity tag. Just say what's wrong and how to fix it.

> this'll pass `[null]` if the join produces nulls. `.filter(Boolean)` before the map should sort it.

> O(n) filter on every render. `useMemo` on `[parts, selectedGroup]` should sort it.

> `fetchKitParts()` in the component body, not a `useEffect`. This'll re-fire every render and loop once state updates downstream.

> silent `catch (e) {}` — the tab'll render empty with no clue why. At least log it.

> no guard on `selectedGroup` being `undefined`. That first call'll hit the server with a broken payload. Block until selection.

### Inline comments — nits

Same tone, just lighter issues.

> `any` return type. Think this is `LabourResult | null`.

> comment says "labor", we're British English in here.

> `z-index: 9999` loses to the modal's 1000. The `--z-dropdown` token should sort it.

> worth adding a null-in-array case here, that's the bug you're about to hit.

### Inline comments — praise

Sprinkle these in when you genuinely like something.

> 👌 clean pattern

> noice, this is exactly what I'd have done

> well done on this 👏

## Token setup

The skill uses `gh` CLI which requires GitHub authentication. Ensure:

```bash
gh auth status
```

The token needs `pull_requests:write` scope to post reviews. For `APPROVE`
events, the token also needs push access to the repo.

If `gh` is not authenticated or lacks scopes, tell Hassan and fall back to
printing the review as text output.
