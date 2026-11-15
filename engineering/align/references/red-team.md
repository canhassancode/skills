# Red team

A fresh subagent argues against the ask before the spec is written. It runs once per ask, after tiering. A child of a cut parent skips it, because the parent was already challenged, unless the child adds or loosens a boundary.

It runs in a fresh context because grilling challenges each answer as it arrives, but nobody in the conversation is placed to challenge the whole idea. The conversation anchors on it.

## Brief

Send exactly this, filled in. Not the conversation.

```
Argue against doing this, then try to break it. Find the strongest reasons it should not be
built, or should be built smaller. If it adds or loosens a boundary (a sandbox, a permission,
an allowlist, a secret, a redaction), list everything that could cross it and say which
crossings the plan doesn't stop.

The ask: <the user's ask, in their words>
Tier: <size and uncertainty>
Repo: <path>

Gather your own facts: the code it would touch, what already does something similar, usage or
data where the repo or tracker has it, and what it would cost to build and keep. Every point
needs evidence: a file:line, a command and its output, a count, or a source with a link.

Return:
Verdict: go | shrink to <the smaller thing> | no-go
Against:
- <point> — <evidence>
Crossings: <each way across the boundary the plan doesn't stop, with evidence> | none — no boundary
For, despite the above: <the one strongest reason to go ahead>
```

## Using the verdict

Show the user the verdict and its points in one message, then ask: go, shrink or no-go?

- **Go**: carry the points that still stand into the spec, as Out of scope lines or as criteria that cover them. Each crossing becomes a criterion with a Verify step that tries it, or an Out of scope line with its reason.
- **Shrink**: the smaller thing is re-tiered and becomes the ask.
- **No-go**: close as `wontfix`, with the strongest point as the reason.

The user decides. A no-go from the red team is an argument, not a veto, and a go is not permission to skip grilling.

## Evidence

- Klein's pre-mortem (HBR, 2007): imagining the project has failed surfaces risks a team won't raise while it is committed.
- Kumar et al., ASE 2025: agents that challenge developers do better than sycophantic ones (19 developers, 33 issues).
- brigade#136: five spikes asked "can it reach the Docker socket?", not "what can cross the sandbox?". The D-Bus escape was found only at review (ADR-0013).
