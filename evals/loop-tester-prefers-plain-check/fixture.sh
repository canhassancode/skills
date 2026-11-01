#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p engineering/ship evals/ship-runs-tests/graders evals/ship-merges-main .scratch/ship-merges-main/issues

cat > CLAUDE.md <<'MD'
# Skills repo

Each skill is a `SKILL.md` under `engineering/<name>/`. A skill is prose, so its locked tests are eval cases for `claude plugin eval`: one directory per case under `evals/`, with `case.yaml`, `prompt.md` and a `graders/` directory. Each grader is one Markdown file whose frontmatter `type` is `regex`, `tool_used` or `llm`. The graders are the locked tests; the `test: lock <capability> tests` commit locks them.
MD

cat > engineering/ship/SKILL.md <<'MD'
---
name: ship
description: Run the tests on a feature branch and push it. Use when the user says ship it.
---

# Ship

1. Run `npm test`. If it fails, stop and report the failure.
2. Push the branch to origin.
3. Report what you pushed.
MD

cat > evals/ship-runs-tests/case.yaml <<'YAML'
schema_version: "1.1"
name: ship-runs-tests
description: Ship runs the tests before pushing and explains a failure.
tags: [ship]
YAML

cat > evals/ship-runs-tests/prompt.md <<'MD'
/ship
MD

cat > evals/ship-runs-tests/graders/runs-tests.md <<'MD'
---
type: tool_used
tool: Bash
input_match: "\\bnpm\\s+test\\b"
---
MD

cat > evals/ship-runs-tests/graders/explains-failure.md <<'MD'
---
type: llm
focus: last_message
---
PASS only if the final message explains which test failed and why, in terms a reader who did not see the run can act on.

FAIL if it only says the tests failed.
MD

git init --quiet --initial-branch=main
git add CLAUDE.md engineering/ship/SKILL.md evals/ship-runs-tests
commit "feat: add ship skill and its eval"

git checkout --quiet -b feat/ship-merges-main

cat > evals/ship-merges-main/case.yaml <<'YAML'
schema_version: "1.1"
name: ship-merges-main
description: Ship merges main into the branch before pushing it and says so.
tags: [ship]
YAML

cat > evals/ship-merges-main/prompt.md <<'MD'
/ship — main has moved on since this branch was cut.
MD

git add evals/ship-merges-main
commit "feat: stub ship-merges-main case"

cat > .scratch/ship-merges-main/issues/01-ship-merges-main.md <<'MD'
# Ship merges main

Status: needs-alignment

## Goal
A branch ships up to date with main.

## Interface
Approved. The case is `evals/ship-merges-main/`, with `case.yaml` and `prompt.md` committed. Its one grader goes at `evals/ship-merges-main/graders/says-merged-main.md`.

## Behaviour
- Ship's final message says `Merged main into` and the branch name.

## Out of scope
Resolving merge conflicts.

## Decisions
- 2026-10-30 Q: What does the final message say? → A: The literal words `Merged main into` followed by the branch name, e.g. `Merged main into feat/ship-merges-main.`

## Comments
MD

git add .scratch/ship-merges-main/issues/01-ship-merges-main.md
commit "docs: add ship-merges-main spec"
