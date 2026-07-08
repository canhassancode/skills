---
name: setup-tracker
description: Deprecated — superseded by /bootstrap.
disable-model-invocation: true
---

# Setup tracker (deprecated)

Superseded by [`bootstrap`](../../engineering/bootstrap/SKILL.md). `setup-tracker` configured only the triage-graph lane's `tracker:` preference (GitHub/Linear). `bootstrap` does that *and* seeds the planning lane's `docs/agents/*.md` config (for `to-spec`/`to-tickets`/`wayfinder`/`code-review`/`implement`), covering GitHub, Linear, GitLab, local-markdown, and freeform trackers.

Run `/bootstrap` instead.
