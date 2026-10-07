---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet.

**Ask one question at a time, and wait.** Asking several at once is bewildering, and answers come back as a list nobody thought about. Pick the frontier question everything else hangs on, ask it, and recompute the frontier from the answer.

Format a question like so:

```
**<the situation in a few words>**

<one concrete scenario: who, what they do, and what happens today — in the user's own words>

❓ **<the question, whole on its own>**

➡️ **<your recommended answer>** - <why, in plain English>

↳ <the fact this rests on and where it came from (`file:line`, a command, a doc)>
```

Lettered options follow only when the choices genuinely differ; a question with one sensible answer is asked as a check — "I'm assuming X — right?". If the user asks you something, answer it before your next question, and follow them when they change the subject.

**Challenge, don't record.** Before accepting an answer, check it against the code, the glossary, the decisions on record and what the user said earlier. When it clashes, say so with the evidence and ask which holds. An anecdote ("I've never seen it fail") is not evidence — ask what it would cost if it did. A hedge ("sure, I guess") is not a yes: ask again. Agreeing to be agreeable leaves the gap for the build to find.

Finding _facts_ is your job, never the user's. When a question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself, and never ask them how the runtime behaves — find out, or run it. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
