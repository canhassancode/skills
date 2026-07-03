---
status: accepted
---

# Dual-track issue-tracker adapters (GitHub default, Linear per-repo)

## Context

The issue skills (`triage`, `to-prd`, `to-issues`, `pickup`, `morning-brief`) were hard-wired to GitHub via `triage/issue-tracker-github.md`, despite a resolution seam (`project CLAUDE.md → triage-labels.md → issue-tracker-<tracker>.md`) that was designed to be tracker-pluggable but never filled beyond GitHub. Work then adopted Linear — a shared team workspace migrated from Notion — as its issue tracker, while code and pull requests stayed on GitHub. Personal/OSS projects and this skills repo itself remain on GitHub.

## Decision

Support trackers as per-repo adapters rather than migrating wholesale. GitHub stays the default; a repo opts into Linear via its project `CLAUDE.md`. Code-side skills (`commit`, `pr`, `review`) stay GitHub-native regardless of tracker — only issue *tracking* moved, not the code host.

The Linear adapter follows **adopt-don't-impose**: it maps canonical roles onto the team's existing Linear taxonomy and **never bootstraps labels or workflow states in a shared workspace**. A PRD maps to a native Linear **Project** (not a `prd`-labelled issue), with parent/child via sub-issues and "blocked by" via native relations.

## Considered options

- **Full migration to Linear** — rejected: strands personal/OSS repos and this GitHub-hosted skills repo, which would then have no tracker.
- **Port the GitHub label scheme 1:1 onto Linear** (run the same idempotent label bootstrap) — rejected: the workspace is shared and team-owned. The ad-hoc port already produced duplicates (`needs-triage` vs the team's `To triage`, `enhancement` vs the team's `Feature`/`Improvement`). An agent must not manufacture taxonomy in a space it does not own.
- **Dual-track adapter** — chosen: matches upstream (`mattpocock/skills` configures GitHub | Linear | local via a setup skill), preserves single-source-of-truth via `npx skills update`, and confines tracker-specific logic to one adapter file.

## Consequences

- A new `triage/issue-tracker-linear.md` adapter drives operations through the Linear MCP (not a CLI). The label-bootstrap step is disabled for Linear.
- The `## Status` block and the `## Parent` / `## Blocked by` text conventions are dropped on Linear — it surfaces state, hierarchy, and relations natively. The AI-generated disclaimer on comments is kept (it matters more in a shared space, not less).
- `ready-for-agent` against Linear requires the Linear MCP to be authenticated in the headless AFK runtime — verify before relying on it. The natural split: an agent reads the brief from Linear (MCP), ships code via a GitHub PR (`gh`), and a human closes the Linear issue.
- Terminology: canonicalise **Linear (tracker)** to disambiguate from **linear (execution mode)** used in the grill skills' step-1 prompt.
