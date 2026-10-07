# Slice title

One sentence, affirmative, specific, sentence case, no internal names — *Carousels reject off-ratio images before upload*, not *Add ratio validation to `Normaliser`*. Where the deliverable is a removal or a chore, the imperative carries it honestly — *Delete the old ratio column*.

# Slice body

Write it for a colleague who has never seen the alignment: plain words, the behaviour first, every project term either in `CONTEXT.md` or glossed where it first appears. A section with nothing in it is left out — except `Blocked by` and `Unresolved`, which always appear and say `None.`

```markdown
> Spec: #<n> · Alignment: #<n> · Verified against: `<sha>` · Size: <small | medium | large>

# What this builds

Two or three sentences: what the slice does once it ships, and what is true today.

# Scenarios

1. **<A name in plain words.>** <Who, the starting state, the trigger> — <what they observe>.

# Acceptance criteria

Each decided by `<command>`.

- [ ] C1 · S1 · `<witness>`: <what the witness shows, in one line>.

# Decisions

- **<The choice, as a sentence.>** <Why, in one line — the rejected alternative named where it helps.>

# Premises

- <A fact about code, data or runtime the slice rests on> — <the probe: a `path:line @ sha` permalink with the symbol, or the command and the output line that settled it>.

# Boundaries

**Always** <…> · **Ask first** <…> · **Never** <…>

# Out of scope

1. <What, and why not.>

# Interfaces

<details><summary>Owned and consumed</summary>

| name | shape | owned | read by |
| --- | --- | --- | --- |

</details>

# Blocked by

<Each a real ticket, matching its native edges — or None.>

# Unresolved

None.
```

**Scenarios** are numbered from 1 in each slice; the spec's table maps them back. **Criteria** name the scenario they make pass. A criterion only a real system can decide is written `C2 · S1 · **Live**: <what is run> Passing: <the evidence>`, and its prerequisites — fixture, credentials, permission to write outside the repo — are provisioned before the build, or routed as a task.

**Premises** are pinned to the `Verified against` sha, never to a pass. A line number drifts; the sha says exactly what was read, and `/build` re-probes any premise whose file has changed since.

**Size** is stamped by the cut and sets how much ceremony `/build` spends:

| size | when |
| --- | --- |
| small | at most 2 criteria, no live criterion, and no interface another slice reads |
| medium | at most 6 criteria, and at most two interfaces other slices read |
| large | anything else |
