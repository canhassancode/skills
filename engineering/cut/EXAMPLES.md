# Worked cut

One alignment (#228) cut into a spec node and three slices. The spec body follows [SPEC.md](SPEC.md); each slice body follows [TICKET.md](TICKET.md). Titles are the nodes' own; the bodies are what `/cut` transcribes.

## The spec node — `Saved-search alerts` (#231)

````markdown
> Alignment: #228 · Verified against: `3f9c2ab`

Every saved search alerts the shopper once when a matching listing lands, and stops when they delete it.

# What this builds

Shoppers who watch for a kind of listing re-run the same search by hand and miss what lands between visits. A saved search watches for them, puts one row in the daily digest when a match lands, and goes quiet when they delete it.

# Scenarios

| # | scenario | slice |
| --- | --- | --- |
| 1 | **A match lands.** A shopper has saved "road bikes under £500"; when a matching listing is published, the next digest shows it once. | #232 |
| 2 | **A second match the same day.** Another match within 24 hours adds no second row for that search. | #232 |
| 3 | **Nothing matches.** A search with no matches adds no row, and the shopper's other searches still appear. | #233 |
| 4 | **The shopper deletes the search.** Listings published after the delete never appear; one matched before it still does. | #234 |

# Order

#232 goes first — it builds the saved search and the match event. #233 and #234 both build on it and can run side by side.

# Shared pieces

| piece | shape | built by | used by |
| --- | --- | --- | --- |
| `SearchMatchEvent` | `(listing_id, saved_search_id, matched_at)` | #232 | #233 |
| `SavedSearchStore` | `find(query)`, `list(account_id)`, `delete(id)` | #232 | #234 |

# Decisions

- **Alerts go in the existing daily digest, not push.** No client supports push, and it needs a permission this feature doesn't.

# Premises

- Listings publish through one path, `ListingService.commit/1` — [listing.ex:88 @ 3f9c2ab](https://github.com/acme/market/blob/3f9c2ab/lib/listings/listing.ex#L88).

# Out of scope

1. Alerts on sold listings — the index drops them at sale; bringing one back is its own decision.

# Unresolved

None.
````

## Slice #232 — `A saved search alerts once when a matching listing lands`

````markdown
> Spec: #231 · Alignment: #228 · Verified against: `3f9c2ab` · Size: medium

# What this builds

A shopper who saves a search gets one row in their daily digest when a matching listing is published. Today they re-run the search by hand and miss what lands between visits.

# Scenarios

1. **A match lands.** A shopper has saved "road bikes under £500". When a matching listing is published, the next morning's digest shows it once.
2. **A second match the same day.** When another matching listing is published within 24 hours, the digest still shows one row for that search, not two.

# Acceptance criteria

Each decided by `mix test`.

- [ ] C1 · S1 · `test/saved_search/match_test.exs`: a published listing matching one saved search emits one `SearchMatchEvent`.
- [ ] C2 · S2 · `test/saved_search/dedupe_test.exs`: a second match inside 24 hours adds no second digest row.

# Decisions

- **One alert per search per 24 hours, not one per listing.** A busy search would flood the digest.

# Premises

- Listings publish through one path, `ListingService.commit/1` — [listing.ex:88 @ 3f9c2ab](https://github.com/acme/market/blob/3f9c2ab/lib/listings/listing.ex#L88).
- The digest already takes event rows, `Digest.add/2` — [digest.ex:41 @ 3f9c2ab](https://github.com/acme/market/blob/3f9c2ab/lib/digest/digest.ex#L41).

# Boundaries

**Always** copy the saved query into the event; the digest re-reads nothing. · **Ask first** before changing `SearchMatchEvent`'s shape — #233 reads it. · **Never** widen the 24-hour window to make a test pass.

# Out of scope

1. Ranking matches — the digest orders by recency; relevance is its own decision.

# Interfaces

<details><summary>Owned and consumed</summary>

| name | shape | owned | read by |
| --- | --- | --- | --- |
| `SearchMatchEvent` | `(listing_id, saved_search_id, matched_at)` | here | #233 |
| `SavedSearchStore` | `find(query)`, `list(account_id)`, `delete(id)` | here | #234 |

</details>

# Blocked by

None.

# Unresolved

None.
````

## Slice #233 — `A saved search that matches nothing sends no digest row`

````markdown
> Spec: #231 · Alignment: #228 · Verified against: `3f9c2ab` · Size: small

# What this builds

A search that matches nothing adds no row to the digest, and the shopper's other searches still send theirs. Today nothing is saved, so there is no quiet search to tell apart.

# Scenarios

1. **Nothing matches.** A shopper has two saved searches. When a listing is published that matches only the second, the digest shows one row for the second and nothing for the first.

# Acceptance criteria

Each decided by `mix test`.

- [ ] C1 · S1 · `test/digest/partial_test.exs`: an account with one matchless search and one match receives exactly one digest row, for the match.

# Decisions

- **A quiet search is skipped, not the whole digest.** Suppressing the digest would silence the shopper's other alerts.

# Boundaries

**Always** decide sending per account, not per search. · **Ask first** before changing how the digest collects events — #232 shares it. · **Never** add a placeholder row to keep the digest's shape.

# Out of scope

1. Telling the shopper a search has gone quiet — a notification about the absence of notifications.

# Blocked by

#232.

# Unresolved

None.
````

## Slice #234 — `Deleting a saved search stops its alerts`

````markdown
> Spec: #231 · Alignment: #228 · Verified against: `3f9c2ab` · Size: small

# What this builds

Deleting a saved search stops its alerts from the moment the delete commits. Today there is no saved search to delete.

# Scenarios

1. **The shopper deletes the search.** A shopper deletes "road bikes under £500". A matching listing published afterwards never reaches their digest.
2. **A match was already waiting.** A listing matched an hour before the delete; the next digest still shows it.

# Acceptance criteria

Each decided by `mix test`.

- [ ] C1 · S1 · `test/saved_search/delete_test.exs`: after `delete/1`, a matching published listing emits no `SearchMatchEvent`.
- [ ] C2 · S2 · `test/digest/pending_test.exs`: a match recorded before the delete still appears in the next digest.

# Decisions

- **A match made before the delete still sends.** The shopper earned that alert before deleting.

# Premises

- The digest reads saved searches when it assembles, not when it matches — [digest.ex:58 @ 3f9c2ab](https://github.com/acme/market/blob/3f9c2ab/lib/digest/digest.ex#L58) (`Digest.assemble/1`).

# Boundaries

**Always** read the search set when the digest assembles. · **Ask first** before reordering the delete path — #232's dedupe reads the same rows. · **Never** soft-delete to keep tests green; the alerts stop.

# Out of scope

1. Undoing a delete — a restore is a new search with a new id.

# Blocked by

#232.

# Unresolved

None.
````
