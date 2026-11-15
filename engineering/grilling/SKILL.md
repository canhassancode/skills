---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round. Number each question and give your recommended answer, then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1 · <question title>**: <one concrete scenario: who, what they do, what happens today>. <the question>

➡️ <your recommended answer, and why, in plain English>

---

❓ **Q2 · <question title>**: …

➡️ …
```

Word each question so that "yes" accepts your recommended answer. Give lettered options only when the choices genuinely differ.

Each round the user answers reshapes the tree. Settled decisions push the frontier outward and unblock the questions that depended on them, so recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round. If the user asks you something, answer it before the next round, and follow them when they change the subject.

**Challenge, don't record.** Before accepting an answer, check it against the code, the glossary, the decisions on record and what the user said earlier. When it clashes, say so with the evidence and ask which holds. An anecdote ("I've never seen it fail") is not evidence: ask what it would cost if it did. A hedge ("sure, I guess") is not a yes, so ask again.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent with a fresh context window to find it. Don't ask the user for anything you could look up yourself, and never ask them how the runtime behaves: find out, or run it. Don't block on it either. A running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
