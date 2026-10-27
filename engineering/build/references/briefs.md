# Briefs

Each subagent starts fresh and knows only its brief. Fill the angle brackets; pass the spec by path, never restated.

## Builder

```text
Unit <n> of <m> — <one line> · Ticket #<n> · Spec: docs/specs/<capability>.md

Make these locked tests green:
- "<behaviour line>"
- "<behaviour line>"

The loop: <typecheck> · <lint> · <locked command for these tests> · <full suite>
The interface is the committed stubs; build behind them. Follow CLAUDE.md.

Locked files (.acceptance., .properties., .contract., e2e/) are read-only. If one looks wrong, or the
interface can't satisfy it, or you need a service or credential you don't have: stop and report the
test, what it expects and why. Do not work around it. Never read .env, .mcp.json or production config.

Write scratch unit tests where they help; crucible keeps only those that catch something the locked
tests miss. Never shape code to a test's inputs.

Commit once, when this unit's tests and the full suite are green: `feat: <what now works>`, no
criterion codes. Hand back the commit sha, the locked command's output and `git status` clean.
```

## Fix

```text
Fix round · Ticket #<n> · Spec: docs/specs/<capability>.md

<each finding or failed verify step, verbatim, with its file:line and evidence>

Answer each in the code, wherever it lives. Same rules as a unit: locked files read-only, stop on a
wrong test or missing access, follow CLAUDE.md. A finding that would change a behaviour line is not
yours: say so and leave it. One commit, `fix: <what>`, once the full suite is green. Hand back the
sha and the output.
```

## Verifier

```text
Verify · Ticket #<n>

Run these steps against the running app and report what you observed. You have not seen the code
or the tests; don't read them.

<the spec's ## Verify section, verbatim>

Start the app with `timeout 600`, use only credentials already in the environment, and stop it when
done. Never read .env, .mcp.json or production config. For each step return one of:
- passed — the command and its output, or the screenshot path
- failed — what you expected, what you saw, the output
- not run — why (missing credential, service, browser), and the exact steps a reviewer would take
```

## Crucible

```text
/crucible <lock-sha>...HEAD docs/specs/<capability>.md
```

Nothing narrows it: no severity bar, no list of what to skip.
