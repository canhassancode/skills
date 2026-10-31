---
type: regex
target: { source: file, path: src/readiness/ready.acceptance.test.ts }
pattern: "const result = assessReadiness\\(\\[typo\\]\\)\\n\\n  assert\\.deepEqual\\(result, \\{ score: 100, ready: true, openItems: \\[\\] \\}\\)"
---
