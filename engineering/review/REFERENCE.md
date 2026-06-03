# Review — Reference

API and git commands. Voice rules are in [VOICE.md](VOICE.md).

## Local checkout (Mode B)

The goal is to review with a real working tree — so passes can grep call-sites
and run tests — **without disturbing Hassan's current branch or uncommitted
work**. Use a throwaway worktree, never `checkout`/`pull` on his live tree.

### 1. Locate the local clone

```bash
# Are we already inside the target repo?
gh repo view --json nameWithOwner -q .nameWithOwner   # compare to <owner>/<repo>

# Otherwise probe likely roots for a clone whose origin matches:
for d in ~/Repos/* ~/repos/* ~/dev/* ; do
  [ -d "$d/.git" ] && \
    git -C "$d" remote get-url origin 2>/dev/null | grep -qi "<owner>/<repo>" && echo "$d"
done
```

### 2. Add a worktree at the PR head

```bash
REPO=<local-clone-path>
WT=$(mktemp -d -t review-<repo>-<number>-XXXX)
git -C "$REPO" fetch origin <baseRefName> <headRefName>
git -C "$REPO" worktree add --detach "$WT" <headRefOid>
# review inside $WT; diff against the base:
git -C "$WT" diff origin/<baseRefName>...HEAD
```

### 3. No local clone → shallow temp clone

```bash
WT=$(mktemp -d -t review-<repo>-<number>-XXXX)
gh repo clone <owner>/<repo> "$WT" -- --depth 50
git -C "$WT" fetch origin <headRefName>
git -C "$WT" checkout <headRefOid>
```

### 4. Clean up after posting

```bash
git -C "$REPO" worktree remove --force "$WT"   # worktree case
rm -rf "$WT"                                    # temp-clone case
```

If both checkout paths fail, fall back to diff-only review (`gh pr diff` plus
GitHub file fetches) and tell Hassan context is reduced.

## GitHub API

### Fetching PR metadata

```bash
gh pr view <number> --repo <owner>/<repo> --json title,headRefOid,baseRefOid,body,files,number,headRefName,baseRefName
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

| Input         | Resolution                                                      |
| ------------- | --------------------------------------------------------------- |
| `brushfeed#4` | Try `hassan/brushfeed`, then `carpata-ltd/brushfeed`            |
| `api#425`     | Try `hassan/api`, then `carpata-ltd/api`, then current-dir repo |
| `#12`         | Current working directory's repo                                |
| Full URL      | Parse directly                                                  |
| (nothing)     | Current branch diff against `main`                              |

Use `gh pr view <number> --repo <owner>/<repo> --json number` to test if the PR
exists before fetching the full payload. A non-zero exit means try the next
candidate.

## Confirmation format

Present findings to Hassan like this before posting:

```
Ready to post:

**APPROVE** on carpata-ltd/api#425 — "Handle multi-nat-code UVCs in labour-times"

Review body:
> Nice approach on the multi-code resolver, makes sense. Approved 🚀

Post this? Or tweak?
```

```
Ready to post:

**COMMENT** on carpata-ltd/api#425 — "Handle multi-nat-code UVCs in labour-times"

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

Voice rules and the curated example set live in [VOICE.md](VOICE.md).

## Token setup

The skill uses `gh` CLI which requires GitHub authentication. Ensure:

```bash
gh auth status
```

The token needs `pull_requests:write` scope to post reviews. For `APPROVE`
events, the token also needs push access to the repo.

If `gh` is not authenticated or lacks scopes, tell Hassan and fall back to
printing the review as text output.
