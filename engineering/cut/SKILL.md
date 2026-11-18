---
name: cut
description: Publish a parent spec's children as ready-to-build sub-issues. Each child is a tracer-bullet vertical slice with its acceptance criteria, seams, Verify steps and blocking edges, sized for one fresh build session. Use when a parent ticket is ready-to-cut, or a build or align has reshaped the plan.
argument-hint: <parent-ticket-ref>
disable-model-invocation: true
---

# Cut

Turn a parent spec's Children list into tickets an agent can build cold, one fresh session each.

Origin: Pocock's to-tickets (tracer-bullet slices, each sized to a single fresh context window, published ready for an agent) and Anthropic's long-running harness (one feature per session).

## Steps

1. **Read** the parent ticket: its body is the spec. Read the code its Shape names, using a subagent when it's more than a few files. Look for a prefactor that would make the slices easier, and make it the first child.
2. **Draft** each child from the Children list. Each gets:
   - a What to build line a stranger could follow;
   - up to six acceptance criteria drawn from the parent's Goal, Rules and Journeys;
   - its seams, taken from the parent's Shape;
   - its Verify steps;
   - the earlier children it needs, or that change the same function or type.
   Use the child template in [align's spec](../align/references/spec.md). Something the parent doesn't cover is a question for the user, not a criterion.
3. **Check** the set:
   - Each child is vertical: a narrow but complete path that can be seen working on its own, never a layer.
   - Each fits one fresh `/build` session: about six criteria, one seam, and a few files. Wiring that needs a real process proved goes in the same child as the code that needs it.
   - Together the children walk every journey, and the last one completes them.
   - A wide refactor, one mechanical change across many call sites, is cut as expand, then migrate in batches, then contract.
   For each child that fails a check, propose the fix (fold, split or reorder) with its reason. A wrong Goal, Shape or Rules sends the parent back to `/align`.
4. **Show** the set as [EXAMPLES.md](EXAMPLES.md) does, in one message, with its questions in one round: granularity, blocking edges, and anything to fold or split. Nothing is created before a yes.
5. **Publish** in build order. Each child becomes a sub-issue at `ready-to-build`, with its blocking edges set as it lands. A child with a genuinely open question goes to `needs-alignment` instead, and its question goes in the body. The operations are in the repo's `docs/agents/issue-tracker.md`.
6. **Close.** Rewrite the parent's Children list as a checklist of the published children, keeping the rest of its body. Drop `ready-to-cut`, post one session comment, and name `/build <first child>` as next.

The parent wears no label after the cut, and stays open until its last child merges.

Run `/cut <parent>` again when a build stops on a child that was cut too big, or when an align reshapes the plan. It compares the Children list with the parent's children and their edges, read and moved with the operations in `docs/agents/issue-tracker.md`, and proposes the edits.
