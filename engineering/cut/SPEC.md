# Spec body

The map a cut publishes when it makes several slices: the scenario-to-slice assignment and the shared interfaces with their consumers. The node's title is the outcome, sentence case; its body carries no criteria, no boundaries and no workflow label — `ready-to-build` means *the body carries the contract*, and a spec's body carries the map instead.

```markdown
> Alignment: #<n>

<One line: what is true after every slice ships.>

# What this builds

The alignment's `# Problem statement`, transcribed verbatim.

# Scenarios

| scenario | slice | blocked by |
| --- | --- | --- |

# Interfaces

The rows with more than one consumer, each naming the slice that builds it and the slices that use it. A row with a single consumer belongs in that slice.

| name | shape | built by | used by |
| --- | --- | --- | --- |

# Decisions

| decision | taken | rejected | because |
| --- | --- | --- | --- |

# Out of scope

Numbered, each with the reason it was rejected.

# Unresolved

Empty, or the route that settles each entry.

# Sources
```
