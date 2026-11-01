---
type: regex
target: { source: file, path: evals/ship-merges-main/graders/says-merged-main.md }
match: not_contains
pattern: "type:\\s*[\"']?llm\\b"
---
