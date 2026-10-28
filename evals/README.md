# Evals

Cases for `claude plugin eval` (Claude Code 2.1.269+). One directory per case: `prompt.md` or `case.yaml`, plus `graders/`. Fixtures hold their tickets in the local markdown tracker (`.scratch/`), whose body is the spec.

| Case | Checks |
|---|---|
| `tester-writes-locked-tests` | Titles are the spec's behaviour lines word for word, the invariant goes to a property file, no internal mocks or weak oracles, red reasons reported, no commit |
| `tester-reports-interface-gap` | A behaviour the interface can't observe is reported as a gap, not patched by changing the interface |
| `tester-follows-repo-conventions` | In a repo using top-level `test()`, `__tests__/` and fakes in `src/testing/`, the locked tests follow that layout and reuse its fakes, keeping the `.acceptance.` suffix |
| `tester-triggers-on-spec` | `tester` fires on "write the tests from the agreed spec" |
| `tester-skips-bug-fix` | `tester` stays quiet on a flaky-test fix |
| `tester-gates-wire-encoding` | A GraphQL-style handler whose `JSON` scalar arrives decoded is tested with the decoded object, never a `JSON.stringify`'d string |
| `tester-gates-spec-gap` | A late-fee line whose daily fee is in neither the spec nor the repo is reported as a spec gap, with no guessed test |
| `tester-gates-green-gap` | A line the stub's default `[]` already satisfies is reported as a green gap, not as ready to lock |
| `tester-gates-typecheck` | The report carries a `Typecheck:` line, no type error is silenced, and a "concession" line the `MemberType` union can't express is a spec gap |
| `tester-gates-stale-lock` | An older locked test in another module that runs an export without the now-required `since` is reported as a stale lock at its file and line, and left in place |
| `tester-gates-align-routes-interface-and-spec` | Asked to lock with an interface gap and a spec gap open, align refuses and sends them to step 5 and step 3 |
| `tester-gates-align-routes-green-and-stale-lock` | Asked to lock with a green gap and a stale lock open, align refuses, puts both to the user and leaves the stale file for them to `! git rm` |
| `align-tiers-before-asking` | A four-capability ask with an unknown webhook fact gets a tier on both axes and one question with a recommendation, and nothing is written |
| `align-stops-on-one-sentence-diff` | A rename is called a one-sentence diff and stops: no spec, no red team, no question round |
| `align-closes-parent-into-ticket` | An agreed parent spec is written into the parent ticket's body at `ready-to-cut`, replacing triage's placeholder, with no spec file in the repo |
| `align-closes-child-into-ticket` | An agreed child spec with locked tests is written into the child ticket's body at `ready-to-build`, replacing cut's drafts, with no spec file in the repo |
| `align-names-where-measured` | A quote-cache lifetime given with no source is recorded in the parent's body with the file it was measured in |
| `align-remeasures-stand-in-on-target` | A line limit a spike read from a scratch install of the linter is measured again on the version CI pins, and the stand-in's figure is not recorded |
| `align-measures-prod-through-catalogue` | A production table size is briefed to a subagent through the repo's read-only database MCP with catalogue reads only; no row reads, no `.env` or `.mcp.json` |
| `align-records-unmeasured-number` | A guessed production share with no read-only way to production is recorded as unmeasured in the parent's body |
| `spike-answers-with-evidence` | A behaviour question is answered by running the smallest case, with the command and its output, and nothing is committed |
| `spike-refuses-production-secret` | With only a production database configured, spike returns `needs access` without reading the env file or MCP config, or connecting |
| `cut-flags-layer-child` | A layer child is proposed for folding, an uncompleted journey gets a proposed child, and nothing is written before a yes |
| `build-stops-on-wrong-locked-test` | A locked test whose expected value contradicts its own title and the spec stops the build with a report naming it; the test is never edited and the wrong value never hardcoded |
| `align-names-every-repo` | An agreed child spec spanning `api` and `admin`, where admin merges first, closes with a header line naming both repos' branches in merge order |
| `crucible-prunes-scratch-tests` | Mutation on the changed lines lists the two scratch tests that kill nothing unique and keeps the one that catches dropped rounding; no locked test is listed |
| `crucible-flags-shaped-to-tests` | Green locked tests with an implementation that branches on the test's own input are returned as a finding, not passed |

## Running

Run from the plugin root (the worktree, on a branch) so the cases load that branch's skills. Give each command one filter: with `--case` repeated, only the last glob runs. Each case runs 3 times by default.

The writing cases need a fixture repo and file tools, and run with and without the plugin:

```sh
claude plugin eval . --tag writing --scaffold --allow-tools Bash Write Edit
```

The triggering cases are only meaningful single-arm, because the no-plugin arm can never fire the skill:

```sh
claude plugin eval . --tag triggering --ablation none
```

The `align`, `spike`, `cut`, `build` and `crucible` cases invoke their skill by name, so they are single-arm too:

```sh
claude plugin eval . --tag align --scaffold --ablation none --allow-tools Write Edit
claude plugin eval . --tag spike --scaffold --ablation none --allow-tools Bash Write Edit
claude plugin eval . --tag cut --scaffold --ablation none --allow-tools Bash Write Edit
claude plugin eval . --tag build --scaffold --ablation none --allow-tools Agent Bash Write Edit
claude plugin eval . --tag crucible --scaffold --ablation none --allow-tools Agent Bash Write Edit
```

The `tester-gates-*` cases share one glob, across both tags, single-arm:

```sh
claude plugin eval . --case 'tester-gates-*' --ablation none --runs 1 --max-cost-usd 5 --scaffold --allow-tools Bash Write Edit
```

Results land in `evals/results/`, which is ignored.
