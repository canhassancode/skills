# Idea → spec → development with AI coding agents: what measurably works

Researched 2026-10-26. Every claim is linked inline and every source is dated. **[M]** means measured (an RCT, a benchmark, telemetry or a controlled ablation). **[S]** means a survey, i.e. self-report. **[P]** means a practitioner or vendor claim with no supporting data. Where a figure comes only from a secondary write-up, it is marked *unverified*.

---

## TL;DR: the recommended cycle

1. **Size before you spec.** If you can describe the diff in one sentence, skip the spec and the plan ([Claude Code docs, undated, read 2026-10](https://code.claude.com/docs/en/best-practices)) [P]. Otherwise cut the work until each piece fits inside the agent's **80% reliability horizon**, not its 50% headline. For frontier models in 2026 that is roughly **1–3 human-hours** per unit ([METR TH1.1 data](https://metr.org/time-horizons/)) [M].
2. **Small spec = goal, context, constraints, out-of-scope, and a runnable "done when".** Short and well-scoped beats long: shorter, well-scoped Copilot issues are the ones that get merged ([Sayagh, Dec 2025](https://arxiv.org/abs/2512.21426)) [M], and focused ~300-token prompts beat ~113k-token prompts on every model tested ([Chroma, Jul 2025](https://www.trychroma.com/research/context-rot)) [M].
3. **Separate thinking from typing.** Do research and planning in plan mode or a separate session, then implement in a fresh session ([Claude Code docs](https://code.claude.com/docs/en/best-practices)) [P]. **Review the plan**, because "a subpar plan hurts performance even more than no plan at all" ([Liu et al., Apr–Aug 2026](https://arxiv.org/abs/2604.12147)) [M].
4. **The oracle is a test a human wrote or vetted.** TDFlow resolves **94.3%** of SWE-bench Verified with human-written tests, against **68.0%** with LLM-written tests ([Han et al., Oct 2025](https://arxiv.org/html/2510.23761v1)) [M]. Lock the tests against edits: agents delete or rewrite failing tests ([Beck, Jun 2025](https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes); [Anthropic, Nov 2025](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) [P].
5. **Passing tests is not the same as done.** In METR's sample, **0** of the reviewed agent PRs were mergeable as-is, even though 38% passed the tests ([METR, Aug 2025](https://metr.org/blog/2025-08-12-research-update-towards-reconciling-slowdown-with-time-horizons)) [M]. Add end-to-end checks plus a separate evaluator running in fresh context.
6. **Multi-session work runs on persisted artifacts.** That means a product-level spec, a JSON feature list with a `passes` flag, a progress log, git commits, and **one feature per session** ([Anthropic, Nov 2025](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents); [OpenAI ExecPlans, Oct 2025](https://developers.openai.com/cookbook/articles/codex_exec_plans)) [P].
7. **Specify behaviour and boundaries, not patterns.** Repo context files cut success by 0.5–2 points and raise cost by about 20% ([Gloaguen et al., Feb 2026](https://arxiv.org/abs/2602.11988)) [M]. Anthropic's planner deliberately avoids granular technical detail ([Anthropic, Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)) [P].
8. **Keep the ceremony proportional.** Full SDD toolchains (Spec Kit, Kiro) are criticised as overkill for small changes and tedious to review ([Böckeler, Oct 2025](https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html); [Thoughtworks Radar "Assess", Nov 2025](https://www.thoughtworks.com/radar/techniques/spec-driven-development)). No controlled study shows full SDD beating lighter workflows ([de Macedo, Jun 2026](https://arxiv.org/abs/2606.04967)).

---

## 1. Small-session shape: one idea → small spec → one agent session

### How big can one session's task be? The evidence

**The METR time horizon is the best measured proxy [M].** Below are METR's own TH1.1 numbers, parsed from the dataset behind [metr.org/time-horizons](https://metr.org/time-horizons/) (page last updated 2026-09-08 and no longer actively maintained). Horizons are in human-expert minutes.

| Model (release) | 50% horizon | 80% horizon |
|---|---|---|
| Claude 3.7 Sonnet (Feb 2025) | 60 min | 12 min |
| GPT-5 (Aug 2025) | 203 min | 38 min |
| Claude Opus 4.5 (Nov 2025) | 293 min | 49 min |
| GPT-5.2 (Dec 2025) | 352 min | 66 min |
| Claude Opus 4.6 (Feb 2026) | 719 min (~12 h) | 70 min |
| Gemini 3.1 Pro (Feb 2026) | 384 min | 90 min |
| Claude Mythos Preview (Apr 2026) | 1,045 min (~17 h) | 186 min (~3 h) |

- **The 80% horizon runs 5–10× shorter than the 50% horizon.** If you want a session you can walk away from, size it against the 80% column.
- METR states that "measurements above 16 hrs are unreliable with our current task suite" ([METR](https://metr.org/time-horizons/)).
- The doubling time since 2023 is **128.7 days** (CI 104–158) on TH1.1. The all-time stitched figure is 188 days. The original 2025 paper said ~7 months ([Kwa et al., Mar 2025](https://arxiv.org/abs/2503.14499)).
- **Caveat:** the tasks are self-contained and algorithmically scored. Real repositories are messier (see METR's mergeability finding below).

**Vendor sizing rules [P]:**
- Devin: "if a task would take you three hours or less, Devin can most likely do it"; split anything larger into focused sessions ([Devin docs, read 2026-10](https://docs.devin.ai/essential-guidelines/when-to-use-devin.md)).
- Codex: "Keep one chat per coherent unit of work" ([OpenAI Codex best practices, read 2026-10](https://learn.chatgpt.com/guides/best-practices)).
- Amp: "the best threads are short, they do one thing". One feature was built across 13+ threads averaging ~80k tokens ([Metcalf/Amp, Dec 2025](https://ampcode.com/notes/200k-tokens-is-plenty)).

**Benchmarks by task size [M]:**
- **SWE-bench Verified is mostly small work.** 39% of tasks are under 15 minutes (average gold patch ~5 lines) and 52% take 15–60 minutes (~14 lines). Only 8% take 1–4 hours (~50 lines) ([Epoch AI, Jun 2025](https://epoch.ai/blog/what-skills-does-swe-bench-verified-evaluate)).
- METR found those annotator time estimates "too optimistic" ([same source](https://epoch.ai/blog/what-skills-does-swe-bench-verified-evaluate)).
- **SWE-bench Pro is bigger work.** Reference patches average **107.4 lines across 4.1 files**. Success is "relatively stable on single-file problems but decline[s] sharply as file count increases". The best public-set score was 43.6% in Nov 2025 and the best commercial-set score was 17.8% ([Scale AI, v2 Nov 2025](https://arxiv.org/html/2509.16941v2)).
- **Leaderboard scores have climbed since.** Aggregators report ~80% on Pro by mid-2026, but setups differ (*unverified*, [BenchLM](https://www.benchlm.ai/benchmarks/swePro)).

### Context length and spec length

- **Context rot [M]** ([Chroma, Jul 2025](https://www.trychroma.com/research/context-rot)):
  - 18 models and 194,480 calls. Performance degrades as input grows, even on trivial tasks.
  - Semantically similar distractors hurt more than length alone.
  - On LongMemEval, focused prompts (~300 tokens) beat full prompts (~113k tokens) for **all** models.
- **Instruction density [M]** ([IFScale, Jul 2025](https://arxiv.org/abs/2507.11538)):
  - The best frontier models reached only **~68% accuracy at 500 simultaneous instructions**.
  - Models showed a bias towards earlier instructions. Degradation was threshold-shaped for reasoning models and linear or exponential for others.
  - **Implication for specs:** every added rule competes with every other rule.
- **Vendor guidance follows the same line [P]:**
  - "LLM performance degrades as context fills" ([Claude Code docs](https://code.claude.com/docs/en/best-practices)).
  - Context is "a finite resource with diminishing marginal returns" ([Anthropic, Sep 2025](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
  - HumanLayer targets **40–60% context utilisation** ([Horthy, Aug 2025](https://www.humanlayer.dev/blog/advanced-context-engineering)) [P, no data].

### Underspecification

- Agents "struggle to distinguish between well-specified and underspecified instructions". Interaction recovers up to 80–89% of fully-specified performance for Claude models ([Ambig-SWE, v3 Feb 2026](https://arxiv.org/html/2502.13069v3)) [M].
- An uncertainty-aware clarify-or-proceed scaffold reaches **69.4%** on underspecified SWE-bench Verified ([Edwards & Schuster, Mar–Sep 2026](https://arxiv.org/abs/2603.26233)) [M].
- On SWE-RPG (163 tasks, Aug 2026), failing to recover **implicit requirements** is the main bottleneck, accounting for **24.5–46.0%** of runs. The average resolve rate is 31.5% ([Zhou et al., Aug 2026](https://arxiv.org/abs/2608.09072)) [M].
- **Implication:** the spec's main job is to make implicit requirements explicit, or to make the agent ask about them.

### What a good small spec contains

The sources converge on these elements:

| Element | Source |
|---|---|
| Goal: what you are changing | Codex "Goal / Context / Constraints / Done when" ([OpenAI](https://learn.chatgpt.com/guides/best-practices)) [P] |
| Context: files, interfaces, an existing pattern to copy | "name the files and interfaces involved" ([Claude Code docs](https://code.claude.com/docs/en/best-practices)); "hints about the relevant artifacts" correlate with merges ([Sayagh 2025](https://arxiv.org/abs/2512.21426)) [M, correlational] |
| Constraints and **out of scope** | "state what is out of scope" ([Claude Code docs](https://code.claude.com/docs/en/best-practices)) [P] |
| Acceptance: a runnable check, ideally concrete examples | "Give Claude a check it can run" ([Claude Code docs](https://code.claude.com/docs/en/best-practices)); "Tasks with test suites, CI checks, or verifiable outcomes yield the best results" ([Devin](https://docs.devin.ai/essential-guidelines/when-to-use-devin.md)) [P] |
| End-to-end verification step | "end with an end-to-end verification step that proves the feature works" ([Claude Code docs](https://code.claude.com/docs/en/best-practices)) [P] |
| Open questions marked, not guessed | `[NEEDS CLARIFICATION: …]` ([Spec Kit spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md)) [P] |

On spec length, GitHub's guidance is "Copilot works best with clear, well-scoped tasks" ([GitHub docs, read 2026-10](https://docs.github.com/en/copilot/tutorials/cloud-agent/get-the-best-results)) [P]. Sayagh's data adds that **shorter** issues correlate with merged PRs, and that external references (config, dependencies, external APIs) correlate with *lower* merge rates (model AUC 72%; [Dec 2025](https://arxiv.org/abs/2512.21426)) [M, correlational].

---

## 2. Multi-session shape: persisted spec across sessions

### What each pass looks like in the main practices

| Practice | Passes | Persisted artifacts | Evidence class |
|---|---|---|---|
| **Anthropic long-running harness** (Nov 2025) | Initialiser session → N coding sessions, one feature each | `init.sh`, `claude-progress.txt`, JSON feature list (200+ features for a claude.ai clone, all starting as failing), git | [P] ([source](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) |
| **Anthropic planner/generator/evaluator** (Mar 2026) | Planner expands a 1–4 sentence prompt into a product spec → generator → evaluator (Playwright) against agreed "sprint contracts" | spec, contract files | [P] with costs ([source](https://www.anthropic.com/engineering/harness-design-long-running-apps)) |
| **HumanLayer research → plan → implement** (Aug 2025) | Research doc → plan (phases, files, verification per phase) → implement phase by phase, compacting status back into the plan | research.md, plan.md | [P] ([source](https://www.humanlayer.dev/blog/advanced-context-engineering)) |
| **Claude Code explore → plan → code → commit** | Plan mode, editable plan, implement, commit. For big features: interview → SPEC.md → fresh session | SPEC.md, plan | [P] ([source](https://code.claude.com/docs/en/best-practices)) |
| **OpenAI ExecPlans / PLANS.md** (Oct 2025) | One living plan with mandatory Progress, Surprises & Discoveries, Decision Log, Outcomes & Retrospective sections | PLANS.md | [P] "more than seven hours from a single prompt" ([source](https://developers.openai.com/cookbook/articles/codex_exec_plans)) |
| **GitHub Spec Kit** (Sep 2025 →) | constitution → specify → (clarify) → plan → tasks → implement → converge | constitution.md plus a per-feature folder (8 files in Böckeler's test) | [P] ([repo](https://github.com/github/spec-kit), [blog](https://github.blog/2025-09-02-spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)) |
| **AWS Kiro specs** (2025 →) | requirements.md (user stories + EARS acceptance criteria) → design.md → tasks.md; property-based tests derived from acceptance criteria | `.kiro/specs/*` plus steering files | [P] ([Kiro PBT blog, Nov 2025](https://kiro.dev/blog/property-based-testing/)) |
| **BMAD** (v6.12 stable; v7 ETA Oct 2026) | Analyst → PM (PRD) → architect → story files → dev → QA; "the process sizes itself to the work" | PRD, architecture, story files | [P] ([repo](https://github.com/bmad-code-org/BMAD-METHOD)) |
| **Tessl** (Sep 2025 →) | Spec-as-source: `.spec.md` maps 1:1 to code files, and code is marked "GENERATED FROM SPEC" | per-file specs | [P]. Framework still in closed beta per a 2026 review (*unverified*) ([Böckeler](https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)) |

**Böckeler's taxonomy** gives you a vocabulary for choosing ([Oct 2025](https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)):
- **Spec-first:** written for the task, then discarded. Kiro and Spec Kit as she observed them.
- **Spec-anchored:** kept and maintained alongside the code.
- **Spec-as-source:** only the spec is edited. Tessl.

Marc Brooker (AWS) argues SDD means "pulling designs up", not "pulling designs up-front": the spec is the living artifact you iterate on ([Apr 2026](https://brooker.co.za/blog/2026/04/09/waterfall-vs-spec)) [P].

### What the measured evidence says about multi-pass structure

- **A plan helps only if it is good [M]** ([Liu et al., 21,120 SWE-agent trajectories, v3 Aug 2026](https://arxiv.org/abs/2604.12147)):
  - A standard plan improves resolution.
  - Periodic plan reminders reduce plan violations and raise success.
  - "A subpar plan hurts performance even more than no plan at all."
  - Adding mismatched early phases can *degrade* performance.
  - **This is the strongest measured argument for human review of the plan.**
- **Planning-agent ablation [M]:** removing the Planner from AgentForge drops it to "near the single-agent baseline" on 100 SWE-bench Lite tasks ([Apr 2026](https://arxiv.org/pdf/2604.13120)). Read from the search summary; table not checked.
- **Harness cost vs quality [P, with costs]** ([Anthropic, Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)):
  - Solo Opus 4.5 run: 20 min, $9, and the core mechanic was broken.
  - Full planner/generator/evaluator harness: 6 h, $200, and the result was playable.
  - Simplified V2 on Opus 4.6: 3 h 50 min, $124.70.
  - With Opus 4.6 they **dropped sprints** but kept the planner, because "without the planner, the generator under-scoped".
  - The evaluator "is worth its cost only when a task sits beyond what the model reliably does alone".
- **Spec quality correlates with fewer bug-fix commits [M, correlational]** ([EPIC framework, Oct 2026](https://arxiv.org/abs/2610.07534)):
  - Across 114 open-source SDD repos, the top third by spec quality (scored against ISO/IEC/IEEE 29148) spent **11.8%** of commits on bug fixes, against **20.4%** for the bottom third.
  - **No comparison with non-SDD workflows.**
- **No study benchmarks a complete SDD process against an ad-hoc baseline.** A June 2026 survey of Spec Kit, OpenSpec, BMAD, GSD, Spec Kitty and Reversa lists "a lack of benchmarks for the complete process" as an open risk ([de Macedo, Jun 2026](https://arxiv.org/abs/2606.04967)). A registered report designing exactly this kind of study (spec → tests → function) was accepted at SANER 2026, with no results yet ([Rosa et al., Jan 2026](https://arxiv.org/abs/2601.03878)).

### Slicing: vertical vs horizontal vs task lists

- **No controlled evidence either way.** Every source found is practitioner opinion.
  - Tracer bullets and vertical slices: "AI's natural inclination is to build big layers in isolation" ([AI Hero, updated Jan 2026](https://www.aihero.dev/tracer-bullets)) [P, one anecdote]. This author's skills are the upstream of the user's library, so this is not an independent view.
  - Anthropic's harness slices by **user-visible feature**, each with test steps, and works "on one feature only" per session. It calls this "critical" to stop the agent one-shotting the whole project ([Nov 2025](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) [P].
  - OpenAI ExecPlans want milestones that are "independently verifiable" ([cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans)) [P].
  - Kiro and Spec Kit generate **task lists** traced to requirement numbers, which in practice are often layer-ordered ([Böckeler](https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)).
- **Indirect evidence favours small, independently verifiable slices:**
  - Success falls with file count ([SWE-bench Pro](https://arxiv.org/html/2509.16941v2)) and with task length ([METR](https://metr.org/time-horizons/)) [M].
  - DORA 2025 frames AI as an amplifier of existing practices, such as small batches and version control ([Google Cloud, Sep 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)) [S]. I could not verify the full list of seven capabilities from the primary report.
  - Faros telemetry associates AI with **PR size +154%** and **review time +91%** ([Q2 2025](https://faros.ai/research)). Its 2026 report shows PR size +51% and median review time ×5 ([Q2 2026](https://faros.ai/research/ai-acceleration-whiplash)) [M, observational].
  - **Implication:** big slices create a review bottleneck.

### Fidelity mechanisms: keeping implementation faithful to the spec

| Mechanism | Evidence |
|---|---|
| **Human-written or vetted tests as oracle** | TDFlow: 94.3% (human tests) vs 68.0% (LLM tests) on SWE-bench Verified; 88.8% vs 61.0% best baseline on Lite; only 7 test-hacking cases in 800 runs ([Oct 2025 / EACL 2026](https://arxiv.org/html/2510.23761v1)) [M] |
| **Test immutability** | "It is unacceptable to remove or edit tests" plus JSON rather than Markdown, because the model is less likely to overwrite JSON ([Anthropic, Nov 2025](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) [P]; Beck lists "disabling or deleting tests" as a warning sign ([Jun 2025](https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes)) [P] |
| **End-to-end / browser verification** | Without it, Claude "often marked features complete without verifying them end-to-end"; Puppeteer "markedly improved results" ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) [P] |
| **Separate evaluator in fresh context** | Self-evaluation "tends to confidently praise the work" ([Anthropic, Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)); a reviewer subagent checks the diff against PLAN.md ([Claude Code docs](https://code.claude.com/docs/en/best-practices)) [P]. Counterpoint: Cognition's "share full context" ([Jun 2025](https://cognition.com/blog/dont-build-multi-agents)) |
| **Deterministic gates** (Stop hooks, `/goal`, CI) | Böckeler's "computational sensors are cheap and fast enough to run on every change" ([Apr 2026](https://martinfowler.com/articles/harness-engineering.html)) [P] |
| **Progress files, decision logs, git** | Anthropic progress file; ExecPlan mandatory sections ([cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans)) [P] |
| **Plan reminders** | Periodic reminders reduce plan violations and raise success ([Liu et al., 2026](https://arxiv.org/abs/2604.12147)) [M] |
| **Property-based tests from acceptance criteria** | Kiro derives "for any…" properties from acceptance criteria ([Kiro, Nov 2025](https://kiro.dev/blog/property-based-testing/)) [P]; PGS reports **23.1–37.3% relative** pass@1 gains over TDD-style refinement on HumanEval, MBPP and LiveCodeBench ([He et al., Jun 2025](https://arxiv.org/abs/2506.18315)) [M, function-level] |
| **Spec Kit `converge` / `analyze`, checklists** | Böckeler: agent still regenerated existing classes as duplicates despite the checklists ([Oct 2025](https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)) [P] |

**The ceiling on all of this is that tests passing does not mean mergeable.** METR measured it on 18 real issues ([Aug 2025](https://metr.org/blog/2025-08-12-research-update-towards-reconciling-slowdown-with-time-horizons)) [M]:
- 38% (±19%) of agent runs passed the maintainer tests.
- **None** of the reviewed PRs was mergeable as-is.
- Test-passing runs still needed **26 min** of human fixing on average.
- 100% of them lacked adequate test coverage.

The specific numbers come from a small sample; the direction is what matters. Böckeler adds: "Correctness is outside any sensor's remit if the human didn't clearly specify what they wanted" ([Apr 2026](https://martinfowler.com/articles/harness-engineering.html)).

---

## 3. Level of detail and testing

### How much low-level design belongs in the spec?

**Evidence against over-specifying:**
- **Repo context files [M]** ([Gloaguen et al., ETH/ICLR 2026, Feb 2026](https://arxiv.org/html/2602.11988v3)). Setup: Claude Code (Sonnet 4.5), Codex (GPT-5.2, GPT-5.1 mini) and Qwen Code, on SWE-bench Lite and CTXbench.
  - LLM-generated context files changed success by **−0.5 pts** and **−2 pts**, and cut performance in 5 of 8 settings.
  - Developer-written files gave **+2.4 pts**, which was not significant (p=0.21).
  - Both kinds raised cost by **~19–23%** and added 2.5–3.9 steps.
  - "Instructions in context files are well followed": agents obey, so every unnecessary instruction is real overhead.
  - The authors recommend describing only "minimal requirements", with non-standard practices being the useful content.
- **Anthropic's planner [P]:** Anthropic deliberately kept its planner off "granular technical" detail because spec errors cascade. It constrained deliverables and let the agents "figure out the path" ([Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)).
- **Instruction scaling [M]:** more rules means lower adherence per rule ([IFScale](https://arxiv.org/abs/2507.11538)).
- **Vendor guidance [P]:**
  - "For each line, ask: *Would removing this cause Claude to make mistakes?*" and exclude "anything Claude can figure out by reading code" ([Claude Code docs](https://code.claude.com/docs/en/best-practices)).
  - "A short, accurate AGENTS.md is more useful than a long file full of vague rules" ([OpenAI](https://learn.chatgpt.com/guides/best-practices)).

**Evidence for *some* technical detail:**
- Hints about relevant artifacts and "guidance on how to perform the implementation" correlate with merged Copilot PRs ([Sayagh 2025](https://arxiv.org/abs/2512.21426)) [M, correlational].
- Pointing at an existing pattern ("HotDogWidget.php is a good example") is the recommended way to convey style ([Claude Code docs](https://code.claude.com/docs/en/best-practices)) [P].
- HumanLayer plans name exact files and edits, because "a bad line of a plan could lead to hundreds of bad lines of code" ([Aug 2025](https://www.humanlayer.dev/blog/advanced-context-engineering)) [P, reasoning not data].
- Spec Kit splits the layers: the *spec* holds what and why, "avoid HOW"; the *plan* holds the tech choices ([spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md)) [P].

**Synthesis:**
- **Name:** interfaces, boundaries, files, out-of-scope and non-standard conventions.
- **Point at:** one existing pattern rather than naming an abstract pattern (e.g. "factory").
- **Leave out:** patterns the codebase already demonstrates and generic good practice.
- **Prescribe a pattern only when** it is non-standard for the repo or a hard constraint.

No source measured the effect of prescribing design patterns specifically. That remains an open question.

### Testing: TDD, test types, tests as oracle

- **Tests written first and fixed before implementation are the best-supported lever [M].** TDFlow's gap between human tests (94.3%) and LLM tests (68.0%) locates the bottleneck in *writing correct tests*, not passing them. The authors propose that "humans write tests and LLMs produce the fixes" ([Oct 2025](https://arxiv.org/html/2510.23761v1)).
- **The practitioner TDD loop is the same everywhere [P]:**
  - Write tests, confirm they fail, commit them, then implement without modifying them. Claude Code docs: "write a failing test that reproduces the issue, then fix it", and Writer/Reviewer split with "one Claude write tests, then another write code to pass them" ([docs](https://code.claude.com/docs/en/best-practices)).
  - Beck's red-green-refactor system prompt, used on a Rust/Python B+ tree over ~4 weeks. He was "good about the correctness & performance, not so good about the code quality" ([Jun 2025](https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes)).
  - Spec Kit's constitution: test-first is "NON-NEGOTIABLE", with integration tests against real dependencies preferred over mocks ([spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md)).
- **Test types:**
  - Anthropic found unit tests plus `curl` insufficient and browser end-to-end tests essential for web apps ([Nov 2025](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)) [P].
  - Property-based tests derived from acceptance criteria are the most promising way to turn prose requirements into an oracle ([Kiro](https://kiro.dev/blog/property-based-testing/); [PGS](https://arxiv.org/abs/2506.18315)) [M at function level only].
- **AI-generated tests are a weak oracle.** "This approach puts a lot of faith into the AI-generated tests, that's not good enough yet" ([Böckeler, Apr 2026](https://martinfowler.com/articles/harness-engineering.html)) [P]. The same 26-point gap appears in TDFlow [M]. METR found 100% of test-passing agent PRs had inadequate test coverage [M].

---

## 4. The numbers

| Claim | Figure | Source | Date | Class |
|---|---|---|---|---|
| Experienced OSS devs with AI (Cursor + Claude 3.5/3.7) were slower | **+19%** time; devs believed they were ~20% faster; 16 devs, 246 tasks | [METR](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) | Jul 2025 | M (RCT) |
| METR follow-up, late-2025 tools | Returning devs **−18%** time (CI −38% to +9%); new devs **−4%** (CI −15% to +9%); 57 devs, 800+ tasks; METR calls it an "unreliable signal", likely a lower bound because of selection (30–50% withheld tasks) | [METR](https://metr.org/blog/2026-02-24-uplift-update/) | Feb 2026 | M (flawed, per authors) |
| Google enterprise RCT | ~**21%** faster (96 vs 114 min), wide CI, n=96 | [Paradis et al.](https://arxiv.org/abs/2410.12944) | Oct 2024 / ICSE 2025 | M (RCT) |
| Test-passing ≠ mergeable | 38% pass tests; **0** reviewed PRs mergeable; 26 min fix time for passing runs | [METR](https://metr.org/blog/2025-08-12-research-update-towards-reconciling-slowdown-with-time-horizons) | Aug 2025 | M (small n) |
| Time-horizon growth | Doubling **128.7 days** since 2023 (TH1.1); Opus 4.6 p50 719 min / p80 70 min; Mythos Preview p50 1,045 / p80 186 min | [METR TH1.1](https://metr.org/time-horizons/) | 2026-09 | M |
| Context rot | All 18 models degrade with input length; focused (~300 tok) ≫ full (~113k tok) | [Chroma](https://www.trychroma.com/research/context-rot) | Jul 2025 | M |
| Instruction overload | ~**68%** adherence at 500 instructions (best models) | [IFScale](https://arxiv.org/abs/2507.11538) | Jul 2025 | M |
| AGENTS.md / CLAUDE.md effect | LLM-generated −0.5 / −2 pts; dev-written +2.4 pts (n.s.); cost **+19–23%** | [Gloaguen et al.](https://arxiv.org/abs/2602.11988) | Feb 2026 | M |
| Human tests as oracle | **94.3%** (human) vs **68.0%** (LLM tests) SWE-bench Verified | [TDFlow](https://arxiv.org/html/2510.23761v1) | Oct 2025 | M |
| PBT vs TDD-style refinement | **+23.1–37.3%** relative pass@1 | [PGS](https://arxiv.org/abs/2506.18315) | Jun 2025 | M (function-level) |
| Bad plan vs no plan | Subpar plan < no plan; good plan + reminders > none | [Liu et al.](https://arxiv.org/abs/2604.12147) | Apr–Aug 2026 | M |
| Implicit requirements are the bottleneck | **24.5–46.0%** of runs; avg resolve 31.5% | [SWE-RPG](https://arxiv.org/abs/2608.09072) | Aug 2026 | M |
| Asking clarifying questions | Up to 74% gain over non-interactive; 80–89% of fully-specified recovered | [Ambig-SWE](https://arxiv.org/abs/2502.13069) | v3 Feb 2026 | M |
| Spec quality ↔ bug-fix share | 11.8% vs 20.4% of commits (top vs bottom third) | [EPIC](https://arxiv.org/abs/2610.07534) | Oct 2026 | M (correlational) |
| Agent PR rejections | Only **35.7%** of rejected agentic PRs were clear agent failures (9,799 PRs) | [Peralta et al.](https://arxiv.org/pdf/2605.22534) | May 2026 | M (observational) |
| SWE-bench Pro difficulty | 107 LOC / 4.1 files avg; best 43.6% public, 17.8% commercial (Sep 2025 models) | [Scale AI](https://arxiv.org/html/2509.16941v2) | Nov 2025 | M |
| Terminal-Bench 2.0 | 89 tasks; frontier <65% at publication | [Merrill et al.](https://arxiv.org/abs/2601.11868) | Jan 2026 | M |
| DORA 2025 | **90%** use AI; >80% feel more productive; 30% little/no trust; AI ↑ throughput but ↓ stability | [Google Cloud](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report) | Sep 2025 | S |
| Stack Overflow 2025 | 84% use/plan; **46% distrust** vs 33% trust; **66%** "almost right"; 45% debugging AI code slower; 72% don't vibe-code | [SO 2025](https://survey.stackoverflow.co/2025/ai) | Jul 2025 | S |
| Stack Overflow 2026 | 66% use coding agents; Claude Code 66%, Copilot 59%; 93% need attribution to trust; requirements are the most trusted context source (85%) | [SO blog](https://stackoverflow.blog/2026/10/06/the-results-of-the-2026-developer-survey-are-here/) | Oct 2026 | S |
| GitClear 2025 | Moved (refactor) lines 25% → <10%; copy/paste 8.3% → 12.3% (2021→2024); 211M lines | [GitClear](https://www.gitclear.com/ai_assistant_code_quality_2025_research) | early 2025 | M (observational) |
| GitClear 2026 | "Write-Only Mode", 623M changes; secondary reports: refactor moves −70%, duplication +81% | [GitClear research index](https://www.gitclear.com/research) | 2026 | M, *figures unverified* |
| Faros 2025 | +21% tasks, +98% PRs, **+91% review time**, +154% PR size, +9% bugs/dev; no org-level DORA gain | [Faros](https://faros.ai/research) (figures via secondary) | Q2 2025 | M (telemetry) |
| Faros 2026 | Task throughput +33.7%; PR size +51%; review time ×5; bugs/dev +54%; incidents/PR ×3 | [Faros](https://faros.ai/research/ai-acceleration-whiplash) | Q2 2026 | M (telemetry) |
| SDD time saving | "12 hours → 15 minutes" of documentation | [Spec Kit](https://github.com/github/spec-kit/blob/main/spec-driven.md) | 2025 | P, illustrative |
| SDD overhead | 8 files and ~1,300 lines of Markdown to show the current date | [Marmelab](https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html) | Nov 2025 | P, anecdote |
| RPI results | 35k LOC in ~7 h (3 h research/plan); team spends ~$12k/month | [HumanLayer](https://www.humanlayer.dev/blog/advanced-context-engineering) | Aug 2025 | P |
| Long-run harness cost | Solo 20 min/$9 (broken) vs harness 6 h/$200 (works) | [Anthropic](https://www.anthropic.com/engineering/harness-design-long-running-apps) | Mar 2026 | P (n=1) |

**Not found:**
- A controlled study of plan mode as such.
- A study of vertical vs horizontal slicing.
- A head-to-head of full SDD (Spec Kit, Kiro, BMAD) against ad-hoc prompting on matched tasks.
- A 2026 DORA report.
- A new Google internal RCT after 2024.

---

## 5. Worked examples

### Small: one session, ~30–90 human-minutes

```markdown
# Rate-limit the /login endpoint

Goal: Return 429 after 5 failed logins per IP per 15 minutes.

Context: Auth handler src/auth/login.ts. Follow the existing limiter
pattern in src/middleware/uploadLimiter.ts (same Redis client).

Constraints: No new dependencies. Successful login resets the counter.

Out of scope: Account lockout, CAPTCHA, other endpoints.

Done when:
- New test: 5 bad logins → 6th returns 429 with Retry-After header.
- New test: a good login after 3 bad ones resets the count.
- `npm test` and `npm run typecheck` pass. Do not edit existing tests.
- Show the test output.
```

Why it is shaped this way:
- Goal, Context, Constraints and Done-when follow [Codex](https://learn.chatgpt.com/guides/best-practices).
- It points at one existing pattern instead of naming a pattern ([Claude Code docs](https://code.claude.com/docs/en/best-practices)).
- It states out-of-scope explicitly.
- Its oracle is concrete examples and runnable checks.
- It is about 15 lines.
- No plan step is needed: the diff is nearly one sentence.

### Medium: plan pass + implement pass, a few hours

1. **Session A, plan mode.** Research the code ("how are sessions created? where is token refresh?") using subagents. Output `PLAN.md`:
   - phases;
   - files per phase;
   - interface signatures that cross module boundaries;
   - a verification command per phase;
   - an open-questions list.
2. **The human reviews PLAN.md.** This is the measured high-leverage point ([Liu et al.](https://arxiv.org/abs/2604.12147)).
3. **Session B, fresh context.**
   - Write the failing acceptance tests from the plan. The human checks them and commits them.
   - Implement phase by phase, updating PLAN.md's progress section after each.
4. **Session C (or a subagent).** Review the diff against PLAN.md for "gaps that affect correctness or the stated requirements" only ([Claude Code docs](https://code.claude.com/docs/en/best-practices)).

### Large: many sessions, days

- **`SPEC.md` (product level).** User stories with EARS-style acceptance criteria, e.g. "WHEN a user submits an expired token THE SYSTEM SHALL return 401" ([Kiro](https://kiro.dev/blog/property-based-testing/)). Data model, explicit non-goals, no file-level design ([Anthropic planner](https://www.anthropic.com/engineering/harness-design-long-running-apps)).
- **`features.json`.**
  - One entry per user-visible slice: `{id, description, steps_to_verify, passes:false}`.
  - Agents may only flip `passes` ([Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)).
  - Size each slice to roughly the model's 80% horizon (≈1–3 human-hours in 2026; [METR](https://metr.org/time-horizons/)).
- **`progress.md` / ExecPlan sections.** Progress, Surprises & Discoveries, Decision Log ([OpenAI](https://developers.openai.com/cookbook/articles/codex_exec_plans)).
- **Every session:**
  1. Read git log and progress.
  2. Run `init.sh` and the smoke e2e test.
  3. Pick the highest-priority failing feature.
  4. Test-first, then implement.
  5. Run e2e (browser) verification.
  6. Commit and update progress.
- **Periodic independent evaluator** against the spec. Keep it only while it catches things the model misses alone ([Anthropic, Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)).

---

## 6. Disagreements and open questions

- **Is SDD "waterfall strikes back"?**
  - Against:
    - Zaninotto: 8 files and 1,300 lines for a date display; reviewing specs means "spending 80% of your time reading instead of thinking" ([Nov 2025](https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html)).
    - Böckeler: "sledgehammer to crack a nut", "verbose and tedious to review", false sense of control ([Oct 2025](https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)).
    - Thoughtworks: "elaborate and opinionated", Assess ring ([Nov 2025](https://www.thoughtworks.com/radar/techniques/spec-driven-development)). A Portuguese blog reports it is still in Assess in Vol. 34 (Apr 2026); *unverified*.
  - For: Brooker says the spec is the living iterated artifact, not a frozen gate ([Apr 2026](https://brooker.co.za/blog/2026/04/09/waterfall-vs-spec)).
  - **Neither side has outcome data.**
- **Do context files help?**
  - Vendors recommend AGENTS.md and CLAUDE.md, but the only controlled study finds no significant success gain and ~20% extra cost ([Gloaguen et al.](https://arxiv.org/abs/2602.11988)).
  - Both agree on *short*.
- **Separate verifier agents vs shared context.**
  - Anthropic finds self-evaluation over-praises and uses separate evaluators ([Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)).
  - Cognition warns that split agents make conflicting implicit decisions unless they share full traces ([Jun 2025](https://cognition.com/blog/dont-build-multi-agents)).
  - Anthropic itself leaves "single agent vs specialised QA agents" as an open question ([Nov 2025](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)).
  - **Reconciliation that fits both:** the verifier judges *outputs against criteria* and does not make build decisions.
- **Productivity: measured vs perceived.**
  - The METR RCT showed a slowdown (2025), and the follow-up is inconclusive but leans towards speed-up (2026).
  - Surveys show 69–80%+ perceived gains ([SO 2025](https://survey.stackoverflow.co/2025/ai); [DORA 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)).
  - Telemetry shows individual throughput up while review time, bugs and incidents also rise ([Faros 2026](https://faros.ai/research/ai-acceleration-whiplash)).
  - **The consistent signal:** the bottleneck moves to specification and verification. DORA puts it as "friction … moves" toward deciding and verifying ([RDEL summary of DORA](https://rdel.substack.com/p/rdel-112-whats-ais-impact-on-software)).
- **Harness components expire.** Anthropic dropped sprints and context resets as models improved ([Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)). Any fixed SDD ceremony should be re-tested per model generation.
- **Open:**
  - Optimal spec length in tokens; no study.
  - Vertical vs horizontal slicing; no study.
  - Whether prescribing named design patterns helps; no study.
  - Full-process SDD benchmarks; none exist ([de Macedo 2026](https://arxiv.org/abs/2606.04967)).
  - Spec-as-source viability; Tessl is still a thesis, and regeneration from the same spec gave different code in Böckeler's test.

---

## Sources

Dates are publication dates; "read 2026-10" marks undated living docs.

- METR, Early-2025 AI on experienced OSS developers (2025-07-10): https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
- METR, We are changing our developer productivity experiment design (2026-02-24): https://metr.org/blog/2026-02-24-uplift-update/
- METR, Algorithmic vs holistic evaluation (2025-08-12): https://metr.org/blog/2025-08-12-research-update-towards-reconciling-slowdown-with-time-horizons
- METR, Time horizons dashboard, TH1.1 (updated 2026-09-08): https://metr.org/time-horizons/
- Kwa et al., Measuring AI ability to complete long tasks (2025-03-18, v4 2026-07): https://arxiv.org/abs/2503.14499
- Chroma, Context Rot (2025-07-14): https://www.trychroma.com/research/context-rot
- Distyl AI (IFScale), How Many Instructions Can LLMs Follow at Once? (2025-07): https://arxiv.org/abs/2507.11538
- Gloaguen et al., Evaluating AGENTS.md (2026-02-12): https://arxiv.org/abs/2602.11988 (HTML v3: https://arxiv.org/html/2602.11988v3)
- Han et al., TDFlow (2025-10-27; EACL 2026): https://arxiv.org/html/2510.23761v1
- He et al., Property-Generated Solver (2025-06): https://arxiv.org/abs/2506.18315
- Liu et al., From Plan to Action (2026-04-13, v3 2026-08-07): https://arxiv.org/abs/2604.12147
- AgentForge (2026-04): https://arxiv.org/pdf/2604.13120
- Zhou et al., SWE-RPG (2026-08-10): https://arxiv.org/abs/2608.09072
- Ambig-SWE (v3 2026-02-21): https://arxiv.org/abs/2502.13069
- Edwards & Schuster, Ask or Assume? (2026-03-27, v3 2026-09-07): https://arxiv.org/abs/2603.26233
- Sayagh, What Makes a GitHub Issue Ready for Copilot? (2025-12-24): https://arxiv.org/abs/2512.21426
- Peralta et al., Why Are Agentic Pull Requests Merged or Rejected? (2026-05): https://arxiv.org/pdf/2605.22534
- Claudino et al., EPIC Framework for SDD (2026-10-06): https://arxiv.org/abs/2610.07534
- de Macedo, From Prompt to Process (2026-06-03): https://arxiv.org/abs/2606.04967
- Rosa et al., Specification-driven code generation study design (2026-01-07): https://arxiv.org/abs/2601.03878
- Scale AI, SWE-Bench Pro (v2 2025-11-14): https://arxiv.org/html/2509.16941v2
- Epoch AI, What skills does SWE-bench Verified evaluate? (2025-06-13): https://epoch.ai/blog/what-skills-does-swe-bench-verified-evaluate
- Terminal-Bench 2.0 (2026-01-17): https://arxiv.org/abs/2601.11868
- Paradis et al., Google enterprise RCT (2024-10; ICSE 2025): https://arxiv.org/abs/2410.12944
- Google Cloud, Announcing the 2025 DORA report (2025-09-23): https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report
- RDEL #112 on DORA 2025 (2025): https://rdel.substack.com/p/rdel-112-whats-ais-impact-on-software
- Stack Overflow Developer Survey 2025, AI (2025-07): https://survey.stackoverflow.co/2025/ai
- Stack Overflow, 2026 survey results (2026-10-06): https://stackoverflow.blog/2026/10/06/the-results-of-the-2026-developer-survey-are-here/
- GitClear, AI Copilot Code Quality 2025: https://www.gitclear.com/ai_assistant_code_quality_2025_research
- GitClear research index (2026 "Write-Only Mode"): https://www.gitclear.com/research
- Faros AI research index (2025–2026): https://faros.ai/research
- Faros AI, Acceleration Whiplash (Q2 2026): https://faros.ai/research/ai-acceleration-whiplash
- Anthropic, Effective harnesses for long-running agents (2025-11-26): https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- Anthropic, Harness design for long-running application development (2026-03-24): https://www.anthropic.com/engineering/harness-design-long-running-apps
- Anthropic, Effective context engineering for AI agents (2025-09-29): https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Claude Code, Best practices (living doc, read 2026-10): https://code.claude.com/docs/en/best-practices
- OpenAI, Codex best practices (living doc, read 2026-10): https://learn.chatgpt.com/guides/best-practices
- OpenAI Cookbook, Using PLANS.md for multi-hour problem solving (2025-10-07): https://developers.openai.com/cookbook/articles/codex_exec_plans
- Devin docs, When to use Devin (living doc, read 2026-10): https://docs.devin.ai/essential-guidelines/when-to-use-devin.md
- GitHub docs, Copilot cloud agent – get the best results (living doc, read 2026-10): https://docs.github.com/en/copilot/tutorials/cloud-agent/get-the-best-results
- Cognition, Don't build multi-agents (2025-06-12): https://cognition.com/blog/dont-build-multi-agents
- Amp, 200k tokens is plenty (2025-12-09): https://ampcode.com/notes/200k-tokens-is-plenty
- HumanLayer, Advanced context engineering for coding agents (2025-08-29): https://www.humanlayer.dev/blog/advanced-context-engineering
- GitHub Spec Kit repo (read 2026-10): https://github.com/github/spec-kit
- GitHub Spec Kit, spec-driven.md: https://github.com/github/spec-kit/blob/main/spec-driven.md
- GitHub Blog, Spec-driven development with AI (2025-09-02): https://github.blog/2025-09-02-spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- Kiro, Does your code match your spec? (2025-11-17): https://kiro.dev/blog/property-based-testing/
- BMAD-METHOD repo (read 2026-10): https://github.com/bmad-code-org/BMAD-METHOD
- Böckeler, Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl (2025-10-15): https://www.martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- Böckeler, Harness engineering for coding agent users (2026-04-02): https://martinfowler.com/articles/harness-engineering.html
- Thoughtworks Technology Radar, Spec-driven development (2025-11-05): https://www.thoughtworks.com/radar/techniques/spec-driven-development
- Zaninotto/Marmelab, SDD: The Waterfall Strikes Back (2025-11-12): https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html
- Brooker, waterfall vs spec (2026-04-09): https://brooker.co.za/blog/2026/04/09/waterfall-vs-spec
- Beck, Augmented Coding: Beyond the Vibes (2025-06-25): https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes
- AI Hero, Tracer bullets (updated 2026-01-22): https://www.aihero.dev/tracer-bullets
- BenchLM SWE-bench Pro aggregator (2026, unverified): https://www.benchlm.ai/benchmarks/swePro
