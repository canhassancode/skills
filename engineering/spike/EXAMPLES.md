# Spike examples

## Answered

```markdown
**Q:** Does ShipCo's sandbox return 409 when the same idempotency key buys a second label?

**A:** Yes — 409 with the first label's id in `existing_label_id`.

**Evidence**
$ timeout 120 node buy-twice.mjs
first:  201 { id: "lbl_7Qx", tracking: "SC123" }
second: 409 { error: "duplicate", existing_label_id: "lbl_7Qx" }

**Doesn't tell us:** whether production keeps keys longer than the sandbox's 24 hours.
**Took:** 6 minutes. Scratch deleted.
```

The caller logs: `2026-10-21 Q: Retry a 409 from ShipCo? → A: No; it means the label exists, so fetch it (spike).`

## Out of time

```markdown
**Q:** Does our webhook handler survive two deliveries of the same event within one second?

**A:** Unknown at 15 minutes — the local queue wouldn't start without Redis.

**Tried:** `pnpm dev:webhooks` (fails: ECONNREFUSED 6379); an in-memory queue swap, abandoned at the timebox.
**Next:** a spike with Redis running, or ask whoever owns the handler.
**Took:** 15 minutes. Scratch deleted.
```

## Needs access

```markdown
**Q:** How many orders in staging have more than one parcel?

**A:** needs access: a staging read-only database role. Only a production URL is configured, and it wasn't used.
**Took:** 1 minute.
```
