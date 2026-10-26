# Evals

Cases for `claude plugin eval` (Claude Code 2.1.269+). One directory per case: `prompt.md` or `case.yaml`, plus `graders/`.

| Case | Checks |
|---|---|
| `tester-writes-locked-tests` | Titles are the spec's behaviour lines word for word, the invariant goes to a property file, no internal mocks or weak oracles, red reasons reported, no commit |
| `tester-reports-interface-gap` | A behaviour the interface can't observe is reported as a gap, not patched by changing the interface |
| `tester-follows-repo-conventions` | In a repo using top-level `test()`, `__tests__/` and fakes in `src/testing/`, the locked tests follow that layout and reuse its fakes, keeping the `.acceptance.` suffix |
| `tester-triggers-on-spec` | `tester` fires on "write the tests from the agreed spec" |
| `tester-skips-bug-fix` | `tester` stays quiet on a flaky-test fix |

## Running

The writing cases need a fixture repo and file tools:

```sh
claude plugin eval . --case 'tester-*' --scaffold --allow-tools Bash Write Edit
```

The triggering cases are only meaningful single-arm, because the no-plugin arm can never fire the skill:

```sh
claude plugin eval . --case 'tester-triggers-*' --case 'tester-skips-*' --ablation none
```

Results land in `evals/results/`, which is ignored.
