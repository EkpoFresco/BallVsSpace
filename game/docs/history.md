# Implementation history

This consolidates the earlier build log, prototype playtest report, 0.2 reconstruction notes and receiving-machine audit. These are dated results, **not current setup instructions**. Use [development](../../CONTRIBUTING.md), [architecture](architecture.md), [UI](ui/README.md) and [testing](testing.md) for the current implementation.

## 16 October — first territory slice, 0.1

Built the authoritative two-kit slice: draft/private aim, automatic movement/abilities, signed territory, exact cutoff/overtime, match points, Practice and session-only profiles. Ten core logic groups, 126 influence cases, randomized board checks and 400 mirrored rounds passed. Early collision degeneracies were fixed; seed 49 and initial failures were retained.

Ten normal multiplayer matches across two runs produced 80 matching client/server result comparisons. A host-load abort froze simulation between movement/territory updates; the harness initially compared different ticks despite matching grid hashes. Comparing the last territory tick fixed that measurement error. The aborted attempt was excluded. A 130-second recording was live play, not an FPS benchmark.

Initial presentation used small primitive balls and a minimal HUD. The user's visual direction advanced reference reconstruction before human acceptance. The first landscape layout obscured the court; later layouts removed the large footer. An ordinary-Play test-driver nil argument was fixed. Human and real-device gates remained untested.

## 16–17 October — reference reconstruction, 0.2

Measured an 803×602 design viewport, 512×510 outer court, 446×446 inner field and approximately 82-pixel balls. `bvs-motion-2` aligned radius 5.9, center bound 26.1 and spawn ±19 with those proportions. Draft/aim limits changed to 20/30 seconds with 3/2-second early floors; watchdog became 360 seconds. Territory rules remained `bvs-rules-1`.

Added navy bevels, real avatar previews, seven appearances, three-card draft, compact No/Yes selection, dashed aim, trails, purple results and a walkable blue lobby. This was an intermediate approximation. REA was reviewed; no private source/binaries were supplied or extracted.

The pass verified logic, mirrored fixtures, appearance/privacy/projection contracts, a fresh two-client match and actual-click Practice runs. Fixed minimized viewport captures, avatar bounds, collection stacking and an obsolete deadline fixture. A fullscreen GUI/device-safe camera-size mismatch caused aiming drift; using ScreenGui size reduced measured diagonal error to 0.15° within 0.5° tolerance. Early phone-mode injected clicks failed and were not counted as touch acceptance.

## 17 October — 0.3 presentation and separate code review

Expanded to twelve original atlas appearances, 32 authored symbols, dedicated Inventory/Store/utilities, portrait/landscape reflow, richer kiosks/portals and functional world prompts. Territory/area totals became the default view; reference HP/lives were never the new scoring rule. The twelve looks still share Drift/Anchor.

Completed actual-click menus and Practice, emulated bounds/44+ UI-pixel targets, world E prompts and fresh two-client state/art comparisons. The follow-up review fixed input/acknowledgement races, interpolation, UI lifecycle and hidden rendering/network work. [Testing](testing.md#review-and-performance) preserves the findings and measured limits. All 400 mirrored rounds passed asynchronously after an earlier synchronous timeout; the timeout itself was not a pass.

The repository moved to its pack root while preserving history. Source commit `fbaba9d` was pushed to main. Brocoliman received write invitation 338213623, pending at verification. A first hosted build hit an anonymous release-download HTTP 403; authenticating Rokit with the temporary read-only CI token fixed it. [Run 39024494391](https://github.com/EkpoFresco/BallVsSpace/actions/runs/39024494391) passed and its place artifacts matched local/clean-clone builds. Final checkpoint `e35906b` also had successful CI. No Roblox experience publication occurred.

## 17–18 October — UI editing handoff

Added a brief replication skill, frame/source guide and interactive map: 15 screens, 50 regions. A portable folder initially duplicated runtime source, docs and images in Git. Its extracted ZIP passed hashes, local links, all map interactions and gallery image loading. This prompted the repository cleanup: exports are now generated/ignored, documentation is consolidated and old receipts are archived.

## Earlier evidence and tools

[The archive index](../test-evidence/archive/index.json) records original paths, sizes and SHA-256 for 1,096 earlier tracked artifacts in [one ZIP](../test-evidence/archive/2026-10-18-earlier-runs.zip). It includes failed attempts, successful reruns, intermediate screenshots and the 0.2 overlay comparison. Extract it outside the working tree to inspect old relative paths. Selected current receipts/images remain directly browsable in [the evidence index](../test-evidence/README.md).

Superseded one-off diagnostic scripts and the original separate Markdown documents remain recoverable from Git commit `7d3776f`. Untracked exploratory evidence was compressed locally before cleanup. Original research files and all 63 archived reference hashes remain intact.

Earlier machine observations (Studio IDs, process/window handles, executable version paths and collaborator invitation state) were session-specific. Rediscover them when needed. The repo does not require those old IDs to build or inspect the UI.
