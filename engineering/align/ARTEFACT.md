# The Alignment Artefact

The file `/align` maintains on the pass's branch. It is the **residue of the conversation, not its transcript** — what survived the pass, not what was said in it.

One file, revised in place across passes. Keep the headings stable and let their contents sharpen. Plain text throughout, so it diffs between passes, renders wherever the ticket lives, and reads without vision.

The ticket's **comments** hold the decisions that produced each revision. This file holds the current truth.

## Header

```markdown
**Pass:** 3 · **Verdict:** fog · **Ticket:** #42 · **Verified against:** `abc1234`
```

The commit is load-bearing: it is how a later pass knows which facts have expired.

## What we are trying to do

One paragraph, no jargon.

This section gets read first, and it is the one that exposes a pass that never landed. If it cannot be said simply, the pass is not finished — say so in the verdict rather than padding it.

## Scenarios

The named walks the work has to handle, each with its outcome.

| # | scenario | outcome |
| --- | --- | --- |
| 1 | a publisher posts a carousel of four images | published |
| 2 | a publisher posts a carousel where one image is 1:1 | rejected: `ratio_mismatch`, failing index reported |
| 3 | a publisher posts a carousel of 12 images | *unresolved* |

A scenario with no outcome is unresolved by definition, and it is what the gate counts. "Not applicable" is not an outcome; if the scenario does not apply, delete it.

## Interfaces

Everything another part of the system talks to — any surface with a callable shape, not only a type. These are the layers the design spans, and several kinds turn up in one session:

| kind | the shape being decided |
| --- | --- |
| code type | a type, function, class or module signature |
| REST endpoint | method, path, request and response body, status codes |
| event | topic, payload, ordering, delivery guarantee |
| CLI or config | flag, argument, env var, accepted values |
| data | schema, migration, index, retention |

Decided interfaces are written as real, checkable syntax. Undecided ones are a sketch, in whatever notation the operator reached for, with the open part marked.

**Settled** — the fence names the syntax, and it is the shape the work will be built against:

```ts
interface CarouselPost {
  platform: "tiktok";
  images: readonly ImageAsset[];
  caption?: string;
}
```

```http
POST /channels/{channelId}/carousels
Content-Type: application/json

{ "images": [{ "url": "https://…" }], "caption": "" }

201 → { "id": "…", "state": "published" }
422 → { "error": "ratio_mismatch", "index": 2 }
```

**Sketch** — the fence says `text`, and it is a conversation prop rather than a document. Placeholders are visible, because a placeholder handed to an agent becomes an invention:

```text
normalise(assets, targetRatio) -> ok | rejected(why)
```

Promoting a sketch to settled **is** the moment the decision lands. Until then it belongs in the sketch block, with the open question named under Unresolved.

## Modules

Not a diagram. Depth is the property being judged — a small interface over a lot of hidden implementation — and a table makes it countable where a drawing flatters it.

| module | public interface | what it hides | callers |
| --- | --- | --- | --- |
| `Normaliser` | `normalise(assets, ratio)` | per-platform rules, resize, EXIF rotation, decode failures | `PostCarousel` |
| `TikTokClient` | `createCarousel(assets, caption)` | auth, chunked upload, retry and backoff, rate limits | `PostCarousel` |

## Flow and lifecycle

Sequence diagrams for flow, state diagrams for lifecycle, both with `autonumber`. Conventions — including participant declaration — are in [DIAGRAMS.md](./DIAGRAMS.md).

Only the flows this work actually changes, so the diagram stays readable. A diagram of the whole system is a diagram nobody reads.

## Decisions

One block per decision. The rejected alternatives are not optional: a decision recorded without them cannot be revisited, and revisiting is what a later pass is for.

```markdown
### Carousel, not single image

**Chosen:** carousel, up to 10 images, 3:4 enforced on construction.
**Because:** the publisher's team already publishes carousels by hand, so a single-image endpoint would force a second piece of work.
**Rejected:** single-image only — would not remove the manual process it exists to remove.
**Rejected:** 1:1 ratio — the platform crops to 3:4 anyway, so enforcing 1:1 moves the crop somewhere less visible.
```

## Participants

Every participant in every diagram, with the DDD role it plays and whether the repo's `CONTEXT.md` knows the term. A participant that cannot be classified is a finding, not a naming problem — it means two of the roles below are being served by one thing, or a concept has not been decided yet.

| participant | DDD role | in `CONTEXT.md`? |
| --- | --- | --- |
| `Publisher` | actor (human) | yes |
| `PostCarousel` | application service | yes |
| `Carousel` | aggregate | yes |
| `TikTokAPI` | anticorruption layer | no — to add |

## Axes

One mark per axis, every pass. The note is what makes a mark trustworthy later.

| axis | mark | note |
| --- | --- | --- |
| happy path | decision | see Scenarios 1–2 |
| limits | decision | 10 images maximum, enforced on construction |
| failure | decision | per-image rejection with the index reported |
| misuse | N/A | publishing is behind an authenticated session |
| concurrency | N/A | one carousel per publish; no shared state |
| permissions | decision | publisher's own channel only |
| data volume | N/A | at most 10 images |
| observability | unresolved | is a failed publish visible to the publisher after the fact? |
| migration | N/A | no stored data changes shape |
| rollback | unresolved | per-image, or the whole carousel? |
| cost | decision | platform charges per published post, not per attempt |
| timezone | N/A | no scheduling |

An empty N/A column means the axes were never asked. That is a thin pass, and it is the one failure a reviewer can spot at a glance.

## Out of scope

Written with its reason, always. This list is what stops a reviewer, an agent or a colleague re-opening a decision already taken.

```markdown
- **Video posting** — a separate slice. The endpoint this uses accepts images only.
- **Scheduling posts** — deferred until the publish path has run in production for a fortnight.
```

## Unresolved

The list that counts to zero. Every item carries **what would resolve it** — a route, not a wish. An item without a route is a shrug, and a pass carrying one is thin rather than foggy.

```markdown
- **Do carousel creations share the account-level rate limit with single posts?**
  → resolve by reading the platform's content-posting limits page, then posting twice in the sandbox.
- **Does a partially uploaded carousel leave anything on the platform side?**
  → resolve by cancelling mid-upload and listing the account's drafts.
```

## What does not belong here

- **The transcript.** The conversation is the conversation; this file is its residue.
- **Restated facts that live in code or a vendored doc.** Link them, or state the fact once with its source.
- **Speculative work.** Anything nobody decided goes under Unresolved with a route, or stays out.
