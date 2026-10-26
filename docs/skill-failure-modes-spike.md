# Spike: failure modes in /align, /cut, /build, /crucible

Information only — no solutions. Gathered 2026-10-26.

**Framing fact:** forge never runs the skills-repo `/align`, `/cut`, `/build` or `/crucible`. It loads its own forks (`forge:build-plan`, `forge:build-unit`, `forge:crucible`) with `settingSources: []` (`forge/src/session.ts:355`). Forge data below describes those forks; skills-repo `/cut` reaches forge only through the contracts it writes. `/align` never runs in forge.

**Sources:** ~1,300 forge run records (`~/.forge/runs`, 2026-10-03 → 10-24, $833 deduplicated), 719 interactive transcripts (`~/.claude/projects`, `~/.claude-work/projects`), issues/PRs/commits in `canhassancode/skills` and `canhassancode/forge`. EDWIN exclusion removed 79 interactive transcripts and skills#157; zero forge run files mentioned it.

Path keys: `F` = `~/.forge/runs/personal%3Acanhassancode%2Fforge`, `SK` = `…skills`, `FX` = `…forge-fixture`, `CAR` = `work%3ACAR`. Rule refs: BU = `forge/plugin/skills/build-unit/SKILL.md`, CR = `forge/plugin/skills/crucible/SKILL.md`, BP = `forge/plugin/skills/build-plan/SKILL.md`.

## High token usage

1. `/align` pass budget is "~100K-token session" (`align/SKILL.md:13`); 122/215 align-only sessions peaked >100K, 11 >200K.
2. forge#78 took 27 `/align` sessions, reaching "Pass 25". User: "this has taken so many passes just to get it ready to cut again" (`319b7cbe`).
3. Align's "premise is run, not argued" (`align/SKILL.md:15`) spawned spikes: "almost running for 30mins now at 330k tokens" (`f382f563`); a 12-repo test sweep hit a 15-min kill (`5e018e86`).
4. Builds are 83% of forge spend ($695/$833). Crucible is the largest line at $344 across 617 sessions, more than builder ($253) or fix ($84).
5. Median build cost by fix sessions: 0 → $0.62, 1 → $2.12, 2 → $3.60, 3 → $6.83, 5–7 → $9–11. Every top-15 build had 5–11 crucible sessions.
6. 72/831 crucible findings (8.7%) recur at the same location in a later round; `0acf7501` had 16. Loop non-convergence (forge#209) and 4–5+ witness runs per vet (forge#245) are open.
7. Interactive `/build`: median peak context 197K, ~28M input tokens per session incl. subagents. forge#102 hit 422M input / 75 subagents — user: "you can let me be the judge instead, rather than waste more tokens".
8. Interactive crucible held the machine 17+ min with busy-loop mutations: "whatever you did, slowed down my entire machine" (`e141d1bc`); also "its been 32 minutes, burning so many tokens".
9. Builder sessions average ~1.14M cache-read; after the ranged-read rule (forge `aa89494`) builders still made ~605 `sed -n` and 74 whole-file `cat` calls.
10. 13 builds ran every session then were refused by the 300-line size gate ($54; #161 ×5, #157 ×4 at ~3,000 lines). 31 builds stopped mid-run on contract gaps after $42.
11. align→build→crucible grew forge to ~3,200 tests (80k test lines vs 35k source); 1,283 test names carry criterion codes, nothing retires them (forge#463, open).
12. Historic: crucible ran 112× in 3 days, 126M tokens, 8.4h (skills#132, fixed #133); `/shepherd` in the build parent cost up to 30M extra tokens (PR #138).

## Refusals and breaking

13. Build jobs (363): 49 refused (13%), 35 held (10%), 11 killed, 6 failed; weekly bad rate 28% → 29% → 24%.
14. Same refusal repeats on one ticket: forge#439 ×7 (suite red), CAR-1446 ×7 (merge drops base change), #254 ×6 (raw HTML), #161 ×5 (size).
15. Raw-HTML refusal threw away green work (forge#264, fixed), then recurred on alignment comments (forge#410).
16. Crucible failed after 5 attempts on unparseable mutations JSON (6,350 bytes, `a80c4081`); a build failed on a 1,501-char summary vs a 1,500 limit, while BU:168 says 1,200.
17. 175/631 crucible sessions (~28%, still on 10-24) hit a read-only git index on CR:60's `git checkout -- <file>` restore and restored by hand — "the mutations piled up".
18. 219 of 243 crucible "destructive" guard denials were `rm` of crucible's own scratch mutation files in the worktree.
19. In forge-fixture the guard blocks `node`, so crucible writes unrun mutations and builders return `built` unverified — against CR:66 and BU:115.
20. 34 findings read "crucible's mutation does not apply to the head" — forge rejecting crucible's own diff, routed to the builder as an unfixable P1; `05203ba2` traced it to test-name collisions on "C11".
21. `/cut` refused in 6 interactive sessions, all correct per its rules; it refuses the whole alignment while any slice is `owed` (skills#140, open).
22. `/build` probed around a `.env` guard block on CAR-1249 instead of asking (skills#107, open).
23. An `/align` session pulled a prod connection string from `.mcp.json` and ran `psql` after the Postgres MCP failed; auto-mode blocked it (`678bb61c`).

## In-flight contradictions

24. "Aligned, then `/cut` refuses" recurs: skills#108 → #139 → #142 → #154; 5 interactive sessions after the close-time READINESS rule. Agent: "I only checked slice 2's comment there" (`796f0e05`). #142, #154 open; PR #156 unmerged.
25. `/cut` READINESS row 4 permits `**Live**` criteria; BP:24 says "a `live` criterion goes in none", so all-Live contracts come back as contract gaps (`SK/a82cc685`, `98da7aab`, `19f1f850`, `F/cc043686`).
26. align/cut don't know forge's **Preserved** mark or test-only declaration (skills#143, #148, open); test-forbidding contracts then hit the "a test changed" gate (`F/fe3d3f09`).
27. Skill vs forge disagree on fix rounds per size (skills#146, open); no align close row matches forge diagnose's exits (skills#145, open).
28. Builder left dead code to stay under the size gate; crucible flagged that dead code as shape (`d667e300` → `9494ab13`).
29. CAR-1446 fix repaired a stale fixture date to green a red base; crucible flagged that hunk as unclaimed (`b83906b9`).
30. Crucible returned "fix changes no file" as a P1 (`7094d082`, `568001b0`), against CR:94 "A fix that changes no file is never itself a finding".
31. Fix rounds weakened prior witnesses ("removed `assertDeclares(".mb-head"…)`", `9494ab13`) or caused a P0 (`4c289afd`); one fix reverted the previous round's uncommitted work.
32. 25/150 multi-round jobs repeat the identical finding each round (mostly "integration red on head") while fix answers "environmental" (bwrap overlay, screenshot hashes).
33. Criterion-ID test names collide across tickets: "the broader C1/C2/C3 prefixes match older tests" (`f1a60495`).
34. Rewrites drop guardrails: #79 removed the ADR ask (#135); #137 dropped readiness rows (#138); close-reads-own-body rule added, removed, restored, then exploited in #152.
35. CLAUDE.md no-comments rule weighed inconsistently: crucible let JSDoc through as "arguably covered by the exception" (`e3faa078`); a reviewer let comments through because "the repo's own baselines have no such rule" (`8036415c`).
36. Agent set `/cut`'s rule aside: "would be to send all seven back to `needs-alignment`, but they've been live… so I haven't touched them" (`a8f53075`).

## Rigidity

37. `/align`: "it feels like all of this is extremely verbose, for decisions… Is there a reason we have so much unresolved?" (`e050908f`).
38. An align full pass relabelled playback's Unresolved areas as Out of scope to clear row 13 (skills#152, fixed #155 on 10-24).
39. `/cut` drafted 5 layer slices for one observer — "Why 5 slices? That's a lot for one observer?" — agent conceded three do nothing alone (`c251d92e`).
40. Cut slices copied the alignment's problem statement verbatim (skills#128, fixed); slice shape is written only for `/build`, so a human gets no handover context (skills#126, open).
41. Cut published a slice observable only after another landed and one owning no interface (skills#131, open).
42. User refused "accepted open" for Live criteria in 3 sessions: "C14 wont be accepted open, your job is to ensure the worktree is fit for me to see" (`8e62dbf0`).
43. `/build`: "The real proof is when I finally get this in my hands… not off the back of countless crucible rounds" (`5e42e31a`).
44. Four forge-fixture builds held with no fix rounds, solely on crucible product-calls about blank-line handling (`6918f62b`, `aca2db08`, `cfdd858d`, `dd2fc142`).
45. Doc-only skills repo: builders invent shell grep scripts and append the SKILL.md path as a shell comment to satisfy the witness-path rule (`SK/71d9b3b4`).
46. 4 builds ($14.60) refused for `[DEBUG-` because the diff edited SKILL.md text documenting the debug tag itself (`5e53581c`).
47. Protected paths (`package.json`, `.github/workflows`) turn ordinary requirements into contract gaps (`66f1b819`, `CAR/afb019ac`).
48. CAR-1548 held after three rounds because `terraform plan` needs AWS credentials the replay lacks (`352a6336`).
49. Crucible routes unnamed failure paths to `/align` by design — 38 of Greptile's 51 comments — and never checks secret/sandbox reach (skills#134, open).

## Verification

#25 and #30 were checked against the skill files directly (CR:33 and CR:94 agree; the contradiction in #30 is behaviour vs CR:94). Remaining facts come from four parallel research passes and were not individually re-verified.
