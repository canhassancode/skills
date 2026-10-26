# Agent skills fundamentals: research notes

Researched 2026-10-26 from primary sources: Anthropic docs, Anthropic engineering posts, the agentskills.io spec, agents.md, OpenAI Codex docs, and the Cursor, GitHub Copilot and Gemini CLI docs. Two research papers (Chroma, Distyl AI) are cited for instruction-file failure modes. Every claim cites a URL. Text marked **[Inference]** is my reading, not a source statement. Most Anthropic doc pages carry no publication date. Where they show one, it is given, and Claude Code version mentions show how current a page is (the skills and memory pages mention v2.1.309).

## 1. Fundamentals of agent skills

### What a skill is

- A skill is a directory containing a `SKILL.md` file: "organized folders of instructions, scripts, and resources". The YAML frontmatter requires `name` and `description`. Source: Anthropic Engineering, "Equipping agents for the real world with Agent Skills", 16 Oct 2025, by Barry Zhang, Keith Lazuka and Mahesh Murag. https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- A 18 Dec 2025 update to that post says Agent Skills was published "as an open standard for cross-platform portability" (same URL). The spec now lives at https://agentskills.io/specification.
- The open-spec layout is `SKILL.md` (required) plus optional `scripts/` (executable code), `references/` (docs loaded on demand) and `assets/` (templates, images, data). https://agentskills.io/specification
- In Claude Code, "Custom commands have been merged into skills". `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy`. If both exist with the same name, the skill wins. https://code.claude.com/docs/en/skills
- Claude Code classifies skills as **reference** (knowledge used throughout a session) or **action** (do something specific, e.g. `/deploy`). https://code.claude.com/docs/en/features-overview
- The skill-creator announcement classifies them as **capability uplift** (the base model "can't do or can't do consistently") or **encoded preference** (Claude can do each step, and the skill orders the steps to match a team's process). It says capability-uplift skills "may become less necessary as models improve. Evals tell you when that's happened." 3 Mar 2026. https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills

### Frontmatter fields

**Open spec (agentskills.io).** Source: https://agentskills.io/specification

| Field | Required | Constraint |
|---|---|---|
| `name` | Yes | 1–64 chars. Lowercase a–z, 0–9 and hyphens only. No leading, trailing or consecutive hyphens. Must match the parent directory name |
| `description` | Yes | 1–1024 chars, non-empty. Should say what the skill does and when to use it |
| `license` | No | Licence name or a bundled licence file |
| `compatibility` | No | 1–500 chars. Environment requirements |
| `metadata` | No | Map of string keys to string values |
| `allowed-tools` | No | Space-separated pre-approved tools. "Experimental. Support for this field may vary between agent implementations" |

**Anthropic platform (API / claude.ai).** Source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview

- `name`: max 64 chars; lowercase letters, numbers and hyphens; no XML tags; must not contain the reserved words "anthropic" or "claude".
- `description`: non-empty, max 1,024 chars, no XML tags.
- Outside Claude Code, only `name`, `description`, `license`, `compatibility`, `metadata` and `allowed-tools` are allowed. Packaging or upload fails with a hard error on any other key. https://code.claude.com/docs/en/skills

**Claude Code.** Every field is optional and only `description` is recommended. Unrecognised keys are ignored without error. Source: https://code.claude.com/docs/en/skills

| Field | Semantics |
|---|---|
| `name` | `/` menu name. Defaults to the directory name |
| `description` | What the skill does and when to use it. Claude uses it to decide when to apply the skill. If absent, the first non-empty markdown line is used |
| `when_to_use` | Extra trigger context, appended to `description`. Counts toward the 1,536-char listing cap |
| `argument-hint` | Autocomplete hint, e.g. `[issue-number]` |
| `arguments` | Named positional args for `$name` substitution |
| `disable-model-invocation` | `true` stops Claude invoking the skill on its own (see §5). Default `false` |
| `user-invocable` | `false` hides the skill from the `/` menu, and `/name` doesn't run it. Default `true` |
| `allowed-tools` | Tools usable without asking during the invoking turn. The grant clears on the user's next message |
| `disallowed-tools` | Tools removed while the skill is active. Clears on the next message |
| `model` | Model for the rest of the current turn, or `inherit` |
| `effort` | `low`, `medium`, `high`, `xhigh` or `max` while active |
| `context` | `fork` runs the skill in a forked subagent context |
| `agent` | Subagent type for `context: fork`. Default `general-purpose` |
| `background` | With `fork`, `false` waits for the result in the invoking turn. Default `true` (v2.1.218+) |
| `hooks` | Hooks registered on invocation. They persist for the rest of the session |
| `paths` | Globs limiting automatic activation to matching files |
| `shell` | `bash` (default) or `powershell` for `` !`command` `` blocks |
| `metadata`, `license`, `compatibility` | Accepted, not acted on |

Booleans accept `true`/`false`, `yes`/`no`, `on`/`off` and `1`/`0` (v2.1.218+). Command files in `.claude/commands/` accept the same fields except `name` and `paths`. https://code.claude.com/docs/en/skills

### Progressive disclosure

| Level | When loaded | Cost | Content |
|---|---|---|---|
| 1 Metadata | Always, at startup | ~100 tokens per skill | `name` + `description` |
| 2 Instructions | When triggered | Under 5k tokens | `SKILL.md` body |
| 3+ Resources | As needed | None until accessed | Referenced files are read; scripts run via bash, and only their output enters context |

Source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview. The open spec gives the same figures (~100 tokens; "< 5000 tokens recommended"; `SKILL.md` under 500 lines). https://agentskills.io/specification

- Platform docs: metadata is loaded "at startup and includes it in the system prompt". Bundled content has "no practical limit" because files cost nothing until read. https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- Claude Code lifecycle: once a skill is invoked, its rendered content "enters the conversation as a single message and stays there across later turns". Claude Code "does not re-read the skill file on later turns". After auto-compaction, the most recent invocation of each skill is re-attached, keeping the first 5,000 tokens of each, with a combined budget of 25,000 tokens. https://code.claude.com/docs/en/skills
- Nested skill directories (`<subdir>/.claude/skills/`) load the first time Claude reads or edits a file in that subdirectory. https://code.claude.com/docs/en/skills

### How the model decides to invoke

- "The `description` is what Claude matches your request against when determining whether to trigger the Skill." https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- "Claude matches your task against skill descriptions to decide which are relevant. If descriptions are vague or overlap, Claude may load the wrong skill or miss one that would help." https://code.claude.com/docs/en/features-overview
- Agents "typically only consult skills for tasks that require knowledge or capabilities beyond what they can handle alone". A one-step request like "read this PDF" may not trigger a matching PDF skill. https://agentskills.io/skill-creation/optimizing-descriptions
- skill-creator says the same: "Complex, multi-step, or specialized queries reliably trigger skills when the description matches." https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
- In Claude Code, invocation goes through the **Skill tool**. Permission rules `Skill(name)` and `Skill(name *)` allow or deny specific skills, and denying `Skill` disables all skills. https://code.claude.com/docs/en/skills

### Limits and budgets

- Description: 1,024 chars under the spec and the platform. https://agentskills.io/specification ; https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- Claude Code listing cap: `description` + `when_to_use` is truncated at **1,536 chars** per entry. Configurable via `skillListingMaxDescChars`. https://code.claude.com/docs/en/skills
- Claude Code listing budget: the listing "always contains every skill name". When it overflows, descriptions are dropped to fit, starting with the least-invoked skills. The budget "scales at 1% of the model's context window" and can be raised with `skillListingBudgetFraction` or the `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var (a fixed char count). `/doctor` estimates the cost, and `/context` reports the post-budget size. https://code.claude.com/docs/en/skills
- "Every skill in the skill listing adds to your context on every turn, whether or not Claude ever uses it." https://code.claude.com/docs/en/skills
- Platform best practices say Claude picks from "potentially 100+ available Skills". No hard cap on skill count is stated. https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Codex: the initial listing uses "at most 2% of the model's context window, or 8,000 characters when the context window is unknown". Descriptions are shortened first, and with large sets some skills may be omitted with a warning. `skills.max_context_tokens` can be set "up to 10,000 tokens". https://learn.chatgpt.com/docs/build-skills (redirected from developers.openai.com/codex/skills)

## 2. Authoring best practices (Anthropic)

Source unless stated: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

- **Concise is key.** "The context window is a public good." The default assumption is "Claude is already very smart". Challenge each paragraph: "Does this paragraph justify its token cost?"
- **Degrees of freedom.** Match specificity to "the task's fragility and variability":
  - High freedom (text heuristics) when many approaches are valid.
  - Medium freedom (pseudocode or parameterised scripts).
  - Low freedom (exact scripts, "Do not modify the command") for fragile, sequence-critical operations.
  - The analogy is a "narrow bridge with cliffs" versus an "open field".
- **Test across models.** What works for Opus may need more detail for Haiku.
- **Naming.** Gerund form is suggested (`processing-pdfs`). Noun phrases and action forms are acceptable. Avoid vague names (`helper`, `utils`), reserved words, and inconsistent patterns.
- **Descriptions.**
  - "Always write in third person. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems."
  - Include both what the skill does and when to use it, with key terms.
  - Avoid vague descriptions ("Helps with documents").
  - Contrast: agentskills.io recommends imperative phrasing ("Use this skill when...") and erring "on the side of being pushy". https://agentskills.io/skill-creation/optimizing-descriptions **[Inference]** The two Anthropic-adjacent sources differ on voice (third-person declarative versus imperative). Both agree that "when to use" belongs in the description.
- **Body size.** Keep the `SKILL.md` body under 500 lines. Split into files as it approaches that.
- **References one level deep.** Claude may partially read nested references (e.g. `head -100`). Link every reference file directly from `SKILL.md`. Give reference files over 100 lines a table of contents.
- **Organisation patterns.**
  - High-level guide with references.
  - Domain-specific split (`reference/finance.md`, `reference/sales.md`).
  - Conditional details.
- **Workflows and feedback loops.**
  - Give complex tasks sequential steps, with a copyable checklist.
  - Use the "validator → fix errors → repeat" loop.
  - Use plan-validate-execute with a verifiable intermediate file for batch, destructive or high-stakes operations.
- **Content.**
  - No time-sensitive information. Use an "Old patterns" section instead.
  - Use consistent terminology.
  - Use templates (strict or flexible) and input/output example pairs.
  - Don't offer too many options. Give a default plus an escape hatch.
- **Scripts.**
  - "Solve, don't defer": scripts should handle their own errors.
  - No "voodoo constants".
  - Utility scripts are more reliable than generated code and save tokens.
  - Say explicitly whether Claude should run a script or read it.
  - Use forward-slash paths and fully qualified MCP tool names (`ServerName:tool_name`).
  - Don't assume packages are installed.
- **Evaluation first.** "Create evaluations BEFORE writing extensive documentation." The steps are: identify gaps without the skill, build three scenarios, take a baseline, write minimal instructions, iterate. "There is not currently a built-in way to run these evaluations" (platform page). The checklist asks for at least three evaluations, tested on Haiku, Sonnet and Opus.
- **Iterate with Claude A/B.** One instance authors the skill, and a fresh instance uses it on real tasks. Watch for unexpected exploration paths, missed connections, overreliance on one section, and ignored files.
- **Engineering blog equivalents:** start with evaluation, structure for scale, think from Claude's perspective (watch `name`/`description`), and iterate with Claude. https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- **skill-creator style guidance.** "Try to explain to the model why things are important in lieu of heavy-handed musty MUSTs." It flags repeated ALL-CAPS ALWAYS/NEVER as a sign to explain the reasoning instead. https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md (Contrast: the platform doc's Claude A/B example suggests stronger language such as "MUST filter" when a rule is missed.)
- **Claude Code specifics.**
  - Put the most important instructions near the top of `SKILL.md`, because compaction keeps only the start.
  - Word guidance as standing instructions ("Run the tests after every edit").
  - Move rules that must always hold into a hook, optionally declared in the skill's `hooks` frontmatter.
  - Source: https://code.claude.com/docs/en/skills
- **Security.** Use skills only from trusted sources and audit bundled files. Skills that fetch external URLs are risky. https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview

## 3. CLAUDE.md / AGENTS.md

### How CLAUDE.md loads (Claude Code)

Source unless stated: https://code.claude.com/docs/en/memory

- **Scopes, in load order:**
  1. Managed policy (`/etc/claude-code/CLAUDE.md` on Linux; the `claudeMd` key in managed settings).
  2. User (`~/.claude/CLAUDE.md`).
  3. Project (`./CLAUDE.md` or `./.claude/CLAUDE.md`).
  4. Local (`./CLAUDE.local.md`).
- **Ancestors** of the working directory load at launch. Files are concatenated, not overridden, ordered from the filesystem root down, so instructions closer to the cwd are read last. Within a directory, `CLAUDE.local.md` follows `CLAUDE.md`.
- **Subdirectories** load on demand, once Claude reads, writes or edits a file there (including a `cat`/`head` that counts as a read).
- **Delivery.** "CLAUDE.md content is delivered as a user message after the system prompt, not as part of the system prompt itself… there's no guarantee of strict compliance." For system-prompt-level instructions, use `--append-system-prompt`.
- **Imports.** `@path` syntax, relative to the importing file, with recursion up to **four hops**. Imports inside code spans and fences are skipped. External imports in project files trigger a one-time approval dialog. Imports "don't reduce its context cost".
- **Comments.** Block-level HTML comments are stripped before injection.
- **Rules.**
  - `.claude/rules/*.md` without `paths` load at launch with `.claude/CLAUDE.md` priority.
  - With `paths` frontmatter, a rule loads when Claude reads, writes or edits a matching file.
  - User rules in `~/.claude/rules/` load before project rules. Neither set overrides the other.
- **Compaction.** "Project-root CLAUDE.md survives compaction: after `/compact`, Claude re-reads it from disk and re-injects it." Nested files and path rules reload on demand.
- **Size limits.**
  - A launch-time file over 4 MiB is skipped.
  - On-demand files (subdirectory CLAUDE.md, path rules) are truncated past a per-file limit: 40,000 chars at 200K context, and 200,000 chars (Opus/Sonnet 4.6) or 150,000 chars (later models) at 1M. v2.1.309+.
  - Startup warnings fire when a file is over the recommended length, or when files add up past a combined limit.
- **Auto memory.** `MEMORY.md` loads its first 200 lines or 25KB, whichever comes first.
- **AGENTS.md interop (v2.1.277+).**
  - By default (`claude-md-or-agents-md`), Claude reads `AGENTS.md` only when there is no `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` in the cwd or above.
  - `~/.claude/CLAUDE.md`, managed CLAUDE.md and rules don't count for that check.
  - Other settings: `claude-md-and-agents-md`, `claude-md`, `managed-only`.
  - `AGENTS.local.md`, `AGENTS.override.md` and `.agents/` are not read.
- **Subagents** load CLAUDE.md, except built-in Explore and Plan and agents with `omitClaudeMd`. https://code.claude.com/docs/en/features-overview

### AGENTS.md (open format and other tools)

- AGENTS.md is "a README for agents". There are no required fields; it is "just standard Markdown". "The closest AGENTS.md to the edited file wins", and "explicit user chat prompts override everything". It is stewarded by the Agentic AI Foundation under the Linux Foundation and is "used by over 60k open-source projects". No size guidance. Undated. https://agents.md/
- **Codex.**
  - Builds an instruction chain at start.
  - Global level: `~/.codex/AGENTS.override.md` or else `AGENTS.md`.
  - Project level: from the root down to the cwd, at most one file per directory (override, then AGENTS.md, then fallback names). Files are concatenated root-first, so nearer files take precedence.
  - Loading stops at `project_doc_max_bytes`, default **32 KiB**.
  - Undated. https://learn.chatgpt.com/docs/agent-configuration/agents-md
- **Cursor.** Supports AGENTS.md in the root and subdirectories, and more specific files take precedence. Rules are "Always Apply", "Apply Intelligently" (by description), "Apply to Specific Files" (globs) or "Apply Manually" (@-mention). "Keep rules under 500 lines." https://cursor.com/docs/context/rules
- **GitHub Copilot.** Supports `.github/copilot-instructions.md`, path-specific `.github/instructions/*.instructions.md` with `applyTo`, and AGENTS.md anywhere ("nearest… will take precedence"). It also reads a single root `CLAUDE.md` or `GEMINI.md`. The only size cue is in the generation prompt template: "no longer than 2 pages". https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
- **Gemini CLI.** Loads global `~/.gemini/GEMINI.md`, workspace dirs and their parents, and just-in-time ancestors on tool access. It concatenates them and sends them "with every prompt". Supports `@file` imports and `/memory reload`. `context.fileName` can include `AGENTS.md`. Last updated 18 Jun 2026; the page notes Gemini CLI was replaced by Antigravity CLI for some tiers on 18 Jun 2026. https://geminicli.com/docs/cli/gemini-md/

### Documented best practices and size guidance

- "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." https://code.claude.com/docs/en/memory
- Keep CLAUDE.md "to facts Claude should hold in every session: build commands, conventions, project layout, 'always do X' rules". Multi-step procedures, or entries that matter for only part of the codebase, go in a skill or a path-scoped rule. https://code.claude.com/docs/en/memory
- Write concrete, verifiable instructions ("Use 2-space indentation"). If two instructions contradict, "Claude may pick one arbitrarily". `/doctor prompt-audit` (v2.1.283+) finds stale or conflicting instructions. https://code.claude.com/docs/en/memory
- "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!" https://code.claude.com/docs/en/best-practices
- The best-practices page has an include/exclude table:
  - Include: bash commands Claude can't guess, non-default style, test runners, repo etiquette, architectural decisions, environment quirks, gotchas.
  - Exclude: anything derivable from code, standard conventions, detailed API docs, frequently changing info, tutorials, file-by-file descriptions, "write clean code".
  - Source: https://code.claude.com/docs/en/best-practices
- Emphasis: "add emphasis such as 'IMPORTANT' to that line alone. If you emphasize many lines, none of them stands out." https://code.claude.com/docs/en/best-practices
- `/doctor` proposes trims. It cuts derivable content (directory layouts, dependency lists, architecture overviews) and keeps pitfalls, rationale and non-default conventions. https://code.claude.com/docs/en/memory

### Failure modes of large or padded instruction files

- **Anthropic, failure pattern "The over-specified CLAUDE.md"**: "If your CLAUDE.md is too long, Claude ignores half of it because important rules get lost in the noise. Fix: Ruthlessly prune. If Claude already does something correctly without the instruction, delete it or convert it to a hook." Also: "If Claude keeps doing something you don't want despite having a rule against it, the file is probably too long and the rule is getting lost." https://code.claude.com/docs/en/best-practices
- **Anthropic, context degradation:** "LLM performance degrades as context fills… Claude may start 'forgetting' earlier instructions." https://code.claude.com/docs/en/best-practices
- **Anthropic, features overview:** too much configuration "can also add noise that makes Claude less effective; skills may not trigger correctly, or Claude may lose track of your conventions". https://code.claude.com/docs/en/features-overview
- **Anthropic, "Effective context engineering for AI agents"** (29 Sep 2025, Rajasekaran, Dixon, Ryan, Hadfield):
  - Context rot means recall "decreases" as tokens grow, and there is a finite "attention budget" (n² token relationships).
  - The aim is the "smallest possible set of high-signal tokens".
  - System prompts should sit at the "right altitude".
  - Prefer a few canonical examples over lists of edge-case rules.
  - It describes Claude Code's CLAUDE.md as "naively dropped into context up front", with just-in-time glob/grep alongside.
  - Source: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- **Chroma, "Context Rot"** (14 Jul 2025, Hong, Troynikov, Huber; 18 models):
  - "model performance consistently degrades with increasing input length", even on simple tasks.
  - A single distractor reduces performance.
  - Coherent haystacks hurt more than shuffled ones.
  - On LongMemEval, focused prompts (~300 tokens) beat full prompts (~113k tokens), with the largest gap for Claude, mostly from abstentions.
  - Source: https://www.trychroma.com/research/context-rot
- **Distyl AI, "How Many Instructions Can LLMs Follow at Once?"** (arXiv 2507.11538, 15 Jul 2025, NeurIPS 2025):
  - The IFScale benchmark uses 500 keyword-inclusion instructions across 20 models. The best reach 68% at 500 instructions.
  - Decay comes in threshold, linear and exponential shapes. claude-sonnet-4 is listed as linear.
  - There is a bias toward earlier instructions.
  - Source: https://arxiv.org/abs/2507.11538
  - **[Inference]** The task is keyword inclusion, not coding-agent behaviour. Transfer to CLAUDE.md is plausible but not shown.
- **Steering blog** (18 Jun 2026, Michael Segner, Anthropic): instructions "can fail under pressure, in long sessions, in ambiguous situations, or due to prompt injection". "A real guardrail needs to be deterministic, and the enforcement methods are hooks and permissions." It rates root CLAUDE.md context cost as "High" and skills as "Low". https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more

## 4. CLAUDE.md vs skills (and commands, subagents, hooks, MCP)

- **Where content belongs.** "Put it in CLAUDE.md if Claude should always know it: coding conventions, build commands, project structure, 'never do X' rules. Put it in a skill if it's reference material Claude needs sometimes… or a workflow you trigger with `/<name>`." "Rule of thumb: Keep CLAUDE.md under 200 lines. If it's growing, move reference content to skills or split into `.claude/rules/`." https://code.claude.com/docs/en/features-overview
- **Load comparison.**
  - CLAUDE.md loads every session.
  - Rules load every session or when matching files are opened.
  - Skills load on demand.
  - Only skills can trigger workflows with `/<name>`.
  - Both CLAUDE.md and skills support `@path` imports.
  - Source: https://code.claude.com/docs/en/features-overview
- **Context cost by feature.**
  - CLAUDE.md: full content on every request.
  - Skills: descriptions on every request, full content when used.
  - MCP: tool names at start, schemas deferred.
  - Subagents: isolated.
  - Hooks: zero unless they return output.
  - Source: https://code.claude.com/docs/en/features-overview
- **Build-over-time triggers.**
  - A convention got wrong twice goes in CLAUDE.md.
  - A prompt you keep retyping becomes a user-invocable skill.
  - A playbook pasted for the third time becomes a skill.
  - Something that should "happen every time without asking" becomes a hook.
  - Source: https://code.claude.com/docs/en/features-overview
- **Hooks are for enforcement.** "An instruction like 'never edit `.env`' in CLAUDE.md or a skill is a request, not a guarantee. A `PreToolUse` hook that blocks the edit is enforcement." https://code.claude.com/docs/en/features-overview
- Hooks "are deterministic and guarantee the action happens", unlike advisory CLAUDE.md. https://code.claude.com/docs/en/best-practices
- Settings (`permissions.deny`) are client-enforced, while CLAUDE.md "shape[s] Claude's behavior but [is] not a hard enforcement layer". https://code.claude.com/docs/en/memory
- **Subagents.** Use them for context isolation, where only a summary returns. A subagent's `skills:` field preloads full skill content at launch. A skill can run in a subagent via `context: fork`. https://code.claude.com/docs/en/features-overview
- **MCP vs skill.** "MCP connects Claude to external services. Skills extend what Claude knows, including how to use those services effectively." https://code.claude.com/docs/en/features-overview
- **Slash commands** are now skills, as covered in §1. https://code.claude.com/docs/en/skills
- **Trade-offs.**
  - Reliability: CLAUDE.md is always present, but adherence falls with length (§3).
  - A model-invoked skill costs only its description, but depends on description matching and can under-trigger (§5).
  - A user-invoked skill is reliable when typed, but requires the human to remember it.
  - **[Inference]** None of the sources quantifies always-on versus on-demand reliability head-to-head.

## 5. `disable-model-invocation`

### Documented semantics (Claude Code)

Source unless stated: https://code.claude.com/docs/en/skills

- "Claude can't invoke the skill on its own."
- In the invocation table, the row for `disable-model-invocation: true` reads: "You can invoke: Yes · Claude can invoke: Not on its own · **Description not in context**, full skill loads when invoked."
- "Hide individual skills by adding `disable-model-invocation: true` to their frontmatter. This removes the skill from Claude's context entirely."
- On the Skill tool: "By default, Claude can invoke any skill that doesn't have `disable-model-invocation: true` set." "If Claude tries anyway, Claude Code blocks the call and instructs it not to reproduce the deploy steps another way, so expect Claude to suggest running `/deploy` yourself."
- The flag "also prevents the skill from being preloaded into subagents and from running when a session-scoped scheduled task fires with the skill as its prompt".
- Context cost: "For user-only skills (`disable-model-invocation: true`), nothing loads until you invoke them… User-only skills have zero cost until invoked." https://code.claude.com/docs/en/features-overview
- **Interaction with `user-invocable`.**
  - The two fields are orthogonal.
  - `user-invocable: false` hides the skill from the `/` menu, but its description stays in context and Claude can invoke it ("background knowledge that isn't actionable as a command").
  - **[Inference]** Setting both would leave a skill nobody can invoke. The docs don't discuss that combination.
- **Settings equivalent.** `skillOverrides` sets the same visibility without editing the file:
  - `"on"`: name and description.
  - `"name-only"`: the name is listed without a description.
  - `"user-invocable-only"`: hidden from Claude but in the `/` menu. This is the settings analogue of `disable-model-invocation`.
  - `"off"`: hidden from both.
  - Plugin skills are unaffected.
- **Cursor** supports `disable-model-invocation` with the meaning "only used when explicitly invoked". https://cursor.com/docs/context/skills

### Documented rationale for setting it

- "Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`, or `/send-slack-message`. You don't want Claude deciding to deploy because your code looks ready." https://code.claude.com/docs/en/skills
- "Use `disable-model-invocation: true` for skills with side effects. This saves context and ensures they run only when you name them." https://code.claude.com/docs/en/features-overview
- "Use `disable-model-invocation: true` for workflows with side effects that you want to trigger manually" (the `/fix-issue` example). https://code.claude.com/docs/en/best-practices
- Troubleshooting "Skill triggers too often": make the description more specific, or "Add `disable-model-invocation: true` if you only want manual invocation". https://code.claude.com/docs/en/skills

### Model-invoked vs human-invoked reliability

- **Under-triggering is acknowledged.** skill-creator says: "currently Claude has a tendency to 'undertrigger' skills -- to not use them when they'd be useful. To combat this, please make the skill descriptions a little bit 'pushy'." Its example appends "Make sure to use this skill whenever the user mentions… even if they don't explicitly ask for a 'dashboard.'" https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
- **Simple tasks may bypass skills.** Claude "only consults skills for tasks it can't easily handle on its own". https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
- **Description optimisation evals.**
  - About 20 queries (8–10 should-trigger, 8–10 should-not, with near-misses as the most valuable negatives).
  - Each query is run 3 times to get a trigger rate, with a 0.5 pass threshold.
  - Split 60/40 into train and validation, select by validation pass rate, and stop after about 5 iterations.
  - Model behaviour is "nondeterministic".
  - Sources: https://agentskills.io/skill-creation/optimizing-descriptions ; skill-creator automates the loop (`run_loop`, `best_description`).
- **Measured result.** Description tuning "saw improved triggering on 5 out of 6 public skills". No absolute trigger rates are published. https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills
- **Claude Code tooling.**
  - Plugin skills can be measured with a `tool_used: Skill` grader in `claude plugin eval`.
  - Malformed frontmatter means `/skill-name` still works, but Claude "can't match against your `description`".
  - When the listing overflows, descriptions of rarely invoked skills are dropped first, which "removes the keywords Claude needs to match your request".
  - Source: https://code.claude.com/docs/en/skills
- **Human invocation as the fallback.** "To tell Claude to use a specific skill, invoke it with `/<name>`." https://code.claude.com/docs/en/features-overview
- **Persistence after invocation.** Claude can stop following a skill in later turns, after compaction or for rules that must always hold. The fixes are standing-instruction wording, re-invocation, or hooks. https://code.claude.com/docs/en/skills

### Other tools' equivalents

- **Codex:** in `agents/openai.yaml`, `policy.allow_implicit_invocation` defaults to `true`. When it is `false`, "Codex won't invoke the skill implicitly from a user prompt, but explicit `$skill` invocation still works." A skill can be disabled entirely with `[[skills.config]]` and `enabled = false` in `~/.codex/config.toml`. https://learn.chatgpt.com/docs/build-skills
- **Cursor:** supports `disable-model-invocation: true`, and the skill is invoked via `/`. https://cursor.com/docs/context/skills
- **Gemini CLI:**
  - No per-skill frontmatter equivalent is documented on the skills page.
  - `/skills disable <name>` turns a skill off entirely.
  - Activation runs through an `activate_skill` tool with a user-consent prompt.
  - Last updated 30 Apr 2026. https://geminicli.com/docs/cli/skills/

## Open questions / where sources are silent

- Whether a skill with `disable-model-invocation: true` can be run by Claude when the user asks in natural language ("run the deploy skill") rather than typing `/deploy`. The docs say Claude Code blocks Claude's Skill-tool call and expect Claude to suggest `/deploy`. They don't explicitly cover a user's natural-language request. **[Inference]** It is blocked either way. https://code.claude.com/docs/en/skills
- Where exactly the skill listing sits in Claude Code (system prompt, Skill tool description, or a system reminder). The platform docs say "system prompt", and the Claude Code docs only say "into context". https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview ; https://code.claude.com/docs/en/skills
- No source publishes absolute trigger rates for model-invoked skills, or a direct reliability comparison of model-invoked skills against CLAUDE.md content or human invocation. The only figure is "5 out of 6" skills improved. https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills
- No Anthropic source quantifies how adherence degrades with CLAUDE.md length. "Under 200 lines" is guidance, not a measured threshold. Neither the combined-length warning threshold nor the "recommended length" is given numerically. https://code.claude.com/docs/en/memory
- The description voice conflicts: platform best practices say third person, while agentskills.io says imperative ("Use this skill when..."). Neither cites evidence.
- The emphasis guidance conflicts: skill-creator discourages "musty MUSTs", while the platform Claude A/B example suggests "MUST filter". Claude Code best practices allow "IMPORTANT" on single lines only.
- The AGENTS.md spec gives no size guidance. Codex enforces 32 KiB by truncation. Copilot only hints "2 pages".
- The setting-name table for `skillListingBudgetFraction` (default 1%) and `SLASH_COMMAND_TOOL_CHAR_BUDGET` exists, but the full entries in the settings reference and env-vars pages were not retrieved (the pages were too long). Defaults come from the skills page only.
- Upstream sources don't discuss the instruction-count research (IFScale) or Chroma's findings in relation to skill descriptions. The link from listing size to triggering quality is asserted qualitatively by Anthropic ("skills may not trigger correctly"), not measured.

## Sources

- Claude Code, Skills: https://code.claude.com/docs/en/skills
- Claude Code, Memory (CLAUDE.md, rules, AGENTS.md): https://code.claude.com/docs/en/memory
- Claude Code, Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview
- Claude Code, Best practices: https://code.claude.com/docs/en/best-practices
- Claude Code, Settings reference (index rows only): https://code.claude.com/docs/en/settings-reference
- Claude Code, Environment variables (partial): https://code.claude.com/docs/en/env-vars
- Claude Platform, Agent Skills overview: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- Claude Platform, Skill authoring best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Anthropic Engineering, Equipping agents for the real world with Agent Skills (16 Oct 2025; update 18 Dec 2025): https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- Anthropic Engineering, Effective context engineering for AI agents (29 Sep 2025): https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Claude blog, Steering Claude Code (18 Jun 2026): https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more
- Claude blog, Improving skill-creator (3 Mar 2026): https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills
- anthropics/skills, skill-creator SKILL.md: https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
- Agent Skills specification: https://agentskills.io/specification
- Agent Skills, Optimizing skill descriptions: https://agentskills.io/skill-creation/optimizing-descriptions
- AGENTS.md: https://agents.md/
- OpenAI Codex, Build skills: https://learn.chatgpt.com/docs/build-skills
- OpenAI Codex, AGENTS.md: https://learn.chatgpt.com/docs/agent-configuration/agents-md
- Cursor, Rules: https://cursor.com/docs/context/rules
- Cursor, Skills: https://cursor.com/docs/context/skills
- GitHub Copilot, Repository custom instructions: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
- Gemini CLI, GEMINI.md (updated 18 Jun 2026): https://geminicli.com/docs/cli/gemini-md/
- Gemini CLI, Agent Skills (updated 30 Apr 2026): https://geminicli.com/docs/cli/skills/
- Chroma, Context Rot (14 Jul 2025): https://www.trychroma.com/research/context-rot
- Jaroslawicz et al., How Many Instructions Can LLMs Follow at Once? (arXiv 2507.11538, 15 Jul 2025): https://arxiv.org/abs/2507.11538
