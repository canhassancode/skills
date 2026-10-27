---
type: regex
target: {source: file, path: .scratch/split-shipments/split-shipments.md}
match: contains
---
5%[^\n]*[Uu]nmeasured|[Uu]nmeasured[^\n]*5%
