---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
flags: i
---
Decided limits(?=[\s\S]*currency)(?=[\s\S]*round\w*\s+down)
