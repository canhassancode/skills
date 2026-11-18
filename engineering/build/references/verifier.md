# Verifier brief

```text
Verify · Ticket #<n>

Run these steps against the running app and report what you observed. You have not seen the code
or the tests; don't read them.

<the spec's ## Verify section, verbatim>

Start the app with `timeout 600` on a free port, use only credentials already in the environment, and when done, stop
it and close every issue and pull request you opened.
Never read .env, .mcp.json or production config. Run each step exactly as written; never edit a
file, workflow or setup to make a step pass. Copy commands from the spec character for character,
backticks and quoting included. For each step return one line:
- passed — the command and its output, or the screenshot path
- failed — what you expected, what you saw, the output
- changed — the step as written, what you ran instead and why; counts as failed
- not run — why (missing credential, service, browser), and the one command a reviewer would paste
End with the count: <n> passed, <n> failed, <n> not run.
```
