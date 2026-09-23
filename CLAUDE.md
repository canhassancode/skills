# Skills repo — conventions

## Upstream

This library was copy-paste imported from [`mattpocock/skills`](https://github.com/mattpocock/skills) on **2026-05-13**. There is **no shared git history** — no merge base, no common ancestor. The content baseline is upstream `v1.1.0` (`d574778`) against local `3090773`.

```sh
git remote add upstream https://github.com/mattpocock/skills.git
```

That remote is the whole mechanism. There is no `/sync` skill, no recorded baseline SHA in a tracking file, no rejected-hunk ledger and no scheduled drift check — harvesting is a manual pass, run when there is a reason to run it.

A remote named `upstream` outranks `origin` when `gh` resolves this repo, so the first `gh` call after adding it lands on `mattpocock/skills` with read-only access. Fix it once per clone: `gh repo set-default canhassancode/skills`.

### Classes

Every registered skill is one of three. The class governs what a harvest is allowed to do to it.

**Synced** — tracks upstream byte-for-byte: `research`, `wayfinder`, `writing-great-skills`.

One why-line covers them: they are general-purpose and upstream maintains them better than a fork would. **`wayfinder` is the exception that earns its own line:** it carries one deliberate divergence — upstream's `/setup-matt-pocock-skills` is `/bootstrap` here. Perfect sync is exactly what let that dangling command name sit in the file unnoticed, so it will recur on every harvest unless the divergence is re-applied by hand each time.

**Adapted** — an upstream shape carrying deliberate local changes. Upstream fixes land here hunk by hunk.

| Skill | Why it diverges |
|---|---|
| `triage` | The Linear adapter and the markdown-ticket flow are local. |
| `grilling` | There is no ambient capture path here; a grilling's output is the route it picks, not a vault write. |
| `diagnose` | Keeps the local name; upstream's rename to `diagnosing-bugs` is not taken. |
| `tdd`, `domain-modeling`, `prototype`, `improve-codebase-architecture`, `codebase-design` | Local domain-doc conventions (`CONTEXT.md`, `docs/adr/`) and British English. |
| `grill-me` | Local description and the second-brain sweep; the body is still upstream's one-line delegation. |

**Forked** — shares a name or an idea with upstream, not a body; or has no upstream counterpart. Upstream diffs are read for ideas, never applied.

| Skill | Why |
|---|---|
| `align` | No upstream counterpart — supersedes `grilling` and `grill-me`. Owns the planning lane's entry — four entries, one of them a refusal — the write ask, and the `needs-alignment` state (ADR-0005, ADR-0007). |
| `handoff`, `receive` | Local is a two-sided pair using the Obsidian vault as cross-machine transport. Upstream's is a one-sided temp-dir doc with no reader. |
| `bootstrap` | Configures both lanes and five trackers; upstream's `setup-matt-pocock-skills` configures one. |
| `commit`, `pr` | Local conventions and PR shape. |
| `design-system` | No upstream counterpart. The System/Flavour split and the `DESIGN.md` artifact are local by construction. |
| `cut` | No upstream counterpart — stage 2: turns an aligned contract into vertical slices that carry their own context, and closes or graduates the alignment ticket (ADR-0006). |
| `build` | No upstream counterpart — stage 3's run: the contract, the fit, the sequential loop of fresh-child units, crucible as the gate, and the pull request with its criteria table. |
| `crucible` | No upstream counterpart — the only review policy; falsification, the consumer grep and the three baselines; `/review` invokes it, completing ADR-0007's deferred retirement (ADR-0009). |
| `personal/*` | No upstream counterpart. The Obsidian second brain is local by construction. |

The experiment bench sits outside these tables until it ships: `in-progress/system-map` is the one unregistered directory (`## The count`), forked from the work `claude-code-config` repo — diff against that, not this remote.

### Edit-time discipline

Editing a **synced** or **adapted** `SKILL.md` means: diff against `upstream/main` first, run `/writing-great-skills` over it, then edit. (`writing-great-skills` is byte-synced and has never actually been run — that is the gap, not the rule.)

### Install-direct upstream skills

Some upstream skills are installed directly from `mattpocock/skills` and are deliberately **not vendored** into this library — `teach` and `wait-what` are the current ones. Installed-and-absent-from-the-library is a category with a reason, not drift. Do not re-raise it as a gap, and do not tidy it into `engineering/` or `productivity/`.

## The count

**32 skill directories live in this library; 31 are registered.** The unregistered one is `in-progress/system-map`, parked on the experiment bench — not shipped, not deprecated. `deprecated/` residents are never registered and never counted.

Of the 31 registered, **17 carry `disable-model-invocation: true` and 14 do not**. The installed set (`~/.agents/skills`) runs ahead of this library: `teach` and `wait-what` come from `mattpocock/skills`, `watch` from `bradautomates/claude-video`, and Claude's own synced bundle sits under `synced/` — all installed direct and deliberately not vendored here.

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

Seven canonical states plus `wontfix`: `needs-triage`, `needs-info`, `needs-alignment`, `ready-to-propose`, `awaiting-decision`, `ready-to-cut`, `ready-to-build`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (`CONTEXT.md` + `docs/adr/`). See `docs/agents/domain.md`.
