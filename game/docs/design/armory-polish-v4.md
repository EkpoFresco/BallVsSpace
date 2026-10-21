# Armory polish and code review

21 October 2026 · `0.4.2-armory-polish` · 43 canonical Luau scripts.

The user authorized visual/interaction review, icons matching the approved flat heroes, weapon animation/functionality checks, code optimization and a GitHub push. This continues the [flat armory](flat-armory-v3.md) and preserves [weapon-v2 rules and tuning](weapon-territory-v2-build.md).

## Presentation changes

- Thirty-two original outlined icons use the same cream, steel, gold, mint and coral as the weapons. Charcoal panels, magenta headings, mint actions and the cream character showcase remain. Editable assets and upload bindings are documented in [ui-v4](../../assets/art/ui-v4/README.md).
- Inventory separates the weapon name from its ability and shows damage, reach and spin speed in the detail footer. All thirty descriptions and stat lines are checked at the supported emulated sizes.
- Weapon poses use a fractional display clock shared with interpolated ball positions. Projectiles, whips, reversals and charged swings no longer advance only with the 10 Hz territory packets. Replay also interpolates poses and restores recorded HP.
- Damage, healing and guard blocks have short text feedback. A preallocated ring reinforces a hit; reduced motion keeps the text and suppresses the rise/ring. New rounds and replay rewinds reset feedback history.
- Hover/press tweens cancel the previous transition. Selection events provide a focus tint. Automated mouse input is verified; this does not certify physical gamepad navigation.

## Code analysis and fixes

| Area | Finding and change | Verification |
| --- | --- | --- |
| Territory rendering | 1,024 studs each carried decorative child Instances. A single transparent stud overlay replaces them; seven signed ownership colors are precomputed. Identical immutable decoded buffers skip repeated application. | All 1,024 final cells verified, before/after CPU microbenchmarks, live match and two-client checks. |
| Motion/replay | Ball interpolation and weapon clocks could disagree. The controller now returns a fractional pose tick, interpolates copies of history, and bounds missing-packet extrapolation to six ticks. | Fractional clock, moving projectile between snapshots, immutable history, startup/same-tick/stale packet checks; 3,600 native weapon poses. |
| Combat feedback | HP changes had no local contact cue. Reused labels/rings report damage, healing and blocked guards without allocating per-hit Instances or tweens. | No duplicate hit on unchanged HP, reduced motion, round reset and all thirty heroes. |
| Camera lifecycle | A lobby-only flag could ignore a replacement camera or respawn. Battle wrote camera/movement every frame and restored hardcoded movement defaults. Cache camera, humanoid and mode identities; save/restore movement values and freeze both jump modes. | Replacement camera, nondefault movement restoration, 1,000 unchanged calls with zero camera writes, and one actual character reset preserving GUI and camera subject. |
| UI lifecycle | Overlapping button tints could finish out of order. Cancel the previous tween before starting the next. | Actual menu clicks and fresh 100-cycle menu/skin fixture with no descendant growth. |

The review traced Bootstrap command validation through queue, draft, aim, simulation, combat, territory, result resolution and replication, then client decoding, buffering, replay, camera and UI ownership. It also inspected protocol input bounds, command replay protection, profiles, draft randomness, telemetry and module cleanup. Existing safeguards remain: authoritative deadlines, finite/schema-checked and rate-limited commands, bounded history/sample/trace tables, simultaneous hit collection before HP application, inert defeated weapons, and cutoff locking. No damage, spin, range, match duration or result rules changed in this polish pass.

`Protocol.decodeTerritory` creates a new buffer for accepted snapshots/deltas. The renderer's identity cache relies on that immutable-buffer contract; a future in-place decoder must invalidate the cache explicitly. Hidden fallback ViewportFrames/models remain for API compatibility; they were not rewritten without evidence of a bottleneck. Profiles are still session-only and the server still hosts one 1v1 arena.

## Measurements and test scope

| Measurement | Before | After |
| --- | ---: | ---: |
| Territory GUI descendants | 4,098 | 1,027 |
| Fully changed board update, median | 3.2223 ms | 2.0242 ms |
| Repeated identical board call, mean | 0.02039 ms | 0.0000621 ms |

The board fixture uses twelve batches of thirty fully changed immutable boards, followed by 1,000 identical calls. The descendant reduction is 3,071 (about 75%); measured changed-board CPU time fell about 37% in this Studio run. These are isolated CPU calls, not whole-game FPS or phone results. Two-hero rendering remains about 0.066 ms median in a 2,000-call fixture; that small change is not presented as a proven speedup.

Retained [test evidence](../../test-evidence/README.md) covers 22 logic groups, thirty mirrored pairs / sixty accelerated rounds, a fresh two-client match, 286 emulated layout checks, actual menu input at three sizes, ninety geometry-alignment poses, 3,600 animation poses, lifecycle/camera tests, complete Practice with replay/rematch, source/build checks and a fresh saved-file launch. Native screenshots are visually inspected in addition to numerical assertions. Synthetic animation galleries establish pose continuity, not live combat authority; the separate match and multiplayer runs cover that path.

Remaining gates: physical-phone touch/FPS, physical gamepad input, human readability/feel acceptance, latency/loss and disconnect stress, all-matchup balance, 2v2, durable progression and final audio. The sixty mirrored rounds test symmetry; they are not a 435-pair balance study. GitHub source sharing does not publish a Roblox experience.
