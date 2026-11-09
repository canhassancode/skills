---
created: 2026-11-08
question: Which proven practices keep independently written, locked pre-implementation tests from being wrong or unsatisfiable, and is there a simpler build flow than align → tester → build → crucible?
---

# Locked-test validity and simpler build flows

Read alongside [`process-tiering-for-agent-builds.md`](process-tiering-for-agent-builds.md), whose tiering findings are not repeated. Local facts come from `canhassancode/brigade`'s stop comments and git history, and from `canhassancode/skills#179`.

**Outcome (#185):** the split lock below was red-teamed and dropped. A blind replay of a throwaway implementation at four lock commits caught brigade's known defects, so that row shipped as the validator.

## Short answer

- **No practice proves a test can pass while no implementation exists.** Every measured method runs the test against some implementation: a gold patch (TDFlow, SWE-bench) or a generated one (Nexus). Red proves nothing about green. Nothing measured compares lock timings.
- **The TDFlow citation does not support this flow as worded.** 94.3% used tests that came from the fix's own pull request and were gold-validated by the dataset. 93.3% shows validity is the variable, not authorship. This flow's tests are LLM-written and unvalidated by execution, which is closer to the 68.0% arm plus an unmeasured human sign-off.
- **Best-fitting tweak [synthesis]:** split the lock. Titles and assertions lock at red; harnesses, fakes and fixtures stay editable until first green; a party other than the builder settles disputes. The real build then serves as the throwaway implementation. It would have ended 3 of the 6 test-defect stops (`#21`, `#44`, `#63`) without a relock through `/align`, and a fourth (`#5`) is already closed by tester's lint step. No study measures this, and it reopens the amender `#179` dropped.
- **Removing `/tester`:** no measured result favours it, and the local numbers cannot separate the two flows. Test-after on faulty code measurably loses fault detection (14% vs 25%).
- **Draft PR at lock and test shape:** no measured evidence either way. All the shape positions are opinion or rule of thumb.

## Corrections to the premises

Checked against `brigade` and this repo. These change the conclusions below.

- **The throwing-stub mechanism explains four of the six defects, not all.** `#21`, `#44`, `#46` (first test) and `#18` were assertions masked at red. `#5` is a lint failure on the file. `#63` was a test locked earlier, in `#71`, and already green; `#63`'s spec then added a second comment that broke the harness's `at(-1)` read. The second `#46` test was also an older lock (`#44`'s line) colliding with a new spec.
- **"Against the rule" is mostly anachronistic.** The sentence "Fakes, harnesses and fixtures never carry one" entered `locking.md` on 2026-11-04 (`d63d85b`); the original (`9479d38`) has no such rule. 41 of the 44 suffix-locked support files on `main` were added before that date, including those behind `#44` and `#63`. Only `#21`'s harness (`69f6f83`, 2026-11-07) was locked after it.
- **`#5` is already closed.** Tester step 7 has run lint, format and secret scan before lock since `d63d85b`.
- **Stops are not the biggest cost.** `#179`'s transcript analysis (2026-11-03) found "Locked-test friction is a minor share"; fix loops, guard prompts and worktree environment cost more.
- **Rough denominator.** The stop comments show 8 stops against at least 24 tickets with a lock line and about 189 locked tests, by a regex over ticket comments. Roughly 8–10 defective tests is about 5%. That is not comparable with the 22–33% below, because hidden wrong-but-passing tests are not counted **[synthesis]**.
- **The stop reports were accurate.** The stop diagnosis or proposal was accepted in five of the six tickets (`#5`, `#18`, `#44`, `#46`, `#63`); `#21` is still open. Of 26 real guard blocks, `#179` found 0 were "a builder changing a test it didn't need to", though the guard was also bypassed 4 times.
- **`/build`'s origin line overstates ImpossibleBench.** It says "read-only tests plus 'stop and say so' took cheating from 54% to 9%". Those were separate experiments: read-only in §5.2 and the abort option in §5.3. The 54→9 figure is GPT-5, and the effect is "much less pronounced for Claude Opus 4.1" ([arXiv 2510.20270](https://arxiv.org/abs/2510.20270)). `locking.md` states this correctly.
- **`/tester`'s 14% vs 25% drops a condition.** The 14% applies to tests generated after *erroneous* code ([Konstantinou et al., arXiv 2607.05139](https://arxiv.org/abs/2607.05139)).

## What 94.3% vs 68.0% supports

From [TDFlow, arXiv 2510.23761v2](https://arxiv.org/abs/2510.23761), read in full:

| Arm | Pass | Cost per issue | What the tests were |
|---|---|---|---|
| Human-written | 94.3% | $1.01 | SWE-bench Verified's own tests, from the resolving pull request |
| LLM-generated | 68.0% | $4.12 ($2.83 on test resolution) | Claude 4 Sonnet from the issue text, while GPT-5 solved them |
| LLM-generated, Bad Test Rate 0 | 93.3% | not given | Instances where every generated test failed before the gold patch and passed after it |

- **Were the 94.3% tests pre-validated? Yes, by dataset construction.** SWE-bench keeps an instance only with a fail-to-pass transition on the gold patch ([SWE-bench Goes Live, arXiv 2505.23419](https://arxiv.org/abs/2505.23419)). TDFlow calls them "gold-standard".
- **They are not pre-implementation tests.** They were mined from the fix's pull request ([TDD-Bench, arXiv 2412.02883](https://arxiv.org/abs/2412.02883)), so they are known to be satisfiable because a real implementation passed them **[synthesis]**.
- **Authorship is not the variable.** The authors: "whether or not the reproduction test is written by a human or an LLM doesn't matter ... so long as the test truly tests for reproduction behavior".
- **The 93.3% is post-hoc.** It selects on a gold patch that does not exist before implementation, about 20% of instances (read off Figure 2). That subset may simply be easier **[synthesis]**.
- **The arms do not map cleanly onto `/build`.** TDFlow grades on hidden tests and submits the patch with the most passing tests, so a wrong test costs money but does not halt the run. `/build` stops. These are bug reproductions rather than feature acceptance tests, and 45 of 500 instances could not run.
- **The authors name the weakness.** "If the initial tests are incorrect, then there is no correction mechanism" is "the primary explanation" for underperformance in LLM mode. There is also no early stop for "truly unsolvable" tests.

So it supports three claims: an executable oracle is effective when the oracle is valid; invalid tests are the bottleneck; read-only tests with few hacks are viable (7 of 800 runs). It says nothing on human sign-off, and it does not support "human-owned tests" as the mechanism **[synthesis]**. Three local citations need rewording: [`engineering/build/SKILL.md`](../../engineering/build/SKILL.md), [`engineering/tester/SKILL.md`](../../engineering/tester/SKILL.md) and [ADR-0011](../adr/0011-locked-tests-replace-the-contract-pipeline.md).

## 1. Satisfiability before lock

| Practice | Measured effect | Cost | Limit |
|---|---|---|---|
| Gold-patch validation | TDFlow 68.0% overall vs 93.3% on validated instances. On TDD-Bench, 44 of 493 human-test instances were filtered for lacking fail-to-pass behaviour or coverage; the best LLM fail-to-pass rate was 23.6% | Free only when a fix already exists | Unavailable before implementation. Proves one solution passes, not that others would: TDD-Bench notes tests that "would reject some valid" code |
| Refinement against a generated implementation ([Nexus, arXiv 2510.26423](https://arxiv.org/abs/2510.26423), GPT-4.1-Mini, Table 3) | Direct → refinement only: HumanEval 80.24 → 85.24, LiveCodeBench 45.57 → 54.05, TestEval 55.15 → 73.39 | One generated implementation plus up to 5 loops; no cost reported | Function-level expected outputs, not harnesses. Passing means "highly likely", against code "not guaranteed to be perfect" |
| Multi-agent deliberation, no execution (same table) | HumanEval 91.68, but LiveCodeBench 45.38 (−0.20). Both together: 93.69 and 56.71 | Four panel agents | Helps on easy tasks, nothing on the hard benchmark |
| Execution-grounded anchors ([AlphaCodium, arXiv 2401.08500](https://arxiv.org/abs/2401.08500), vendor) | Whole flow 19% → 44% pass@5; anchors not isolated | Run-fix loops | Asking the model "who is wrong" often gives "hallucinations" |
| Mutation-validated tests after code ([Meta ACH, arXiv 2501.12862](https://arxiv.org/abs/2501.12862)) | 73% accepted (140 of 191) | Post-code by design | Tests must build, pass consistently and catch an uncaught fault. Answers a different question |
| Contract tests on fakes ([*SWE at Google* ch. 13](https://abseil.io/resources/swe-book/html/ch13.html); [Fowler](https://martinfowler.com/bliki/ContractTest.html)) | None found; established practice | Real-dependency runs, "just once a day" | Covers fake vs real, not harness logic. `layers.md` already does this for ports |
| Vacuity detection in model checking ([Beer et al.](https://link.springer.com/doi/10.1007/3-540-45657-0_39), abstract only) | No effect size read | Automated, needs a model | The nearest formal analogue: a property that passes trivially is flagged. For failures there is no equivalent without an implementation **[synthesis]** |

Baseline rates:
- Spec-only LLM tests failed correct code 21.7%, 28.1% and 32.9% of the time on HumanEval, MBPP and APPS across 11 models. For GPT-4 on HumanEval, 99.3% of incorrect tests were oracle errors, not bad inputs ([Huang et al., arXiv 2409.09464](https://arxiv.org/abs/2409.09464), Table 10; 2024 models, mostly function-level).
- Seeing correct code barely helps: 78.3 → 80.4, 71.9 → 75.4, 67.1 → 66.0. So spec-only costs little validity **[synthesis]**. Seeing incorrect code is far worse: 47.1% against 73.9%, averaged across the three datasets.
- This is not an LLM-only problem. Of 443 sampled test bugs in Apache projects, 97% were false alarms, led by semantic (25%), flaky (21%) and environment (18%) causes. FindBugs caught 0 of 50 ([Vahabzadeh et al., ICSME 2015](https://people.ece.ubc.ca/amesbah/resources/papers/icsme15.pdf)). All six local defects are false alarms too, and static analysis would be a weak gate **[synthesis]**.

Per defect, all judgements **[synthesis]**:

| Practice | #21 rename | #44 default param | #63 wrong comment | #46 `threads: []` | #5 lint | #18 cost |
|---|---|---|---|---|---|---|
| Throwaway implementation, full suite | yes | yes | only if it builds the cap and runs old locks | yes | no | yes |
| Harness self-test, run for real | partly: needs the near-identical fixtures | yes, if a case passes `undefined` | no | no | no | no |
| Contract test on the fake | partly | no | no | no | no | no |
| Fresh reader, spec vs test, no execution | no | partly | partly | yes | no | partly |
| Stubs returning typed defaults instead of throwing | no | no | no | no | no | no |
| Lint and format at lock (shipped) | no | no | no | no | yes | no |

`#43` and `#17` escape all of these. They are false premises about the platform, and no test-validity practice reaches them **[synthesis]**. Same-spec independence also has a known ceiling: 27 versions written independently from one specification still showed coincident failures well beyond chance (Knight & Leveson 1986, [abstract and a course summary](https://www.kth.se/social/files/564df871f2765419e306178d/KnightLeveson.pdf); the paper itself was not read). A throwaway from the same spec can share the tester's misreading **[synthesis]**.

**What would change:** "red for the right reason" should be described as proving the test runs, not that it can pass. Executing against a separate throwaway is the only row catching 4–5 of 6, but it pays for a second implementation to learn at lock what the build learns anyway. Keep it for high-risk tickets or brand-new harnesses. Route its failures to the tester as disputes, never as auto-repairs from reading the code, because tests derived from faulty code lose fault detection (Konstantinou; Huang) **[synthesis]**.

## 2. When to lock

**Direct comparison of lock at red, lock at first green or lock assertions only: nothing found.** Tiebreaker agents in builds: nothing found.

| Practice | When the test is pinned | Who may change it | Evidence |
|---|---|---|---|
| ImpossibleBench read-only | Before the agent starts | Nobody | Read-only "restores legitimate performance" and blocks test edits. Claude models cheat mainly (>79%) by editing tests. Special-casing survives. Its tests were validated and then deliberately mutated, so it says nothing about honest test bugs **[synthesis]** |
| TDFlow | Before patching | Nobody | Names "no correction mechanism" as the main LLM-mode weakness |
| AlphaCodium anchors | Each test once it passes | Protected afterwards | A vendor practice, not isolated in measurement. The closest published "lock at first green" |
| GOOS outer loop, walking skeleton | Written first, stays failing through the inner loop | The implementing team | Practitioner. A walking skeleton is a thin real slice built and tested end to end first. Only the [table of contents](https://growing-object-oriented-software.com/toc.html) and secondary summaries were read; the book was not |
| Approval testing, characterisation | After seeing the output | A human re-approves | [Snapshot, then approve](https://approvaltests.com/); [records observed behaviour](https://en.wikipedia.org/wiki/Characterization_test). Pins what is, not what should be, so it suits harnesses rather than assertions **[synthesis]** |
| ATDD, specification by example | Before the code, as a shared artefact | Team | Fit tables improved requirement understanding in student experiments, by abstract ([Ricca et al.](https://iris.unige.it/handle/11567/284198)). Nothing on test defects |
| Cleanroom independent testers | No pre-written acceptance suite; random from an operational profile | Testers | See below |
| TDD sequencing | n/a | n/a | Order of test and code "had no important influence" on quality, while granularity and uniformity did (39 professionals, 82 data points, observational; [Fucci et al., arXiv 1611.05994](https://arxiv.org/abs/1611.05994)) |

**Independent test teams.**
- Cleanroom: 15 student teams, 10 Cleanroom. Cleanroom met requirements more completely, and all ten made every scheduled delivery against two of five. But **both groups had independent testers**, so the study does not isolate independence. Testers certified reliability rather than helped find errors. 86% of developers missed execution, with no relation to quality ([Selby, Basili & Baker, UC Irvine report, May 1986](https://escholarship.org/uc/item/11q2t17z)).
- **Test defect rates and feedback delay in independent teams: nothing found.** A text search of the Cleanroom report turned up no test-defect figure.
- A six-team experiment favoured independent testing on functional completeness; only the abstract record was read ([Sunyaev & Basten, SAC 2015](https://forschung.uni-kassel.de/converis/portal/detail/Publication/3773767?lang=en_GB)).
- Against that, DORA reports performance rises when "developers are primarily responsible" for test automation, and warns the pipeline stays broken otherwise. The page gives no method ([DORA](https://dora.dev/capabilities/test-automation/)). Google records the same historical shift, without a comparison ([*SWE at Google* ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)).
- N-version programming gives correlation data (section 1), not test-defect data.

**What would change [synthesis]:**
- Split what the lock protects. Titles and assertions express behaviour and lock at red. Support files carry mechanics and pin at first green. This fits the data: the proposals on `#21`, `#44` and `#63` target the harness and change no behaviour line. `#44`'s adopted fix also edited the test's call (`createHarness(null)`), though a harness-only fix looks possible.
- The builder never gets the pen, because ImpossibleBench shows that is where Claude cheats. Disputes go to a fresh agent given the spec, the disputed test and the failure evidence, but not the diff. It may edit support files only.
- The arbiter works from a reproduction, not a verdict, given AlphaCodium's "who is wrong" warning. The local stop reports already cite the failing line or output.
- `#46` and `#18` still reach the human: an assertion changes, or an interface changes.
- After a dispute, crucible's lock check diffs the support files, and its existing changed-line mutation shows whether the disputed test still bites.
- This conflicts with two local decisions. `#179` set the north star "a test edit can never turn a fail into a pass", and dropped the amender, recorded as a scope cut with no evidence against it. The human must choose whether to reopen it.

## 3. Simpler flows

No flow here has a controlled comparison with this one.

| Flow | Evidence | Strength | What it gives up |
|---|---|---|---|
| Spec, fresh session builds, subagent reviews against the spec ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)) | "write a failing test that reproduces it, then fix it"; a reviewer "hasn't seen how the code was written". No locks. Warns a reviewer "will always find *something*" | Vendor guidance, no numbers | Read-only oracle and independent test context |
| Plan → generate → evaluator ([Anthropic, Mar 2026](https://www.anthropic.com/engineering/harness-design-long-running-apps)) | One app: solo 20 min and $9, core feature broken; harness 6 h and $200. Generator and evaluator negotiated a contract per sprint. Later sprints were removed, and the evaluator is "worth the cost when the task sits beyond what the current model does reliably solo" | Vendor anecdote, n=1 per model | Upfront tests; the evaluator tests the running app. Close to the `/build` verifier without the tester **[synthesis]** |
| Same agent, red then green ([Willison](https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/)) | Confirm failure or "risk building a test that passes already" | Opinion | Independence. No unsatisfiable tests in practice, since the author fixes them, but also nothing stops it weakening them **[synthesis]** |
| Implementer writes tests after code, then independent review | Fault detection 14% after erroneous code vs 25% independent; the test-driven workflow improved fault detection by 7.9–17.7% per model (Konstantinou). Correct-code context does no harm (Huang). Sequencing did not matter for humans (Fucci) | Measured, function-level | Fault detection when the code is wrong, which is exactly when it matters |
| Separate test agent, no lock ([AgentCoder, arXiv 2312.13010](https://arxiv.org/abs/2312.13010)) | Test accuracy 89.6% and 91.4% vs MetaGPT's 79.3% and 84.4%; pass@1 96.3% and 91.8% | Measured on HumanEval and MBPP only | Any repo-scale evidence and any protection against test edits |
| OpenAI harness engineering | **The post returned 403, so it was not read**; secondary write-ups only, not relied on | None here | Unknown |

Local data does not settle it. 0 of 17 loop PRs against 3–4 of 40 direct PRs had follow-up fixes (`#179`, not randomised). If those fixes fell at random across the 57 PRs, none landing in the 17 has probability 0.23–0.34, and 0 of 17 still allows a true rate up to about 16% (rule of three) **[synthesis]**. Clean-build share of 13–17% regardless of alignment weight says heavier alignment did not buy clean builds; it does not speak to `/tester`.

**What would change:** nothing measured justifies removing `/tester` or keeping it unchanged. The removable part is smaller: the human's sign-off on test files. All six defects passed it. It has no measured value for detecting defects (TiCoder used a simulated user and deferred a user study: [arXiv 2208.05950](https://arxiv.org/abs/2208.05950)). One controlled experiment did find reviewers who read tests first caught more test-code defects, but only its abstract was read ([Spadini et al., ICSE 2019](https://serg.ewi.tudelft.nl/publications/test-driven-code-review-an-empirical-study/)). Keep the human on behaviour lines, which matches `#179`'s north star **[synthesis]**.

## 4. Draft PR at lock and test shape

**Draft PR before implementation: nothing found.** No peer-reviewed study of drafts or of early PRs turned up. Stacking claims are vendor-reported. The local reason is operational: `#179` (2026-11-07) keeps pushing the red lock commit for a future factory, at the known price of 3 refused pushes and 4 `--no-verify` in work builds. None of the six defects relates to it **[synthesis]**.

**Shape**, all weak:

| Position | Claim | Strength |
|---|---|---|
| [Google, *SWE* ch. 11](https://abseil.io/resources/swe-book/html/ch11.html) | 80/15/5, "very rough guideline" | Rule of thumb |
| [Google blog 2015](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html) | Pyramid shape. The body did not extract, so 70/20/10 is seen only in reader comments | Rule of thumb, not fully read |
| [Spotify honeycomb](https://engineering.atspotify.com/2018/01/testing-of-microservices) | Mostly integration for microservices; "we strongly feel" | Experience |
| [Dodds trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications) | "Mostly integration"; no data | Opinion |
| [Trautsch et al., JSS 2020](https://www.swe.informatik.uni-goettingen.de/node/2878) | No evidence either level catches particular defect types better; abstract only | Measured, not on shape |

No study compares suite shapes on escaped defects. The diamond is a defensible preference with no measurement against it.

**What would change:** nothing in the shape. It does have a local price. Brigade's locked set holds 44 support files to 38 test files, and 3 of 6 defects live there. That price falls on harness locking, not on testing at module level, so address it in the lock, not the shape **[synthesis]**. `#18` also shows the cost of whole-object `toEqual`, already covered by `#179`'s lock-shape decision.

## Candidate tweaks

"Caught" means found before the stop, or resolved at the stop without `/align` and a relock where noted. All per-ticket judgements are **[synthesis]**.

| Candidate | Local defects caught | Added cost | Evidence strength |
|---|---|---|---|
| Keep as is | None earlier. All six still stop at build, and none escaped (`#5` type now closed) | None; one relock per stop, about 6 in 24 tickets | Measured for read-only and abort (ImpossibleBench, on other tests); synthesis for the rest |
| Remove `/tester` entirely | All six vanish by construction, with no lock to be wrong | Saves tester time; loses read-only oracle and spec-only tests; fault detection 14% vs 25% on faulty code | Measured against it at function level; local 0/17 vs 3–4/40 is inconclusive |
| Split lock: assertions at red, support at first green, arbiter on dispute | Resolved without relock: #21, #63, and #44 with a harness-only fix. Still human: #46, #18. #5 already closed | Arbiter run per dispute; lock-check change; loses "no test edit" as an absolute | Synthesis; analogues practitioner (anchors, approval) |
| Refuse the suffix on non-test files at lock, alone | #21, #44, #63 become builder-editable | One check; opens the hole that a builder can edit a harness to go green | Practitioner; ImpossibleBench warns against |
| Throwaway implementation before lock, disputes to tester | #21, #44, #46, #18; #63 if full suite and cap are built | About one extra builder pass per ticket; unmeasured locally | Measured on function-level only (Nexus refinement +1.71 to +18.23 points across seven benchmarks; Table 3) |
| Walking skeleton: one hard line built before lock | Whichever harness path it exercises; 0–3 of #21, #44, #63 | One unit up front | Practitioner |
| Fresh reader, spec vs tests, before lock | #46; partly #44, #63, #18 | One small agent | Measured, mixed (Nexus deliberation: +11.43 HumanEval, −0.20 LiveCodeBench) |
| Harness self-tests and contract suites for fakes | #44; partly #21 | Tests of tests to maintain | Practitioner |
| Stubs return typed defaults instead of throwing | None | Stub rewrites | Synthesis |
| Lint and format at lock | #5 | Shipped in `d63d85b` | Practitioner |
| Drop human sign-off on test files, keep behaviour lines | None lost: all six passed sign-off | Saves human time | Synthesis; review evidence abstract-only |
| Move the draft PR to first green | None | Removes refused red pushes; conflicts with the 2026-11-07 decision | Synthesis; nothing found |
| Reword the TDFlow and ImpossibleBench origin lines | None | Three or four lines of prose | Measured: the papers say otherwise |

## Not read in full

- **Fetch failed:** OpenAI's [harness engineering](https://openai.com/index/harness-engineering/) and [*Why we no longer evaluate SWE-bench Verified*](https://openai.com/index/why-we-no-longer-evaluate-swe-bench-verified/) (403). A search excerpt reports at least 59.4% of 138 audited problems had flawed tests; that would strengthen "gold-validated is not implementation-independent", but it is not relied on here. Spadini's full text (connection refused). GOOS ch. 10 (403). Cockburn's walking-skeleton page (404).
- **Abstract or record only:** Spadini, Sunyaev & Basten, Trautsch, Ricca, Beer et al.
- **Secondary only:** Knight & Leveson 1986, read through a course summary, plus the Brilliant et al. follow-up by search excerpt only.
- **Searched, nothing usable:** Melnik & Maurer; Alloy's satisfiability check; Microsoft and Yahoo test-team changes with measured results. Specification by Example and *Working Effectively with Legacy Code* were not read.
