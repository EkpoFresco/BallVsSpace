# Build status

## Armory polish and code review — 21 October 2026

Current version: `0.4.2-armory-polish`, 43 canonical scripts. The [review](game/docs/design/armory-polish-v4.md) records the visual polish, code analysis, measurements and limitations. Thirty-two original UI icons match the flat heroes; Inventory shows damage/reach/spin, weapons and replay use a smooth pose clock, and hits, healing and blocks have reduced-motion-aware feedback. The camera now handles replacement/respawn and restores movement settings. Gameplay rules and tuning are unchanged.

The studded board uses 1,027 descendants instead of 4,098. Its measured fully changed-board update fell from 3.2223 to 2.0242 ms in Studio; this is CPU microbenchmark evidence, not phone FPS. Static checks, both builds and four tooling tests passed. Runtime validation passed 22 logic groups, 60 mirrored rounds, a fresh two-client match (six state/visual comparisons, zero mismatches or aborts), 286 emulated layout checks, actual menus at three sizes, 90 geometry-alignment poses, 3,600 animation poses, 100 menu cycles without growth and one actual character reset. A complete three-round Practice match, Replay and Rematch passed with no client errors. [Receipts and screenshots](game/test-evidence/README.md) retain the exact scope.

**Resume:** human play/readability review and matchup tuning, then physical-phone touch/FPS, physical gamepad, and network stress. 2v2, durable progression, final audio and public release remain open. Local development and the requested GitHub source push do not publish a Roblox experience.

The rebuilt [primary place](game/places/BallVsSpace.rbxl) was reopened from disk under Studio `0.743.0.7431133`; all 43 saved sources match, the authored lobby still has 427 descendants, and ordinary Play starts without client errors. The final session has [Inventory open](game/test-evidence/screenshots/polish-v4-final-inventory.jpg), with Practice accessible after closing it.

## Prior flat armory implementation — 21 October 2026

The user approved the six-character A refinement and authorized the build. Version `0.4.1-flat-armory` now has 43 canonical scripts: plain balls, thirty weapon-head sprites assembled with grips/chains/shields, and restored charcoal/magenta/mint menus with the earlier italic headings. The [visual build guide](game/docs/design/flat-armory-v3.md) records the implementation and asset source. Combat rules and tuning remain unchanged.

The primary [BallVsSpace.rbxl](game/places/BallVsSpace.rbxl) was rebuilt and reopened from disk; all 43 saved sources match. Formatting, lint, strict analysis, both place builds, four tooling tests and 22 Studio logic groups passed. Fresh two-client multiplayer completed with eight state/visual comparisons and zero mismatches or aborts. The visual checks cover all 30 heroes, 90 weapon poses, 286 emulated layouts, actual menu clicks at three sizes, and 100 UI cycles with no descendant growth. Two complete Practice rounds, replay, restored results and confirmed rematch passed with no client errors. See [receipts and captures](game/test-evidence/README.md).

The broad runtime suite used Studio 0.744. The final saved-file verification, 90-pose rendering, lifecycle checks, startup visibility and charcoal-gradient checks passed after reopening under Studio `0.743.0.7431133`. These version scopes are recorded separately. The final session is ordinary Play with the [Inventory open](game/test-evidence/screenshots/flat-v3-final-inventory.jpg), all 30 heroes available, and Practice accessible after closing the panel.

**Resume:** play this visual build with the user, collect art/readability feedback, then tune matchups. Physical-phone touch/FPS, gamepad and human acceptance remain pending. The existing sixty mirrored v2 rounds establish symmetry, not broad balance. 2v2, durable progression, final audio and public release gates remain open. No public experience publication, purchases or unrelated-experience edits occurred.

## Prior visual correction request — 20 October 2026

**21 October update:** the user selected **A — flat balls and crisp weapons**. The [six-character refinement](game/assets/ui-concepts/weapon-heroes-v3/a-refined-six.png) expands that direction to spear, axe, hammer, twin daggers, trident and chain flail; [prompt and review notes](game/assets/ui-concepts/weapon-heroes-v3/a-refinement.json) are retained. A is the selected visual direction. The new sheet is a concept, with no runtime asset changes in this pass.

The user rejected the v2 character art and unsolicited blue UI styling. The current primitive faces and capsule-like weapon visuals are not an accepted art direction. The initial options were [A — flat and clear](game/assets/ui-concepts/weapon-heroes-v3/option-a-flat.png), [B — simple with detail](game/assets/ui-concepts/weapon-heroes-v3/option-b-shaded.png), [C — Roblox toy](game/assets/ui-concepts/weapon-heroes-v3/option-c-toy.png). All use plain colored balls and recognizable spear, axe, hammer and dagger silhouettes. The [prompt set and review notes](game/assets/ui-concepts/weapon-heroes-v3/prompts.json) retain the drafts and constraints; A was subsequently selected as recorded above.

The UI target returns to the earlier action-v1 charcoal panels, magenta headers, mint actions and established typography/layout. Automated geometry checks below do not establish visual quality or user acceptance. This concept pass changed no runtime source or saved place. Refine the selected art direction before applying a new roster look; preserve the existing gameplay rules and avoid further unrequested palette/layout changes.

## Prior weapon-v2 build — 20 October 2026

The user approved the [proposal](game/docs/design/weapon-territory-v2-plan.md), then authorized implementation, UX review and local launch. [Implemented rules and roster](game/docs/design/weapon-territory-v2-build.md): 30 original heroes, free arena movement, weapon-only capture, health/KO combat, a 45-second cutoff with territory then health deciding the result, and a centered studded arena with compact HP panels. The former twelve appearances and two shared kits are retired. This is a playable first tuning pass, not a completed balance or finished-art claim.

The primary file is [BallVsSpace.rbxl](game/places/BallVsSpace.rbxl), built from 42 canonical scripts and the unchanged authored lobby. Version `0.4.0-weapon-heroes`, rules `bvs-rules-2-weapon`, motion `bvs-motion-3`. A v1 backup is preserved in ignored `.local/weapon-v2-backup/`. Rojo 7.7.1, StyLua 2.5.2, Selene 0.32.0 and Luau LSP ran on this machine. Use PowerShell 7 for `verify.ps1`; Windows PowerShell 5 treats the analyzer's informational stderr as a terminating error.

UX fixes include weapon/paint alignment, subpixel weapon positioning, unobscured weapon portraits, real server draft offers, removal of the obsolete reroll overlap, unclipped short-screen help, visible replay heroes and the correct HP metric for KO/health results.

Validation: 22 Studio logic groups; 30 mirrored pairs / 60 accelerated rounds; a fresh two-client complete match with zero state/art mismatches or aborts; 286 emulated layout checks with zero issues; real menu clicks at three sizes; 100 UI cycles with 2,694 descendants before/after; complete Practice, visible replay and confirmed rematch. All 30 heroes passed actual rendered weapon-position/width checks. Formatting, lint, strict analysis, four tooling tests and both place formats passed. The built file was reopened from disk and all 42 sources matched; original reference hashes remain intact. See the [receipts and captures](game/test-evidence/README.md).

**Resume:** play the current build with the user, tune matchups and readability, then address physical-phone touch/FPS, gamepad and human acceptance. The 60-round symmetry fixture is not all-matchup balance evidence. 2v2, durable progression, final character art/audio and release gates remain open. No public publication, purchases or unrelated-experience edits occurred.

Local launch reopened the canonical binary without the QA file lock. Studio applied its pending automatic update from 0.743 to 0.744 during reopening; source matching, 30-hero weapon rendering and result-metric checks passed on 0.744. The final session is ordinary Play in Lobby, with Practice available. Earlier full-match/multiplayer/layout receipts retain their 0.743 scope.

## Historical v1 build and menu corrections

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

The current flat-armory resume step is at the top. The following material records the earlier v1 handoff. Its physical-device/human gates in the [backlog](game/docs/backlog.md) remain pending. The [pipeline skill](game/skills/roblox-ui-pipeline/SKILL.md), [historical play guide](game/docs/ui/action-v1.md) and [code review](game/docs/ui/review.md) preserve that work; use the [current testing guide](game/docs/testing.md) for weapon-v2 gameplay and flat-armory presentation.

The A/B/C benchmark is incomplete: native repair and Figma authoring were intertwined, timing/cost logs are unavailable, B's local-browser restriction remains and C lacks independent native translation. Route A is an older convenience snapshot, not canonical current source. Earlier work is retained in [project history](game/docs/history.md) and [UI design history](game/docs/ui-design-history.md). No public release or purchases occurred.
