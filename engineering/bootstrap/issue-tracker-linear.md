# Issue tracker: Linear

Issues and specs for this repo live in **Linear**. All operations go through the **Linear MCP** (`linear-server` tools) — there is no CLI.

Linear is almost always a **shared team workspace**. The governing principle is **adopt-don't-impose**: map onto the taxonomy the team already has, and **never create labels, workflow states, or Projects that don't already exist**. On first use, call `list_teams`, `list_issue_statuses`, and `list_issue_labels` to read the current taxonomy before writing. The richer triage-lane conventions (role→label mapping, AI disclaimer, what doesn't apply on Linear) live in `~/.claude/skills/triage/issue-tracker-linear.md`; this file covers what the **planning-lane** skills (`to-spec`, `to-tickets`, `wayfinder`, `code-review`) need.

## Conventions

- **Publish a spec** (`/to-spec`): `save_project` with the spec body as the Project description. A spec is a **Project**, not a labelled issue — Projects are the team's native epic mechanism.
- **Publish tickets** (`/to-tickets`): `save_issue` per ticket, assigned to the spec's Project. Parent/child via native **sub-issues** (`save_issue` with a parent), never a `## Parent` text section. Blocking edges via Linear's native **blocking relation**, never a `## Blocked by` text section.
- **Read an issue**: `get_issue` for the body, `list_comments` for the discussion.
- **Reference** issues by their `CAR-###` identifier (or URL), not `#N`.
- **Agent-grabbable state**: apply the `ready-for-agent` label (a kept personal-workflow label — see the triage adapter's role mapping). Won't-do → native `Canceled` state.
- No `## Status` block — Linear surfaces state, hierarchy, and activity natively.

## Pull requests as a triage surface

N/A. Linear has no PR concept, and the planning lane doesn't triage — its tickets are `ready-for-agent` by construction.

## When a skill says "publish to the issue tracker"

`save_issue` (or `save_project` for a spec).

## When a skill says "fetch the relevant ticket"

`get_issue` for the body, `list_comments` for the discussion.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a **Linear Project**; its tickets are the Project's **issues**.

- **Map**: a Project whose description holds the Destination / Notes / Decisions-so-far / Not-yet-specified / Out-of-scope body. `save_project`. The Project *is* the map — don't create a `wayfinder:map` label. To keep maps visually separable from spec Projects, prefix the name, e.g. `Wayfinder: <destination>`.
- **Child ticket**: an **issue** in the map's Project (`save_issue` with the Project set), the question in the body under `## Question`. Record the ticket type on a `Type:` line at the top of the body — `research` / `prototype` / `grilling` / `task` — rather than a `wayfinder:<type>` label, so no new taxonomy is manufactured in the shared workspace.
- **Blocking**: Linear's native **blocking relation** between issues (the same mechanism `/to-tickets` uses) — it renders the frontier visually in Linear's own UI. If the integration token can't set relations, fall back to a `Blocked by: CAR-###` line at the top of the body. A ticket is **unblocked** when every blocker is `Done` or `Canceled`.
- **Frontier**: `list_issues` scoped to the map's Project, open states only, dropping any with an open blocker or an assignee; first in map order wins.
- **Claim**: `save_issue` assigning the ticket to the driving dev — the session's first write, before any work. An open, unassigned ticket is unclaimed.
- **Resolve**: `save_comment` with the answer, move the issue to `Done` (or `Canceled` if it turned out to sit past the destination), then append a context pointer (gist + `CAR-###` link) to the map Project's Decisions-so-far.

Confirm the exact MCP calls — especially setting blocking relations — against the live server before relying on them; run `list_teams` / `list_issue_statuses` / `list_issue_labels` first, per adopt-don't-impose.
