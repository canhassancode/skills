---
name: cut
description: Publish a parent spec's children as sub-issues — each a vertical capability with its goal and draft behaviour lines — ready for their own align. Use when a parent ticket is ready-to-cut, or a child's align has reshaped the plan.
argument-hint: <parent-ticket-ref>
disable-model-invocation: true
---

# Cut

Turn a parent spec's Children list into tickets a person or an agent can pick up cold, each one aligned just before it is built.

Origin: Anthropic's long-running harness (one user-visible feature per session) and OpenAI's ExecPlans (milestones that are independently verifiable).

Children are drafts. Their interface and tests come later, through `/align <child>`, because a quarter of later slices in this library's trackers changed contract after a sibling merged.

## Steps

1. **Read** the parent ticket and its spec: on `spec/<capability>` while its pull request is open, on the default branch once merged.
2. **Draft** each child in the Children list: its title, a goal line a stranger could follow, up to six draft behaviour lines drawn only from the parent's Goal, Journeys and Rules, and the earlier siblings it needs. Something the parent doesn't cover is a question for the user, not a line.
3. **Check** each child against [align's size and vertical rules](../align/references/tiers.md#size), and the set against the parent: together the children walk every journey, and the last one completes them. For each child that fails, propose the fix — fold, split or reorder — with the reason. The user decides, and the spec's Children list is edited to match. Only a wrong Goal, Shape or Rules sends the parent back to `needs-alignment`.
4. **Show** the set as [EXAMPLES.md](EXAMPLES.md) does. Nothing is created before a yes.
5. **Publish**, in build order: each child as a sub-issue at `needs-alignment`, its blocking edges set as it lands. The operations are in [`docs/agents/issue-tracker.md`](../../docs/agents/issue-tracker.md).
6. **Close.** Commit any Children list edit to the spec's open pull request, or a new one once it has merged; push, and mark it ready. Update the parent's children checklist, drop `ready-to-cut`, post the session comment, and name the next act: merge the spec, then `/align <first child>`.

The parent wears no label after the cut; it stays open until its last child merges.

Run `/cut <parent>` again whenever a child's align splits, folds or drops it: it compares the Children list with the open sub-issues and proposes the edits.
