---
type: regex
target: last_message
pattern: "(^|\\n)(?![^\\n]*(carrier|purchaseLabel|idempotency[- ]key))[^\\n]*❓[^\\n]*\\b(twice|second (request|label|purchase|call|time)|duplicate|again|same order|double)\\b"
flags: i
match: not_contains
---
