# Triage Labels

The skills speak in terms of canonical roles across two lanes — the **inbound** lane, where triage classifies work that arrived cold, and the **planning** lane, where `align` creates work and holds it in `needs-alignment` until its tests are locked, or until it is a parent spec for `/cut` to split into children. This file maps those roles to the actual label strings used in this repo's issue tracker.

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| —                          | `needs-alignment`    | Planning lane: the spec, interface or locked tests are still owed |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| —                          | `ready-to-propose`   | Planning lane: a formal proposal is owed before work can go on |
| —                          | `awaiting-decision`  | Planning lane: the proposal is out; a human decides |
| —                          | `ready-to-cut`       | Planning lane: the parent spec is agreed; its children are owed |
| —                          | `ready-to-build`     | Locked tests committed; takeable now |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

When a skill mentions a role (e.g. "stamp the takeable label"), use the corresponding label string from this table.

Edit the right-hand column to match whatever vocabulary you actually use.
