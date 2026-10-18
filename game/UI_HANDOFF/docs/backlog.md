# Remaining game work

The 0.3 presentation pass implements the authored screens, 32 symbols, 12 ball appearances, responsive menus and detailed interactive lobby. The subsequent code review fixes input races, interpolation, font restoration and hidden rendering cost. See [presentation](presentation.md), [code review](code-review.md) and the [actual comparisons](../REFERENCE_COMPARISON.html). Pixel-perfect identity and subjective acceptance are not claimed.

These remaining concept/product tasks retain section 12's dependencies.

| Priority | Work | Acceptance |
| --- | --- | --- |
| P0 | Human visual and territory-readability acceptance | Review eight paired surfaces; record the ten-observer M1 comprehension/appeal gate and agree which game differences to retain |
| P1 | Remaining M2 reliability matrix | Async inbox where required, latency/loss/disconnect/exploit scenarios; original-ack replay is now implemented and regression tested |
| P1 | 2v2, parties and four arenas | Four real clients, team-union scoring, arena isolation and measured capacity; depends on M2 |
| P2 | More abilities and guided practice | Distinct abilities with counterplay, teaching and balance evidence; twelve appearances currently share Drift/Anchor |
| P2 | Audio, accessibility and physical devices | Ownership without color alone, audio controls, physical touch/gamepad and phone profiling; emulator layouts already checked |
| P2 | Persistence, progression and rewards | Durable profile/session safety, migration and reward deduplication; current profiles are explicitly session-only |
| P3 | Beta/release gates | 100 actual character resets, network/capacity/device evidence, human gates and explicit release decision |

The 100 menu/skin-cycle fixture is a UI allocation check, not the 100-character-reset gate. Store previews and free collection work; trade, fusion, purchases and 2v2 describe their real availability. Private reference physics and the full proprietary roster were not recovered.
