---
name: gauntlet
description: "Run a ticket through the gated gauntlet — deterministic preflight in this session, then the gauntlet-run workflow (specify, coder, cleaner, QA, ship) behind receipt-verified gates."
argument-hint: <issue-number | linear-id | ticket.md path> [--from specify|coder|cleaner|qa|ship]
disable-model-invocation: true
---

# Gauntlet

Runs one ticket end to end and opens a PR only when every gate is green. Preflight is shell run here, in your session, with no model in the loop; the stages run inside the `gauntlet-run` workflow. The runner is `"${CLAUDE_CONFIG_DIR:-$HOME/.claude}/gauntlet/run.py"`; its README (`gauntlet/README.md` beside it) is the per-repo bootstrap.

## Procedure

1. **Parse the arguments.** The first token is the ticket reference; an optional `--from <stage>` names the stage to enter at (default `specify`). Valid stages: `specify`, `coder`, `cleaner`, `qa`, `ship`. Anything else: stop and list them.
2. **Resolve a Linear reference.** If the reference matches `[A-Z]+-\d+`, fetch the issue through the Linear MCP tools, write its title as an H1 and its description verbatim below it to `.gauntlet/ticket-<id>.md` in the repo root, and use that path as the reference. A GitHub number or a file path needs nothing — `run.py` reads those itself.
3. **Preflight.** From the repo root run, via Bash:

   ```sh
   python3 "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/gauntlet/run.py" preflight <ref> [--from <stage>]
   ```

   It leaves main, mints the run secret, writes `.gauntlet/ticket.json`, refuses a body without `- [ ] Given …, when …, then …` criteria, and runs clean-tree, install, setup, build and coverage (plus acceptance green when re-entering past the coder). It prints one JSON line.
4. **Branch on `ok`.**
   - `false` → stop. Show `failed` and `tail` verbatim. Do not fix anything, do not retry, do not invoke the workflow. A missing config means the repo has not been bootstrapped (see the README); a ticket with no criteria goes back through `/to-tickets`; a red guard is the repo's problem to solve in this session.
   - `true` → invoke the workflow immediately, passing the JSON object as `args` (not a string):

     `Workflow({ name: "gauntlet-run", args: <the parsed JSON> })`

5. **Report the outcome** when the workflow returns: the PR URL on `ship`; on `escalate`, the reason, the stage, and the `reenter` command verbatim — that command is how the run resumes once the cause is fixed here.

## Rules

- Never write acceptance criteria. A free-text idea is not a ticket; it goes through `/grilling` → `/to-tickets` first.
- Never run a stage in this session. Specify, coder, cleaner and QA are fresh-context agents inside the workflow by design; the operator's window stays lean.
- Never invoke the workflow with a hand-built `args` — only preflight's output. The secret and HEAD it carries are what the receipts are hashed over.

## Related

`to-tickets` — writes the criteria this consumes · `gauntlet-run` — the workflow this invokes · `implement` — the manual alternative for work that is not gauntlet-shaped
