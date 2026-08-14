# Issue tracker: Linear

Issues, specs, and their state live in **Linear**. Use this adapter when the repo declares `tracker: linear` (see the resolution note in the skills that reference it). All operations go through the **Linear MCP** (`linear-server` tools) — there is no CLI.

Linear is almost always a **shared team workspace**, not a personal tracker. The governing principle is **adopt-don't-impose**: map the canonical roles onto the taxonomy the team *already has*, and **never create labels, workflow states, or projects that don't already exist**. If a mapping below has no existing target, stop and ask the maintainer — do not manufacture taxonomy in a space you don't own. There is **no bootstrap step** on Linear (unlike GitHub).

## Operations (MCP tools)

- **Create an issue**: `save_issue` (title, description, team, labels, state). Descriptions take real markdown.
- **Read an issue**: `get_issue` for the body + metadata, `list_comments` for the discussion.
- **List / query issues**: `list_issues` with `team`, `state`, `label`, `assignee` filters. For "what's assigned to me", filter `assignee: "me"`, open states.
- **Comment**: `save_comment`.
- **Create / read a document**: use the Linear MCP's document tool — confirm the exact name against the live tool list before relying on it (`list_documents` / `get_document` for reads; the create/update tool is the `save_*`-family equivalent). A Document attaches to a **Project** or an **Initiative**, or sits at workspace level; place it in the location the calling skill confirmed, never a new one.
- **Edit description in place**: `save_issue` with the updated `description` field. Linear's activity feed captures the diff natively — do not repost the body as a comment. Accompanying comments carry only the delta and reasoning, never a re-paste of the full body. When the integration token lacks write scope on the description (guest or restricted-role member), `save_issue` will fail; surface this failure rather than silently falling back to a body-reposting comment.
- **Apply / remove a role**: `save_issue` with the updated `labels` set (roles are labels here — see mapping).
- **Move delivery state**: `save_issue` with `state` (the native workflow state).
- **Close as won't-fix**: `save_issue` with `state: Canceled` (the native state *is* won't-fix); duplicates → `state: Duplicate`. No label needed.
- **Resolve the workspace shape first**: on first use in a repo, call `list_teams`, `list_issue_statuses`, and `list_issue_labels` to confirm the current team taxonomy before mapping — don't assume the table below is still exact.

Infer the team from the workspace (single team → use it; otherwise ask).

## Role mapping (the work team — verify with `list_issue_labels` before trusting)

Canonical roles map onto the **existing** team taxonomy. Roles are carried as **labels** (they classify a personal AFK workflow and sit alongside the team's native delivery states); won't-fix is the exception — it's a native state.

| Canonical role | Linear target | Notes |
| --- | --- | --- |
| `needs-triage` (state) | label **`To triage`** | Adopt the team's label; the ported `needs-triage` label is a duplicate to retire |
| `needs-info` (state) | label **`needs-info`** | No team equivalent — keep |
| `ready-for-agent` (state) | label **`ready-for-agent`** | Personal AFK workflow — keep |
| `ready-for-human` (state) | label **`ready-for-human`** | Personal AFK workflow — keep |
| `wontfix` (state) | native state **`Canceled`** | Close by moving state, no label |
| `bug` (category) | label **`Bug`** | Adopt the team's; don't create a lowercase `bug` |
| `enhancement` (category) | label **`Feature`** | Adopt the team's; `Improvement` for minor changes. Ported `enhancement` is a duplicate to retire |
| `spec` (document) | native **Project** | See "Specs are Projects" below — a spec is a Project, not a label |
| `proposal` (document) | native **Document** | See "Proposals are Documents" below — a decision doc, not a labelled issue |

The native workflow states (`Backlog` → `Todo` → `In Progress` → `In Review` → `Done`) are the team's **delivery** pipeline and are orthogonal to the triage-role labels. Don't overload them with triage vocabulary.

## Specs are Projects, not labelled issues

A spec is an epic-style parent document — on Linear that is a **native Project**, which is exactly how this team already organises work (rich-body Projects with child issues).

- **`/to-spec`** → `save_project` with the spec body as the Project description.
- **`/to-tickets`** → `save_issue` for each slice (ticket), assigned to the Project.
- **Parent / child** → native **sub-issues** (`save_issue` with a parent), not a `## Parent` text section.
- **Blocked by** → native **blocking relation**, not a `## Blocked by` text section.
- **References** → the `CAR-###` identifier (or the issue URL), not `#N`.

## Proposals are Documents, not labelled issues

A proposal (`/to-proposal`) is a decision document for a decision-maker, not a delivery item — on Linear that is a native **Document**, placed in the location the user confirms.

- **`/to-proposal`** → create a Document with the proposal body, attached to the agreed **Initiative** or **Project**. Where the agreed home is a single-decision request rather than a document, publish it instead as an issue labelled `ready-for-human`.
- **Placement is adopt-don't-impose** — attach to an existing Initiative / Project; never create one to hold the proposal. If no home exists, ask.
- **The ask stays outstanding on the Document itself** — no separate log. Advance the body's status line (`draft` → `shared` → `decided`) as the decision lands.

## Disclaimer

The AI disclaimer defaults to **ON** for Linear (shared team space where AI authorship signal has value for teammates). Every triage comment and issue body starts with `> *This was generated by AI during triage.*` unless the repo has set `triage-disclaimer: off` via `bootstrap`.

## What does *not* apply on Linear

- **No `## Status` block** in the body. Linear surfaces state, hierarchy, and activity natively; the block is redundant GitHub-era maintenance. When a triaged issue's description changes, edit it in place with `save_issue` (see Operations above) — description edits are native, not comment-driven.
- **No label/state/Project bootstrap.** Detect and map; never create in a shared workspace without explicit maintainer sign-off.
- **AFK caveat.** A `ready-for-agent` issue is only grabbable if the Linear MCP is authenticated in the headless AFK runtime. The natural split: the agent *reads* the brief from Linear (MCP), *ships code* via a GitHub PR (`gh`), and a human closes the Linear issue. Verify MCP reachability before relying on `ready-for-agent` against Linear.

## When a skill says "publish to the issue tracker"

Create a Linear issue with `save_issue` (or a Project with `save_project` for a spec).

## When a skill says "fetch the relevant ticket"

`get_issue` for the body, `list_comments` for the discussion.
