---
created: 2026-07-01
updated: 2026-07-26
sources: grill-with-docs session (2026-07-01)
---

# Dual-Track Tracker Adapter — GitHub + Linear (grill)

How the personal skills repo (`canhassancode/skills`) should support **two issue trackers at once** — GitHub for personal/OSS, Linear for work — after work migrated its tracker Notion→Linear. A `grill`-sourced decision. Built by Hassan.

## The question

The issue skills (`triage`, `to-prd`, `to-issues`, `pickup`, `morning-brief`) were hard-wired to GitHub. Work adopted **Linear**. Should the skills integrate both, or migrate wholly to Linear? And separately: the repo drifted from its upstream (`mattpocock/skills`) — reel it back?

## Decisions

1. **Dual-track adapter, not migration.** GitHub stays the default; Linear is a per-repo adapter selected via a `tracker:` declaration in the project's `CLAUDE.md`. Work repos → Linear; personal/OSS + the skills repo itself → GitHub. Full migration was rejected because it strands every non-work repo (including the GitHub-hosted skills repo, which would then have no tracker).
2. **The code host didn't move — only issue tracking did.** `commit`/`pr`/`review` stay GitHub-native regardless of tracker. This is the clean seam and it narrows the whole change: only the *issue* skills touch the tracker.
3. **Adopt-don't-impose on Linear.** The Linear adapter maps canonical roles onto the team's *existing* taxonomy and **never bootstraps labels/states in a shared workspace**. A PRD maps to a native Linear **Project** (what the team already uses — rich-body parents), with sub-issues + native blocking relations, not a `prd`-labelled issue. Drop the `## Status` block and `## Parent`/`## Blocked by` text sections on Linear (it surfaces these natively); keep the AI-generated disclaimer on comments.
4. **Reel back exactly one thing from Pocock:** his tracker-agnostic `setup` pattern (asks GitHub|Linear|local, writes the per-repo config). Everything else that drifted — the Obsidian second brain, the log spine, the four-pass discipline, `to-proposal`/`pickup`/`receive` — is *ahead* of upstream, not behind. Reeling those back would be regression.

## Sharpest insight

**The adapter is entering someone else's house.** Work Linear is a shared *team* workspace, not a personal tracker. The GitHub adapter's habit — idempotently *create* the canonical labels — is actively wrong there. Evidence it had already gone wrong: the GitHub label scheme had been hand-ported into the team Linear (identical hex codes), spawning duplicates against the team's own conventions (`needs-triage` vs the team's `To triage`, `enhancement` vs `Feature`/`Improvement`, a half-ported `bug`, a `prd` label now superseded by native Projects). So a good adapter for a shared space *detects and maps*, it does not manufacture taxonomy.

The second insight: **most "drift" from an upstream template is you outgrowing it, not failing it.** The instinct to "reel it back" assumes divergence = decay. Here the only drift worth correcting was the *one abstraction that was dropped* (tracker-agnostic setup) — which, conveniently, is the exact mechanism that makes the Linear support installable. Reeling it back and solving the tracker problem are the same task.

## Why this was live now (a flipped premise)

The 2026-06-10 grill (the 2026-06-10 daily-workflow redesign grill (retired)) had closed the "pipeline feels broken at work" pain as a *misdiagnosis* — "work IS GitHub, the substrate was fine." That premise died when work moved Notion→Linear (~2026-06-29). The earlier fix (grill-output-as-fan-out, not a forced PRD pipeline) still stands and was never the tracker's fault; but the *tracker* mismatch that was ruled out then is now real.

## Consequences / open threads

- New `triage/issue-tracker-linear.md` adapter drives ops through the **Linear MCP** (not a CLI); bootstrap disabled.
- Terminology collision to canonicalise: **Linear (tracker)** vs **linear (execution mode)** in the grill skills' step-1 prompt.
- **AFK reachability risk:** `ready-for-agent` against Linear only works if the Linear MCP is authenticated in the headless pi/ralph runtime. Natural split — agent reads the brief from Linear (MCP), ships code via a GitHub PR (`gh`), a human closes the Linear issue. Verify before relying on it.
- Ops debt (not a skills change): tidy the duplicate labels already made in the team Linear.
- Execution: no issue ceremony — it's one coherent prompt-file edit, done in a session. Recorded in skills-repo ADR `0001-dual-track-issue-tracker-adapters`.

## Superseded in part (2026-07-26)

Decision 4 listed `pickup`/`receive` among the things "ahead of upstream, not behind". [Inbound Triage Lane & Ticket Legibility](./inbound-triage-lane-and-ticket-legibility.md) **reverses that for `pickup`** — deprecated as 574 words of per-ticket ceremony guarding a risk `/implement` absorbs — and leaves `receive` stranded, since it defines itself as "the session analogue of `/pickup`". The dual-track adapter itself is unaffected and is what makes "one skill, two trackers" cheap; that grill also confirmed the lane's real habitat is the work Linear, not GitHub.

## Refined (2026-07-27)

The claim that **"most drift from an upstream template is you outgrowing it, not failing it"** survives as the majority case but is no longer the whole story. A full audit against `mattpocock/skills` ([Upstream Skill Fork Policy](./upstream-skill-fork-policy.md)) split the divergence explicitly: most of it *is* deliberate adaptation worth keeping (the second-brain hooks, the Structure review axis, the Linear adapter, the four-pass discipline), but a real one-way decay class exists alongside it — a diagnosis skill eleven weeks behind a substantial rewrite, two upstream bug fixes never taken, and a shared skill body that silently *regressed* because local blocks were appended to a file whose upstream text had moved. Outgrowing and failing are not alternatives; the same library does both at once, per skill.

## Related

- [Upstream Skill Fork Policy](./upstream-skill-fork-policy.md) — the audit and policy that refines the "outgrowing, not failing" claim above.
- the 2026-06-10 daily-workflow redesign grill (retired) — the grill whose "work IS GitHub" premise this supersedes.
- [Inbound Triage Lane & Ticket Legibility](./inbound-triage-lane-and-ticket-legibility.md) — decides which triage roles and skills survive on top of this adapter.
- [Skill Execution-Mode Pattern](./skill-execution-mode-pattern.md) — the "linear vs fan-out" execution mode that collides in name with Linear the tracker.
