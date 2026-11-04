---
created: 2026-11-04
question: How much upfront spec-and-test rigour pays off for AI-agent-built changes, and how should process be tiered by change type and size, especially for prompt/skill changes versus code changes?
---

# Process tiering for agent builds

Read alongside [`engineering/align/references/tiers.md`](../../engineering/align/references/tiers.md). Its sources (the one-sentence rule, METR time horizons, SWE-bench Pro, *Effective harnesses*) are not repeated here.

## Short answer

- **Code:** tests given to the model up front improve its output measurably, and that justifies locked tests for code. But passing tests is a weak proxy for "mergeable", so review still has to happen after the tests go green. Telling the agent to "do TDD", with no tests in hand, made results worse in the one study that measured it.
- **Prompts and skills:** the main practitioner sources say *error analysis first, then targeted evals*. They do not say "write evals before every change". Anthropic's skill guidance does put evals first for a **new** skill, but only three scenarios, run against a no-skill baseline. Of the popular skill repos, only obra/superpowers says "test first for every edit", and its own reference contradicts that. Its slow behavioural evals are kept out of PR gating.
- **Tiering:** DORA's evidence favours small batches and extra scrutiny for *risky* changes only. Uniform heavyweight gates bring no measured stability gain and slow delivery down.

## 1. Test-first and spec-first for LLM coding

| Finding | Number | Source |
|---|---|---|
| Putting tests in the prompt (GPT-4, function-level) | MBPP 69.67% → 82.45%; HumanEval 78.66% → 87.81%. A remediation loop that feeds back failing tests adds about 5 points more (87.71%, 93.30%) | Mathews & Nagappan, *Test-Driven Development for Code Generation*, ASE '24, [arXiv 2402.13521](https://arxiv.org/html/2402.13521v1), Table II |
| "Do TDD" instructions with **no** targeted tests, given to a SWE-bench agent | Regressions rose from 6.08% (vanilla) to 9.94%, worse than doing nothing. Telling the agent *which tests to check* cut regressions to 1.82% | Alonso et al., *TDAD*, [arXiv 2603.17973](https://arxiv.org/abs/2603.17973) (preprint; Qwen3-Coder 30B, 100 instances) |
| A plan before the code | Up to +25.4% relative Pass@1 over direct generation, and +11.9% over chain-of-thought | Jiang et al., *Self-planning Code Generation*, [arXiv 2303.06689](https://arxiv.org/abs/2303.06689) |
| Passing tests is not the same as mergeable (small sample) | Claude 3.7 Sonnet passed the human tests on 38% of runs. **0 of 15** reviewed PRs were mergeable. Even the passing ones needed about 26 minutes of fixing, mostly for test coverage, docs and lint | METR, [*Algorithmic vs. Holistic Evaluation*](https://metr.org/blog/2025-08-12-research-update-towards-reconciling-slowdown-with-time-horizons), Aug 2025 |
| Passing tests is not the same as mergeable (296 PRs, 4 maintainers) | Maintainer merge rates ran **24.2 points** below the SWE-bench grader. The implied time horizon for Sonnet 4.5 drops from about 50 minutes to about 8 | METR, [*Many SWE-bench-passing PRs would not be merged*](https://metr.org/notes/2026-03-10-many-swe-bench-passing-prs-would-not-be-merged-into-main/), Mar 2026 |
| A process that feels fast may not be fast | Experienced OSS developers were **19% slower** with early-2025 AI, yet believed they were 20% faster | METR, [RCT, Jul 2025](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) |

What follows:
- Tests the agent can execute help it. Procedural instructions without tests can hurt (TDAD).
- The tests do not cover what reviewers reject: quality, coverage, docs (METR ×2). So a post-green review gate like crucible or shepherd is supported by evidence, not ceremony.
- Anthropic's agent guidance agrees on mechanism: code "is verifiable through automated tests" and agents "can iterate on solutions using test results as feedback". Its general rule is to add complexity "only when it demonstrably improves outcomes" ([*Building effective agents*](https://www.anthropic.com/engineering/building-effective-agents)).
- The METR RCT is a warning about self-assessment. "The heavy pipeline feels slow" and "the heavy pipeline feels safe" both need measuring, for example wall-clock time and escaped defects per tier.

## 2. Evals for prompts and skills: before the change, or after error analysis?

**Hamel Husain and Shreya Shankar** ([Evals FAQ](https://hamel.dev/blog/posts/evals-faq/)):
- On writing evals before changes: "Generally no". It "creates more problems than it solves". It works only "for specific constraints where you know exactly what success looks like".
- "Start with error analysis, not infrastructure." "Write evaluators for errors you discover, not errors you imagine." Review at least 100 traces.
- "Fix these obvious gaps first before building complex evaluation infrastructure." "Only build expensive evaluators for problems you'll iterate on repeatedly."
- Evals "often cost considerably more than unit tests to maintain and run".
- For CI: "favor assertions or other deterministic checks over LLM-as-judge". Retire saturated evals, because "if the eval passes all examples, it's giving you no new information".
- The underlying reason is **criteria drift**: "users need criteria to grade outputs, but grading outputs helps users define criteria" (Shankar et al., *Who Validates the Validators?*, [arXiv 2404.12272](https://arxiv.org/abs/2404.12272)). Graders locked before any output has been seen tend to encode imagined criteria.

**Anthropic, skill authoring** ([best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)):
- "Create evaluations BEFORE writing extensive documentation."
- The loop: identify gaps by running *without* the skill, build **three** scenarios, measure a baseline, write minimal instructions, iterate.
- For existing skills the doc switches to observation: "Give Claude B ... actual tasks, not test scenarios", observe, refine.
- The checklist asks for "at least three evaluations".
- This is error analysis first. The gaps come from observed runs, not from a spec.

**Anthropic, agent evals** ([*Demystifying evals for AI agents*](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)):
- "20-50 simple tasks drawn from real failures is a great start."
- It separates *capability* evals, which start at a low pass rate, from *regression* evals, which should sit near 100%. Capability evals graduate into the regression set.
- Its grader rule: "deterministic graders where possible, LLM graders where necessary". It also says "Read the transcripts!"

**OpenAI** ([evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices)):
- "Adopt eval-driven development: Evaluate early and often."
- "Log everything ... so you can mine your logs for good eval cases."
- It lists "vibe-based evals" as an anti-pattern. It does not require an eval per change.

**anthropics/skills, `skill-creator`** ([SKILL.md](https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md)):
- Test prompts are written "after writing the skill draft", 2–3 of them. Assertions are drafted while the first runs execute.
- The baseline is "no skill" for a new skill and the old version for an edit.
- "Subjective skills ... often don't need" assertions, and informal iteration is allowed.

**mattpocock/skills** (upstream `4ae2317`, checked with `git ls-tree`):
- No eval or test files apart from `tdd/tests.md`.
- `writing-for-agents` settles no-op disputes "by running the document, not by debate". That is manual and run-based, not test-first.

**obra/superpowers:**
- The claim is verified. `writing-skills` says "Writing skills IS Test-Driven Development applied to process documentation", "NO SKILL WITHOUT A FAILING TEST FIRST", and that this "applies to NEW skills AND EDITS", with "No exceptions".
  - RED is a subagent run *without* the skill, under a pressure scenario. GREEN is the same run with the skill.
- Its own `references/testing-skills-with-subagents.md` contradicts the "no exceptions" line. It says "Don't test: Pure reference skills ... Skills without rules to violate ... Skills agents have no incentive to bypass."
- In practice ([docs/testing.md](https://github.com/obra/superpowers/blob/main/docs/testing.md)), behavioural evals sit in a separate eval lab with 94 scenarios in `prime-radiant-inc/superpowers-evals`. They are "slow (3-30+ minutes each)". Only static gates are safe for PR CI, and the stated direction is "static gates on PR, live sweep nightly + on-demand".

**Why a one-line prompt tweak is not automatically zero-risk:**
- Meaning-preserving formatting changes moved accuracy by up to **76 points**, and the sensitivity persists with model size and instruction tuning (Sclar et al., [arXiv 2310.11324](https://arxiv.org/abs/2310.11324); few-shot classification, so it transfers only loosely to SKILL.md).
- That argues for re-running *existing* cheap regression cases on a wording change. It does not argue for writing new ones first.

**Verdict:** across the sources the consensus is to run the change first, then do error analysis on real traces, then write targeted evals and promote them to regression.
- Eval-first is endorsed in a narrow form: a new skill, built from observed baseline failures, with about three scenarios.
- No source except superpowers' headline rule asks for locked evals before every prose edit, and superpowers does not gate PRs on them.

## 3. Tiering and risk-based gating

- **Small batches.** Work in "hours to a couple days"; "any batch ... longer than a week ... is too big". AI adoption "often leads to increased software delivery instability", and small batches act "as a critical countermeasure". The page adds that review load per line of machine code "may be higher" ([DORA, *Working in small batches*](https://dora.dev/capabilities/working-in-small-batches/)).
- **Heavyweight approval.** It has "a negative impact on software delivery performance". DORA found "no evidence ... that a more formal, external review process was associated with lower change fail rates". Its recommendation is to "detect and flag high risk changes early on so that they can be subjected to additional scrutiny", rather than treat every change the same ([DORA, *Streamlining change approval*](https://dora.dev/capabilities/streamlining-change-approval/)).
- **Appetite.** Shape Up sets "the amount of time we want to spend on a project, as opposed to an estimate", with "fixed time, variable scope" ([Shape Up ch. 3](https://basecamp.com/shapeup/1.2-chapter-03)). Applied here, each tier would get a cost cap, and scope gets cut to fit it. The repo already does this for evals with the $5 build cap in `CLAUDE.md`.
- **Testing trophy.** "The more your tests resemble the way your software is used, the more confidence they can give you." Testing is framed as return (confidence) on investment (time) ([Kent C. Dodds](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)). For skills, the "integration test" is a real agent run on a realistic task. Static checks such as frontmatter, links and word budget are the cheap base, which matches superpowers' static PR gates.

What decides the heavy gate in these sources: risk (blast radius and how reversible the change is), whether the failure mode is already known, and how cheap verification is. Change size alone does not decide it.

## 4. Mutation testing cost and benefit (Google)

- **Diff-scoped by design.** It runs only on covered, changed lines, with **one mutant per line**, a cap of 7× the files in the changelist, and suppression of "arid" nodes (code where mutants are rarely useful). The median generated mutants per changelist falls from 820 to 77 (one per line) to **7**. Findings must surface while the review is still open ([Petrović et al., *Practical Mutation Testing at Scale*, arXiv 2102.11378](https://arxiv.org/abs/2102.11378)).
- **Signal quality.** Developers first rated 85% of mutants unproductive. Filtering raised the productive share "from 15% to 89%", and 82% of mutants that got feedback were rated productive. Across 776,740 changelists, 16.9M mutants were generated and 2.1M surfaced. Feedback rate was low (66,798 responses).
- **Effect on tests.** Developers exposed to mutants write more tests and better ones, and mutants are coupled with real high-priority faults (Petrović et al., *Does mutation testing improve testing practices?*, ICSE 2021, [arXiv 2103.07189](https://arxiv.org/abs/2103.07189)).
- **Applied here.** The evidence supports crucible's diff-scoped mutation on **code**. It says nothing about mutating prose. `CLAUDE.md` already excludes skill prose from mutation, which is consistent with this.

## Implications for this pipeline

Proposed tiers. Each claim is tagged with its source, or marked **[synthesis]**.

**A. One-line skill tweak** (wording, a pointer, a typo, an example):
- No align, no tester, no new eval. A trivial diff needs no plan (tiers.md), and "fix obvious gaps first" (Hamel).
- Run the static gates (frontmatter, links, the `plugin.json`/README sync), plus the touched skill's **existing** locked regex/tool_used cases at `--runs 1`. Wording can matter (Sclar), and deterministic checks are cheap enough for every change (Hamel). Skip the cases if the line isn't behaviour-bearing **[synthesis]**.
- Commit directly. No crucible mutation (`CLAUDE.md`), no shepherd **[synthesis]**.

**B. Data-driven skill change** (a fix for a failure seen in a real session or trace):
- The trace *is* the error analysis. Turn it into one capability case that fails on `main` and passes on the branch. Here test-first costs almost nothing, because the failure already exists (Anthropic skill best practices step 1; *Demystifying evals*; superpowers RED baseline).
- Skip align's red team and interface. Run crucible's lock check, walk and consumer grep, but not mutation. Run only the touched cases and that skill's tag at hand-back (`CLAUDE.md` spend rule) **[synthesis]**.
- After it is green, the case joins the regression set (*Demystifying evals*). Retire cases that stay saturated and never catch anything (Hamel).

**C. New skill:**
- Run a light align on trigger and description, the branches, and the one job. Then run 2–3 realistic tasks **without** the skill to find the gaps (Anthropic best practices; skill-creator).
- Draft the skill, then run the same tasks with it. Lock regex/tool_used graders only **after** reading the first transcripts (skill-creator drafts assertions during runs; criteria drift, Shankar). Do **not** run `tester` before any draft exists.
- Leave subjective skills on qualitative review (skill-creator). Registry and README updates as usual.

**D. Code feature:**
- Keep the full pipeline: align → tester → build → crucible → shepherd.
- Executable tests given up front raise pass rates (Mathews & Nagappan). Knowing *which* tests matter cuts regressions (TDAD). Planning first helps (Self-planning). Passing tests still leaves a mergeability gap, so the post-green review is justified (METR ×2). Diff-scoped mutation has the best measured cost/benefit (Google).
- Scale it by risk, not by habit (DORA change approval):
  - A one-sentence code diff skips to build plus crucible (tiers.md).
  - Shepherd's bot rounds earn their cost only on changes with a wide blast radius **[synthesis]**.

**Cross-cutting:**
- Never use "follow TDD" prose as a substitute for actual tests. It measurably raised regressions (TDAD).
- Give each tier an appetite (time and dollars), and record wall-clock time and escaped defects per tier. Then "too slow" becomes a measurement instead of a feeling (Shape Up; METR RCT perception gap) **[synthesis on the metric]**.
- Move slow model-judged skill evals out of the per-change path into an on-demand or nightly sweep, and keep only deterministic cases per change (superpowers `docs/testing.md`; Hamel on CI) **[synthesis for this repo]**.
