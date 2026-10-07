# Spec body

The map a cut publishes when it makes several slices: which slice makes each scenario pass, the order they build in, and the pieces more than one slice shares. The node's title is the outcome, sentence case; its body carries no criteria, no boundaries and no workflow label — `ready-to-build` means *the body carries the contract*, and a spec's body carries the map instead. Plain words, as in [TICKET.md](TICKET.md); a section with nothing in it is left out, except `Unresolved`.

```markdown
> Alignment: #<n> · Verified against: `<sha>`

<One line: what is true after every slice ships.>

# What this builds

The alignment's `# Problem statement`, transcribed verbatim.

# Scenarios

| # | scenario | slice |
| --- | --- | --- |
| 1 | **<A name in plain words.>** <Who, the starting state, the trigger> — <what they observe>. | #<n> |

# Order

<Two sentences: which slice goes first and why, which can run side by side.>

# Shared pieces

| piece | shape | built by | used by |
| --- | --- | --- | --- |

# Decisions

- **<A choice that binds more than one slice.>** <Why, in one line.>

# Premises

- <A fact more than one slice rests on> — <its probe, pinned to the sha>.

# Out of scope

1. <What, and why not.>

# Unresolved

None.
```

A piece only one slice uses belongs in that slice, not here. A decision or premise only one slice rests on lives in that slice.
