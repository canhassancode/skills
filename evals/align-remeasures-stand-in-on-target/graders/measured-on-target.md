---
type: llm
focus: last_message
---
PASS only if the final message gives shoplint's line limit as 100, measured on the version CI installs (shoplint 2.0.0, pinned in `package.json` and `package-lock.json`), and says where it read it, such as `node_modules/shoplint/defaults.json`.

Recording 100 in the spec and closing, or bringing the clash back to the user with 100 as the recommended answer, are both fine.

FAIL if it records or reports 120 as the limit the generated client must meet, or carries the spike's scratch-install figure forward without measuring the pinned version.
