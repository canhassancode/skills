# Issue tracker: Local Markdown

Issues for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- Specs live in the repo at `docs/specs/<capability>.md`, owned by `/align`; a ticket file holds its goal line and the spec's path
- Tickets are `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading
- A duplicate sets `Status: closed` and adds a `Duplicate of: <path>` line near the top, naming the survivor's file

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Publishing a cut

`/cut` publishes a parent spec's children. The semantics live in the skill; these are the operations.

- **Each child** — `.scratch/<feature-slug>/issues/NN-<slug>.md`, in build order, with `Status: needs-alignment` and a `Parent: <parent file>` line near the top.
- **Blocking edges** — a `Blocked by: NN, NN` line near the top of the child. A ticket is unblocked when every file it lists is `resolved`.
- **The parent** — drops its `Status:` line once every child exists; its checklist names each child file, and it stays open until the last one is `resolved`.
