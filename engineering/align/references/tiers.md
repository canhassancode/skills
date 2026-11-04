# Tiers

Two questions set the route: does it fit one session, and does anyone know enough to spec it? Size decides parent or child; uncertainty decides whether to explore first.

|  | Known | Foggy |
|---|---|---|
| **Fits one session** | Child spec → interface → tests | Explore, then a child spec |
| **Bigger** | Parent spec → `/cut` | Explore, then a parent spec |

Above the grid: **a one-sentence diff** needs no plan. Say so and stop.

## Medium

The medium, what the change is made of, decides what proves it.

| Medium | Proved by | Align does | Ends at |
|---|---|---|---|
| **Code**: app code, scripts, hooks | locked tests, written first | spec → interface → `/tester` → lock | `ready-to-build` → `/build` |
| **Prose and settings**: skills, docs, config | crucible's review | spec | applied in the session on the user's go, then crucible, one fix round and a ready pull request; or `ready-to-build` → build's light route |

A change that touches both is code. Prose and settings get no interface and no locked tests: a test of prose checks that a file says what it says.

## Size

A child fits one session when:

- it is one capability a user or caller could notice on its own;
- its behaviour fits in about six lines;
- it adds to at most one public interface and one port;
- it is roughly 1–3 human-hours of work.

Anything bigger is a parent. A parent's children are vertical: each one is observable alone, never a layer.

## Uncertainty

It is foggy when the spec would rest on something nobody has seen. Each unknown takes one route:

| The unknown is | Route | Returns |
|---|---|---|
| how something behaves when run: an API, a library, our own system | `/spike` | the answer and its evidence; the code is thrown away |
| a fact written down somewhere: docs, standards, prior art | `/research` | a sourced note |
| a shape the user must see to judge: a UI, a state model, a flow | `/prototype` | a throwaway to react to, with the user's verdict |

Each route gets one question and returns one answer, which lands in Decisions. A question that can't be put in one sentence isn't ready for a route — grill it first.

## Evidence

- The one-sentence rule: Claude Code best practices, "if you could describe the diff in one sentence, skip the plan".
- Session size: METR's 80% time horizon, about 1–3 human-hours for 2026 frontier models; success falls with file count (SWE-bench Pro).
- One feature per session: Anthropic, *Effective harnesses for long-running agents*, Nov 2025.
- The uncertainty axis and the grid are synthesis, not measured.
- The medium axis: on skill prose the loop cost about 3x a direct change, plus $2–48 of evals per build, and its useful catches came from crucible reading the diff; on code it cost about 2.8x and caught authorisation and validation bugs before merge (#179, measured on: transcripts and git, 2026-10-01 to 2026-11-04). Error analysis before evals for prompts: Husain and Shankar; no evals in mattpocock/skills (`docs/research/process-tiering-for-agent-builds.md`).
