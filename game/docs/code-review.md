# Post-presentation code review — 17 October 2026

This review began after the 0.3 desktop, phone-emulator, world-prompt and fresh two-client presentation checks. It covers all runtime modules, input/replication, UI lifecycle, the Rojo mapping, builds, asset generation and partner handoff. Fixes were made in canonical source and tested in the verified local BallVsSpace Studio.

## Findings fixed

| Finding | Fix |
| --- | --- |
| Aim Lock could use an earlier throttled direction | Lock carries the final angle atomically. Server validates, rounds and freezes it. Regression asserts 314.6 becomes 315 and later Aim is rejected. |
| Rapid draft clicks raced a delayed commit | Wait for the accepted selection acknowledgement; scope the commit to match/round/generation; prevent another selection while committing. |
| Extra touch pointers or older state could disturb aim | Track the initiating InputObject, clear it on phase exit, preserve local angle while aiming and send a trailing update after release. |
| Interpolation before the buffered interval jumped forward | Hold the earliest sample, refresh same-tick velocity and reject stale ticks. |
| Malformed motion could duplicate seat identity | Reject nonsequential seat IDs before applying the snapshot. |
| Retried commands received a different acknowledgement | Replay original outcomes from a bounded 64-entry per-player cache, behind the global rate limiter. Evicted IDs remain rejected. |
| Loaded atlas balls still moved detailed hidden models | Release hidden fallback detail, retain one colored sphere and skip hidden model/weapon transforms. Static previews have a bounded image-load check. |
| Score updates repeated full UI layout | Cache viewport, phase, touch mode and territory visibility; continue updating scores and input feedback. |
| Portrait font restoration raced the caption | ButtonText follows its button's restored TextSize. |
| An old toast fade obscured new messages | Cancel the active fade before showing another message. |
| Cosmetic preview ignored reduced motion | Preview spin respects the setting. |
| Equip feedback did not affect the next draft | Offer the equipped appearance first; each round still requires explicit selection. |
| Identical buffers were serialized per participant | Construct one territory/motion payload per broadcast. Studio hashes update when grid/state changes. |

## Results

- `replica-review-core.json`: 11 groups pass, including signed pressure, collision sweeps, exact cutoff/overtime, final-angle locking, acknowledgement cache and disconnect/profile cases.
- `replica-review-client.json`: startup interpolation, same-tick velocity, stale motion, font round trip and notification race pass. One hundred menu/skin cycles retain exactly 586 descendants before and after; the isolated fixture destroys its GUI afterward. This is not 100 character resets.
- `review-final-result.json`: real clicks across menus, queue/cancel, private draft, loaded art, shell diameter and a complete two-round Practice match pass. Final result: tick 1800, counts 450/386, `match_points`.
- Formatting, Selene, strict Luau analysis and binary/XML builds pass. All 41 canonical sources match the explicitly verified local Studio, PlaceId/GameId 0. Additional final device/multiplayer and repository checks are recorded in BUILD_STATUS.

## Performance measurements

The identical two-ball benchmark runs 20 batches of 100 render calls with loaded atlases. Baseline mean **0.5116 ms/call**, median 0.5189, p95 batch mean 0.5761. Final mean **0.1395 ms/call**, median 0.1362, p95 batch mean 0.1874: approximately **73% less CPU time in this fixture**. Its fallback parts fall from **210 to 2**. Evidence: `replica-review-baseline-render.json` and `replica-review-final-render.json`. This is not a whole-game FPS claim.

SceneAnalysis ran all six runtime queries: instances, triangles, script memory, unparented instances, animation and audio. Triangle counts depend on viewpoint; shadow work must be separated when comparing draws. MicroProfiler used a snapshot buffer, disposed its session and disabled capture afterward. The baseline lobby had 62 complete frame intervals, median 16.65 ms/p95 17.56; the final sample had 68, median 16.70/p95 17.88. These Studio samples show similar frame pacing and include engine/editor work; they do not establish physical-phone performance. Raw reports are preserved as `replica-review-baseline-*` and `replica-review-final-*`.

## Contracts and remaining scope

The review changes no solver, kit speed or victory rule. Signed 32×32 influence, maximum-per-team pressure, swept painting, team-union counts, tick-1800 cutoff and exact overtime/draw rules remain intact. `bvs-motion-2` is a documented proposal, not recovered proprietary physics.

Profiles remain session-only, with one active arena, two ability kits and 1v1/Practice. Parties, 2v2, durable economy, broader networking/capacity tests, physical touch/gamepad and human acceptance remain in [backlog](backlog.md). The multiplayer driver is gated to Studio test telemetry. The source handoff does not publish a Roblox experience.
