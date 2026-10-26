# Capturing agreements and decisions before work ships, and who decides

## Scope

Asked: before an idea, bug, feature or small change moves from discussion, research, prototype or spike to something shipped, how are agreements and decisions captured, and how is deciding split between agent and human? The question covers what the artefacts look like (the capture artefact during exploration, the final spec, the cut into tickets), with real GitHub examples and measured outcomes where they exist.

Companion to [agent-delegation-best-practice.md](agent-delegation-best-practice.md), which already covers context rot, multi-agent vs single agent, handoff contents, Anthropic's long-running harnesses, self-review bias and MAST. This note does not repeat those findings.

Excluded: this repository's skills and docs (deliberately not read), and any recommendation or design for the user's system. Findings only.

Evidence classes used throughout:

- **[measured]**: a number from a controlled study, a dataset analysis, or a vendor-run measurement. Vendor-internal numbers and preprints are flagged.
- **[first-party]**: guidance or templates from the organisation that owns the practice or tool, without a published measurement.
- **[opinion]**: argument, practitioner heuristic, or secondary interpretation.
- **[observed]**: something verified directly in a public artefact for this note (via the GitHub API). It is a single case, not a rate.

Dates are publication dates. "Today" is 2026-10-26.

## 1. The "smart zone" and the ~100k-token claim

### Lineage

- **Geoffrey Huntley, 2025-07-14:** "you only have approximately 170k of context window to work with … The more you use the context window, the worse the outcomes you'll get." An earlier excerpt says Claude 3.7's output quality "clips at the 147k-152k mark" of an advertised 200k [opinion, personal observation] ([ghuntley.com/ralph](https://ghuntley.com/ralph/)).
- **HumanLayer (Dex Horthy), "Getting AI to Work in Complex Codebases", 2025-08-29:** the research → plan → implement workflow with "frequent intentional compaction", "keeping utilization in the 40-60% range (depends on complexity of the problem)". It puts human review on research and plans: "a bad line of research … could result in thousands of bad lines of code," and "When you review the research and the plans, you get more leverage than you do when you review the code." The terms "dumb zone" and "smart zone" do not appear in it [opinion/first-party practitioner] ([ace-fca.md](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)).
- **Its outcomes are anecdotes:** a BAML bug-fix PR approved overnight; 35k LOC in 7 hours (3 h research and plans, 4 h implementation) on features "estimated … 3-5 days each"; "6 PRs in a day"; and a failure on parquet-java that the author blames on shallow research [opinion, self-reported, uncontrolled] (same source).
- **"No Vibes Allowed: Solving Hard Problems in Complex Codebases", AI Engineer Code Summit talk, posted 2025-12-02** ([YouTube](https://www.youtube.com/watch?v=rmvDxxNubIg)). A write-up reports Horthy saying diminishing returns begin past "approximately 40% of the context window", naming that region the "dumb zone", and keeping implementation "under 40%" to stay in the "smart zone" [opinion; secondary account, transcript not verified] ([StartupHub, 2025-12-03](https://www.startuphub.ai/ai-news/ai-video/2025/ais-codebase-conundrum-humanlayers-context-engineering-breakthrough/)).
- **HumanLayer, "Long-Context Isn't the Answer", 2026-03-23** is the closest primary source for a ~100k number. "We used to set this at around %40 of sonnets 168k token window" (≈ 67k), and now "we've updated our context warnings for long-context models to trigger at the 100k token mark. For opus 1m this is only 10% of the context window." It uses "smart zone" and "dumb zone" without numeric boundaries. Its evidence is the team's own observation "over the course of a couple of weeks" plus IFScale (below); no adherence-by-length measurement is reported [first-party practitioner, unmeasured] ([HumanLayer blog](https://www.humanlayer.dev/blog/long-context-isnt-the-answer)).
- **Later restatements:** "This usually sits within the first ~100k tokens," with no evidence cited ([Bizzotto, Code with Andrea, 2026-07-14](https://codewithandrea.com/articles/keep-coding-agent-smart-zone/)). Matt Pocock discusses "the 'smart zone' vs the 'dumb zone'" on a Pragmatic Engineer episode (2026-09-17); the show notes give no number ([Pragmatic Engineer](https://newsletter.pragmaticengineer.com/p/ai-skills-with-matt-pocock)). A third-party glossary attributed to Pocock gives 125K–150K on frontier models, "though this is debated" (the page now 404s; seen only in a search snippet) [opinion].
- **Anthropic's own docs** say performance "degrades as it fills" and give no threshold [first-party] ([Claude Code best practices](https://code.claude.com/docs/en/best-practices)).

### Measured backing for degradation (not for a threshold)

- Input length alone cut performance 13.9%–85% across 5 models on maths, QA and coding, even with perfect retrieval and with irrelevant tokens masked. Reciting the evidence before answering recovered up to 4% [measured] ([Du et al., EMNLP Findings 2025, 2025-10-06](https://arxiv.org/abs/2510.05381)).
- LongCodeBench: Claude 3.5 Sonnet fell from 29% to 3% and Qwen2.5 from 70.2% to 40% as context grew toward 1M; "long-context remains a weakness for all models" [measured, preprint] ([Rando et al., 2025-05-12, v3 2025-10-22](https://arxiv.org/abs/2505.07897)).
- IFScale: with 500 simultaneous instructions the best frontier models reached 68% accuracy, with a bias toward earlier instructions. This is instruction density, not context length [measured, preprint] ([Jaroslawicz et al., 2025-07-15](https://arxiv.org/abs/2507.11538)).
- Chroma Context Rot and Lost in the Middle are in the prior note.

### Verdict

**No specific number is supported by evidence.** Degradation with length is measured, and its onset varies by model, task and what fills the window. The "smart zone / dumb zone" vocabulary and the 40% figure are HumanLayer practitioner heuristics, reported second-hand from a talk. "~100k" is HumanLayer's 2026 *warning trigger* for 1M-context models, chosen to roughly match its earlier 40%-of-168k rule (≈ 67k). It was not derived from a measurement. Secondary sources spread it from 60k to 150k+. Treat it as a heuristic [opinion].

## 2. Decision capture in human practice: fields, lifecycle, evidence

### Artefact shapes

**ADR, Nygard (2011-11-15)** [first-party] ([Cognitect](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)):

```
# ADR N: <short noun phrase>
Context        – forces at play (technological, political, social, project-local); value-neutral
Decision       – "We will …"
Status         – proposed → accepted → (deprecated | superseded)
Consequences   – all resulting context, positive, negative and neutral
```

One or two pages; numbered monotonically, never reused; reversed decisions are kept and marked superseded; stored in the repo (`doc/arch/adr-NNN.md`).

**MADR 4.0.0 (released 2024-09-17)** [first-party] ([template](https://github.com/adr/madr/blob/develop/template/adr-template.md)):

```
---
status: "{proposed | rejected | accepted | deprecated | … | superseded by ADR-0123}"
date / decision-makers / consulted / informed
---
# {short title, representative of solved problem and found solution}
## Context and Problem Statement
## Decision Drivers
## Considered Options
## Decision Outcome
### Consequences
### Confirmation          ← how compliance is checked (review, fitness function, arch test)
## Pros and Cons of the Options
## More Information
```

**Y-statement (Zimmermann; first presented at SATURN 2012; also Zdun et al., IEEE Software 2013)**: a one-sentence decision record [first-party] ([Zimmermann, 2020-04-27, updated 2026-09-12](https://www.ozimmer.ch/practices/2020/04/27/ArchitectureDecisionMaking.html); [Wikipedia citing Zdun et al. 2013](https://en.wikipedia.org/wiki/Architectural_decision)):

> In the context of ⟨use case⟩, facing ⟨concern⟩, we decided for ⟨option⟩ and neglected ⟨other options⟩, to achieve ⟨benefit⟩, accepting that ⟨drawback⟩.

**Design doc (Google), Malte Ubl 2020-07-06** [first-party/opinion] ([industrialempathy.com](https://www.industrialempathy.com/posts/design-docs-at-google/)): context and scope (explicitly "not a requirements document"); goals and **non-goals**; the actual design (trade-off centred; system-context diagram, API and storage sketches); **alternatives considered** ("one of the most important sections"); cross-cutting concerns (security, privacy, observability). Length is 10–20 pages for large projects and 1–3-page "mini docs" for incremental work. Lifecycle: creation and rapid iteration → review → implementation and iteration (update the doc; amendments after launch) → maintenance and learning (re-read one or two years later). Don't write one when the solution is unambiguous, when the doc would be an implementation manual, or during rapid prototyping.

**Rust RFC** [first-party] ([template](https://github.com/rust-lang/rfcs/blob/master/0000-template.md); [process](https://github.com/rust-lang/rfcs/blob/master/README.md)):

```
- Feature Name / Start Date / RFC PR / Rust Issue (tracking issue)
## Summary  ## Motivation  ## Guide-level explanation  ## Reference-level explanation
## Drawbacks  ## Rationale and alternatives  ## Prior art
## Unresolved questions   ← split into "resolve before merge" vs "resolve during implementation before stabilization" vs "out of scope"
## Future possibilities
```

Lifecycle: RFC PR → motion for final comment period (FCP) with a disposition (merge, close or postpone), needing sign-off from every sub-team member → 10-day FCP → merged ("active") → "Every accepted RFC has an associated issue tracking its implementation" → stabilisation. Being active "is not a rubber stamp"; substantial changes after acceptance need a new RFC.

**Python PEP** [first-party] ([PEP 1](https://peps.python.org/pep-0001/)): a preamble (Status, Type, Discussions-To, Post-History, Resolution, Replaces, Superseded-By …); sections Abstract, Motivation, Specification, Rationale, Backwards Compatibility, Security Implications, How to Teach This, Reference Implementation, **Rejected Ideas**, **Open Issues**. Status values are Draft, Accepted, Provisional, Final, Deferred, Rejected, Withdrawn, Superseded and Active. An Accepted PEP becomes Final once the reference implementation is merged. The Steering Council or a PEP-Delegate decides.

**Kubernetes KEP** [first-party] ([template](https://github.com/kubernetes/enhancements/tree/master/keps/NNNN-kep-template); [process](https://github.com/kubernetes/enhancements/blob/master/keps/sig-architecture/0000-kep-process/README.md)):

```
kep.yaml: status: provisional|implementable|implemented|deferred|rejected|withdrawn|replaced
          stage: alpha|beta|stable ; milestone: {alpha, beta, stable} ; reviewers ; approvers ; feature-gates
README:   Release Signoff Checklist · Summary · Motivation (Goals / Non-Goals) · Proposal (User Stories,
          Risks and Mitigations) · Design Details (Test Plan: unit/integration/e2e; Graduation Criteria:
          Alpha/Beta/GA/Deprecation; Upgrade/Downgrade; Version Skew) · Production Readiness Review
          Questionnaire (enablement/rollback, monitoring SLIs/SLOs, scalability, troubleshooting) ·
          Implementation History · Drawbacks · Alternatives
```

State definitions: `provisional` means the owning SIG accepts "that this work must be done" while the design is defined; `implementable` means "The approvers have approved this KEP for implementation"; `replaced` points to `superseded-by`.

**Oxide RFD** [first-party] ([RFD 1](https://rfd.shared.oxide.computer/rfd/0001)): states `prediscussion` (placeholder on a branch), `ideation` (topic only, a scratchpad), `discussion` (an open PR), `published` (discussion has converged; still updatable), `committed` ("entirely implemented") and `abandoned`. "Notes are encouraged to be timely rather than polished"; allow 3–5 business days for comment; do not merge an RFD no one has read.

**Amazon Working Backwards (Vogels, 2006-11-01)** [first-party] ([All Things Distributed](https://www.allthingsdistributed.com/2006/11/working_backwards.html)): four documents written before building: press release, FAQ, customer-experience description (mock-ups or code-snippet use cases), and user manual (concepts, how-to, reference). The later PR/FAQ form (one-page release plus an external and internal FAQ) is described only in secondary sources found here [opinion/secondary].

**Shape Up pitch (Basecamp)** [first-party] ([ch. 6](https://basecamp.com/shapeup/1.5-chapter-06); [ch. 3 and glossary](https://basecamp.com/shapeup/1.2-chapter-03)): Problem · **Appetite** ("How much time we want to spend and how that constrains the solution") · Solution · **Rabbit holes** · **No-gos**. "Estimates start with a design and end with a number. Appetites start with a number and end with a design." Fixed time, variable scope; small batch is 1–2 weeks, big batch 6 weeks; the **circuit breaker** cancels projects that don't ship in one cycle by default.

**Spike (XP)** [first-party] ([extremeprogramming.org](http://www.extremeprogramming.org/rules/spike.html)): "a very simple program to explore potential solutions … ignore all other concerns. Most spikes are not good enough to keep, so expect to throw it away. The goal is reducing the risk of a technical problem or increase the reliability of a user story's estimate." Timebox: a pair "for a week or two". No standard report format was found.

### Fields that recur across human artefacts

| Field | ADR | MADR | Design doc | Rust RFC | PEP | KEP | Shape Up |
|---|---|---|---|---|---|---|---|
| Problem / context | ✓ | ✓ | ✓ | Motivation | Motivation | Motivation | Problem |
| Explicit non-goals / out of scope | – | – | Non-goals | Unresolved (out of scope) | – | Non-Goals | No-gos |
| Alternatives / rejected options | – | Considered Options | ✓ | ✓ | Rejected Ideas | Alternatives | – |
| Consequences / drawbacks | ✓ | ✓ | – | Drawbacks | Backwards Compat. | Drawbacks, Risks | Rabbit holes |
| Open questions | – | – | – | ✓ (staged) | Open Issues | – | – |
| How "done" is verified | – | Confirmation | – | – | Reference Impl. | Test Plan, Graduation Criteria | – |
| Time budget | – | – | – | – | – | milestones | Appetite |
| Lifecycle status | ✓ | ✓ | – | PR + tracking issue | ✓ | ✓ | cycle / circuit breaker |
| Named decider | – | decision-makers | reviewers | sub-team FCP | Steering Council / Delegate | approvers | betting table |

### Empirical evidence on human decision capture

- **Knowledge vaporisation:** Jansen and Bosch (2005) named the loss of architectural decisions that live only as tacit knowledge [established concept; original not accessed, via secondary sources]. A survey of 81 practitioners found they value design rationale and use it to reason, but face barriers to documenting it [measured, survey] ([Tang et al., JSS 79(12), 2006](https://figshare.swinburne.edu.au/articles/report/A_survey_of_architecture_design_rationale/26269849)).
- **Controlled experiment:** with 50 master's students, documented design rationale significantly improved the effectiveness of individual and team decision-making with no change in efficiency [measured, students] ([Falessi, Cantone, Becker, ISESE 2006](https://art.torvergata.it/handle/2108/57816)).
- **ADR adoption on GitHub:** adoption is low but rising every year. About 50% of repos with ADRs hold only 1–5. Systematic use involves "two or more users over a longer period of time"; Nygard's template dominates [measured, MSR] ([Buchgeher et al., IEEE Access 11, 2023](https://research.jku.at/en/publications/using-architecture-decision-records-in-open-source-projects-an-ms/)).
- **Template comparison:** in an expert screening of five templates (Tyree/Akerman, Nygard, arc42, Y-statement, MADR), Nygard and MADR came out top. In a student experiment Nygard beat MADR on overall score; the abstract gives no N or statistics [measured, preprint, small] ([Nogueira et al., 2026-04-30](https://arxiv.org/abs/2604.27333)).
- **Process conformance:** mined PEP decision-making did not comply with the documented process, which "lacks the right level of granularity" [measured, mining study] ([Savarimuthu et al., ECIS 2016, via search summary](https://ro.uow.edu.au/eispapers/6479)).
- **LLMs and decision records:** checking code against 980 ADRs from 109 repos, LLMs were accurate on explicit, code-inferable decisions and weaker on implicit or deployment decisions [measured, preprint] ([Su et al., 2026-02-07](https://arxiv.org/abs/2602.07609)). LLM-generated rationale reached precision 0.27–0.28 and recall 0.63–0.72 against expert rationale; 64–69% of the extra arguments were judged helpful and 1.6–3.2% potentially misleading [measured] ([Zhou et al., ACM TOSEM, 2025](https://arxiv.org/abs/2504.20781)). A multi-agent pipeline drafted Nygard ADRs from five meeting transcripts and captured "most" expert-identified decisions; RAG enrichment introduced content not faithful to the transcript [measured, small, preprint] ([da Silva & Gama, 2026-08-18](https://arxiv.org/abs/2608.17694)).
- **No study found** that measures RFC, KEP, PR/FAQ or Shape Up pitch effectiveness on delivery outcomes, or any spike-report format.

## 3. Agent-era capture and spec artefacts

### GitHub Spec Kit (latest release v1.2.3, 2026-10-22) [first-party] ([repo](https://github.com/github/spec-kit))

Commands: `constitution`, `specify`, `clarify`, `plan`, `tasks`, `analyze`, `checklist`, `implement`, `converge`, and `taskstoissues` (deprecated; moved to a `github` extension).

`constitution.md`: `# [PROJECT_NAME] Constitution` · `## Core Principles` (five named principles) · two free sections · `## Governance`.

`spec.md` ([template](https://github.com/github/spec-kit/blob/main/templates/spec-template.md)):

```
# Feature Specification: [FEATURE NAME]
**Feature Branch** / **Created** / **Status**: Draft / **Input**: User description: "$ARGUMENTS"
## User Scenarios & Testing (mandatory)
### User Story 1 - [Title] (Priority: P1)
  **Why this priority** · **Independent Test** · **Acceptance Scenarios**
### Edge Cases
## Requirements (mandatory)
### Functional Requirements   - **FR-001**: System MUST …   - **FR-006**: … [NEEDS CLARIFICATION: auth method not specified …]
### Key Entities
## Success Criteria (mandatory)
### Measurable Outcomes       - **SC-001**: [Measurable metric]
## Assumptions
```

`plan.md`: Summary · Technical Context (Language/Version, Primary Dependencies, Storage, Testing, Target Platform, Project Type, Performance Goals, Constraints, Scale/Scope, each allowing "NEEDS CLARIFICATION") · **Constitution Check** · Project Structure · **Complexity Tracking**.

`tasks.md`: format `[ID] [P?] [Story] Description`. Phase 1 Setup → Phase 2 Foundational ("No user story work can begin until this phase is complete") → one phase per user story, each with a **Goal**, an **Independent Test** and a closing **Checkpoint** → polish. "Tests are OPTIONAL - only include them if explicitly requested."

`checklist.md`: a "reviewer-owned requirements-quality review artifact"; `[x]` "does not mean implementation work is complete."

**Human/agent split encoded in the commands** [first-party]:

- `specify`: "**LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**" — only where "No reasonable default exists". Otherwise "Use reasonable defaults … document assumptions in Assumptions section". If more than 3, "keep only the 3 most critical (by scope/security/UX impact) and make informed guesses for the rest."
- `clarify`: "asking up to 5 highly targeted clarification questions", one at a time, "Never reveal future queued questions". Each question carries a "Why it matters" line and a "**Recommended:** Option [X]" the user can accept with "yes". Questions are limited to ones that "materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, or compliance validation."
- `converge`: "Assess the current codebase against the feature's spec, plan, and tasks, then append any remaining unbuilt work as new tasks."

### AWS Kiro [first-party] ([Specs, updated 2026-10-15](https://kiro.dev/docs/specs/); [Feature specs, 2026-08-04](https://kiro.dev/docs/specs/feature-specs/); [Bugfix specs, 2026-08-04](https://kiro.dev/docs/specs/bugfix-specs/))

- Three files: `requirements.md` (or `bugfix.md`), `design.md` and `tasks.md`. Requirements use EARS: "WHEN [condition/event] THE SYSTEM SHALL [expected behavior]". Workflows run Requirements-First (Requirements → Design → Tasks) or Design-First (Design → Requirements → Tasks).
- `bugfix.md`: **Current behavior** "WHEN … THEN the system [incorrect behavior]" · **Expected behavior** "… SHALL …" · **Unchanged behavior (regression prevention)** "… SHALL CONTINUE TO …". `design.md` holds root cause, fix and properties to test; tasks carry property-based tests for repro, fix and no-regression.
- Gates: a Review button opens Markdown Review per document; "Quick Spec" runs "without approval gates", which implies standard specs have them. Tasks execute in dependency "waves".
- EARS origin: Mavin et al., Rolls-Royce, IEEE RE'09. Its claimed reduction of natural-language requirement problems was not verified here [first-party claim] ([Wikipedia](https://en.wikipedia.org/wiki/Easy_Approach_to_Requirements_Syntax)).

### Tessl [first-party] ([docs](https://docs.tessl.io/reference))

`.spec.md` files with a required Target section linking `@generate` (generate code from the spec) or `@describe` (document existing code), an `{ .api }` block, `@use` dependencies, and capabilities each linked to a `[@test]` file. The full framework is in closed beta, and a registry tile uses a different YAML-frontmatter convention [first-party; two conventions, not reconciled].

### HumanLayer research → plan → implement (2025-08-29) and QRSPI (2026)

The research doc covers relevant files, information flow and possible causes. The plan covers exact steps, files to edit, and testing. Status is compacted back into the plan after each verified phase; a write-up summarises the plan as filenames, line numbers, snippets and test steps [opinion/first-party practitioner] ([ace-fca.md](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)). HumanLayer's 2026 talks ("Lessons Learned Rolling Out RPI to Hundreds of Engineers", 2026-03-24; "Everything We Got Wrong About Research-Plan-Implement", 2026-04-20) describe a move to smaller workflows and a "QRSPI" variant. These were listed only in [HumanLayer's resources index](https://www.humanlayer.dev/blog/humanlayer-resources) and not watched — **contents unverified**.

### Claude Code [first-party] ([best practices, living doc](https://code.claude.com/docs/en/best-practices))

- Interview prompt: "Interview me in detail using the AskUserQuestion tool … technical implementation, UI/UX, edge cases, concerns, and tradeoffs. Don't ask obvious questions … then write a complete spec to SPEC.md." Then execute it in a fresh session.
- Plan mode: explore → plan (Ctrl+G to edit the plan) → implement → commit. "If you could describe the diff in one sentence, skip the plan."
- Plan-conformance review prompt: "review the … diff against PLAN.md. Check that every requirement is implemented, the listed edge cases have tests, and nothing outside the task's scope changed. Report gaps, not style preferences."
- Permissions changed: auto mode is now the default starting mode (v2.1.283+), with a classifier that blocks "scope escalation, unknown infrastructure, and hostile-content-driven actions". This supersedes the August 2025 framing that Claude Code "must ask for human approval before taking any actions that modify code or systems" ([Anthropic, safe and trustworthy agents framework, 2025-08](https://www.anthropic.com/news/our-framework-for-developing-safe-and-trustworthy-agents)).

### OpenAI Codex ExecPlans (`PLANS.md`; cookbook, first committed 2025-10-14, now marked archived) [first-party] ([source](https://github.com/openai/openai-cookbook/blob/main/articles/codex_exec_plans.md))

```
# <Short, action-oriented description>
## Purpose / Big Picture
## Progress                    ← timestamped checkboxes; the only place checklists are allowed
## Surprises & Discoveries     ← "Observation: …" with evidence snippets
## Decision Log                ← "Decision: …" plus rationale, date
## Outcomes & Retrospective
## Context and Orientation  ## Plan of Work  ## Concrete Steps
## Validation and Acceptance  ## Idempotence and Recovery  ## Artifacts and Notes  ## Interfaces and Dependencies
```

Rules: "fully self-contained … all knowledge and instructions needed for a novice to succeed"; a "living document"; "Validation is not optional." On autonomy: "do not prompt the user for 'next steps'; simply proceed to the next milestone … Resolve ambiguities autonomously, and commit frequently." The only number given is that a similar document "enabled Codex to work for more than seven hours from a single prompt" [first-party, single case].

**OpenAI "Harness engineering" (Ryan Lopopolo, 2026-02-11): still 403, unverified.** Search snippets from openai.com describe a ~100-line AGENTS.md used as a map into `docs/`, a `docs/exec-plans/{active,completed}/` tree with `tech-debt-tracker.md`, and "a million lines of code" with no manually written code. A third party says a team of three over five months [unverified].

### Issue-to-agent guidance [first-party]

- **GitHub Copilot coding agent** ([docs](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results)): a good issue has "A clear description of the problem," acceptance criteria (for example, whether tests are expected), and guidance on which files should change; "treat the issue as a prompt." Keep for humans: broad cross-repo refactors, heavy business logic, "Tasks involving security, personally identifiable information, authentication repercussions," production-critical and incident work, ambiguous or deep-domain tasks, and learning tasks. Iterate by mentioning `@copilot` in batched PR reviews; only users with write access are obeyed.
- **Devin** ([instructing](https://docs.devin.ai/essential-guidelines/instructing-devin-effectively); [when to use](https://docs.devin.ai/essential-guidelines/when-to-use-devin)): "Make important decisions and judgment calls for Devin"; "Define clear scope, boundaries, and success criteria"; "if a task would take you three hours or less, Devin can most likely do it"; "Good tasks have a clear start and end, plus explicit success criteria"; split larger work into one session per verifiable sub-task.
- **Factory Droid Spec Mode** ([docs](https://docs.factory.com/cli/user-guides/specification-mode)): read-only research and a proposed plan, then `ExitSpecMode` requests approval. The user picks manual approvals or autonomy Low ("File edits plus low-risk commands"), Medium (plus "reversible workspace changes such as installs, builds, and local commits") or High. Approved specs are saved as `YYYY-MM-DD-slug.md`, and organisations can cap the maximum level.
- **Cursor Plan Mode** ([docs](https://cursor.com/docs/agent/plan-mode)): asks clarifying questions, researches, writes a plan the user edits as Markdown, then "Click to build."
- No vendor above publishes outcome data for its spec format.

## 4. Human vs agent decision balance

### Frameworks

- **Origin:** Sheridan & Verplank (1978) proposed a 10-point scale of automation. Parasuraman, Sheridan & Wickens (IEEE SMC-A, 2000) applied levels separately to four functions: information acquisition, information analysis, decision and action selection, and action implementation. Middle levels include "suggests one alternative", "executes unless the human vetoes within a time window", and so on [established; via secondary reproductions, originals not accessed] ([MITRE reproduction](https://www.mitre.org/sites/default/files/pdf/pr-16-3426-lessons-lost-automation-in-aviation-definition-of-automation.pdf)).
- **Feng, McDonald & Zhang, "Levels of Autonomy for AI Agents" (2025-06-14, v2 2025-07-28):** five levels defined by the user's role: operator, collaborator, consultant, approver, observer. The paper proposes "autonomy certificates". It is conceptual, with no measurement [opinion/framework] ([arXiv 2506.12469](https://arxiv.org/abs/2506.12469)).
- **Shipped equivalents:** Factory's Off/Low/Medium/High; Claude Code's Manual/auto/plan modes; Google ADK's experimental Tool Confirmation, which pauses for "decision making, verification, security, or general oversight" [first-party] ([ADK](https://adk.dev/tools-custom/confirmation/)).

### Usage data (what people actually delegate)

- **Anthropic, "Measuring AI agent autonomy in practice" (2026-02-18)** [measured, vendor data]:
  - The longest Claude Code turns (99.9th percentile) went from under 25 to over 45 minutes between Oct 2025 and Jan 2026.
  - Full auto-approve rises from ~20% of sessions (under 50 sessions of experience) to over 40% by 750 sessions. Interrupt rate rises from 5% to ~9% of turns with experience.
  - On the hardest tasks Claude stops to ask for clarification more than twice as often as on minimal ones.
  - Internally, interventions per session fell from 5.4 to 3.3.
  - Public API: 73% of tool calls appear to have a human in the loop (an upper bound), 0.8% of actions appear irreversible, and software engineering is ~50% of tool calls.
  - Position: "effective oversight doesn't require approving every action but being in a position to intervene when it matters" ([Anthropic](https://www.anthropic.com/research/measuring-agent-autonomy)).
- **Anthropic internal study (2025-12-02; survey of 132 plus 53 interviews, 200k transcripts, Aug 2025)** [measured, self-report plus vendor transcripts]:
  - Claude is used in 59% of work, but more than half of respondents can "fully delegate" only 0–20% of it.
  - Delegated work is easy to verify, low-stakes, repetitive, or well-defined. Kept work is "high-level thinking, design decisions," and tasks needing organisational context or "taste".
  - Human turns per transcript fell from 6.2 to 4.1, and the design/planning share of usage rose from 1.0% to 9.9% ([Anthropic](https://www.anthropic.com/research/how-ai-is-transforming-work-at-anthropic)).
- **Economic Index** [measured, vendor data]:
  - Claude Code was 79% automation vs 49% on Claude.ai, and directive 43.8% vs 27.5% (2025-04-28, sample from Apr 6–13 2025) ([software development report](https://www.anthropic.com/research/impact-software-development)).
  - June 2026: Claude Code shows higher autonomy than chat for 26 of 31 output types (+0.37 on a 1–5 scale), and the median Claude Code blog-producing session has a single human prompt ([June 2026 report](https://www.anthropic.com/research/economic-index-june-2026-report)).
  - Claude.ai augmentation (52%) overtook automation (45%) in the January 2026 report ([Jan 2026](https://www.anthropic.com/research/anthropic-economic-index-january-2026-report)).

### Productivity evidence

- **METR RCT (early 2025):** experienced open-source developers were 19% *slower* with AI (CI +2% to +39%) while believing they were faster [measured, RCT].
- **METR follow-up (2026-02-24):** 57 developers, 143 repos, 800+ tasks. Time change was −18% for returning developers (CI −38% to +9%) and −4% for new recruits (CI −15% to +9%); both intervals include zero. METR calls the data "an unreliable signal" because developers refused to work without AI and withheld AI-friendly tasks, which likely biases toward underestimating speedup. The design is being changed [measured, with stated selection bias] ([METR](https://metr.org/blog/2026-02-24-uplift-update/)).
- **DORA 2025 (2025-09-23; ~5,000 respondents):** 90% use AI and more than 80% believe it raised their productivity, while ~30% have little or no trust in AI-generated code. AI adoption correlates positively with throughput and *negatively* with delivery stability: "AI doesn't fix a team; it amplifies what's already there" [measured, survey] ([Google Cloud](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)). The AI Capabilities Model includes working in small batches (large AI-generated changes are hard to review), a clear and communicated AI stance, and AI-accessible internal data with least-privilege retrieval [first-party] ([dora.dev capabilities](https://dora.dev/capabilities/working-in-small-batches/)). No 2026 annual DORA report was found.

### Where human checkpoints add value: plan review vs code review

- **HULA at Atlassian (ICSE-SEIP 2025):** human gates at plan and at code. Of 663 Jira issues: plan generated 527 (79%) → plan approved 433 (82%) → code generated 376 (87%) → PR raised 95 (25%) → merged 56 (59%), so ~8% end-to-end. In a survey of 109 engineers, 69% and 64% said plans matched the issue and their approach, 67% disagreed that the code fully addressed the issue without humans, and 54% disagreed that it was defect-free. "Human involvement is still needed to ensure the code completely addresses the task." The biggest drop-off is *after* plan approval, between code and PR [measured, single company] ([Takerngsaksiri et al.](https://arxiv.org/html/2411.12924v1)).
- **Field study, 19 developers × 33 issues (ASE'25):** about half were resolved. Incremental collaborators did better than one-shot issue pasters, and the authors recommend agents "challenge developers" rather than be sycophantic [measured, small] ([Kumar et al.](https://arxiv.org/abs/2506.12347)).
- **Interviews with 17 developers (2026-06-03):**
  - Oversight takes four forms: a priori control, co-planning, real-time monitoring, and post-hoc review.
  - Heuristic #1 is judging the work by the plan ("I just look at the plan"). The authors call this an *assumption* that agents follow plans; participants report tangents ("It starts doing random things").
  - Developers keep the choice of approach, responsibility for test cases ("100% responsible"), deny-lists for deletions, and scope (small chunks).
  - "If you provide a high level plan, you get high level code."
  - [measured, qualitative] ([Dhanorkar et al.](https://arxiv.org/html/2606.05391))
- **Underspecification:** models "struggle to distinguish between well-specified and underspecified instructions"; interacting to resolve underspecification improved performance by up to 74% over non-interactive runs [measured, ICLR 2026] ([Ambig-SWE](https://arxiv.org/abs/2502.13069)).
- **Counter-position:** "The End of Code Review: Coding Agents Supersede Human Inspection" argues human review is no longer a necessary gate [opinion, position paper] ([Monperrus, 2026-06-11](https://arxiv.org/abs/2606.13175)).
- **No controlled study was found** that compares plan review with code review as the human checkpoint. HumanLayer's "more leverage" claim is practitioner opinion.

### Who decides what: source positions

| Decision | Human owns, per | Agent may own, per | Evidence class |
|---|---|---|---|
| Scope, approach, judgement calls | Devin ("Make important decisions and judgment calls for Devin"); Anthropic staff keep "design decisions", "taste"; interviewees pick the approach | Spec Kit `specify`: reasonable defaults recorded under Assumptions, ≤3 open questions; ExecPlans: "Resolve ambiguities autonomously" | first-party; measured (self-report, qualitative) |
| Acceptance criteria / success | Copilot and Devin: the issue author states them; interviewees: humans own test cases | Kiro and Spec Kit generate draft criteria for human review | first-party; qualitative |
| Clarifying questions | Human answers | Spec Kit `clarify`: agent picks ≤5, recommends an answer the user can accept with "yes"; Claude asks more on harder tasks | first-party; measured (vendor) |
| Security, PII, auth, production incidents | Copilot docs: keep for humans | – | first-party |
| High-stakes or irreversible actions | Anthropic framework: sign-off "before high-stakes decisions"; interviewees use deny-lists; Factory caps autonomy; ADK confirmation | Claude Code auto mode: a classifier decides routine actions | first-party; measured (0.8% of API actions irreversible) |
| Per-action approval | – | Anthropic: approving every action "may add friction without clear safety benefits"; experienced users auto-approve more | first-party + vendor data |
| Merge / acceptance | Maintainers (all PR datasets); HULA's human code gate | Monperrus argues agents can replace review | measured; opinion |

## 5. Measured outputs and real GitHub examples

### Datasets of agent PRs and issues

- **AIDev (Li, Zhang & Hassan, 2025-07-20):** 456k+ agent PRs across 61k repos by Codex, Devin, Copilot, Cursor and Claude Code. In the AIDev-pop subset (repos with >500 stars; 7,122 agent PRs), merge rates were Codex 64%, Devin 49% and Copilot 35% against a human baseline of 76.8%. Table 5 gives 65.3/48.9/38.2, plus Cursor 51.4 and Claude Code 52.5. For documentation PRs, Codex (88.6%) and Claude Code (85.7%) beat humans (76.5%) [measured, preprint, with internal inconsistencies] ([arXiv 2507.15003](https://arxiv.org/html/2507.15003v1)).
- **Failed agentic PRs (Ehsani et al., 2026-01-21, MSR'26):** 33,596 PRs from an AIDev-pop variant (>100 stars) [measured] ([arXiv 2601.15195](https://arxiv.org/html/2601.15195v1)):
  - Merge rates: Codex 82.6%, Cursor 65.2%, Claude Code 59.0%, Devin 53.8%, Copilot 43.0%.
  - By task: documentation 84%, CI 79% and build 74% merge at the highest rates; performance (55%) and fix (64%) at the lowest.
  - Odds: merge odds fall ~1% per extra changed line and ~15% per failed CI check.
  - In 562 rejected PRs: 38% abandoned or never reviewed, 23% duplicates, 4% unwanted feature, 17% CI/test failure, only 1% "wrong task description". Maintainers repeatedly ask for "small, focused" PRs.
- **What predicts agent difficulty:** over CoderForge trajectories, static features predict difficulty at AUC 0.863. Patch fragmentation and repository scale dominate; prompt-text features matter only for mid-difficulty tasks [measured, ESEM 2026] ([Al-Haque & Johnson, 2026-08-18](https://arxiv.org/abs/2608.18280)).
- **Bug-report quality:** resolvable bug reports have 110%–2700% higher description-quality scores than non-resolvable ones (Meng et al. 2024, as cited by CodeScout). CodeScout itself rewrites underspecified requests into fuller problem statements via codebase pre-exploration (ACL Findings 2026) [measured, cited second-hand] ([arXiv 2603.05744](https://arxiv.org/abs/2603.05744)).
- **SWE-bench Verified (OpenAI, 2024-08-13):** 93 developers triple-annotated 1,699 SWE-bench samples for problem-statement underspecification and unfair tests, keeping 500. The commonly cited 38.3% underspecified / 61.1% unfair tests / 68.3% filtered figures could not be confirmed here (openai.com returned 403). OpenAI has since stopped reporting Verified and recommends SWE-bench Pro, citing training contamination [first-party; page not accessed, figures via secondary summaries] ([OpenAI](https://openai.com/index/introducing-swe-bench-verified/); [why we no longer evaluate](https://openai.com/index/why-we-no-longer-evaluate-swe-bench-verified/)).

### Real artefacts on GitHub (each verified via the GitHub API on 2026-10-26)

**Kubernetes KEP-753, Sidecar Containers** [observed] ([KEP](https://github.com/kubernetes/enhancements/tree/master/keps/sig-node/753-sidecar-containers); [tracking issue #753](https://github.com/kubernetes/enhancements/issues/753)):

- Lifecycle: `kep.yaml` has `creation-date: 2018-05-14`, `status: implemented`, `stage: stable`, milestones alpha v1.28 → beta v1.29 → stable v1.33. The tracking issue opened 2019-01-29 and closed 2025-05-16, seven years from proposal to GA.
- README (~2,000 lines): Release Signoff Checklist · Summary · Motivation · Proposal · Design Details · Production Readiness Review Questionnaire · Implementation History · Drawbacks · Future use of restartPolicy field · Alternatives.

**Rust RFC 2497, if-/while-let-chains** [observed] ([RFC text](https://github.com/rust-lang/rfcs/blob/master/text/2497-if-let-chains.md); [RFC PR](https://github.com/rust-lang/rfcs/pull/2497); [tracking issue #53667](https://github.com/rust-lang/rust/issues/53667); [stabilisation PR #132833](https://github.com/rust-lang/rust/pull/132833)):

- Lifecycle: RFC PR opened 2018-07-13 and merged 2018-08-24, when the tracking issue was opened. Stabilisation PR "Stabilize let chains in the 2024 edition" merged 2025-04-22, the same day the tracking issue closed.
- Headings: Summary · Motivation · Guide-level explanation · Reference-level explanation (Grammar, Rollout Plan, Semantics) · Drawbacks · Rationale and alternatives (including "A survey - Method/Data/Analysis") · Prior art (Swift, Kotlin) · **Unresolved questions** (The final syntax; Irrefutable let bindings …) · Appendices.

**ADRs in a production repo, Backstage** [observed] ([docs/architecture-decisions](https://github.com/backstage/backstage/tree/master/docs/architecture-decisions)): `adr000-template.md` to `adr015`. ADR013 is titled `'ADR013: [superseded] Proper use of HTTP fetching libraries'` with a note "superseded by ADR014 … no longer applies"; its body is Context · Decision · Consequences (Nygard). The example catalogue [architecture-decision-record/architecture-decision-record](https://github.com/architecture-decision-record/architecture-decision-record) (formerly joelparkerhenderson/…, 17.3k stars, pushed 2026-10-21) is examples and templates, not a live project.

**Spec Kit in a shipped feature, `pamburus/hl` (3.3k-star log viewer)** [observed] ([specs/010-pager](https://github.com/pamburus/hl/tree/master/specs/010-pager)):

- Files: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `tasks.md`, `checklists/`.
- `spec.md` headings: `## Clarifications` → `### Session 2026-02-16`, `### Session 2026-02-15`, `### Session 2025-01-15` · User Scenarios & Testing (9 user stories, P1–P3) · Edge Cases · Requirements (71 FR lines, grouped e.g. "Pager Execution and Security", "Environment Variable Handling").
- Clarifications are logged as Q→A decisions, for example: "Q: Should env.delimiter override a profile's delimiter …? → A: No. Profiles are coherent units … Breaking this coherence causes footguns."
- Shipped on branch `010-pager` as PRs [#1330](https://github.com/pamburus/hl/pull/1330) (merged 2026-02-16) and [#1345](https://github.com/pamburus/hl/pull/1345) (merged 2026-02-26). A follow-up fix, [#1434](https://github.com/pamburus/hl/pull/1434) "remove --mouse from default less arguments", merged 2026-05-18.
- **Artefact drift:** the spec header still reads `**Status**: Draft`. `tasks.md` has 51 of 66 tasks ticked, and phases marked ✅ still contain unticked tasks (for example T016–T018 under "Phase 3 … ✅").

**Kiro-layout specs in a shipped feature, `growilabs/growi`** [observed] ([.kiro/specs/hotkeys](https://github.com/growilabs/growi/tree/master/.kiro/specs/hotkeys)):

- Files: `requirements.md`, `design.md`, `tasks.md`, `spec.json`. `spec.json` records `"phase": "implementation-complete"` and `approvals.{requirements,design,tasks}.{generated,approved}: true`. That approvals file matches the cc-sdd convention ([gotalab/cc-sdd](https://github.com/gotalab/cc-sdd)) rather than documented Kiro behaviour — **toolchain not confirmed**.
- `requirements.md`: Introduction · Current Architecture Overview · Registered Hotkeys table · "Requirement N" with **Objective** ("As a developer, I want …") and numbered **Acceptance Criteria** ("The GROWI application shall …").
- `design.md` contains "## Implementation Deviations from Requirements" (a table: Requirement | Deviation | Justification). `tasks.md` ends with a Requirements Coverage matrix.
- Shipped as [#10807](https://github.com/growilabs/growi/pull/10807) (merged 2026-02-24). Four months later, [#11340](https://github.com/growilabs/growi/pull/11340) (merged 2026-06-22) fixed `Ctrl+/` firing inside the editor and restored the old react-hotkeys behaviour of ignoring shortcuts in editable elements. That was an implicit behaviour the spec's "preserve all existing hotkey functionality" requirements did not enumerate.
- GitHub code search returns ~30k `requirements.md` files under `.kiro/specs` containing "SHALL" (a count of matching files, not of projects).

**Copilot coding agent, issue → PR in dotnet/runtime** [observed] ([issue #136102](https://github.com/dotnet/runtime/issues/136102) → [PR #136126](https://github.com/dotnet/runtime/pull/136126)):

- The issue was written by a human (2026-10-19) and assigned to `jkotas` and `Copilot`. Its structure: Description (with the CoreCLR vs NativeAOT discrepancy) · Reproduction Steps (a complete C# program) · Expected behavior ("Proposed: CoreCLR's", with exact expected output). It links the earlier issue where the gap was noticed.
- The PR body was agent-written: a one-line problem statement · **Validation** · **Regression coverage** · "Fixes #136102". It took 8 commits and 5 review comments from `jkotas`, plus a Copilot automated review, before approval by `MichalStrehovsky`. Merged 2026-10-21, two days after the issue.

## Where sources disagree

| Question | Position A | Position B | Scope / reconciliation |
|---|---|---|---|
| Is there a context threshold? | HumanLayer: 40% band (2025), 100k-token warning (2026); Huntley ~147–170k; others 60k–150k+ | Measured studies: degradation is graded and model- and task-dependent; Anthropic gives no number | Numbers are tool settings and heuristics, not findings |
| Where the human checkpoint goes | HumanLayer: review research and plans for "more leverage"; interviewees judge work by the plan | HULA: largest loss is after plan approval (code → PR 25%); interviewees report agents leaving plans; Copilot/maintainers: review the PR | No controlled comparison exists |
| How many questions the agent asks | Spec Kit: ≤3 markers in `specify`, ≤5 in `clarify`, defaults otherwise; ExecPlans: resolve autonomously | Claude Code: "Keep interviewing until we've covered everything"; Ambig-SWE: interaction up to +74% on underspecified tasks | Spec Kit caps human load; Ambig-SWE measures the benefit of asking. No study tests a cap |
| Per-action approval | Anthropic framework (2025-08): ask before modifying code or systems | Anthropic 2026: approving every action adds friction without clear benefit; auto mode is now default | Same vendor; superseded within a year |
| Spec detail | Spec Kit/Kiro: multi-file specs with FR/SC IDs and EARS criteria | Anthropic planner (prior note): high-level only; Google: no design doc when unambiguous; Claude Code: skip planning for one-sentence diffs | Depends on task size; unmeasured |
| Agent PR merge rates | AIDev v1: Codex 64%, Devin 49%, Copilot 35% (>500-star repos) | Ehsani et al.: Codex 82.6%, Devin 53.8%, Copilot 43.0% (>100-star variant) | Different subsets and periods; neither controls for task type or issue quality |
| Is code review still needed? | HULA, interviewees, METR, DORA stability finding | Monperrus 2026 position paper | Evidence vs argument |
| ADR template | Nygard most adopted (Buchgeher) and preferred in a student experiment | MADR better for structural detail (same experiment) | Small samples |

## Evidence strength and gaps

- **Strongest measured evidence:** length-driven degradation (Du et al.; LongCodeBench; IFScale); the HULA funnel; the AIDev-derived merge and failure data; METR RCTs (with stated bias); DORA survey correlations; Anthropic's vendor usage data on auto-approve, interrupts and delegation.
- **Vendor-internal or self-reported:** all Anthropic usage and Economic Index numbers; Anthropic staff productivity self-reports; HumanLayer outcome anecdotes; OpenAI's "seven hours" ExecPlan claim.
- **Asserted but unmeasured:** any token threshold for a "smart zone"; that research or plan review beats code review as the human checkpoint; that Spec Kit's ≤3/≤5 question caps are right; that EARS, user-story priorities or FR/SC IDs improve agent outcomes; that spec-driven tools improve delivery (GitHub, AWS, Tessl, Factory and Cursor publish no outcome data).
- **No study found** that measures:
  - decision-artefact effectiveness for RFCs, KEPs, PR/FAQs, Shape Up pitches or spike reports;
  - how often agent-era specs stay in sync with shipped code (the two GitHub examples show drift and a missed implicit behaviour, but they are single cases);
  - which specific decisions, when left to the agent, cause rework.
- **Preprints and small samples:** the ADR template experiment (N not stated), GADR (5 transcripts), the 17-developer interview study, and the 19-developer field study.
- **Fast-moving:** Anthropic's approval guidance changed between 2025-08 and 2026; Spec Kit deprecated `taskstoissues` in favour of an extension and added `converge`; OpenAI's ExecPlans cookbook is marked archived; HumanLayer revised RPI into smaller workflows (2026 talks, unverified).
- **Not accessed:** OpenAI "Harness engineering", SWE-bench Verified pages, and "Practices for governing agentic AI systems" (all 403); the "No Vibes Allowed" transcript; the Sheridan & Verplank and Parasuraman et al. originals; Jansen & Bosch 2005; the full Buchgeher abstract (DOAJ 403; JKU summary used).

## Sources

| Source | Owner | Date | Class |
|---|---|---|---|
| [Ralph Wiggum as a software engineer](https://ghuntley.com/ralph/) | Geoffrey Huntley | 2025-07-14 | opinion |
| [Getting AI to Work in Complex Codebases (ace-fca)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md) | HumanLayer (Dex Horthy) | 2025-08-29 | practitioner, anecdotal |
| [No Vibes Allowed (talk)](https://www.youtube.com/watch?v=rmvDxxNubIg) / [StartupHub write-up](https://www.startuphub.ai/ai-news/ai-video/2025/ais-codebase-conundrum-humanlayers-context-engineering-breakthrough/) | HumanLayer / StartupHub | 2025-12-02 / 2025-12-03 | opinion (secondary) |
| [Long-Context Isn't the Answer](https://www.humanlayer.dev/blog/long-context-isnt-the-answer) | HumanLayer (Kyle) | 2026-03-23 | practitioner, unmeasured |
| [Keep your coding agent in the smart zone](https://codewithandrea.com/articles/keep-coding-agent-smart-zone/) | Andrea Bizzotto | 2026-07-14 | opinion |
| [Context Length Alone Hurts LLM Performance](https://arxiv.org/abs/2510.05381) | Du et al. | 2025-10-06 (EMNLP Findings) | measured |
| [LongCodeBench](https://arxiv.org/abs/2505.07897) | Rando et al. | 2025-05-12 (v3 2025-10-22) | measured, preprint |
| [How Many Instructions Can LLMs Follow at Once?](https://arxiv.org/abs/2507.11538) | Jaroslawicz et al. | 2025-07-15 | measured, preprint |
| [Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | Michael Nygard | 2011-11-15 | first-party |
| [MADR template](https://github.com/adr/madr) | ADR org | v4.0.0, 2024-09-17 | first-party |
| [Architectural decision making (Y-statements)](https://www.ozimmer.ch/practices/2020/04/27/ArchitectureDecisionMaking.html) | Olaf Zimmermann | 2020-04-27 (upd. 2026-09-12) | first-party |
| [Design Docs at Google](https://www.industrialempathy.com/posts/design-docs-at-google/) | Malte Ubl | 2020-07-06 | first-party / opinion |
| [Rust RFCs README and template](https://github.com/rust-lang/rfcs) | Rust project | living | first-party |
| [PEP 1](https://peps.python.org/pep-0001/) | Python | living | first-party |
| [KEP process and template](https://github.com/kubernetes/enhancements/tree/master/keps) | Kubernetes | living | first-party |
| [RFD 1](https://rfd.shared.oxide.computer/rfd/0001) | Oxide | undated | first-party |
| [Working Backwards](https://www.allthingsdistributed.com/2006/11/working_backwards.html) | Werner Vogels | 2006-11-01 | first-party |
| [Shape Up](https://basecamp.com/shapeup) | Basecamp (Ryan Singer) | 2019 | first-party |
| [Spike solution](http://www.extremeprogramming.org/rules/spike.html) | Don Wells, XP | 1999 | first-party |
| [A survey of architecture design rationale](https://figshare.swinburne.edu.au/articles/report/A_survey_of_architecture_design_rationale/26269849) | Tang, Babar, Gorton, Han | 2005/2006 | measured (survey) |
| [Documenting design decision rationale (experiment)](https://art.torvergata.it/handle/2108/57816) | Falessi, Cantone, Becker | 2006 | measured (students) |
| [Using ADRs in Open Source Projects](https://research.jku.at/en/publications/using-architecture-decision-records-in-open-source-projects-an-ms/) | Buchgeher et al. | 2023 (IEEE Access) | measured |
| [One Size Fits All? ADR templates](https://arxiv.org/abs/2604.27333) | Nogueira, Silva, Conte | 2026-04-30 | measured, preprint |
| [PEP process compliance](https://ro.uow.edu.au/eispapers/6479) | Savarimuthu et al. | 2016 (ECIS) | measured (summary only) |
| [LLMs detecting ADR violations](https://arxiv.org/abs/2602.07609) | Su et al. | 2026-02-07 | measured, preprint |
| [LLMs generating design rationale](https://arxiv.org/abs/2504.20781) | Zhou et al. | 2025 (ACM TOSEM) | measured |
| [GADR](https://arxiv.org/abs/2608.17694) | da Silva & Gama | 2026-08-18 | measured, preprint |
| [Spec Kit](https://github.com/github/spec-kit) | GitHub | v1.2.3, 2026-10-22 | first-party |
| [Kiro Specs](https://kiro.dev/docs/specs/) | AWS | updated 2026-10-15 | first-party |
| [Tessl spec syntax](https://docs.tessl.io/reference) | Tessl | living | first-party |
| [Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Anthropic | living, read 2026-10-26 | first-party |
| [Framework for safe and trustworthy agents](https://www.anthropic.com/news/our-framework-for-developing-safe-and-trustworthy-agents) | Anthropic | 2025-08 | first-party |
| [Codex ExecPlans (PLANS.md)](https://github.com/openai/openai-cookbook/blob/main/articles/codex_exec_plans.md) | OpenAI | 2025-10-14 (archived) | first-party |
| [Harness engineering](https://openai.com/index/harness-engineering/) | OpenAI (Ryan Lopopolo) | 2026-02-11 | not accessed (403) |
| [Copilot coding agent: best results](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results) | GitHub | living | first-party |
| [Instructing Devin](https://docs.devin.ai/essential-guidelines/instructing-devin-effectively) / [When to use Devin](https://docs.devin.ai/essential-guidelines/when-to-use-devin) | Cognition | living | first-party |
| [Factory Spec Mode](https://docs.factory.com/cli/user-guides/specification-mode) | Factory | living | first-party |
| [Cursor Plan Mode](https://cursor.com/docs/agent/plan-mode) | Cursor | living | first-party |
| [ADK Tool Confirmation](https://adk.dev/tools-custom/confirmation/) | Google | living (experimental) | first-party |
| [Levels of Autonomy for AI Agents](https://arxiv.org/abs/2506.12469) | Feng, McDonald, Zhang | 2025-06-14 (v2 2025-07-28) | framework |
| [Types and levels of automation (MITRE reproduction)](https://www.mitre.org/sites/default/files/pdf/pr-16-3426-lessons-lost-automation-in-aviation-definition-of-automation.pdf) | Parasuraman, Sheridan, Wickens | 2000 | established (secondary) |
| [Measuring AI agent autonomy in practice](https://www.anthropic.com/research/measuring-agent-autonomy) | Anthropic | 2026-02-18 | measured, vendor data |
| [How AI is transforming work at Anthropic](https://www.anthropic.com/research/how-ai-is-transforming-work-at-anthropic) | Anthropic | 2025-12-02 | measured, self-report |
| [Economic Index: software development](https://www.anthropic.com/research/impact-software-development) | Anthropic | 2025-04-28 | measured, vendor data |
| [Economic Index June 2026](https://www.anthropic.com/research/economic-index-june-2026-report) | Anthropic | 2026-06-26 | measured, vendor data |
| [Changing our developer productivity experiment design](https://metr.org/blog/2026-02-24-uplift-update/) | METR | 2026-02-24 | measured (with stated bias) |
| [2025 DORA Report announcement](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report) | Google DORA | 2025-09-23 | measured (survey) |
| [Human-In-the-Loop Software Development Agents (HULA)](https://arxiv.org/html/2411.12924v1) | Takerngsaksiri et al. (Atlassian) | 2024-11 (ICSE-SEIP 2025) | measured |
| [Why AI Agents Still Need You](https://arxiv.org/abs/2506.12347) | Kumar et al. (Microsoft) | 2025-06-14 (ASE'25) | measured, small |
| [Human oversight of agentic systems in practice](https://arxiv.org/html/2606.05391) | Dhanorkar, Passi, Vorvoreanu | 2026-06-03 | qualitative (17 interviews) |
| [Ambig-SWE](https://arxiv.org/abs/2502.13069) | Vijayvargiya et al. | 2025-02-18 (ICLR 2026) | measured |
| [The End of Code Review](https://arxiv.org/abs/2606.13175) | Martin Monperrus | 2026-06-11 | opinion (position paper) |
| [AIDev: The Rise of AI Teammates in SE 3.0](https://arxiv.org/html/2507.15003v1) | Li, Zhang, Hassan | 2025-07-20 | measured, preprint |
| [Where Do AI Coding Agents Fail?](https://arxiv.org/html/2601.15195v1) | Ehsani et al. | 2026-01-21 (MSR'26) | measured |
| [What Makes Issue Resolution Tasks Difficult for Agents?](https://arxiv.org/abs/2608.18280) | Al-Haque & Johnson | 2026-08-18 (ESEM 2026) | measured |
| [CodeScout](https://arxiv.org/abs/2603.05744) | — | 2026-03-05 (ACL Findings 2026) | measured |
| [Introducing SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/) | OpenAI | 2024-08-13 | not accessed (403) |
| GitHub artefacts: [KEP-753](https://github.com/kubernetes/enhancements/issues/753), [RFC 2497](https://github.com/rust-lang/rfcs/pull/2497) → [#53667](https://github.com/rust-lang/rust/issues/53667) → [#132833](https://github.com/rust-lang/rust/pull/132833), [Backstage ADRs](https://github.com/backstage/backstage/tree/master/docs/architecture-decisions), [hl 010-pager](https://github.com/pamburus/hl/tree/master/specs/010-pager), [GROWI hotkeys](https://github.com/growilabs/growi/tree/master/.kiro/specs/hotkeys), [dotnet/runtime #136102](https://github.com/dotnet/runtime/issues/136102) → [#136126](https://github.com/dotnet/runtime/pull/136126) | various | verified 2026-10-26 | observed |
