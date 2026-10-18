# Code and design map

Canonical runtime source is `game/src/`, mapped by [default.project.json](../default.project.json). All 41 Luau files use strict mode. UI export copies are context snapshots.

| Folder | Roblox location | Responsibility |
| --- | --- | --- |
| `src/shared` | ReplicatedStorage.Shared | Config, catalogs, types, geometry, territory math, round rules, protocol and draft |
| `src/server` | ServerScriptService.Server | Entry point, queue/match/simulation, abilities, profiles and replication |
| `src/client` | StarterPlayerScripts.Client | Entry point, input, buffered state/motion, UI, camera and renderers |

## Follow a match

1. `server/Bootstrap.server.luau` owns command validation, rate limiting, readiness and the update loop. `CommandHistory` replays original acknowledgements through a bounded per-player cache.
2. `QueueService` seats one 1v1 arena; Practice explicitly uses a deterministic bot. `MatchService` owns Draft → Aim → Battle → result transitions, deadlines, rounds and watchdogs.
3. `SimService`, `Geometry2D` and the two `Abilities` implement numerical motion. `TerritoryService` applies pressure; `RoundRules` resolves scores, cutoff and overtime.
4. `ReplicationService` builds private views. Shared territory/motion payloads are serialized once per broadcast. Territory/state use reliable remotes; motion uses an UnreliableRemoteEvent.
5. `client/Bootstrap.client.luau` connects actions and acknowledgements. `MatchController` buffers incoming state; `HudController`, `LobbyPanels`, `TerritoryRenderer` and `BallRenderer` display it.

## Design contracts

- Rules `bvs-rules-1`: signed **32×32** influence, maximum pressure per team, team-union counts and swept painting. Pressure weakens reinforced enemy cells through neutral before capture.
- Regulation freezes at **tick 1800**. Overtime needs a two-cell lead held for ten consecutive updates; an unheld lead at the cap is a draw. A round win gives one match point, a draw half each. First to two points, or the higher score after three rounds, wins.
- Draft/aim limits: **20/30 seconds**; early-lock floors: **3/2 seconds**; watchdog: **360 seconds**. Opponent choices stay private during draft and aim stays private until reveal.
- Motion `bvs-motion-2`: radius **5.9**, center bound **26.1**, spawn **±19**. The rendered shell is about **82.23 design units** on a 446-unit court. Speeds/response are proposed values, not recovered reference physics.
- Twelve `AppearanceCatalog` entries map to **Drift and Anchor**. Profiles are session-only. One arena, 1v1 and Practice are implemented; [backlog](backlog.md) lists future systems.

## Rendering and performance

The match court and territory are 2D UI. Balls use authored atlas images with one fallback sphere each. Side/winner avatars are 3D models inside ViewportFrames. The lobby is world geometry. See the [UI map](ui/map.html) and [editing guide](ui/README.md).

The 803×602 design canvas scales to actual fullscreen ScreenGui size. `ReferenceLayout` must agree with court, tile, ball and aiming coordinates. Camera.ViewportSize can exclude safe areas the GUI uses; this previously caused phone aim misalignment.

Territory and area counts commit together after a 100 ms display delay. Full snapshots occur at transitions and at least every two seconds; rejected deltas trigger rate-limited recovery. Motion interpolation holds the earliest sample until its interval begins, refreshes same-tick velocity and rejects stale snapshots.

Existing optimizations skip hidden fallback transforms, cache layout until its dependencies change and reuse replication buffers. Territory updates only changed tile properties. [Testing](testing.md#review-and-performance) records the measured render improvement and its limits.

## Numerical decisions retained

The solver batches earliest contacts from pre-contact velocities, applies impulses, separates overlaps and restores kit speed. A zero resultant direction reverses the prior direction. If speed restoration makes a pair approach again, a shared normal component capped by the slower speed plus adjusted tangent magnitudes prevents repeated zero-time collisions. Mirrored fixtures verify these decisions; future four-ball balance remains untested.

Studio automation activates only through explicit test arguments/attributes. Ordinary Play does not enable its telemetry remote. [History](history.md) preserves earlier superseded assumptions.
