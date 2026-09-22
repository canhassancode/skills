---
name: cut
description: Cut a settled alignment into a spec/ticket with vertical slices a builder can pick up cold — one ticket per slice, carrying the interfaces, scenarios, criteria, decisions and rejections that bear on it. Use when a ticket sits at ready-to-cut, when the operator asks to slice, break down or ticket up settled work, or straight after an alignment closes aligned.
argument-hint: <ticket-ref | current conversation>
disable-model-invocation: true
---

# Types
Spec = Parent ticket that houses multiple tickets beneath it: See [SPEC.md](SPEC.md)
Ticket = Vertical tracer bullet sliced tickets: See [TICKET.md](TICKET.md)

# Procedures
1. For a large piece of work. Must be cut into a spec, then to **Vertical Tracer Bullet** tickets. Each ticket delivering noteable value.
2. For a ticket that needs multiple tickets but likely no spec, then create **Vertical Tracer Bullet** tickets only.
3. For a small piece of work. Output to a single ticket.
4. If alignment ticket is sufficient, ask user if this ticket can just be changed as `ready-to-build`.

# Ticket Labels
1. By default, tickets are `ready-to-build`.
2. Tickets that are created with further alignment should get `needs-alignment`.
3. Tickets created with blocking edges on a human gets `ready-for-human` or `needs-info`.

# Relationships
- Specs can have many tickets.
- Decide upfront on blocking relationships, use the repo issue-tracker native relationship features.
 
