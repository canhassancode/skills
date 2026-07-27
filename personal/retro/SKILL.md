---
name: retro
description: Drain ~/Obsidian/Profile/observations.md — read the observations back, take them one at a time, and turn each into a change made in the same sitting. Use when the user runs /retro.
disable-model-invocation: true
---

# Retro

Drains `~/Obsidian/Profile/observations.md`. `/observe` fills it; this empties it.

**The whole file by default.** A single observation may be passed as an argument, but the default is the whole file, and that is load-bearing: the repeat signal — the same friction written down three times in different words — is only visible with the items side by side.

## Procedure

1. **Read the file back.** Show what is in it, in order, unabridged. Hassan sees the batch before anything is decided.
2. **One at a time, propose then judge.** For each observation, the agent proposes: what change would settle it, and where that change lands. Hassan accepts, redirects, or rejects. Nothing is applied on the agent's own authority.
3. **Make the change in this sitting.** The observation drains **to the change, not to a ticket**. Edit the file, flip the setting, rewrite the skill — now. Filing a ticket is the admitted exception, for a change genuinely too big for one sitting; if it is being used more than rarely, the sitting has become a triage queue and the drain has failed.
4. **Remove the item.** Outright deletion from `observations.md` — no archive section, no "resolved" heading. The change is the record.

## The one test

There is no routing table. For each observation, ask:

> **What would have to be different for this not to recur?**

The target falls out of the answer. A correction pattern points at that `SKILL.md`, or the global `CLAUDE.md`. A hook or setting misfiring points at `~/dotfiles`. "I keep meaning to read X" points at `Inbox/`, drained later by `/ingest`. A fact about another model or harness is a Library page, or it is nothing. Human practice, art, how Hassan explains things — straight to the vault. Noise is deleted, no ceremony.

These are illustrations, not a lookup table. A table would ossify the routes; the question does not.

## The invariant

**`/retro` cannot end with an item still in the file.** Every observation ends the sitting as a change, a filed exception, or a deletion. "I'll deal with it next time" is not an exit — it is how the file stopped draining in the first place.

## Multi-repo by construction

One sitting routinely commits to `~/Repos/skills`, `~/dotfiles` and `~/Obsidian`. Do not assume the session is inside one project or that the working directory is the target; resolve each change's repo from the change itself, and commit in each repo it touches.
