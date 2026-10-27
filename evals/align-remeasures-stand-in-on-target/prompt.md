/align .scratch/api-client/api-client.md — we've done this one in this session: tiered as a known parent, the red team said go, and I approved every section of the parent spec below. Close the session. There's no remote here.

## Goal
Generate the ShipCo API client from ShipCo's OpenAPI file, so nobody hand-edits it and CI's lint passes on it as generated.

## Out of scope
A second carrier, publishing the client as a package.

## Shape
- One generator script, `scripts/generate-client.js`, writing `src/shipping/client/`.

## Rules every child follows
- Generated lines wrap at shoplint's line limit, 120 characters.

## Journeys
1. ShipCo publishes a new OpenAPI file, someone reruns the generator, and CI's lint passes with no hand edits.

## Children, in build order
1. Generate types — one type per schema in the OpenAPI file.
2. Generate requests — one function per operation, wrapped at the line limit.

## Decisions
- 2026-10-27 Q: What line limit does shoplint enforce? → A: 120 (spike: `npx shoplint --print-config` against a scratch install of shoplint).
- 2026-10-27 Q: Commit the generated client or generate in CI? → A: Commit it; reviews see the diff.
