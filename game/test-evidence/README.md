# Test evidence

## Armory polish v4 / 21 October

- [Logic](results/polish-v4-logic.json): 22 groups. [Roster](results/polish-v4-roster.json): 30 mirrored pairs, 60 rounds, 30,720 matching cells. [Two clients](results/polish-v4-multiplayer.json): one completed match, six state/visual comparisons, zero mismatches, visual failures or aborts.
- [Animation](results/polish-v4-animation.json): 30 heroes / 3,600 native poses, fractional clock, projectile movement between territory packets, bounded extrapolation, immutable history, damage/healing/block feedback, reduced motion and round reset. [Alignment](results/polish-v4-render.json): 90 poses, 130 active edges, 36 guard checks. [Real-time gallery](results/polish-v4-gallery.json) and [two](screenshots/polish-v4-motion-1.jpg) [frames](screenshots/polish-v4-motion-2.jpg) show synthetic native weapon animation; separate live matches verify gameplay.
- [Scale](results/polish-v4-scale.json): 286 emulated checks, zero flagged issues, all thirty description/stat strings fit. [Menus](results/polish-v4-menus.json): actual clicks at 568×320, 900×650 and 1920×1080. Visually inspected [short Inventory](screenshots/polish-v4-inventory-short.jpg), [short Store](screenshots/polish-v4-store-short.jpg), [desktop Inventory](screenshots/polish-v4-inventory-desktop.jpg), [short Rewards](screenshots/polish-v4-rewards-short.jpg), [help](screenshots/polish-v4-help-short.jpg), [settings](screenshots/polish-v4-settings-short.jpg), and [effects](screenshots/polish-v4-effects.jpg). [Utility panels](results/polish-v4-screens.json) add eight states at two sizes and verify visible new icon images loaded.
- [Complete Practice](results/polish-v4-flow.json): three rounds at tick 2700, real selection/aim clicks, visible Replay, restored results and acknowledged Rematch; no client errors. [Battle 1](screenshots/polish-v4-battle-1.jpg), [battle 2](screenshots/polish-v4-battle-2.jpg), [confirmed rematch](screenshots/polish-v4-rematch.jpg).
- [Lifecycle](results/polish-v4-client.json): 100 menu/skin cycles, 1,778 descendants before/after. [Camera](results/polish-v4-camera.json): replacement camera, both jump modes, original movement restored, 1,000 unchanged calls with zero camera writes. [Actual respawn](results/polish-v4-respawn.json): one reset, retained single UI, new camera subject and movement available.
- Board [before](results/polish-v4-baseline-board.json) / [after](results/polish-v4-board.json): 4,098 → 1,027 descendants, median fully changed update 3.2223 → 2.0242 ms. Two-hero renderer [before](results/polish-v4-baseline-render.json) / [after](results/polish-v4-render-benchmark.json) remains around 0.066 ms median. These are isolated CPU microbenchmarks, not device FPS. [Build hashes](results/polish-v4-build-hashes.json).

The final camera/tint changes followed the broad layout tests; the camera, 100-cycle client, real respawn, roster, multiplayer, complete flow and utility-panel checks used the final sources. Runtime tests used Studio `0.743.0.7431133`. One initial utility fixture incorrectly required hidden ImageLabels to report loaded; direct inspection showed visible images loaded and hidden pages initialized lazily. The corrected fixture checks visible labels and passed; the first failure remains in local `runs/`. Human acceptance, physical phone/gamepad/FPS, network stress and broad balance remain pending. Original research evidence is preserved.

- [Fresh saved file](results/polish-v4-saved-place.json): all 43 sources match, 30 heroes, 427-descendant authored lobby and binary hash. [Local launch](results/polish-v4-launch.json): ordinary Play, no client errors, loaded new icons and fitting stat text. [Final Inventory](screenshots/polish-v4-final-inventory.jpg) and [lobby](screenshots/polish-v4-launched-lobby.jpg). [Repository audit](results/polish-v4-audit.json) verifies all 63 protected reference hashes and local document links.

## Prior flat armory v3 / 21 October

- [Logic](results/flat-v3-logic.json): 22 groups passed with unchanged weapon-v2 rules. [Fresh multiplayer](results/flat-v3-multiplayer.json): two clients, one complete match, eight state/visual comparisons, zero mismatches, visual failures or aborts.
- [Native roster review](results/flat-v3-roster-art.json): all 30 heroes, loaded sprite images, circular bodies, restored palette and italic display font. Captures: [polearms and heavy](screenshots/flat-v3-roster-1.jpg), [blades and chains](screenshots/flat-v3-roster-2.jpg), [guards and ranged](screenshots/flat-v3-roster-3.jpg).
- [Weapon alignment](results/flat-v3-render.json): 90 poses, 130 active edges and 36 guard-segment checks. Actual sprite bounds follow capsule geometry; includes powered widths, extensions and projectiles. This does not claim per-pixel collision or human art acceptance.
- [Scale](results/flat-v3-scale.json): 286 emulated layout checks, zero flagged issues. [Actual menu input](results/flat-v3-menus.json): scrolling, first/last selection, empty clicks, Store routes and closing at three sizes. [Short Inventory](screenshots/flat-v3-inventory-short.jpg) and [short Store](screenshots/flat-v3-store-short.jpg) were visually inspected.
- [Practice, replay and rematch](results/flat-v3-flow.json): two full rounds using actual clicks, final-row wildcard reachable, replay visible, results restored, rematch acknowledged, client errors empty. [Battle](screenshots/flat-v3-battle.jpg), [draft](screenshots/flat-v3-draft.jpg), [rematch](screenshots/flat-v3-rematch.jpg).
- [Lifecycle](results/flat-v3-client.json): 100 menu/skin cycles, 1,778 descendants before/after; interpolation, font resize, modal and toast checks pass. [Result metrics](results/flat-v3-results.json) and [final build hashes](results/flat-v3-build-hashes.json).
- [Fresh saved file](results/flat-v3-saved-place.json): all 43 sources match, 30 heroes, 427-descendant authored lobby and the final binary hash. [Local launch](results/flat-v3-launch.json): ordinary Play, Lobby and Practice ready, no client errors. [Final presentation](results/flat-v3-final-visual.json): new and lobby weapon renderers hidden until posed, white gradient multiplier with charcoal endpoints, and actual Inventory click. [Final Inventory](screenshots/flat-v3-final-inventory.jpg) and [launched lobby](screenshots/flat-v3-launched-lobby.jpg) were visually inspected. [Repository audit](results/flat-v3-audit.json) checks protected evidence and local links.

Broad runtime checks used Studio 0.744. The final startup-visibility and charcoal-gradient corrections followed the full flow. After reopening the saved binary, source matching, weapon alignment (90 poses), lifecycle (100 cycles), launch and final presentation checks passed under Studio `0.743.0.7431133`; the linked alignment/lifecycle receipts are those fresh-file reruns. The earlier full-flow battle image predates the gradient multiplier correction. Physical-device touch/FPS, gamepad, human acceptance and broad matchup balance remain pending. The sixty mirrored simulation rounds in v2 remain the balance-independent symmetry evidence; this visual pass did not change tuning or rerun that batch.

## Prior weapon-v2 build / 20 October

- [Logic](results/weapon-v2-logic.json): 22 groups, including body-inert capture, hit rearming, simultaneous damage, KO cutoff, wire validation and all 30 heroes.
- [Roster symmetry](results/weapon-v2-roster.json): 30 mirrored pairs / 60 accelerated full rounds. All paired end ticks, HP, area and 30,720 cell comparisons match. Not exhaustive balance evidence.
- [Two clients](results/weapon-v2-multiplayer.json): one fresh normal-clock match, eight state and eight visual comparisons, zero mismatches/failures/aborts.
- [Scale](results/weapon-v2-scale.json): 26 states × 11 viewport passes = 286, zero flagged issues; all 30 catalog strings checked. [Actual menus](results/weapon-v2-menus.json) use mouse clicks at three sizes, including the final hero row and Store routes.
- [Complete Practice](results/weapon-v2-flow.json): actual hero/aim input, two rounds, replay with visible heroes, result restoration and server-confirmed rematch; no client MessageError entries. Studio CorePackages/external-asset warnings were observed in earlier sessions, so this is not a warning-free claim.
- [Client lifecycle](results/weapon-v2-client.json): 100 menu/skin cycles, 2,694 descendants before/after; interpolation, toast and font restoration checks. [Renderer benchmark](results/weapon-v2-benchmark.json): 2,000 two-hero render calls; not phone FPS.
- [Weapon alignment](results/weapon-v2-render.json): all 30 heroes / 54 visible edges, actual GUI centers and widths against shared authoritative geometry. [Result metrics](results/weapon-v2-results.json): KO/health show HP and area shows percentages.
- [Fresh saved-place verification](results/weapon-v2-saved-place.json): all 42 sources match, 30 heroes, unchanged 427-descendant lobby, version and binary hash. [Build hashes](results/weapon-v2-build-hashes.json) and [repository audit](results/weapon-v2-audit.json).
- [Final local launch](results/weapon-v2-launch.json): ordinary Play, lobby and Practice ready, after Studio's automatic update to 0.744. The saved-source, weapon-alignment and result-metric checks passed on that version; the earlier full-match, multiplayer and scale runs used 0.743.
- Visual review: [battle](screenshots/weapon-v2-battle.jpg), [draft](screenshots/weapon-v2-draft.jpg), [last-row wildcard](screenshots/weapon-v2-collection.jpg), [short Inventory](screenshots/weapon-v2-inventory-short.jpg), [short Store](screenshots/weapon-v2-store-short.jpg), [confirmed rematch](screenshots/weapon-v2-rematch.jpg).

The complete match and scale captures precede the final subpixel weapon-coordinate refinement and shorter Sola description; the saved-place alignment/result checks validate those final source changes. No combat rules changed afterward. Physical touch, phone FPS, gamepad, broad balance and human acceptance remain pending. Older receipts below are historical v1 evidence.

| Location | Contents |
| --- | --- |
| [screenshots/](screenshots/) | Current action-v1 captures plus retained 0.3 desktop, phone and world-prompt evidence |
| [results/](results/) | Selected final results and benchmark/reference checks |
| [archive/index.json](archive/index.json) | Searchable original paths and hashes for 1,096 earlier tracked files |
| [archive/2026-10-18-earlier-runs.zip](archive/2026-10-18-earlier-runs.zip) | Earlier receipts, successes/failures, screenshots and historical comparison |
| `runs/` | Ignored fresh command output; promote only meaningful final evidence |

For visual browsing use the [UI map](../docs/ui/map.html) and [reference comparison](../docs/ui/reference-comparison.html). The gallery is historical (17 October). Current action-v1 evidence is listed below.

## Earlier v1 menu and static-world corrections / 20 October

- [Final save/source verification](results/fixes20-verification.json): one primary place, static authored model, unchanged approved inputs and fresh-file verification.
- [Menu input](results/fixes20-menus.json): actual clicks at three sizes, including blank spaces, first/last rows, scrolling, Store category return and close.
- [Scale matrix](results/fixes20-scale.json): 297 checks, zero issues; ten sizes and a return pass. Borders and Store card containment added.
- [Static-world round trip](results/fixes20-world.json) and [lobby actions](results/fixes20-world-lobby.json): Edit/Play/Stop identity, 13 logic groups and actual E-key prompt routes into Practice.
- [Final lifecycle](results/fixes20-lifecycle.json): 100 UI/skin cycles, 795 descendants before/after, after the final close transition fix.
- [First-row Inventory](screenshots/fixes20-final-04-inventory-0.jpg), [short scrolled Inventory](screenshots/fixes20-menus-20-inventory-image-short-0.jpg), [wide scrolled Inventory](screenshots/fixes20-menus-98-inventory-image-wide-0.jpg).
- Direct Inventory → Store, with visible close control: [900×650](screenshots/fixes20-close-v2-05-store-medium-0.jpg), [568×320](screenshots/fixes20-close-v2-11-store-short-0.jpg), [1920×1080](screenshots/fixes20-close-v2-17-store-wide-0.jpg).
- [Saved Edit map](screenshots/fixes20-map-edit.jpg). No new two-client or physical-device claim; the earlier full-match receipts below retain their original scope.

Earlier close omissions were a real rendered regression despite passing bounds/click checks. The new transition captures supersede that earlier assessment. Retired save-location receipts below are historical.

## Earlier review / 20 October

- [Primary save verification](results/primary-place-save.json): the primary local file, generated build and GitHub-ready place have the same SHA-256; 42 sources verified in the primary Studio window and six fresh desktop/landscape panel checks passed.
- [Scale matrix](results/review20-scale.json): 27 states × 11 viewport passes = 297 checks, zero flagged issues; ten sizes plus return-to-small, all catalog strings. Includes round/service/rematch states and connection/replay banners.
- [Visual review](results/review20-visual.json): eight isolated native captures, five live-flow captures and two settled delivery captures. [Compact Inventory](screenshots/review20-ready-02-compact-inventory-0.jpg), [Store](screenshots/review20-preview-10-store-desktop-0.jpg), [live result with confirmed rematch](screenshots/review20-phone-132-match-result-0.jpg).
- [Complete landscape flow](results/review20-phone.json): real menus, equip/navigation, queue cancellation, private draft, 315° aim, two rounds, replay playback/result restoration and persistent rematch confirmation.
- [Final regression](results/review20-regression.json): 13 logic groups, eight presentation checks, modal cancellation, 100 UI/skin cycles (722 descendants before/after), renderer fixture and a fresh two-client match. Six state and six visual comparisons, zero failures/aborts; completed within the bounded driver run.
- [Delivery navigation](results/review20-preview.json): 800×600 desktop and LandscapeRight Inventory/Store/Rewards, actual close controls, safe bounds and centered panels. Studio restored to 1280×900 with Inventory open.
- [Decoder benchmark](results/review20-protocol.json): six alternating batches of 500 decodes per version/case; byte equivalence checked. Median 12-cell delta: 0.1726 → 0.0143 ms. This isolates CPU decoding; it does not measure game FPS.
- [Figma update](results/review20-figma.json): existing HUD/result frames now use match points; screenshots inspected. Approved Inventory/Store and JSON inputs retained.
- [Final source/build verification](results/review20-verification.json): 42 matching Studio sources, static checks/builds, four Node tooling tests, approved hashes and targeted stale-banner transition check after the broader runtime passes. [Current snapshot](results/action-v1-current-snapshot.json) also matches route A's convenience copy.
- [Console](results/review20-console.json) retains CorePackages FoundationProvider and external asset-type warnings. No matching authored source/asset reference was found for the reported ID; authored atlas checks passed. Some first-show screenshots omitted a close control; settled captures and real close clicks verified it. These observations are retained rather than claiming a warning-free render.

The [review](../docs/ui/review.md) explains the fixes. Physical touch, gamepad, device performance and human acceptance remain pending.

## Earlier scale refinement / 19 October

- [Scale matrix](results/ui-scale-matrix.json): 22 native states × nine viewport passes, including all twelve catalog strings; zero flagged geometry, fit, font-floor, target or overlap issues. [Visual sweep](results/scale-visual-result.json): 31 captures inspected across three sizes. See `scale-visual-*` screenshots.
- [Queued preview](results/action-theme-presentation-result.json): desktop and LandscapeRight Inventory, Store and opaque Rewards, centered with safe bounds and close targets.
- [Final delivery preview](results/delivery-preview-result.json): latest desktop and LandscapeRight Inventory/Store/Rewards checks; Studio left in Play with desktop Inventory open. Captures use `delivery-preview-*`.
- [Final small-window interactions](results/last-ux-check-result.json): scroll to Laser and equip with the action in view at 567×320, scroll Store to Parasol, reroll Draft, then verify the bot portrait and centered action. [Small Inventory](screenshots/last-ux-check-v2-10-small-scrolled-inventory-0.jpg), [final Aim](screenshots/last-ux-check-v2-32-final-aim-0.jpg).
- [Final refined phone flow](results/scale-verified-phone-result.json): actual menus, equip, Store routes, queue/cancel, private draft, All Balls, 315° server-observed aim and a complete two-round match.
- [Earlier complete desktop flow](results/verified-theme-desktop-result.json), [earlier complete phone flow](results/verified-theme-phone-result.json), [centered phone menus](results/centered-phone-menus-result.json). These predate the final deep scale refinement; retain their exact scope.
- [Queued regression](results/action-theme-regression-result.json): Help, lifecycle, renderer fixture, 11 logic groups, appearance contract and a fresh two-client match. The [refined regression](results/scale-final-regression.json) passed the same checks; multiplayer completion was confirmed after the driver timeout with matching run IDs. That timeout is retained, not relabeled as a passing bounded driver run.
- [Figma responsive refinement](results/figma-scale-refinement.json) and [font/bounds audit](results/figma-scale-audit.json). Figma editing/screenshot evidence is separate from Roblox execution.
- [Code review](../docs/ui/review.md), [current build guide](../docs/ui/action-v1.md), [portable pipeline skill](../skills/roblox-ui-pipeline/SKILL.md).

Earlier action-theme captures are preserved in the [pre-scale archive](archive/2026-10-19-before-scale-refinement.zip) with a [hash index](archive/2026-10-19-before-scale-refinement.json). Current scale and refined live captures remain directly browsable.

## Historical retained results

- [action-v1 pilot setup](results/action-v1-pilot-setup.json) and [common input manifest](results/action-v1-baseline-manifest.json): verified Figma editing, 41 matching Studio sources, three independent baselines and six matching builds. Historical setup evidence only; current implementation is described above, while independent route comparison remains incomplete.

- [Practice and menu flow](results/review-final-result.json), [emulated layouts](results/review-layout-final-result.json), [world prompts](results/visual-v3-world-result.json).
- [Logic suite](results/replica-review-core.json), [400 mirrored rounds](results/replica-review-mirrored-final.json), [two-client match](results/replica-review-multiplayer-tracked-result.json).
- [UI/interpolation lifecycle](results/replica-review-client.json), [equipped draft](results/replica-review-equipped-draft.json).
- [Baseline renderer](results/replica-review-baseline-render.json) and [final renderer](results/replica-review-final-render.json); fixture results, not phone FPS.
- [Source consistency](results/source-consistency.json), [clean clone](results/review-clean-clone.json), [hosted build](results/github-actions-verified.json), [artifact match](results/github-artifact-verification.json).
- [UI map checks](results/ui-handoff-validation.json), [earlier sharing-packet checks](results/ui-packet-validation.json).
- [Repository cleanup](results/repository-cleanup.json): preserved source/reference hashes, tooling/build checks and the regenerated standalone UI packet.

Run commands and interpretation are in [testing](../docs/testing.md). Human acceptance, physical touch/device performance and later networking/release gates remain pending. Archive members retain their original paths; failures have not been relabeled as passes.
