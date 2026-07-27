---
name: observe
description: Append one timestamped observation to ~/Obsidian/Profile/observations.md — something noticed about how the work goes, a correction that keeps recurring, a tool that keeps misfiring. Use when the user runs /observe.
disable-model-invocation: true
---

# Observe

`/observe <free text>` appends **one timestamped line** to `~/Obsidian/Profile/observations.md`.

That is the whole skill. No hubs, no template, no three-file model.

## Procedure

1. Get the date and time: `date +%F`, `date +%H:%M`.
2. Append one line to `~/Obsidian/Profile/observations.md`, creating the file if it is missing:

   ```
   - YYYY-MM-DD HH:MM — <the observation, as given>
   ```

3. Say nothing else. Capture is near-zero friction or it does not happen.

## Called by nothing

No skill calls `/observe` on exit. There is no spine. It fires when Hassan runs it — and at most once more per session at the agent's discretion: **when a correction lands mid-session** (the same correction a second time, a hook or setting misfiring), the agent may offer, in one line, "worth an `/observe`?" and then drop it. Hassan decides; the agent files.

## The file drains

`observations.md` is a queue, not a journal. `/retro` reads it, routes each item to a change, and deletes it. An observation still sitting there is not filed — it is undrained. If the file only grows, the answer is to run `/retro`, not to give the file more structure.

## Confidentiality

Never write Class A — live secrets, credentials, tokens, customer PII, customer financial data, verbatim proprietary source. Pseudonymise customer identity.
