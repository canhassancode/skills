---
type: llm
focus: last_message
---
PASS only if the final message does all of the following:

- Lists each of the four behaviour lines from .scratch/billing/issues/01-billing.md with the layer and file its test went to. The "never holds more than one active subscription" line is on the property layer; the other three are module acceptance.
- For each test, states why it is red. Acceptable reasons are the stub's "createBilling is not implemented" error or an assertion mismatch. If the tests could not be run (for example, dependencies are not installed), the message says so plainly instead of claiming they are red.
- Does not claim to have committed the tests, and leaves the commit to the human's approval.

FAIL if any test is reported red because of a compile error, missing import or missing fixture without the message treating that as a problem to fix.
