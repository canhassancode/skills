# The specification

One structured document, published as a comment on the ticket. The tracker item is the source of truth — **not its body**: the body stays the prose a human wrote, and the specification is a separate, append-only, structured comment.

## Publication format

A published specification is one comment: a `## gauntlet-spec` heading, then a single fenced `json` block. The heading is what makes it legible to a human scanning the ticket and what the fetcher anchors on.

````md
## gauntlet-spec

```json
{ … }
```
````

**Append, never edit.** Re-specifying is posting another comment; the newest `gauntlet-spec` block on the ticket wins and the earlier ones stay readable as history.

## Schema

```json
{
  "origin":  { "tracker": "github", "kind": "ticket", "ref": "42",
               "url": "https://github.com/…/issues/42" },
  "title":   "Order lookup returns 404 for a missing order",

  "contract": {
    "sourcePaths": ["src"],
    "carry":       ["local.settings", "secrets.d/"],
    "build":       "pnpm type-check",
    "setup":       "pnpm test:db:up",
    "teardown":    "pnpm test:db:down",
    "acceptance":  { "run": "mkdir -p .gauntlet && pnpm test:integration",
                     "output": ".gauntlet/report.json",
                     "pattern": "**/*.spec.ts" },
    "coverage":    { "run": "pnpm test:coverage",
                     "output": "coverage/coverage-final.json" },
    "serve":       { "run": "pnpm dev", "url": "http://127.0.0.1:4321",
                     "ready": ["/health"], "startup": 1015 }
  },

  "criteria": [
    { "id": "42/behaviour-1", "class": "behaviour",
      "text": "Given no order with id 9, when GET /orders/9, then the status is 404",
      "edge": { "address": "GET /orders/:id",
                "witness": { "file": "tests/orders.spec.ts",
                             "name": "GET /orders/1 returns the order" } } },

    { "id": "42/invariant-1", "class": "invariant",
      "text": "Given order 1 exists, when GET /orders/1, then the status is 200",
      "binds": { "file": "tests/orders.spec.ts",
                 "name": "GET /orders/1 returns the order" } }
  ],

  "procedures": [
    { "id": "procedure-1",
      "at": "http://127.0.0.1:4321/orders/9",
      "do": "Open the page in a browser and read it.",
      "expect": "The page shows 'Order not found'. No error banner appears." }
  ],

  "retired": []
}
```

## `origin`

| field | meaning |
| --- | --- |
| `tracker` | whichever `/bootstrap` configured for this repo |
| `kind` | `ticket` or `review-comment` |
| `ref` | the ticket — the publication address, and the prefix on every criterion id |
| `thread` | the review comment's id. Present only on `review-comment`; it is what routes `ship` to reply in-thread rather than top-level |
| `url` | the human link to whichever of the two the session started from |

On a `review-comment` origin whose pull request came from no ticket, `ref` is the pull request number. GitHub shares one number space across issues and pull requests, so the prefix stays unambiguous.

## `contract`

One command per surviving guard, each derived from the repo and each **executed green in a throwaway worktree during the session** that publishes it.

| field | source |
| --- | --- |
| `sourcePaths` | the tree |
| `carry` | the main clone's ignored inventory, filtered by the operator to preconditions and falsified by the proof run |
| `build`, `setup`, `teardown`, `acceptance.run` | `package.json` scripts, or the stack's equivalent |
| `acceptance.output` | wherever the runner is told to write its JSON report |
| `acceptance.pattern` | the glob that says what a test file is — it also bounds which paths the examiner may delete |
| `coverage.run` | the instrumented suite — a `package.json` script, or the acceptance runner with its coverage flag |
| `coverage.output` | wherever that run writes its JSON report |
| `serve.run`, `serve.url`, `serve.ready` | the dev-server script and its config |
| `serve.startup` | measured during the proof run, in milliseconds |

`carry` is **paths only, never contents** — the specification is published as a tracker comment, so a field holding file bodies would leak every secret in the repo into a public thread. Preflight resolves each path against the main clone and copies it into the run's worktree before `install`; a declared path the clone does not have is a red preflight. An empty list is legal.

`coverage` is **optional**, and `crap` is its only consumer. A repo that declares none runs fine — the guard reports that it could not run, and the run continues. It is a separate command, never `acceptance.run` with the flag added to it — the same runner is fine, but the acceptance suite runs at every gate, and instrumenting that one would tax all four chains for a guard that runs on one. The re-run is priced at the `code` gate alone.

There is no `ceiling` key and no `format` key. The ceiling is harness-owned, like `depth`'s, and the format is discriminated from the report itself — istanbul or coverage-py.

There is no `examples` field. A criterion carries its values in its own prose, so a second array would only duplicate them.

## `criteria`

| field | `behaviour` | `invariant` |
| --- | --- | --- |
| `id` | `<ref>/behaviour-N` | `<ref>/invariant-N` |
| `text` | the criterion in prose, carrying its own values | the same |
| `edge.address` | required — the address it asserts through | — |
| `edge.witness` | `{file, name}` of a test that already passes, or `null` | — |
| `binds` | — | required `{file, name}` of a test that already passes |

**A behaviour's witness may be `null`; an invariant's `binds` may not.** The two pointers carry different obligations. An invariant is green-only, so the test it binds is its entire ruler — without one it asserts nothing at all. A behaviour is red-then-green and is ruled by its own test's status; its witness is an **exemplar**, the passing test the examiner reads to find the convention at that edge. Where the seam does not exist yet — a new endpoint, a new export — no such test can exist, and a witness requirement would bar every new capability from the gauntlet.

The key is still required. `"witness": null` is the declaration *this is a new seam*; an absent `witness` is a field left out, and `admit` rejects it.

## Criterion ids

`<ref>/<class>-N` — the id sits **inline in the test name**, and the prose around it is decorative:

```ts
describe('GET /orders/:id', () => {
  test('returns the order', …)
  test('returns 404 when order 9 is absent [42/behaviour-1]', …)
})
```

The guard matches `\b42/behaviour-1\b`. Mistype it and the gate goes red with *0 tests named 42/behaviour-1* — the load-bearing string is short, and any long string is decorative.

**N is a high-water mark, not a per-specification count.** The second specification on ticket #42 continues from where the first stopped, so its ids read `42/behaviour-2` and the tests run 1 committed keep theirs. Resolve the mark as the **maximum of two sources**, both already in hand:

1. the baseline report, token-scanned for `\b<ref>/<class>-\d+\b`;
2. the earlier `gauntlet-spec` blocks on the ticket, which catches a specification that was published but whose run never committed tests.

Numbering need not be contiguous — a specification carrying only `42/behaviour-2` is graded correctly, because the guard iterates the specification's own criteria and never assumes a starting point.

An id that a run committed is **provenance, not a role label**. A later specification preserving `[42/behaviour-1]` binds an invariant to that exact name, brackets included, and never renames it.

## `retired`

Grouped by file, expanded by `/specifier` from the report it just ran:

```json
"retired": [
  { "file": "src/libs/component-resolver/engine.test.ts",
    "names": ["resolves a Toyota front brake disc", "throws on an unknown OE code"] }
]
```

Grouping by file is what keeps the list inside the tracker's comment limit — the path is the expensive part, and repeating it per test roughly doubles the bytes.
