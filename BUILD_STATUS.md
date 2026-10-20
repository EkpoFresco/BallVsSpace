# Build status

Updated 20 October 2026 after the user's menu and save-location report. The single working place is [game/places/BallVsSpace.rbxl](game/places/BallVsSpace.rbxl). Open it in Studio: the map is visible and editable before Play; press F5 for the game UI. Canonical code remains in game/src/ (40 scripts), and the static world is [Lobby.rbxm](game/assets/world/Lobby.rbxm).

## Latest corrections

- Inventory/Store empty-space clicks stay inside the modal. Only the close control or outside backdrop dismisses it.
- Selection borders render inside each card, above its fills, with grid padding and a scrollbar gutter. Top, left and final-row outlines remain visible.
- Close controls use the approved Figma red square, cream border and Montserrat multiplication mark. A separate render-transition bug is fixed by showing the control after its parent has rendered; actual Inventory → Store captures verify it at three sizes.
- Store art, name and action share a bounded card with consistent padding and independent gutters. Returning from an Inventory-only category no longer leaves a stale Store tab selected. Short headers clear Roblox's controls.
- The lobby is authored geometry, not generated on Play. Removed both runtime world builders (526 lines). Fixed buried court/queue floors, overlapping portal placement and billboard text sizing; added a contained plaza edge, benches and a continuous entry path. Camera and lighting are saved with the place.
- Earlier work used the already-open file under Desktop/VibeCode/Reaction Game. That was a delivery mistake. Its former file and retired Studio session are preserved in ignored .local/legacy-places/ under descriptive names. The duplicate generated binary is retired; verification builds directly into the single primary path. Roblox's AutoRecovery file remains untouched.

The approved [design](game/assets/ui-concepts/action-v1/design.json) and [pilot](game/assets/ui-concepts/action-v1/pilot.json) are unchanged. The editable Figma Inventory/Store page is node 0:1; node 21:188 is the archived portrait exploration. Landscape remains the phone layout.

## Verification

[Actual menu input](game/test-evidence/results/fixes20-menus.json) passed at 568×320, 900×650 and 1920×1080, including empty-space clicks, first/last-row selection, scroll reachability, Store routes and close clicks. [The scale matrix](game/test-evidence/results/fixes20-scale.json) passed 27 states across ten sizes plus a return-to-small pass: 297 checks, zero flagged geometry, text-fit, font-floor, target or overlap issues. It also checks inset strokes and grouped-card containment. Visual inspection remains separate from these numerical checks.

[Saved-world round trip](game/test-evidence/results/fixes20-world.json): the same 427-descendant scene survives Edit → Play → Stop, with 273 anchored parts and 20 action prompts. Actual E-key Store/Inventory/queue/Practice interactions passed. Thirteen logic groups passed. The final close-control change passed a fresh [100-cycle lifecycle check](game/test-evidence/results/fixes20-lifecycle.json), with 795 descendants before/after. [Final verification](game/test-evidence/results/fixes20-verification.json) records build hashes, source matching and close-transition captures. The primary file was reopened from disk, independently of the synchronized test session.

Formatting, lint, strict analysis, four tooling tests and both place formats passed. [Review and evidence](game/test-evidence/README.md) retain previous multiplayer and complete-match results with their original scope; this correction pass did not rerun multiplayer. Earlier claims that close-control omissions were merely screenshots were insufficient: the direct transition now has its own rendered regression evidence. Physical phone touch/FPS, gamepad and human acceptance remain pending.

## Continue

Use the primary place above for the user's next review, then the physical-device/human gates in the [backlog](game/docs/backlog.md). Preserve the territory/replication contracts and current two-kit game. The [pipeline skill](game/skills/roblox-ui-pipeline/SKILL.md), [play guide](game/docs/ui/action-v1.md), [testing guide](game/docs/testing.md) and [code review](game/docs/ui/review.md) remain the handoff.

The A/B/C benchmark is incomplete: native repair and Figma authoring were intertwined, timing/cost logs are unavailable, B's local-browser restriction remains and C lacks independent native translation. Route A is an older convenience snapshot, not canonical current source. Earlier work is retained in [project history](game/docs/history.md) and [UI design history](game/docs/ui-design-history.md). No public release or purchases occurred.
