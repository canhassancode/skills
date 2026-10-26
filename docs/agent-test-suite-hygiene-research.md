# Keeping agent-written test suites small, fast and honest (as of October 2026)

Researched 2026-10-26. Companion to `agent-testing-research.md`; findings already recorded there (2× test-to-source ratio in agent PRs, 36% vs 26% mock commits, TestGen-LLM's survival filter, Meta JiTTest, MIST-RL, LTM, ACH acceptance) are referenced, not re-derived. The second companion named in the brief, `agent-test-layers-examples.md`, does not exist in `docs/`.

Every source carries its date. Classes: **[M]** measured (benchmark, controlled study, telemetry, mined data). **[S]** stated in a primary specification: tool docs, a report schema, a book's normative text. **[P]** practitioner or vendor claim without data. Stryker and Vitest facts were checked against the live docs and the report schema on 2026-10-26: StrykerJS **10.1.1** and Vitest **5.0.5** are the current npm `latest`.

---

## TL;DR

1. **No one has measured how test suites grow in agent-heavy repositories.**
   - The nearest data is per-PR: agent PRs carry ~2× the test-to-source ratio of human PRs (Jan 2026) [M], and test-containing agent PRs became more common over 2025 ([Jan 2026](https://arxiv.org/abs/2601.03556)) [M].
   - I found no longitudinal suite-size or test-deletion study for agent repositories.
2. **Unbounded growth of locked acceptance tests is a lifecycle problem.**
   - The spec tools that handle it key the spec, and so its tests, to *current requirements*, not to changes. OpenSpec's delta model has ADDED, MODIFIED and REMOVED; REMOVED deletes the requirement from the source of truth on archive (docs, Oct 2026) [S].
   - Spec Kit offers "flow-forward" (a new directory per change, history kept) or a "living spec" edited in place (Spec Kit docs) [S].
   - BDD's own record is poor: **80.2%** of 1.1M Gherkin steps across 347 repos are exact duplicates by step weight ([Apr–Jun 2026](https://arxiv.org/abs/2604.20462)) [M].
3. **Run fewer tests per change; don't delete them permanently.**
   - Google's TAP: of 5.5M affected tests over a month, only **63K ever failed**, and **1.23%** of executions found a breakage. Selecting by dependency distance saved **42–55%** of resources with no missed breakage ([2017](https://research.google/pubs/pub45861/)) [M].
   - Meta's predictive selection halves infrastructure cost and still catches **>99.9%** of faulty changes ([2018](https://arxiv.org/abs/1810.05286)) [M].
   - Permanent reduction is riskier: reduced suites missed some faults in up to **52.2%** of real failed builds ([ISSTA 2018](https://mir.cs.illinois.edu/gyori/pubs/issta18.pdf)) [M].
4. **When you do prune, prune by killed mutants, not by coverage.** Statement-coverage reduction cut suites by **62.9%** but lost up to **20.5%** of killed mutants. Reducing on killed mutants lost **none**, at a cost of an 11.9 pp larger suite ([FSE 2014](https://mir.cs.illinois.edu/gyori/pubs/fse14reduction.pdf)) [M].
5. **Weak oracles dominate agent test code.**
   - **80.2%** of 86,156 agent test-file patches (33,596 PRs, five agents) carry weak or no oracle: no assertion, existence-only, boolean-only, mock-call-only, or snapshot-only.
   - Claude Code's strong-oracle rate on new test files is **67%**; Codex's is **18%** ([Jun 2026](https://arxiv.org/abs/2606.18168)) [M].
   - Pseudo-tested methods occur even in strong human suites: **1–46%** of methods across 21 projects ([2018](https://arxiv.org/abs/1807.05030)) [M]. No study measures pseudo-tested rates in agent suites.
6. **Chasing every surviving mutant creates the very tautological tests you're trying to remove.** Google's developers first rated **85%** of surfaced mutants unproductive, warning that tests written for them become "change-detector" tests. Diff-only mutation, arid-node suppression and one mutant per line raised productivity to **89%** ([2021](https://arxiv.org/abs/2102.11378)) [M].
7. **Stryker can answer "which test earns its place", but not on its default settings.**
   - `killedBy` and `coveredBy` are per-test arrays in the report schema [S].
   - The Vitest runner bails on the first failing test unless `disableBail: true`, so by default `killedBy` lists one killer per mutant and can't measure redundancy [S].
   - Scope the run to the diff with `--mutate file.ts:start-end`, and use `--incremental` (killed results are reused only if the killing test is unchanged) [S].
8. **I found no measured data on why agent tests are slow.**
   - The mechanisms are known [S/P]: jsdom costs **200–500 ms per import** (Vitest docs) [S]; there are fixed sleeps and container start-ups; and LLM tests inherit flakiness from their prompt context ([SAP, Jan 2026](https://arxiv.org/abs/2601.08998)) [M].
   - Google's small-test rule (one process, no sleep, no I/O) and Bazel's size-to-timeout table (60/300/900/3600 s) are the primary-source budgets [S].

---

## 1. Suite growth and retiring tests

### Growth: what is measured

| Evidence | Finding | Class |
|---|---|---|
| Agent PRs vs human PRs (AIDev) | ~2× test-to-source line ratio; agents favour *adding* tests over editing them ([Milanese et al., 2026-01-29](https://arxiv.org/abs/2601.21194), in companion doc) | M |
| Tests in agentic PRs | Test-containing PRs grow more common over time, are larger, and take longer; merge rate is similar ([AIDev tests study, 2026-01-07](https://arxiv.org/abs/2601.03556)). Abstract only; no ratios read | M |
| Agent commits touching tests | 23% vs 13% for non-agent commits; newer repos show a higher share ([Hora & Robbes, MSR 2026, 2026-01-30](https://arxiv.org/abs/2602.00409)) | M |
| Agent-generated vs human files, test commits | 6.09% vs 6.31% of commits: no difference ([EASE 2026, v2 2026-05-09](https://arxiv.org/html/2605.06464v2)) | M |
| Agent code under test | 50.4% of agentic PRs that modify tested code change no tests; 61.5% (Java) and 27.0% (Python) of changed lines covered ([2026-07-20](https://arxiv.org/html/2607.18057)) | M |
| Classic co-evolution | Test code grows either synchronously or in "phases", with large differences in coverage for the same proportion of test code ([Zaidman et al., EMSE 2011](https://link.springer.com/article/10.1007/s10664-010-9143-7)) | M, pre-agent |

**The gap.** No study I found tracks *net* suite size, test-to-code ratio over a repository's life, or test deletion in agent-heavy repositories. The per-PR signals (more tests added, 2× ratio, fewer edits to existing tests) point to monotonic growth. That is an inference, not a measurement.

### Retiring and superseding acceptance tests: how practice handles it

- **Google's rule for when tests may change** ([SWE at Google ch. 12, 2020](https://abseil.io/resources/swe-book/html/ch12.html)) [S]:
  - Pure refactorings "shouldn't need to change" tests.
  - New features add tests but "shouldn't need to change any existing tests".
  - Bug fixes add a missing case.
  - Only *behaviour changes* are expected to change existing tests.
  - So a diff that edits or deletes a locked acceptance test is legitimate exactly when the spec's requirement changed. That makes the check mechanical.
- **OpenSpec** ([`docs/concepts.md`, last commit 2026-10-14](https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md)) [S]:
  - `openspec/specs/` is "the source of truth — how your system currently behaves". Each change is a folder of *delta specs*.
  - On archive, ADDED is appended and MODIFIED replaces the existing requirement.
  - REMOVED is "Deleted from main spec". Removing the last requirement retires the capability when `retire_capabilities: true` is set.
  - The archived change keeps its history. The docs say nothing about tests, but the model maps one-to-one onto a test lifecycle keyed by requirement.
- **Spec Kit** ([Evolving Specs guide](https://github.github.com/spec-kit/guides/evolving-specs.html), undated, read 2026-10-26) [S]. It offers two modes:
  - **Flow-forward**: a new feature directory per change, with completed artefacts retained unchanged and cross-linked when superseded.
  - **Living spec**: revise `spec.md` first, then reconcile `plan.md` and `tasks.md`.
  - The guide does not say what happens to tests. Its open issues ([#1191](https://github.com/github/spec-kit/issues/1191), [#916](https://github.com/github/spec-kit/issues/916)) confirm there's no first-class "update spec" command.
  - Flow-forward on its own is exactly the per-feature growth pattern the user worries about.
- **Kiro** ([Spec best practices, updated 2026-09-25](https://kiro.dev/docs/specs/best-practices/)) [S]:
  - Feature specs are "designed for continuous refinement": edit `requirements.md`, refine the design, then **Sync Files** on `tasks.md`.
  - Bugfix specs generate property-based tests covering the fix *and* "SHALL CONTINUE TO" preservation clauses.
  - Requirement removal is not covered.
- **Specification by Example / living documentation** (Adzic, *Specification by Example*, 2011) [S]:
  - Executable specifications are "living documentation" only if they are continuously validated and reorganised.
  - The book's table of contents prescribes "organise current work by stories" and then "reorganise stories by functional areas". Per-story acceptance tests are *temporary* packaging, folded into a per-capability specification once done (attribution read via a TOC mirror, *unverified* against the book text).
  - Adzic's 2026 public position, with Terhorst-North (GOTO, [2026-05-29](https://goto.buzzsprout.com/1714721/episodes/19171518-spec-driven-dev-is-back-but-not-how-you-think-daniel-terhorst-north-gojko-adzic)), is sceptical of one-shot spec-to-product. He prefers deterministic CI guardrails over markdown instructions [P].
- **BDD in the wild** [M]:
  - The duplication problem is measured: 80.2% step-weighted exact duplicate steps, and 62.5% of step lines eliminable in the median repository ([cukereuse, v3 2026-06-12](https://arxiv.org/abs/2604.20462)).
  - A 75-practitioner survey names "evolving, duplicated and entangled scenarios" as a reason teams abandon BDD (cited in that paper, *unverified*).

**Synthesis.**
- The suite stays bounded when acceptance tests are indexed by **requirement ID in a living spec**, not by feature or ticket.
- Its size then tracks the number of live requirements, and a requirement's MODIFIED or REMOVED delta is the only licence to change its locked tests.
- Flow-forward history belongs in the archived change folder, not in the test tree.

---

## 2. Minimisation and selection

### Selection (run less, keep everything): industrial numbers

- **Google TAP** ([Memon et al., ICSE-SEIP 2017](https://research.google/pubs/pub45861/)) [M]:
  - 150M test runs a day across 13K projects.
  - Of 5.5M affected tests in a month, **63K ever failed**. **91.3%** passed at least once and never failed.
  - **1.23%** of executions found a breakage or fix.
  - Running only targets within dependency distance 10 (or 6) executed 61% (50%) of targets and saved **42% (55%)** of resources, "and did not miss a single breakage or fix".
- **Meta predictive test selection** ([Machalica et al., 2018](https://arxiv.org/abs/1810.05286)) [M]:
  - Build-dependency selection picks ~10⁴ tests per change.
  - The gradient-boosted model selects under one third of them, halving infrastructure cost and cutting executions by a factor of three.
  - It still reports **>99.9%** of faulty changes and **>95%** of individual failures.
  - The model is retrained weekly on three months of history.
- **Google flakiness context** [M, *secondary*]: 84% of pass→fail transitions at Google are due to flakiness, and 16% of tests show some flakiness ([ICSE 2019](https://research.google/pubs/pub48335/), figures via search snippet).

### Selection tooling in this stack (verified 2026-10-26)

| Tool | Mechanism | Class |
|---|---|---|
| Vitest 5 `--changed [ref]` | Runs tests affected by uncommitted changes or changes since a ref. A change to `setupFiles`, `globalSetup`, the config "with everything it imports", `.env`, or `forceRerunTriggers` reruns everything. `toMatchFileSnapshot` targets aren't tracked ([docs](https://vitest.dev/config/changed)) | S |
| `vitest related <files>` | "Run only tests that cover a list of source files" ([CLI](https://vitest.dev/guide/cli)) | S |
| Vitest `--coverage.changed` | Coverage only for files changed since a ref | S |
| Vitest tags (≥ 4.1) | Per-tag `timeout` / `retry`; filter with `--tags-filter` ([docs](https://vitest.dev/config/tags)) | S |
| Turborepo `--affected` | `--filter=...[main...HEAD]`; package-level by default ("if any file in a package changed, all of its tasks are selected"). Task-level with `futureFlags.affectedUsingTaskInputs`. A shallow clone means everything counts as changed ([docs, 2026-10-21](https://turborepo.dev/docs/reference/run)) | S |

### Reduction (delete permanently): the fault-detection cost

- **Shi et al., FSE 2014** (18 projects, 261,235 tests, 3,590 commits) [M]:
  - Statement-coverage reduction: **−62.9%** size, **up to −20.5%** killed mutants.
  - Killed-mutant reduction: **0 loss** at +11.9 pp size.
  - Relaxing to 95% of requirements: a further 17.14 pp median size cut.
- **Shi et al., ISSTA 2018** (1,478 real failed builds, 32 projects) [M]: the reduced suite missed at least one fault in up to **52.2%** of failed builds. Traditional reduction metrics did *not* predict this loss.
- **Similarity-based (LTM, FSE 2025)**: ~42% test-time saving at a fault-detection rate of 0.84 (companion doc) [M].
- **Mutant-set reduction**: subsumption-based MuJava-M generated **64.43% fewer** mutants, with full effectiveness on 20 of 32 targets and >95% on 29 ([ICST 2020](https://www.cin.ufpe.br/~damorim/publications/guimaraes-etal-icst2020.pdf), via search summary) [M]. Redundant (subsumed) mutants inflate scores. Papadakis et al. (ISSTA 2016) showed they can artificially inflate apparent effectiveness [M, *secondary*].

### LLM/agent-driven pruning (2025–2026)

- I found **no 2025–2026 study that evaluates an LLM or agent pruning an existing suite**.
- The work is all on the generation side:
  - MIST-RL: −19.3% tests, +28.5% mutation score ([Mar 2026](https://arxiv.org/abs/2603.01409)) [M].
  - TestGen-LLM keeps a test only if it adds coverage [M].
  - Coverage-gated few-shot suite enhancement ([Feb 2026](https://arxiv.org/html/2602.12256v1)) [M, abstract only].
- An October 2026 survey of 95 LLM test-generation records explicitly "does not pool effect sizes". It warns that execution-feedback loops can drift toward "easier-to-pass assertions" ([2026-10-04](https://arxiv.org/html/2610.05001)) [S, survey].

---

## 3. Speed

### Why agent-written tests are slow: evidence status

| Cause | Evidence |
|---|---|
| Heavy DOM environment per file | jsdom ≈ **200–500 ms per import**, happy-dom ≈ 90–200 ms, plus window construction ([Vitest perf guide, v5.0.5](https://vitest.dev/guide/improving-performance)) | S |
| Fixed sleeps / real timers | Google: `sleep()` adds "unnecessary speed limits"; poll for state instead ([SWE at Google ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)) [S]. Practitioners report generated Playwright tests using `waitForTimeout`; one team banned it by lint ([dev.to, 2026](https://dev.to/tamizuddin/post-mortem-surviving-ai-generated-playwright-tests-in-production-5bak)) [P] |
| Flakiness inherited from context, then retries | 63% (72/115) of flaky LLM-generated DBMS tests assumed unordered-collection order. The LLMs copied flakiness from the existing tests in the prompt ([SAP, ICSE-SEIP 2026, 2026-01-13](https://arxiv.org/abs/2601.08998)) | M |
| Container start-up | 1–15 s per image or suite (practitioner estimates). No controlled fake-vs-container benchmark found | P |
| Over-use of E2E | Agent-generated long Playwright flows fail ~48% of the time at Slack (companion doc) [M]. No data on agents choosing E2E over unit | — |
| Over-mocking | Measured agents mock *more*, not less (36% vs 26%) [M]. So unit-level slowness in agent suites is more likely to come from environment and setup than from real network I/O. This is an inference | — |

**No study measures the runtime of agent-written suites or per-test duration against human tests.**

### Budgets with primary sources

- **Google test sizes** ([SWE at Google ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)) [S]:
  - *Small*: a single process; may not "sleep, perform I/O operations, or make any other blocking calls", and only an in-memory filesystem.
  - *Medium*: a single machine, network to `localhost` only.
  - *Large*: anything else.
  - Target mix ≈ **80/15/5** by count.
  - Flakiness: Google "hovers around **0.15%**", and "as you approach 1% flakiness, the tests begin to lose value".
- **Bazel size → default timeout** ([Test encyclopedia](https://bazel.build/reference/test-encyclopedia)) [S]:
  - small **60 s**, medium **300 s**, large **900 s**, enormous **3600 s**.
  - Advice: "set your timeout as tight as you can without incurring any flakiness".
  - `--test_verbose_timeout_warnings` flags oversized declarations.
- **Vitest defaults** ([CLI](https://vitest.dev/guide/cli)) [S]:
  - `testTimeout` 5000 ms, `slowTestThreshold` **300 ms**, `retry.count` 0.
  - Default pool is `forks` ("slightly slower than `threads` in larger projects").
  - `isolate: true` per file; disabling it helps only projects without shared side effects.
  - `--shard` splits *files*, not cases; merge with `--reporter=blob` and `--merge-reports`.
  - `fsModuleCache` on by default (example: 8.75 s → 5.90 s on a 900-module graph).
- **Kent Beck, Test Desiderata** ([testdesiderata.com](https://testdesiderata.com/), undated; [newsletter, 2022-01-20](https://newsletter.kentbeck.com/p/desirable-unit-tests)) [S]:
  - Twelve properties traded off as sliders. Relevant here are *Fast*, *Behavioural* ("if the behaviour changes, the test result should change"), *Structure-insensitive* ("should not change their result if the structure of the code changes"), *Isolated*, *Composable* and *Deterministic*.
  - "Too much mocking, especially strict mocking, is a structure sensitivity nightmare."

**In-memory fakes vs testcontainers.**
- No controlled benchmark exists. The structural argument is Google's: medium tests (localhost containers) and small tests (in-process fakes) have different ceilings.
- For the user's "fakes only at network/process ports" rule, an in-process fake keeps a test *small*. A testcontainer makes it *medium*, so put it in a separate Vitest project with its own timeout [S, by Google's definitions].

---

## 4. Tautological tests

### Definitions in the literature

- **Pseudo-tested method** ([Niedermayr et al. 2016; Vera-Pérez et al., EMSE 2018](https://arxiv.org/abs/1807.05030)) [S/M]:
  - A covered method where *no* test fails when its body is replaced by a fixed value (empty body for `void`, `0`/`null`/`true`/`false` for returns). This is "extreme mutation", implemented by Descartes for PIT.
  - Across **21** projects, pseudo-tested methods made up **1–46%** of analysed methods (below 7% in 14 of them). They were present even at 97–98% line coverage.
  - Developers judged only **30 of 101** sampled pseudo-tested methods worth extra tests.
- **Weak oracle taxonomy for agent tests** ([Banik et al., AITest 2026, 2026-06-16](https://arxiv.org/html/2606.18168)) [M]:
  - Weak categories: W1 no assertion, W2 existence/non-null only, W3 boolean only, W4 mock/call-verification only, W5 snapshot only.
  - Strong categories: S1 value equality, S2 error/containment/type, S3 two or more strong kinds.
  - **80.2%** of 86,156 patches are weak or no-oracle; S1 is 11.3% and S3 5.7%.
  - Strong-oracle rate on new test files ranges from **18% (Codex) to 67% (Claude Code)**. Strong oracles raise merge odds (OR 1.28).
  - The paper calls mocking the module under test "passing by construction".
  - Caveat: classification uses *added lines in patches*, so edits to existing tests can look assertion-free.
- **Change-detector tests** ([Petrović et al., Google, 2021](https://arxiv.org/abs/2102.11378)) [S]:
  - Tests written to kill unproductive mutants "test the current implementation rather than the specification".
  - They cause "brittle tests and false alarms". This is the mutation-testing route *into* tautology.
- **Interaction vs state** (SWE at Google ch. 12) [S]: "test state, not interactions"; interaction tests "check how a system arrived at its result" and are more brittle. W4 is the measured version of this.
- **Test smells in LLM tests** ([LLM test-smell diffusion study, v3 2026-08-01, TOSEM](https://arxiv.org/html/2410.10628)) [M] (older models: GPT-3.5/4, Mistral/Mixtral):
  - Assertion Roulette is "the most dominant smell": 38–49% (tsDetect) at class level and 92.8–99% at method level.
  - Unknown Test (no assertion) reaches up to **77%** in class-level LLM suites, against 0–7% for EvoSuite.
  - VibeCheck (Kiro/Antigravity/Cursor with Sonnet 4.5, 15 repos, [Sep 2026](https://arxiv.org/abs/2609.05978)) reports tests that are "runnable but frequently lack strong assertions" [M, abstract only, no figures].

### Detection that fits a Vitest/TypeScript stack

| Signal | How | Class |
|---|---|---|
| Can't fail | Mutant kills per test from Stryker `killedBy` (needs `disableBail`). A test that kills **zero** mutants in the code it covers is tautological or redundant | S (mechanism) |
| Pseudo-tested code | No JS port of Descartes. Stryker's `BlockStatement` mutator (empties a block) is the nearest analogue for void bodies. Stryker has only `excludedMutations`, no include list, so an "extreme-only" run means excluding every other mutator ([core schema](https://github.com/stryker-mutator/stryker-js/blob/master/packages/api/schema/stryker-core.json)) | S |
| Assertion-free / conditional assertions | `@vitest/eslint-plugin`: `expect-expect`, `no-conditional-expect`, `no-conditional-in-test`, `valid-expect`, `no-standalone-expect` ([repo](https://github.com/vitest-dev/eslint-plugin-vitest)) | S |
| Mock-only oracles (W4) | No off-the-shelf rule. Practical proxy: forbid `vi.mock` of modules inside the deep module, allowing it only for port adapters (`no-restricted-syntax` or import rules) | P |
| JS test-smell tooling | SNUTS.js exists; a 2025 SBES study says JS test-smell tooling still lags ([SBES 2025](https://sol.sbc.org.br/index.php/sbes/article/view/30417)) | M/P |

**Rates in agent suites.**
- Measured weak-oracle prevalence: **80.2%** of patches.
- Measured LLM smell prevalence (older models): up to 77% assertion-free class suites.
- Pseudo-tested rate in agent-written suites: **not measured anywhere I found**.

---

## 5. Mutation testing mechanics (Stryker specifics)

### What the report gives you ([schema](https://github.com/stryker-mutator/mutation-testing-elements/blob/master/packages/report-schema/src/mutation-testing-report-schema.json), read 2026-10-26) [S]

- `files[path].mutants[]` carries:
  - `id` ("can be used to correlate this mutant across reports") and `mutatorName`.
  - `location`, `status` (Killed, Survived, NoCoverage, CompileError, RuntimeError, Timeout, Ignored, Pending) and `statusReason`.
  - **`coveredBy`** (test ids), **`killedBy`** (test ids), `testsCompleted`, `duration` and `static`.
- `testFiles[path].tests[]` carries `id` ("used to correlate what test killed a mutant"), `name` and `location`.
- The schema itself says of `killedBy`: "It is a best practice to 'bail' on first failing test, in which case you can fill this array with that one test."

### Configuration that matters ([config docs](https://stryker-mutator.io/docs/stryker-js/configuration/), [Vitest runner](https://stryker-mutator.io/docs/stryker-js/vitest-runner/)) [S]

| Option | Fact |
|---|---|
| `coverageAnalysis` | Default `perTest` since v5: "Only the tests that cover a specific mutant are executed for each mutant." The **Vitest runner ignores the setting and always uses perTest** |
| `vitest.related` | Default `true`: only tests related to mutated files run. Turn it off when tests reach code indirectly |
| `vitest.pool` | Default `threads` (configurable since 10.1.0). Browser Mode is not supported. Stryker forces `maxWorkers: 1` and `bail: 1` (`0` only with `disableBail`) |
| `disableBail` | Default `false`. **Must be `true` to get every killing test in `killedBy`**, which is needed for redundancy and subsumption analysis. Costs more runtime (no figure published) |
| `mutate` with ranges | `"src/app.ts:1-11"` or `:startLine[:startColumn]-endLine[:endColumn]`; can't be combined with a glob on the same entry. This is how to scope to a diff |
| `incremental` / `incrementalFile` / `force` | Killed mutants are reused if "the culprit test still exists, and it didn't change". Others are reused if "no new test covers it, and no tests changed". The dry run is always required. Test-change detection is full for Vitest. Changes outside mutated and test files (dependencies, env, snapshots) are **not** detected. `--force --mutate file:5-7` reruns a scope |
| `ignoreStatic` | Skips mutants executed only at module load. Requires `perTest` |
| `thresholds.break` | Default `null` (never fails). Set it to gate CI |
| Equivalent mutants | `// Stryker disable next-line <Mutator>: reason` marks them `Ignored`, and they stay in the report |

**Cost data.**
- Stryker publishes no elapsed-time speed-ups for incremental mode. The only figure is 3,731 of 3,965 results reused (234 rerun) ([blog, 2022-09-06](https://stryker-mutator.io/blog/announcing-incremental-mode/)) [S].
- Treat `stryker-incremental.json` as a CI artefact, not a committed file, and run `--force` periodically [S].
- **Extreme vs full mutation** (PIT, [Descartes tool paper, Nov 2018](https://arxiv.org/abs/1811.03045)) [M]:
  - JFreeChart: 5 m 48 s / 7,210 mutants against 41 m 28 s / 89,592.
  - Spoon: 2 h 25 m against **56 h 48 m**.
  - Java Git: 1 h 30 m against 16 h.
  - Roughly an order of magnitude fewer mutants and less time.
- **Diff-scoped mutation at Google** ([2021](https://arxiv.org/abs/2102.11378)) [M]:
  - ~17M mutants over 760K changes, with 2M surfaced in review.
  - Only changed, covered, non-arid lines are mutated, at one mutant per line.
  - 87.5% of generated mutants were killed by the existing tests.
  - Productivity went from 15% to 89%; 82% of surfaced mutants with feedback were rated productive overall.

### Equivalent mutants

- **Meta ACH** ([FSE 2025](https://arxiv.org/abs/2501.12862)) [M]:
  - An LLM equivalence detector scored precision/recall **0.79/0.47** raw and **0.95/0.96** with simple preprocessing.
  - It ran over 9,095 mutants on 10,795 Kotlin classes; 73% of the generated tests were accepted.
  - No 2026 revision found. Meta's [Sep 2025 blog](https://engineering.fb.com/2025/09/30/security/llms-are-the-key-to-mutation-testing-and-better-compliance/) restates it qualitatively.
- **LLMutantKiller** ([ISSTA 2026](https://conf.researchr.org/details/issta-2026/issta-2026-research-papers/7/LLMutantKiller-Using-Large-Language-Models-to-Generate-Tests-that-Kill-Mutants)) [M]:
  - Applied to 915 StrykerJS survivors from 13 JS/TS apps, it kills **up to 95.3%** of those that induce behavioural change.
  - The equivalent share is not in the abstract.
  - Pairing it with Google's warning matters: a tool that kills survivors on demand will also write change-detector tests for unproductive ones.

### Minimal test sets from kill data

- With `disableBail: true`, `killedBy` gives a test × mutant kill matrix. Choosing the smallest set of tests that preserves every kill is set cover. Greedy set cover is the standard heuristic.
- Shi 2014 is the evidence that killed-mutant requirements preserve fault detection better than coverage requirements (0 vs up to 20.5% loss).
- Subsumption-aware mutant reduction (only "subsuming" mutants count) avoids redundant mutants inflating the score. No StrykerJS implementation exists, and dynamic subsumption is test-set-relative and undecidable in general [S].

---

## 6. Numbers table

| Claim | Figure | Source | Date | Class |
|---|---|---|---|---|
| Agent test patches with weak or no oracle | **80.2%** of 86,156 | [Banik et al.](https://arxiv.org/abs/2606.18168) | 2026-06-16 | M |
| Strong-oracle rate, new test files | 18% (Codex) – **67% (Claude Code)** | same | 2026-06-16 | M |
| Merge odds, strong vs weak oracle | OR 1.28 | same | 2026-06-16 | M |
| Pseudo-tested methods, 21 Java projects | 1–46% of analysed methods | [Vera-Pérez et al.](https://arxiv.org/abs/1807.05030) | 2018 | M |
| Pseudo-tested methods developers would fix | 30 of 101 | same | 2018 | M |
| LLM class-level suites with no assertion | up to 77% (EvoSuite 0–7%) | [LLM test-smell diffusion study](https://arxiv.org/html/2410.10628) | v3 2026-08-01 | M (older models) |
| Gherkin steps that are exact duplicates | 80.2% step-weighted; 58.6% median repo | [cukereuse](https://arxiv.org/abs/2604.20462) | 2026-04/06 | M |
| Google: affected tests that ever failed | 63K of 5.5M; 1.23% of executions useful | [Memon et al.](https://research.google/pubs/pub45861/) | 2017 | M |
| Google: distance-based selection | −42% / −55% resources, 0 missed breakages | same | 2017 | M |
| Meta predictive selection | Cost ÷2, executions ÷3, >99.9% faulty changes, >95% failures caught | [Machalica et al.](https://arxiv.org/abs/1810.05286) | 2018 | M |
| Coverage-based reduction | −62.9% size, up to −20.5% killed mutants | [Shi et al. FSE](https://mir.cs.illinois.edu/gyori/pubs/fse14reduction.pdf) | 2014 | M |
| Mutant-based reduction | 0 mutant loss, +11.9 pp size vs coverage-based | same | 2014 | M |
| Reduction on real failed builds | Up to 52.2% of builds miss a fault | [Shi et al. ISSTA](https://mir.cs.illinois.edu/gyori/pubs/issta18.pdf) | 2018 | M |
| Subsumption mutant reduction | −64.43% mutants, full effectiveness on 20/32 targets | [Guimarães et al.](https://www.cin.ufpe.br/~damorim/publications/guimaraes-etal-icst2020.pdf) | 2020 | M (*via summary*) |
| Google mutants initially unproductive | 85%; productivity 15% → 89% | [Petrović et al.](https://arxiv.org/abs/2102.11378) | 2021 | M |
| Google mutants killed by existing tests | 87.5% | same | 2021 | M |
| Extreme vs full mutation time (Spoon) | 2 h 25 m vs 56 h 48 m | [Descartes](https://arxiv.org/abs/1811.03045) | 2018 | M |
| Meta LLM equivalent-mutant detection | P/R 0.79/0.47 → 0.95/0.96 | [ACH](https://arxiv.org/abs/2501.12862) | Jan 2025 | M |
| LLM kills behaviour-changing StrykerJS survivors | up to 95.3% of 915 | [LLMutantKiller](https://conf.researchr.org/details/issta-2026/issta-2026-research-papers/7/LLMutantKiller-Using-Large-Language-Models-to-Generate-Tests-that-Kill-Mutants) | ISSTA 2026 | M |
| Stryker incremental reuse example | 3,731 / 3,965 reused | [Stryker blog](https://stryker-mutator.io/blog/announcing-incremental-mode/) | 2022-09-06 | S |
| Flaky LLM DBMS tests from unordered collections | 63% (72/115) | [Berndt et al.](https://arxiv.org/abs/2601.08998) | 2026-01-13 | M |
| jsdom import cost | 200–500 ms per import | [Vitest docs](https://vitest.dev/guide/improving-performance) | v5.0.5 | S |
| Vitest slow-test threshold default | 300 ms | [Vitest CLI](https://vitest.dev/guide/cli) | v5.0.5 | S |
| Bazel default timeouts by size | 60 / 300 / 900 / 3600 s | [Bazel](https://bazel.build/reference/test-encyclopedia) | current | S |
| Google flaky rate | ~0.15%; value lost near 1% | [SWE at Google ch. 11](https://abseil.io/resources/swe-book/html/ch11.html) | 2020 | S/M |
| Google test mix target | 80 / 15 / 5 | same | 2020 | S |
| Agent PRs changing tested code with no test change | 50.4% | [Dipongkor et al.](https://arxiv.org/html/2607.18057) | 2026-07-20 | M |

---

## 7. Recommended hygiene policy (for deep-module TS, Vitest + Playwright, locked acceptance tests, Stryker)

1. **Key every locked acceptance test to a live requirement ID, never to a ticket.**
   - Keep one spec per capability. Requirement IDs appear in the test titles.
   - A CI check fails on orphans (a test whose ID is not in the current spec) and on uncovered requirements.
   - The suite's size is then bounded by live requirements.
   - Per-story acceptance files are folded into the capability's file when the change closes (OpenSpec archive; SbE "reorganise by functional area").
2. **The only licence to edit or delete a locked test is a MODIFIED or REMOVED requirement delta in the same diff, approved by the human.**
   - Refactors and new features touching existing locked tests are a stop signal (Google ch. 12).
   - The implementing agent stays locked out. The *spec change* unlocks the specific test IDs, not the file.
3. **Select, don't delete, for speed.**
   - Per change: `vitest --changed origin/main` (or `vitest related`) plus `turbo run test --affected`, with `forceRerunTriggers` covering shared setup.
   - Full suite on `main` and nightly.
   - Permanent reduction risks up to 52% of real failing builds; selection at Google and Meta lost ~0.
4. **Agent-written unit tests earn their place by kills.**
   - Run Stryker on the diff only: `--mutate` with line ranges from `git diff`, `--incremental`, `disableBail: true`, and the JSON reporter.
   - From `killedBy`, greedily keep the agent tests that kill a mutant the locked suite and already-kept tests miss. Delete the rest, including every zero-kill test.
   - Evidence: Shi 2014 (kill-based reduction loses nothing); TestGen-LLM keeps 25% (companion doc).
5. **Don't make the agent kill every survivor.**
   - Only mutants on changed, non-arid lines count, at most one per line.
   - Survivors in logging, capacity hints or config are ignored, not tested.
   - Google's 85% "unproductive" figure, and its change-detector warning, apply directly. LLM-killer tools will happily write those tests.
6. **Size-class the suite with Vitest projects and tags, Google style.**
   - *small*: `environment: 'node'`, in-process fakes at ports, fake timers, no network or filesystem. Use a tight `testTimeout` (≈ 1 s) and `slowTestThreshold` 300 ms, and fail CI if any test exceeds its tag's budget.
   - *medium*: testcontainers, localhost only, with a separate timeout.
   - *large*: a handful of Playwright journeys.
   - Use jsdom only where a file needs a DOM; it costs 200–500 ms per import.
7. **Lint the cheap tautologies away before mutation runs.**
   - `@vitest/eslint-plugin`: `expect-expect`, `no-conditional-expect`, `no-conditional-in-test`, `valid-expect`.
   - Forbid `vi.mock` of anything except port adapters.
   - Ban `page.waitForTimeout` and real `setTimeout` waits in tests.
8. **Run a full `--force` Stryker run on a schedule** (weekly), because incremental mode can't see dependency, env or snapshot changes. Store the incremental file as a CI artefact.

---

## 8. Open questions

- **Growth curves.** No longitudinal measurement of suite size, test-to-code ratio or test deletion in agent-heavy repositories. Only per-PR ratios and adoption trends exist.
- **Runtime.** No study compares per-test or suite runtime of agent-written tests with human-written ones. The user's "slow" observation is unmeasured in the literature.
- **Pseudo-tested rate in agent suites.** Weak-oracle prevalence is measured (80.2%). Extreme-mutation survival of agent tests is not. JS also has no Descartes; a `BlockStatement`-only Stryker run is an untested approximation.
- **Cost of `disableBail`.** Kill-matrix redundancy analysis needs it; StrykerJS publishes no figure for its runtime overhead on Vitest.
- **Equivalent-mutant marking vs the zero-comments rule.** Stryker's documented mechanism for marking an equivalent mutant is an inline `// Stryker disable` comment. Your zero-comments rule forbids that, so decide whether that rule makes an exception or equivalents go unmarked (counted as Survived).
- **LLM-driven pruning of existing suites.** No 2025–2026 evaluation found. Every LLM result is generation-side filtering.
- **Requirement-keyed test lifecycle.** OpenSpec, Spec Kit and Kiro all model requirement change, but **none documents what happens to tests** when a requirement is modified or removed.

---

## Sources

Dates are publication or last-update dates; "read" means fetched 2026-10-26.

- Banik, Chowdhury, Shamim — All Smoke, No Alarm: Oracle Signals in Agent-Authored Test Code — https://arxiv.org/abs/2606.18168 — 2026-06-16
- Tabassum et al. — VibeCheck — https://arxiv.org/abs/2609.05978 — 2026-09-05 (v2 09-14)
- Survey of LLM-based test generation — https://arxiv.org/html/2610.05001 — 2026-10-04
- LLM test-smell diffusion study — On the Diffusion of Test Smells in LLM-Generated Unit Tests — https://arxiv.org/html/2410.10628 — v3 2026-08-01
- Berndt et al. — Flakiness of LLM-Generated Tests for DBMS (SAP) — https://arxiv.org/abs/2601.08998 — 2026-01-13
- Do Autonomous Agents Contribute Test Code? — https://arxiv.org/abs/2601.03556 — 2026-01-07
- Hora & Robbes — Are Coding Agents Generating Over-Mocked Tests? — https://arxiv.org/abs/2602.00409 — 2026-01-30
- Agent-generated code maintenance (EASE 2026) — https://arxiv.org/html/2605.06464v2 — 2026-05-09
- Dipongkor et al. — Test Coverage Analysis of Agentic Pull Requests — https://arxiv.org/html/2607.18057 — 2026-07-20
- cukereuse — duplicate Gherkin steps — https://arxiv.org/abs/2604.20462 — 2026-04-22 (v3 06-12)
- SWE-Mutation — https://arxiv.org/abs/2605.22175 — 2026-05-21
- LLMutantKiller (ISSTA 2026) — https://conf.researchr.org/details/issta-2026/issta-2026-research-papers/7/LLMutantKiller-Using-Large-Language-Models-to-Generate-Tests-that-Kill-Mutants — 2026
- MIST-RL — https://arxiv.org/abs/2603.01409 — 2026-03
- Foster et al. — Mutation-Guided LLM-based Test Generation at Meta (ACH) — https://arxiv.org/abs/2501.12862 — 2025-01-22
- Meta Engineering — LLMs are the key to mutation testing — https://engineering.fb.com/2025/09/30/security/llms-are-the-key-to-mutation-testing-and-better-compliance/ — 2025-09-30
- Petrović, Ivanković, Fraser, Just — Practical Mutation Testing at Scale — https://arxiv.org/abs/2102.11378 — 2021
- Vera-Pérez et al. — A Comprehensive Study of Pseudo-tested Methods — https://arxiv.org/abs/1807.05030 — 2018
- Vera-Pérez et al. — Descartes tool demonstration — https://arxiv.org/abs/1811.03045 — 2018-11-07
- Shi, Gyori, Gligoric, Zaytsev, Marinov — Balancing Trade-offs in Test-Suite Reduction — https://mir.cs.illinois.edu/gyori/pubs/fse14reduction.pdf — FSE 2014
- Shi et al. — Evaluating Test-Suite Reduction in Real Software Evolution — https://mir.cs.illinois.edu/gyori/pubs/issta18.pdf — ISSTA 2018
- Guimarães et al. — subsumption-based mutant reduction (ICST 2020) — https://www.cin.ufpe.br/~damorim/publications/guimaraes-etal-icst2020.pdf — 2020 (via summary)
- Memon et al. — Taming Google-Scale Continuous Testing — https://research.google/pubs/pub45861/ — 2017
- Machalica et al. — Predictive Test Selection — https://arxiv.org/abs/1810.05286 — 2018
- Assessing Transition-based Test Selection Algorithms at Google — https://research.google/pubs/pub48335/ — 2019 (figures via snippet)
- Winters, Manshreck, Wright — Software Engineering at Google, ch. 11 Testing Overview — https://abseil.io/resources/swe-book/html/ch11.html — 2020
- Software Engineering at Google, ch. 12 Unit Testing — https://abseil.io/resources/swe-book/html/ch12.html — 2020
- Bazel Test Encyclopedia — https://bazel.build/reference/test-encyclopedia — read
- Kent Beck — Test Desiderata — https://testdesiderata.com/ — undated, read
- Kent Beck — Desirable Unit Tests — https://newsletter.kentbeck.com/p/desirable-unit-tests — 2022-01-20
- Zaidman et al. — Studying the co-evolution of production and test code — https://link.springer.com/article/10.1007/s10664-010-9143-7 — 2011
- StrykerJS configuration — https://stryker-mutator.io/docs/stryker-js/configuration/ — read (v10.1.1 current)
- StrykerJS incremental mode — https://stryker-mutator.io/docs/stryker-js/incremental/ — read
- StrykerJS Vitest runner — https://stryker-mutator.io/docs/stryker-js/vitest-runner/ — read
- StrykerJS disable mutants — https://stryker-mutator.io/docs/stryker-js/disable-mutants/ — read
- Stryker supported mutators — https://stryker-mutator.io/docs/mutation-testing-elements/supported-mutators/ — read
- Stryker — Announcing incremental mode — https://stryker-mutator.io/blog/announcing-incremental-mode/ — 2022-09-06
- Mutation testing report schema — https://github.com/stryker-mutator/mutation-testing-elements/blob/master/packages/report-schema/src/mutation-testing-report-schema.json — read
- StrykerJS core options schema — https://github.com/stryker-mutator/stryker-js/blob/master/packages/api/schema/stryker-core.json — read
- Vitest Improving Performance — https://vitest.dev/guide/improving-performance — v5.0.5, read
- Vitest CLI — https://vitest.dev/guide/cli — v5.0.5, read
- Vitest `changed` — https://vitest.dev/config/changed — v5.0.5, read
- Vitest `tags` — https://vitest.dev/config/tags — v5.0.5, read
- `@vitest/eslint-plugin` — https://github.com/vitest-dev/eslint-plugin-vitest — read
- Turborepo `run` reference — https://turborepo.dev/docs/reference/run — 2026-10-21
- OpenSpec concepts — https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md — last commit 2026-10-14
- Spec Kit — Evolving Specs in Existing Projects — https://github.github.com/spec-kit/guides/evolving-specs.html — undated, read
- Spec Kit issues #1191, #916 — https://github.com/github/spec-kit/issues/1191, https://github.com/github/spec-kit/issues/916 — read
- Kiro — Spec best practices — https://kiro.dev/docs/specs/best-practices/ — 2026-09-25
- GOTO podcast — Spec-driven dev is back (Terhorst-North, Adzic) — https://goto.buzzsprout.com/1714721/episodes/19171518-spec-driven-dev-is-back-but-not-how-you-think-daniel-terhorst-north-gojko-adzic — 2026-05-29
- SNUTS.js — https://sol.sbc.org.br/index.php/sbes/article/view/30417 — SBES
- AI-generated Playwright post-mortem — https://dev.to/tamizuddin/post-mortem-surviving-ai-generated-playwright-tests-in-production-5bak — 2026 [P]
