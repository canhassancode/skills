# Skills repo — conventions

## Deprecating a skill

When a skill is superseded (not just bug-fixed, but replaced by a different skill that does the job better):

1. **Move** the skill folder into `deprecated/` (`git mv <category>/<name> deprecated/<name>`)
2. **Rewrite** its `SKILL.md` into a redirect stub — keep the frontmatter (with `disable-model-invocation: true` so the agent never sees it), replace the body with a one-paragraph pointer to the replacement skill. Update relative links to account for the new location
3. **Remove** from `.claude-plugin/plugin.json` — deprecated skills must not be registered
4. **Add** to the `## deprecated/` section in `README.md`, noting what superseded it
5. **Update** any in-repo references (other skills, CONTEXT.md) that still point at the old path

Do not delete the folder — the redirect stub keeps old references from breaking.

## Adding a skill to the plugin registry

When adding a new skill:

- **Add** its path to `.claude-plugin/plugin.json` under the `skills` array (format: `"./skills/<category>/<name>"`)
- **Add** it to the correct category section in `README.md` with a one-line description of what it does, linking to its `SKILL.md`

When removing/deprecating a skill:

- **Remove** from `.claude-plugin/plugin.json`
- **Do not** remove from `README.md` — move the entry to the `## deprecated/` section instead, noting the replacement

## README.md

The README is the human-facing catalogue. It mirrors what's in plugin.json but adds descriptions.

- Every registered skill gets a line in its category section
- Deprecated skills live in `## deprecated/` — name what superseded each
- The `## My day-to-day` section is opinionated — update it only when the daily workflow actually changes, not every time a skill is added or retired
