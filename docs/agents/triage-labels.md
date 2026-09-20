# Triage Labels

The skills speak in terms of canonical roles across two lanes — the **inbound** lane, where **Triage** classifies work that arrived cold, and the **planning** lane, where **Align** creates work and holds it in `needs-alignment` until `/cut` cuts it into slices. This file maps those roles to the actual label strings used in this repo's issue tracker.

| Label in mattpocock/skills | Label in our tracker | Meaning                                          |
| -------------------------- | -------------------- | ------------------------------------------------ |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue          |
| —                          | `needs-alignment`    | Planning lane: the body is not yet the contract  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information         |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| —                          | `ready-to-propose`   | Planning lane: a formal proposal is owed before work can be cut |
| —                          | `awaiting-decision`  | Planning lane: the proposal is out; a human decides |
| —                          | `ready-to-cut`       | Planning lane: the contract is done; the slices are owed |
| —                          | `ready-to-build`     | Cut and published; takeable now          |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.

Edit the right-hand column to match whatever vocabulary you actually use.