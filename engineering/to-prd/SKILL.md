---
name: to-prd
description: Turn the current conversation context into a PRD and publish it to the project issue tracker. Use when user wants to create a PRD from the current context.
---

This skill takes the current conversation context and codebase understanding and produces a PRD. Do NOT interview the user — just synthesize what you already know.

Resolve the repo's issue tracker: read a `tracker:` preference from the project CLAUDE.md or skills — `github` (default) or `linear`. Load the matching adapter — `~/.claude/skills/triage/issue-tracker-github.md` or `~/.claude/skills/triage/issue-tracker-linear.md` — together with `~/.claude/skills/triage/triage-labels.md` for the canonical-role vocabulary. Default to GitHub when no preference is declared. This can be overridden by the user upon request.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the PRD, and respect any ADRs in the area you're touching.

2. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

3. Write the PRD using the template below, then publish it to the project issue tracker. Apply the `prd` label — this marks the issue as an epic-style parent document. Do NOT apply `needs-triage`: grilling already triaged it, and a PRD is not a work item that progresses through triage states (its children are).

   Populate the `## Status` block at the top of the body with the actual labels and today's date. Leave the `## Updates` section as a placeholder; `/triage` will append entries as material decisions land. See the [Status block + Updates pattern](../triage/SKILL.md#status-block-and-updates-section) in the triage skill for the maintenance rules.

4. **Decide what's next.** Ask the user whether the PRD is ready to break into tracer bullets now, or whether it needs external input first (stakeholder approval, a spike result, missing context).

   - **Ready** → suggest `/to-issues #<number>` as the next step.
   - **Not ready** → apply the `needs-info` label to the PRD AND post a one-line comment naming the specific blocker (e.g. "blocked on @cto approval", "waiting on spike #137"). Do NOT run `/to-issues` yet. When the blocker resolves, the maintainer removes `needs-info` manually and runs `/to-issues`.

   The `prd` and `needs-info` labels compose orthogonally: `prd` says "this is an epic-style parent document"; `needs-info` says "waiting on external input". On GitHub, `gh issue list --label prd --label needs-info` surfaces all blocked PRDs; on Linear, a PRD is a Project, so filter Projects (or the equivalent state) for blocked ones.

<prd-template>

## Status

- **Last update:** <YYYY-MM-DD> — newly published, no triage yet

## Updates

_Material decisions get logged here by `/triage` as they happen — one line each, with a link to the triggering comment. The body below stays current; this section is the audit trail of how it got there._

- _No updates yet._

---

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
