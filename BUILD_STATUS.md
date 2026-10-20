# Build status

Updated 20 October 2026. The final code/logic and visual refinement pass is complete. Open the saved [primary place](game/places/BallVsSpace.rbxl) in Roblox Studio and press F5; `game/builds/BallVsSpace.rbxl` is the identical generated build. Canonical source is `game/src/` (42 scripts). The user's primary local file at `Desktop/VibeCode/Reaction Game/BallVsSpace.rbxl` has also been updated from this build, with its previous version backed up locally.

The compact primary place is now retained in Git alongside source, artwork, approved inputs, tools, skill and selected evidence. Verification refreshes it; CI rejects a stale saved place. Exploratory logs, duplicate pilot checkouts and XML builds remain generated/ignored. The primary Studio window has all 42 current scripts and is left in Play with Inventory open.

## Current UI

- Charcoal surfaces, crimson graphic headers, Montserrat, cyan actions and canonical artwork match the approved direction. Selected and equipped states remain distinct.
- Phones use LandscapeSensor and device-safe margins. Inventory stays beside fixed details and Equip; only its collection grid scrolls, including on medium-height desktops. Store keeps its horizontal composition with aligned columns and scrolling where necessary.
- Lobby controls retain readable physical sizes and clear native movement controls. Draft artwork adapts before descriptions shrink; All Balls uses Back / Choose Ball. Match scores, player labels, utilities, settings and notifications have been checked at small sizes. Long player display names truncate deliberately instead of shrinking.
- HUD badges show actual match points. Round results show territory; match results show match points. Replay is reachable, rematch stays confirmed as Queued ✓, and stopped matches explicitly show no result. Compact result cards and connection/replay banners retain physical font sizes.
- Removed unused heart drawing and unreachable action branches. Territory deltas adjust only changed-cell counts; full snapshots validate/count in one pass. HUD/clock updates avoid repeated work. Wildcard timeout restores a matching kit/appearance; expired rematches are rejected. Modal opening tweens cancel on close/resize, and lobby transitions clear stale status.
- Figma contains editable Inventory/Store, twelve full-game screens and two additional landscape Draft variants. The approved [design](game/assets/ui-concepts/action-v1/design.json) and [pilot](game/assets/ui-concepts/action-v1/pilot.json) inputs are unchanged.

## Verification

The [current scale matrix](game/test-evidence/results/review20-scale.json) passed 27 rendered UI states at ten sizes plus a return to the smallest size: **297 checks, zero flagged issues**. It covers all twelve catalog strings, font/target floors, text fit, safe bounds and button overlaps, including intermediate 800×600 and 900×650 desktops. Sizes also cover the shortest landscape window, older/notched phones, Android, tablet, HD and ultrawide. [Visual evidence](game/test-evidence/results/review20-visual.json) includes eight isolated captures, five live-flow captures and two settled delivery captures.

The [live landscape flow](game/test-evidence/results/review20-phone.json) passed menus/equip, navigation, queue cancellation, private draft, 315° server-observed aiming, two complete rounds, replay restoration and rematch confirmation. The [regression](game/test-evidence/results/review20-regression.json) passed 13 logic groups, eight presentation contracts and 100 UI/skin cycles (722 descendants before/after). A fresh two-client match completed within the driver window: six state and six visual comparisons, zero mismatches, visual failures or aborts.

Formatting, lint, strict analysis, four Node tooling tests and both place builds passed. All 42 Studio sources match. The last lobby-banner reset passed a targeted server-state transition check and fresh [desktop/opposite-landscape navigation](game/test-evidence/results/review20-preview.json). [Verification and build hashes](game/test-evidence/results/review20-verification.json) record the final snapshot. The [decoder benchmark](game/test-evidence/results/review20-protocol.json) measured 0.173 → 0.014 ms for a 12-cell delta in Studio; this is not whole-game or phone FPS.

See the [evidence index](game/test-evidence/README.md) for scopes and retained earlier results. Some first-show captures omitted a close control; settled captures and actual close clicks verified it. Console output retains Roblox CorePackages and external asset-type warnings; authored atlas loading passed. Physical phone touch/FPS and human acceptance remain pending.

The reviewed [pipeline skill](game/skills/roblox-ui-pipeline/SKILL.md) is one file, validated and installed at `C:/Users/nsidi/.codex/skills/roblox-ui-pipeline/`. Invoke `$roblox-ui-pipeline` for future work.

## Scope and continuation

Resume physical-device/human acceptance in the [backlog](game/docs/backlog.md). Keep the approved UI and territory/replication contracts. No public release, new economy, purchases, kits, persistence or trading mechanics were added.

The A/B/C benchmark is still incomplete: native repair and Figma authoring were intertwined, timing/cost logs are unavailable, B's local-browser restriction remains and C has no independent native translation. Route A is only a convenience snapshot of current source; B/C remain the baseline. [Play guide](game/docs/ui/action-v1.md), [testing](game/docs/testing.md), [code review](game/docs/ui/review.md), [pilot status](game/docs/ui/pilot-setup.md).

Earlier implementation, cleanup, rejected designs and setup observations are preserved in [project history](game/docs/history.md) and [UI design history](game/docs/ui-design-history.md). Historical empty-Figma and portrait notes are superseded by this status.
