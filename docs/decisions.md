# Implementation decisions and specification notes

The research specification and original evidence remain unchanged. These are implementation decisions, not observations of the reference game. Scoring remains `bvs-rules-1`.

## M1 scope

- The catalog contains Drift and Anchor only. Draft offers both, in a stable seeded order. The three-distinct-card algorithm is tested against an eight-ID fixture, but the six future kits are not executable. There is no useful wildcard choice when every implemented kit is already offered; wildcard UI and its full lifecycle tests await the expanded roster.
- One arena serves a FIFO queue. A separate Practice button explicitly seats a deterministic bot. Parties, 2v2, four-arena allocation and durable profiles are later milestones.
- The profile adapter stores only session state and deduplicated completed-match IDs. It does not award durable coins, XP or mastery. All UI identifies session-only progress.
- Original cyan/coral primitives, diamond/circle labels and strength shading replace the reference's HP/lives presentation. The court is generated at runtime; no reference image is a game asset.

## Collision refinements discovered by tests

The solver batches earliest contacts from pre-contact velocities, applies normal impulses, separates overlaps and restores each kit's speed. Two degeneracies required explicit numerical decisions:

1. A zero resultant direction after simultaneous contacts reverses the prior direction before restoring speed. Retaining the incoming direction caused repeated zero-time impacts in the triple-contact fixture.
2. Restoring unequal kit speeds can make a resolved pair immediately approach again. Only when post-normalization relative normal speed is negative, both bodies receive a shared normal component clamped to the slower speed; tangential magnitudes restore each body's prescribed speed and preserve tangent sign. This prevents repeated zero-time impacts. It does not alter cell pressure or scoring.

The first failing artifacts are retained. The corrected solver passed 200 mirrored pairs (400 rounds), including the previously failing seed 49, with exact mirrored cells and zero recovery events. This is numerical evidence, not proof of human balance or of all future four-ball configurations.

## Rendering and test choices

- A Scriptable camera is reapplied after Roblox's default camera step, including Focus. Setting only CFrame left Focus under the core controller and initially prevented court rendering. Ball labels use a screen-space projection for reliable visibility.
- Territory and area counts commit together after a 100 ms presentation delay. Full snapshots are sent at transitions and at least every two seconds. A rejected delta requests a rate-limited snapshot. Motion uses an UnreliableRemoteEvent; territory and state are reliable.
- Every server territory update asserts a full-grid recount in M1. This deliberately favors evidence over premature optimization.
- Studio automated play activates only through the explicit StudioTestService test argument (or an explicit test attribute). Its telemetry RemoteEvent does not exist during ordinary play or outside Studio.
- The code uses no downloaded gameplay assets. Roblox's own Studio/CoreGui warnings are logged separately from project failures.
- A host-overload abort demonstrated that simulation ticks can stop between territory updates. The test harness initially compared the displayed grid tick with the later movement tick, reporting two mismatches despite equal hashes. It now compares `floor(simTick / 6) * 6` and counts only normal `match_points` completions; aborted attempts remain separate evidence.

## Known gaps to address before M2 acceptance

- Old/duplicate command IDs are harmlessly rejected, but do not yet replay the original acknowledgment as §9 requires. Add a bounded per-player acknowledgment cache and live duplicate-command tests before reliable multiplayer acceptance.
- Match commands are processed synchronously without yielding; phase advancement has one owner. A queued inbox with explicit receipt timestamps should replace this when async persistence/party services are introduced.
- A full transport loss/jitter matrix, exploit burst profiling, disconnect/reconnect in every phase, 100-reset leak checks and a four-client run are pending. Existing unit checks do not stand in for those tests.
- The final two-second replay uses client-received authoritative frames. A durable, versioned event replay/export pipeline is not implemented.
- Audio, richer patterns/accessibility, fully adaptive compact-landscape presentation, a guided onboarding experiment, and real-phone profiling remain M3/human work. The iPhone 17 Pro landscape emulator showed controls obscuring the court; this is a failed layout check. Portrait at an observed 401×778 viewport showed the full court. Small docked Studio viewports can also make the court too small; use a full-size test viewport for M1 desktop play.
