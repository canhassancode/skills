---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. **Load the web tools before reading anything.** `WebSearch` and `WebFetch` are deferred — only their names are advertised, so their schemas must be pulled in with `ToolSearch` (query `select:WebSearch,WebFetch`) before either can be called. Skip this and the agent finds no fetch tool, silently falls back to `curl`, and researches badly: raw HTML instead of markdown, no search step so sources are guessed at rather than found, outright failure on JS-rendered and bot-protected pages, and one shell spawned per fetch. Reserve `curl` for what it is actually good at — a plain JSON API, or checking an HTTP status.
2. Investigate the question against **primary sources** — official docs, source code, specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that owns it.
3. Write the findings to a single Markdown file, citing each claim's source.
4. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.
