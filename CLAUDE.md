# Skills repo — conventions

## Upstream

This library was copy-paste imported from [`mattpocock/skills`](https://github.com/mattpocock/skills) on **2026-05-13**. There is **no shared git history** — no merge base, no common ancestor. The content baseline is upstream `v1.1.0` (`d574778`) against local `3090773`.

```sh
git remote add upstream https://github.com/mattpocock/skills.git
```

That remote is the whole mechanism. There is no `/sync` skill, no recorded baseline SHA in a tracking file, no rejected-hunk ledger and no scheduled drift check — harvesting is a manual pass, run when there is a reason to run it.

### Classes

Every skill is one of three. The class governs what a harvest is allowed to do to it.

**Synced** — tracks upstream byte-for-byte: `research`, `resolving-merge-conflicts`, `wayfinder`, `writing-great-skills`.

One why-line covers them: they are general-purpose and upstream maintains them better than a fork would. **`wayfinder` is the exception that earns its own line:** it carries one deliberate divergence — upstream's `/setup-matt-pocock-skills` is `/bootstrap` here. Perfect sync is exactly what let that dangling command name sit in the file unnoticed, so it will recur on every harvest unless the divergence is re-applied by hand each time.

**Adapted** — an upstream shape carrying deliberate local changes. Upstream fixes land here hunk by hunk.

| Skill | Why it diverges |
|---|---|
| `code-review` | The Structure axis is local — it encodes the ladder in the global `CLAUDE.md`. |
| `triage` | Linear adapter, the `## Status` block, and the markdown-ticket flow are all local. |
| `grilling` | There is no ambient capture path here; a grilling's output is the route it picks, not a vault write. |
| `implement` | Takes a ticket reference and fetches the agent brief through the tracker adapter. |
| `diagnose` | Keeps the local name; upstream's rename to `diagnosing-bugs` is not taken. |
| `to-spec`, `to-tickets` | Publish `ready-for-agent` by construction into this repo's two-lane model. |
| `tdd`, `domain-modeling`, `prototype`, `improve-codebase-architecture`, `codebase-design` | Local domain-doc conventions (`CONTEXT.md`, `docs/adr/`) and British English. |
| `grill-me` | Local description and the second-brain sweep; the body is still upstream's one-line delegation. |

**Forked** — shares a name or an idea with upstream, not a body; or has no upstream counterpart. Upstream diffs are read for ideas, never applied.

| Skill | Why |
|---|---|
| `handoff`, `receive` | Local is a two-sided pair using the Obsidian vault as cross-machine transport. Upstream's is a one-sided temp-dir doc with no reader. |
| `system-map` | Its live upstream is the work `claude-code-config` repo, not `mattpocock/skills`. Diff against that, not this remote. |
| `grill-with-docs` | Built around this repo's `CONTEXT.md` / ADR layer and the four-pass discipline. |
| `bootstrap` | Configures both lanes and five trackers; upstream's `setup-matt-pocock-skills` configures one. |
| `commit`, `pr` | Local conventions and PR shape. |
| `design-system` | No upstream counterpart. The System/Flavour split and the `DESIGN.md` artifact are local by construction. |
| `to-proposal` | No upstream counterpart — the decision-doc sibling of `to-spec`, publishing to the tracker as `ready-for-human`. |
| `gauntlet` | No upstream counterpart. The entry point of the gated build spine that lives in dotfiles (`claude/gauntlet/`, `claude/workflows/gauntlet-run.js`, `claude/agents/gauntlet-*.md`). |
| `personal/*` | No upstream counterpart. The Obsidian second brain is local by construction. |

### Edit-time discipline

Editing a **synced** or **adapted** `SKILL.md` means: diff against `upstream/main` first, run `/writing-great-skills` over it, then edit. (`writing-great-skills` is byte-synced and has never actually been run — that is the gap, not the rule.)

### Install-direct upstream skills

Some upstream skills are installed directly from `mattpocock/skills` and are deliberately **not vendored** into this library — `teach` is the current one. Installed-and-absent-from-the-library is a category with a reason, not drift. Do not re-raise it as a gap, and do not tidy it into `engineering/` or `productivity/`.

## The count

**33 skill directories live in this library; 32 are registered.** The unregistered one is `in-progress/system-map`, parked on the experiment bench — not shipped, not deprecated. `deprecated/` residents are never registered and never counted.

Of the 32 registered, **18 carry `disable-model-invocation: true` and 14 do not**. The installed set (`~/.agents/skills`) runs one ahead on both counts — **33 directories, 19 invisible / 14 visible** — because `teach` is installed direct from upstream and deliberately not vendored here.

## Deprecating a skill

When a skill is superseded (not just bug-fixed, but replaced by a different skill that does the job better):

1. **Move** the skill folder into `deprecated/` (`git mv <category>/<name> deprecated/<name>`)
2. **Rewrite** its `SKILL.md` into a redirect stub — keep the frontmatter (with `disable-model-invocation: true` so the agent never sees it), replace the body with a one-paragraph pointer to the replacement skill. Update relative links to account for the new location
3. **Remove** from `.claude-plugin/plugin.json` — deprecated skills must not be registered
4. **Add** to the `## deprecated/` section in `README.md`, noting what superseded it
5. **Update** any in-repo references (other skills, CONTEXT.md) that still point at the old path

Do not delete the folder — the redirect stub keeps old references from breaking.

## Adding a skill to the plugin registry

When adding a new skill:

- **Add** its path to `.claude-plugin/plugin.json` under the `skills` array (format: `"./skills/<category>/<name>"`)
- **Add** it to the correct category section in `README.md` with a one-line description of what it does, linking to its `SKILL.md`

When removing/deprecating a skill:

- **Remove** from `.claude-plugin/plugin.json`
- **Do not** remove from `README.md` — move the entry to the `## deprecated/` section instead, noting the replacement

## README.md

The README is the human-facing catalogue. It mirrors what's in plugin.json but adds descriptions.

- Every registered skill gets a line in its category section
- Deprecated skills live in `## deprecated/` — name what superseded each
- The `## My day-to-day` section is opinionated — update it only when the daily workflow actually changes, not every time a skill is added or retired

## Issue tracker

tracker: github

triage-disclaimer: off

## Agent skills

### Issue tracker

GitHub Issues (`canhassancode/skills`). External PRs are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (`CONTEXT.md` + `docs/adr/`). See `docs/agents/domain.md`.
