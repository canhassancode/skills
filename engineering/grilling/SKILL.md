---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
**S1** - <one concrete walk, in the user's own words, and the outcome it has today>

---

❓ **Q1** - **<question title>**: <question body; name the scenario it turns on, and what changes under each option>

- **A.** <option>
- **B.** <option>

➡️ **<recommended answer>** - <the reason, in plain English>

↳ <the fact this rests on and where it came from (`file:line`, a command, a doc) — or the route that would settle it when no fact can>

---

❓ **Q2** - **<question title>**: <question body>
```

Open the round with its scenarios — the concrete walks its questions turn on, in the user's own words. Number them (`S1`, `S2`) when a round turns on more than one, and have each question name its own. Every question carries its options as lettered choices, so answers come back as `Q1: C`. The `↳` line shows the fact the question rests on and where it came from, because facts are found and never asked — the user should be able to see what the choices stand on. A scenario no option changes is decoration: delete it, or make it the question.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
