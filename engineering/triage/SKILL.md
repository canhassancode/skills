---
name: triage
description: Queue work that arrived cold — classify it, name its route, and write the placeholder body.
disable-model-invocation: true
---

# Triage

Queue inbound work. Triage **classifies and routes**: it writes no brief, runs no pass, and stamps no state a builder can take. The pass that turns a placeholder into a contract is `/align`'s.

A ticket wearing `ready-to-propose`, `awaiting-decision`, `ready-to-cut` or `ready-to-build` is planning work, not inbound — leave it alone. `needs-alignment` is the one state the two lanes share: triage queues into it, and an `/align` pass is what clears it. A body already carrying the contract's rows is planning work whatever it wears — say so and stop, rather than re-queuing it.

## Roles

Two **category** roles — `bug` and `enhancement`. Every queued issue carries exactly one category and one state; an unlabelled issue is queued the moment it lands. Flag conflicting states and ask before acting.

| state | means | the write |
| --- | --- | --- |
| `needs-triage` | classified, route named, waiting to be picked up | a comment naming the route |
| `needs-info` | blocked on a fact from outside the room | the notes below |
| `needs-alignment` | a pass is owed | the placeholder body |
| `wontfix` | not worth doing | the reason, then close |

Human-only work wears `needs-alignment` too: delegability is a body fact, so no state carries it.

A `wontfix` on an enhancement also records the rejection in `.out-of-scope/<concept>.md` where the repo sets `out-of-scope: on`; bugs never get an entry.

These roles are canonical; the label strings are the repo's. Read `docs/agents/triage-labels.md` and apply its strings — where it disagrees with this table, the repo wins. Commands live in the repo's `docs/agents/issue-tracker.md`. Nothing global is read at run time.

## Procedures

1. **Read the context.** Issue, comments, labels, reporter, dates, prior triage notes, and the codebase around it — searched by domain concept, not by the request's wording. Report where you looked. Two checks:
   - **Redundancy** — the behaviour already exists somewhere. That is `wontfix` pointing at where it lives, never an out-of-scope entry.
   - **Prior rejection** — where the repo sets `out-of-scope: on`, read `.out-of-scope/*.md` and surface any record that resembles this issue.
2. **Reproduce (bugs only).** Trace the code path. Report one of three: a repro with the path, a failure to repro, or detail too thin to try — the last is a strong `needs-info`. A bug always ends with its blast radius sized:

   | the trace shows | state | the write |
   | --- | --- | --- |
   | a confined blast radius | `bug` + `needs-triage` | `/diagnose` named as the route |
   | a wide or unreproducible fault | `bug` + `needs-alignment` | the placeholder body |

   Triage invokes no other skill — the route is a name, not a session.
3. **Recommend, then wait.** Category, state, reasoning, and the codebase summary. The maintainer directs; work that needs fleshing out is a pass, and a pass is `/align`'s.
4. **Write.** Show the body and confirm it before it is written — a route answer is never write permission. Apply the category and the state, and say why on the ticket itself: the placeholder carries the reasoning when one is written, the notes otherwise. Close the issue only on `wontfix`, with the reason, or as a duplicate of the ticket with the richest context — the survivor, whose triage notes receive the closed ticket's unique facts.

## What needs attention

Query the tracker and present three buckets, oldest first: unlabelled, `needs-triage`, and `needs-info` with reporter activity since the last notes. Show a count and a one-line summary each, and let the maintainer pick.

## Sweep

`/triage sweep [scope]` triages a backlog instead of one ticket. With no scope it reads the open tickets assigned to the operator that are unlabelled or wear `needs-triage`, `needs-info` or `needs-alignment`, paging the tracker until the list is exhausted; a wider scope only when the operator names one. Planning states are left alone whatever the scope.

1. **Group.** Sort every ticket into a **Duplicate**, a **Family** or a single, and pick each group's survivor by the close rule in Procedures step 4.
2. **Trace.** One code trace per group, run on the survivor; what it finds routes the whole group by the single-ticket rules — the Roles table, and for a bug Procedures step 2. A ticket whose behaviour already exists, or whose code no longer exists, is a `wontfix` candidate, where it lives or the missing code named as the reason. Age is shown, but age never decides.
3. **Plan.** One table: `ticket · what it is · group · action · state after · route`, where "what it is" is one plain line ending in the ticket's age — a number alone does not say what a ticket is. Every ticket read is one row. The operator confirms it as one set, with overrides per row; nothing is written before that confirmation.
4. **Write.** Apply each row's category and state after, with the write the Roles table gives that state. Close each duplicate and family member with the repo's duplicate command, its comment naming the survivor, and fold its unique facts into the survivor's triage notes. A family survivor carries a `needs-alignment` placeholder listing every member along with what only that member said; a survivor already carrying one gets the new members appended, not a second placeholder.
5. **Report.** The before → after count, the failed rows, and the next-up queue: `/diagnose` routes first, then `/align` survivors oldest first.

The sweep runs no pass, stamps no `ready-to-*` state, and creates no Linear labels, states or Projects. It reads open tickets only, so a re-run resumes from live state.

## A markdown ticket

Treat a path to a `.md` file as the issue body. Read it — parsing any frontmatter for `category` or `state` hints — then run the same procedures above, and ask how to land the outcome:

- **Promote to the tracker** — create the issue, write the placeholder from the file, apply the category and the state, then delete or archive the file. Durable tracker state beats a local-only file.
- **Keep local** — update the file in place: frontmatter for `category` and `state`, then the placeholder body below it.

## Bodies

### The placeholder

The alignment body's degenerate case: **Background**, **Problem statement**, **Triage notes**, and no `Passes:` header. Write it only where the body cannot already answer the first two. `/align`'s first pass replaces the notes and folds their text into Background. The template sits beside the alignment body in [EXAMPLES.md](../align/EXAMPLES.md).

### The needs-info notes

```markdown
## Triage Notes

**What we've established so far:**

- point 1
- point 2

**What we still need from you (@reporter):**

- question 1
- question 2
```

Capture what the session settled under "established so far" so the work is not lost, and keep each question specific and actionable. A reply returns the issue to `needs-triage`, where the notes are read before anything is re-asked.

## Quick override

"When #42 goes to `needs-alignment`" is an instruction: confirm the state, the comment and any close, then act — no reproduction, no sizing.

## AI disclaimer

The repo's `triage-disclaimer` preference sets whether queued comments and bodies open with `> *This was generated by AI during triage.*`
