# Test evidence

| Location | Contents |
| --- | --- |
| [screenshots/](screenshots/) | Current action-v1 captures plus retained 0.3 desktop, phone and world-prompt evidence |
| [results/](results/) | Selected final results and benchmark/reference checks |
| [archive/index.json](archive/index.json) | Searchable original paths and hashes for 1,096 earlier tracked files |
| [archive/2026-10-18-earlier-runs.zip](archive/2026-10-18-earlier-runs.zip) | Earlier receipts, successes/failures, screenshots and historical comparison |
| `runs/` | Ignored fresh command output; promote only meaningful final evidence |

For visual browsing use the [UI map](../docs/ui/map.html) and [reference comparison](../docs/ui/reference-comparison.html). The gallery is historical (17 October). Current action-v1 evidence is listed below.

## Current review / 20 October

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
