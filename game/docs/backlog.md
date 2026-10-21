# Remaining game work

The [weapon-v2 build](design/weapon-territory-v2-build.md) implements 30 original heroes, weapon-only territory capture, health/KO combat and a centered studded arena. The authored lobby and responsive menu infrastructure remain. Automated evidence is separate from human acceptance and balance.

These remaining concept/product tasks retain section 12's dependencies.

| Priority | Work | Acceptance |
| --- | --- | --- |
| P0 | Human visual and territory-readability acceptance | Review eight paired surfaces; record the ten-observer M1 comprehension/appeal gate and agree which game differences to retain |
| P1 | Remaining M2 reliability matrix | Async inbox where required, latency/loss/disconnect/exploit scenarios; original-ack replay is now implemented and regression tested |
| P1 | 2v2, parties and four arenas | Four real clients, team-union scoring, arena isolation and measured capacity; depends on M2 |
| P1 | Hero balance and guided practice | Test all weapon families, matchups and aim strategies; improve teaching and counterplay from human play evidence |
| P2 | Audio, accessibility and physical devices | Ownership without color alone, audio controls, physical touch/gamepad and phone profiling; emulator layouts already checked |
| P2 | Persistence, progression and rewards | Durable profile/session safety, migration and reward deduplication; current profiles are explicitly session-only |
| P3 | Beta/release gates | 100 actual character resets, network/capacity/device evidence, human gates and explicit release decision |

The 100 menu/skin-cycle fixture is a UI allocation check, not the 100-character-reset gate. Store previews and free collection work; trade, fusion, purchases and 2v2 describe their real availability. Private reference physics and the full proprietary roster were not recovered.
