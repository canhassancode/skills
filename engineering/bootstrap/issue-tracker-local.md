# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading
- A duplicate sets `Status: closed` and adds a `Duplicate of: <path>` line near the top, naming the survivor's file

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Publishing a cut

`/cut` transcribes a settled alignment into slices. The semantics live in the skill; these are the operations.

- **One slice** — the alignment file graduates in place: swap its `Status: ready-to-cut` line for `Status: ready-to-build`. Its body already carries the contract; nothing is rewritten.
- **Several slices** — write `.scratch/<feature-slug>/spec.md` from the spec body: the map, with no status. Write each slice as `.scratch/<feature-slug>/issues/NN-<slug>.md` with the slice body, `Status: ready-to-build`, and its top link row pointing at `spec.md`.
- **Blocking edges** — a `Blocked by: NN, NN` line near the top of the slice. A ticket is unblocked when every file it lists is `resolved`.
- **Close the alignment ticket** — set its `Status:` to `closed` and append a `## Cut` note naming the slice files, once every slice exists.
