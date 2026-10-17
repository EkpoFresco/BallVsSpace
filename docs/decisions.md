# Implementation decisions and specification notes

The research specification and original evidence remain unchanged. These are implementation decisions, not observations of the reference game. Scoring remains `bvs-rules-1`.

## Updated user visual requirement

The earlier presentation schedule is superseded by the current user instruction: reconstruct the reference appearance now, then differentiate. See `replica-pass.md`. The new build uses the existing canonical controller/service filenames; four new modules are AppearanceCatalog, BallArt, ReferenceLayout and ReferenceUi. The human milestone no longer delays visual work.

Motion is explicitly versioned `bvs-motion-2`: physical radius 5.9, center bound 26.1 and spawn ±19 replace the prior 1.5 / 30.5 / ±24 assumptions. On the 446-pixel inner court this is an 82.23-pixel body, with the left spawn at x268.59, matching the inspected approximately 82-pixel body and x270 opening. Both client projection and server collision bounds agree. Per-kit speeds and collision response remain our proposed arcade rules, not recovered reference formulas. The signed influence, max-team pressure, tick-1800 cutoff and exact overtime/draw rules are unchanged.

Draft and aim windows are 20/30 seconds. The service watchdog is 360 seconds so three legal full-length choices and overtime rounds cannot exceed the old 240-second watchdog. Early locks retain the 3/2-second minimums.

Appearance IDs are bounded strings validated against AppearanceCatalog and the selected legal kit on the server. They are private during draft and revealed with the kit. Cell, Acid, Poison, Verity, Burst and Vampire are Drift appearances; Axe is an Anchor appearance. Clicking a visible card sends the appearance and kit, then commits after the action interval. No reference assets or private scripts were extracted. The clean floor is the default visual study; the authoritative territory grid is selectable in settings.

The user explicitly requires the finished play view/UI to look almost identical to the original reference. This supersedes treating the prototype's initial minimal HUD as final art direction. After the logic checkpoint, a first match-screen pass recreated the front-facing navy court, blue surroundings, side figures, centered cards, outlined type and gold lock button with original primitives. Compare camera/court framing, menu placement, draft cards, aim controls, score/result panels and transitions against the supplied evidence at matched viewport sizes. The current pass adds a walkable lobby and compact collection. The comparison page records the remaining differences, especially lobby detail and full-roster coverage. Subjective near-exact acceptance remains open.

## M1 scope

- The ability catalog contains Drift and Anchor only. The UI offers three appearance cards and a seven-appearance picker, all validated against those two legal kits. The three-distinct-card algorithm is tested against an eight-ID fixture, but the six future kits are not executable. There is no useful wildcard choice when every implemented kit is already offered; wildcard UI and its full lifecycle tests await the expanded roster.
- One arena serves a FIFO queue. A separate Practice button explicitly seats a deterministic bot. Parties, 2v2, four-arena allocation and durable profiles are later milestones.
- The profile adapter stores only session state and deduplicated completed-match IDs. It does not award durable coins, XP or mastery. All UI identifies session-only progress.
- The former cyan/coral primitive view is superseded by the reference reconstruction. Ball labels show territory percentages, the optional grid retains team strength shading, and the court/ball models are generated from original geometry. No reference image is a game asset.

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
- Audio, richer patterns/accessibility, complete compact-landscape usability, a guided onboarding experiment, and real-phone profiling remain M3/human work. The first iPhone 17 Pro landscape layout obscured the court; that failed capture is retained. The later reference-style pass removes the large battle footer and adapts the card panel, with new emulator captures. These are layout checks, not a physical-phone pass. Use a full-size Studio viewport or device simulation for M1 desktop play.

## Fullscreen input correction

The reference HUD uses ScreenInsets.None. On the iPhone emulator, Camera.ViewportSize was 401×777 while ScreenGui.AbsoluteSize was 401×873. Aim conversion and every visual layer now use the actual fullscreen GUI size; layout listens to that size changing. Main touch controls have a 44-unit minimum height. A live GUI geometry check returned a 314.85° diagonal for a 315° target (pixel rounding tolerance 0.5°), a 44.32-unit Lock Aim height and in-bounds portrait/landscape courts. See replica-layout-*-assertions-verified.json. The failed phone-mode MCP mouse click is retained and is not counted as touch acceptance. This follows the [Camera viewport documentation](https://create.roblox.com/docs/reference/engine/classes/Camera) distinction between device-safe and full-screen sizes.

The compact collection now includes Verity, Axe, Poison, Burst, Cell and Vampire on its first row, with Acid on the second. Selection highlights an icon; Yes confirms and No closes. These are seven appearances over two territory kits, not seven newly implemented ability kits.
