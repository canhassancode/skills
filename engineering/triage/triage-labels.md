# Triage Labels

The skills speak in terms of canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker.

## State labels

Every triaged issue carries exactly one state label.

| Label in our tracker | Meaning                                  |
| -------------------- | ---------------------------------------- |
| `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`    | Requires human implementation            |
| `wontfix`            | Will not be actioned                     |

## Type labels

Orthogonal to state — describe what kind of issue this is, not what state it's in.

| Label in our tracker | Meaning                                                                                              |
| -------------------- | ---------------------------------------------------------------------------------------------------- |
| `prd`                | Epic-style parent document produced by `/to-prd`. Does not carry a state by default; spawns children. A `prd` issue only takes `needs-info` when blocked on external input (approval, spike, missing context). |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from these tables.

Edit the right-hand column to match whatever vocabulary you actually use.
