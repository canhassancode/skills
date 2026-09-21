# The Slice

What `/cut` publishes: one ticket per slice, and the only thing a builder reads before starting — so it has to stand alone.

Everything here is **transcluded from the contract**, never summarised. Copying is safe; re-describing a settled interface in new words is how the ambiguity the alignment killed comes back. A slice that cannot be written this way is evidence the contract is short, and the fix is another `/align` pass.

## Title

One sentence, affirmative, specific, sentence case, no internal names.

| the work | not this | this |
| --- | --- | --- |
| a capability | "Add ratio validation to `Normaliser`" | "Carousels reject off-ratio images before upload" |
| a lifecycle bug | "Fix the retry in `createCarousel`" | "Failed publishes retry as one whole carousel" |
| a wide refactor | "Migrate callers to `asset_ratio`" | "Delete the old ratio column" |
| an ops slice | "Wire up the observability sink" | "Failed publishes surface in the channel" |

Nothing in a title names a module, a file or a layer. **Negative outcomes are fine, negative constructions are not**: "rejects off-ratio images" states a guard; "images never reach TikTok" states an absence, and reads slower. Where the deliverable *is* a removal, the imperative carries it honestly.

The test: read it aloud to someone who has never seen the project, and they can say what changes for the user.

## Body

```markdown
**Contract:** #42 · **Blocked by:** #51 · **Blocks:** #53 · **Container:** carousel-publish

## What to build

The end-to-end behaviour this slice delivers, from the user's perspective — and the first
sentence says what part of the parent's intention it serves, so a builder never wonders why
it exists. Not a layer-by-layer implementation list.

## Scenarios

| # | scenario | outcome |
| --- | --- | --- |
| 2 | a publisher posts a carousel where one image is 1:1 | rejected: `ratio_mismatch`, failing index reported |

## Acceptance criteria

- [ ] Posting four images with the third at 1:1 returns `ratio_mismatch`, names index 2, and uploads nothing

## Interfaces

The settled blocks this slice owns, and the ones it consumes — copied verbatim, in the
syntax the contract settled them in:

```ts
interface CarouselPost {
  platform: "tiktok";
  images: readonly ImageAsset[];
  caption?: string;
}
```

## Flow

The diagram the contract settled for the flow this slice changes, copied whole, with the
part this slice owns named — never by step number. Include it only when this slice changes a
flow; a slice that changes none omits the section, because the flow it rides on is not its own.

```mermaid
sequenceDiagram
    autonumber
    ...
```

## Decisions that bind it

Only the rows whose absence would let a builder re-decide a settled decision; the reason stays
one clause. Where the contract hit a real fork, the row is what stops the fork reopening.

| decision | chosen | rejected | because |
| --- | --- | --- | --- |
| carousel, not single image | carousel, up to 10 images, 3:4 enforced on construction | single-image endpoint | the publisher's team publishes carousels by hand today |

## Out of scope, and decided against

Each with its reason, because a bare exclusion invites the question back:

- **Video posting** — out of scope: the endpoint this uses accepts images only.
- **Scheduling posts** — decided against for now: deferred until the publish path has run in production.
```

**The header is the tracker's.** Reference the contract in the form that tracker's adapter uses — bare `#42` on GitHub, `CAR-###` on Linear — and use native blocking edges and container membership where the tracker has them, with the text line as the fallback. The four relationships to carry: the contract the slice was cut from, what blocks it, what it blocks, and the container it belongs to. Trackers render relationships natively, so they survive an edit and cost a builder nothing to read.

## What earns a place

- **Its scenarios** — the rows of the contract this slice makes hold. One of them has to be there: it is what makes the slice vertical, and a slice that cannot name one is a layer.
- **Its criteria** — each tracing to one of those scenarios. A criterion with no scenario behind it is scope nobody agreed: either it belongs in the contract, or it is not work.
- **Its interfaces** — the settled syntax for what it owns, and the names of what it consumes.
- **Its rejections** — the out-of-scope and decided-against entries that bear on it, with their reasons. This is what answers a review later, human or bot.

## What does not

- **A summary of the parent.** The parent's own body is the record; a slice carries the part of it that bears on this work, verbatim.
- **File paths and line numbers.** They go stale between the cut and the build. The exception is a snippet that encodes a decision more precisely than prose can — a state machine, a reducer, a schema, a type shape — inlined at the decision it belongs to and trimmed to the decision-rich part, never a working demo.
- **Anything decided at the cut.** If it is not in the contract, the cut does not get to invent it.
