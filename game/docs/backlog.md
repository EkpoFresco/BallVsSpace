# Remaining build work

This is an unfinished game. Visual replication is not accepted as 1:1. Each item below needs evidence before it can be closed; the larger milestone dependencies remain in section 12 of the research/build specification.

| Priority | Work | Acceptance |
| --- | --- | --- |
| P0 | Match every authored UI symbol, font, outline, spacing and panel against the reference | Reference/current captures at 803×602, inspected overlays for lobby, draft, collection, aim, battle and results; every intentional difference recorded |
| P0 | Refine ball surfaces and weapon silhouettes | Matched Acid/Axe/Cell/Poison captures and motion comparison; no claim that proposed speeds are recovered reference physics |
| P0 | Finish lobby geometry, prop density and lighting | Matched lobby viewpoints and working authored controls; missing trade/gifts/quests/economy states remain explicit |
| P0 | Make territory ownership and reinforcement understandable | Default visible grid, unambiguous team identity, explained pressure changes, exact score/cutoff; ten-observer M1 gates actually recorded |
| P1 | M2 multiplayer reliability | Original-ack replay, async inbox, disconnect/network/exploit matrix; documented test results |
| P1 | 2v2, parties and four arenas | Correct team-union scoring with four clients; isolated arenas and verified capacity; depends on M2 reliability |
| P2 | Remaining ability kits and guided practice | Distinct server abilities with counterplay, instructions, balance fixtures and live checks; seven current appearances are only two kits |
| P2 | Audio, accessibility and real phones | Readable ownership without color alone, audio/motion controls, actual touch/gamepad and physical-phone profiling |
| P2 | Persistence, progression and rewards | Durable profile/session safety and migration tests; current profiles remain session-only |
| P3 | Beta and release readiness | Human gates, 100-reset leak checks, networking/capacity/device evidence and explicit release decision |

The October 17 handoff restores territory display by default and replaces several placeholder symbol constructions. These are incremental fixes, not completion of the P0 rows. A clean floor remains available from View Settings for comparison. Human/phone gates and GitHub-hosted CI remain pending until run in their actual environments.
