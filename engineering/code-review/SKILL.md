---
name: code-review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along five axes — Standards (does the code follow this repo's documented coding standards?), Spec (does the code match what the originating issue/PRD asked for?), Structure (does the change regress structure or miss a dramatically simpler shape?), Design (does UI code honour the repo's DESIGN.md and design system?), and Verification (does each test or gate actually measure what it claims, or pass green against nothing?). Runs the reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X".
---

Five-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / PRD / spec?
- **Structure** — does the change regress the structure it touches, or leave an obvious path to dramatic simplification unexplored?
- **Design** — does UI code honour the repo's `DESIGN.md` and the design system? Runs only when the diff touches a path with a `DESIGN.md` at or above it.
- **Verification** — does each test or gate the diff touches actually measure what it claims, or pass green against nothing? Runs only when the diff touches tests or gates.

The axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The issue tracker should have been provided to you — run `/bootstrap` if `docs/agents/issue-tracker.md` is missing.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here — not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.) — fetch via the workflow in `docs/agents/issue-tracker.md`.
2. A path the user passed as an argument.
3. A PRD/spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below — a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. The structure baseline

The Structure axis asks a different question from Standards: not "does the diff follow the rules?" but "did the change miss a dramatically simpler shape, or make the structure worse?" It favours restructurings that preserve behaviour while removing structure outright. Like the smell baseline, it is fixed and applies even when the repo documents nothing:

- **Eliminable structure** — prefer changes that remove entire branches, conditionals, or layers over polishing what's there.
- **File-size growth** — a file the diff pushes from below to above 1,000 lines needs architectural justification.
- **Scattered conditionals** — ad-hoc conditionals threaded through unrelated flows are a design problem wanting a dedicated abstraction, not more branches.
- **Type and boundary clarity** — unnecessary optionality, casts, or loosely-shaped objects where an explicit contract would hold the boundary.
- **Canonical-layer discipline** — feature logic leaking into shared paths; near-duplicates of utilities that already exist.
- **Atomic orchestration** — sequential flows where independent work could run in parallel with clearer structure.
- **The ladder** — every new abstraction, helper, or dependency in the diff must beat each rung above it: an existing in-repo pattern, the standard library, a native platform feature, an already-installed dependency, a one-liner.

Three rules bind it:

- **Diff-confined.** Findings apply only to code the diff touches. Structural opportunities in surrounding code are reported as observations, never prescribed — cleaning up untouched code is out of scope.
- **Regressions are hard, the rest is judgement.** A structural regression (the diff leaves structure worse than it found it) is a hard finding; a missed simplification is always a judgement call.
- **The repo overrides.** As with the smell baseline, a documented repo standard wins.

### 5. The design baseline

The Design axis runs **only when the diff touches a path with a `DESIGN.md` at or above it.** The nearest `DESIGN.md` upward governs, and the diff's path selects which surface profile in its `Surfaces` table applies. A backend-only diff skips this axis entirely — note the skip and move on.

When it does run, the baseline is fixed and greppable:

- **Raw values** — a hex code, rgb value, or off-scale spacing anywhere outside the token layer.
- **Missing states** — an interactive element without all four of default, hover, active/pressed, disabled. Inputs additionally need focus and error-with-message.
- **Unguarded motion** — any animation without a `prefers-reduced-motion` branch.
- **Misrouted animation** — GSAP on something a CSS transition covers (hover, press, focus, a simple slide). GSAP earns its place on timelines, staggered entrances and scroll-driven sequences only.
- **Motif breaches** — code contradicting a motif in `DESIGN.md`, or introducing a look that should have been a motif and wasn't written back.
- **System breaches** — anything contradicting `design-system/SYSTEM.md`: icon size not matching adjacent line-height, type above the surface's ceiling, a flat scrim over an image, shadows that read as strong, dark-mode depth built from shadows instead of a lighter surface.

Two rules bind it:

- **`DESIGN.md` overrides.** Where the repo's file makes a deliberate exception, it wins over the baseline.
- **The first four are hard; the last two are judgement.** A raw hex is a violation. "This should have been a motif" is an observation.

### 6. The verification baseline

The Verification axis asks the one question the other four structurally omit: **does a test or gate actually measure the thing it claims, or is it green against nothing?** A test can follow every standard, match the spec, and keep the structure clean while asserting on fiction — green tells you nothing until you know it can go red. It runs **only when the diff touches tests or gates** (test files, CI config, guard/check scripts); a diff with neither has nothing to verify — note the skip and move on. Like the other baselines it is fixed and applies even when the repo documents nothing:

- **Mocked subject** — a test that mocks or stubs the very thing under test, so the assertion passes without the real code ever running. → test the real unit; mock only its collaborators.
- **Fictional fixture** — a fixture, snapshot, or expectation referencing data the real source never produces: a field, record, or shape absent from the actual upstream. → derive fixtures from a real sample; assert on what the source actually emits.
- **Hollow gate** — a check that prints PASS having measured nothing: no assertion, a swallowed error, a trailing `|| true`, a guard that exits `0` before the thing it guards runs. → apply the positive control (below); a gate that can't go red guards nothing.
- **Unfalsifiable assertion** — an assertion that cannot fail: `expect(true)`, asserting on a mock's own return value, a tolerance so wide any value passes. → tighten it until a wrong value goes red.

Two rules bind it:

- **Positive-control is the hard test.** The mechanical version of every finding: mutate the code under test (or the code the gate defends); if the check stays green, it has measured nothing — a **hard** finding. The same smell *without* a demonstrated green-on-broken ("this mock probably hides the real behaviour") is a **judgement** call.
- **Distinct from Standards.** Standards asks whether a test is *well-written*; Verification asks whether it *measures anything*. A test can be clean and hollow at once — report the hollowness here, never on the Standards axis.

### 7. Spawn the sub-agents in parallel

Send a single message with one `Agent` tool call per active axis. Use the `general-purpose` subagent for each.

**Standards sub-agent prompt** — include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full — the sub-agent has no other access to it.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

**Structure sub-agent prompt** — include:

- The diff command and commit list.
- **The structure baseline from step 4 pasted in full, including its three binding rules** — the sub-agent has no other access to it.
- The brief: "Report, structural regressions first, missed simplifications second: every place the diff regresses structure or leaves an obvious path to dramatic simplification unexplored. Name the baseline standard and quote the hunk. Confine findings to code the diff touches; note opportunities in surrounding code as observations only. Distinguish regressions (hard) from simplifications (judgement calls). Under 400 words."

**Design sub-agent prompt** — include:

- The diff command and commit list.
- The path of the governing `DESIGN.md` and the surface profile the diff falls under.
- **The design baseline from step 5 pasted in full, including its two binding rules** — the sub-agent has no other access to it.
- The brief: "Read the `DESIGN.md` at the given path first. Report, hard violations first: every raw value outside the token layer, every interactive element missing a required state, every motion without a reduced-motion branch, every GSAP tween on something CSS covers. Then, as judgement calls: motif breaches and system breaches. Quote the hunk for each finding and name the rule. Under 400 words."

**Verification sub-agent prompt** — include:

- The diff command and commit list.
- **The verification baseline from step 6 pasted in full, including its two binding rules** — the sub-agent has no other access to it.
- The brief: "Report, hollow gates and mocked subjects first (hard where a positive control would stay green), then judgement calls: every test that mocks the thing under test, every fixture or expectation referencing data the real source never produces, every gate that prints PASS having measured nothing, every assertion that cannot fail. For each, quote the hunk and name the rule; where you can, state the positive control — the change to the code under test that *should* turn the check red but wouldn't. Do not re-report Standards smells: confine findings to whether the test or gate measures anything. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report. If no `DESIGN.md` governs the diff, skip the Design sub-agent and note the skip. If the diff touches no tests or gates, skip the Verification sub-agent and note the skip.

### 8. Aggregate

Present the reports under `## Standards`, `## Spec`, `## Structure`, `## Design`, and `## Verification` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings — the axes are deliberately separate (see _Why separate axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

### 9. Write the verdict

The review's outcome is a deterministic artefact the pre-PR gate (`gauntlet-pr-gate.sh`) consumes: a PR cannot open until a clean verdict exists for the exact commit being shipped. After aggregating, write it — pass **or** fail — keyed to the current HEAD.

**Clean = zero hard findings** across the axes that ran. Each axis already labels its findings hard vs judgement — documented-standard breaches, structural regressions, the first four Design violations, and positive-control-proven hollow tests are hard; baseline smells, missed simplifications, motif/system breaches, and merely-suspected Verification issues are judgement calls that are advisory and do **not** block. For Spec, treat a missing or incorrectly-implemented requirement as hard and scope creep as judgement.

Resolve the repo and HEAD, then write the artefact (the `.gauntlet/` directory is globally gitignored — do not add a per-repo ignore rule):

```bash
root=$(git rev-parse --show-toplevel)
sha=$(git rev-parse HEAD)
mkdir -p "$root/.gauntlet"
jq -n --arg sha "$sha" --arg fp "<the fixed point pinned in step 1>" \
      --argjson clean <true|false> --argjson hard <hard-finding count> \
  '{sha:$sha, fixedPoint:$fp, clean:$clean, hardFindings:$hard, reviewedAt:(now|todateiso8601)}' \
  > "$root/.gauntlet/verdict-$sha.json"
```

Report the path written and whether it is clean; a clean verdict for `HEAD` is what unblocks `gh pr create`, and any new commit or amend changes the SHA and needs a fresh review. **Never fabricate a clean verdict** — the SHA key and the recorded `hardFindings` count make a false pass auditable, and a blocker that escapes to the opened PR is a harness bug the retro answers with a new guard or axis, not a prompt tweak.

## Why separate axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**
- Code that follows every convention and matches the spec, but adds a layer or branching the design didn't need → **Standards pass, Spec pass, Structure fail.**
- Code that is clean, correct and minimal, but hardcodes a colour and ships a button with no disabled state → **everything else passes, Design fails.**
- Code that is clean, correct, minimal and well-designed, shipping green tests — but the tests mock the very thing they claim to check, so the green measures nothing → **everything else passes, Verification fails.**

Reporting them separately stops one axis from masking another.
