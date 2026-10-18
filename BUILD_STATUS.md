# Build status

Updated 18 October 2026. **0.3 presentation is built and validated for local 1v1/Practice. Repository cleanup is complete.** Runtime source is `game/src/`; original research remains unchanged.

## Repository cleanup — 18 October 2026

- Reduced tracked files from 1,560 to 243. Current guides cover development, architecture, UI and testing; earlier milestones are consolidated in [history](game/docs/history.md).
- Replaced the tracked UI source/image duplicate with a generated folder and ZIP under `game/exports/`. The portable packet contains 155 files and 90 gallery images.
- Kept current evidence in `screenshots/` and `results/`; 1,096 earlier tracked artifacts are preserved in an indexed ZIP. New exploratory output goes to ignored `runs/`.
- Grouped Studio, QA, CI and type tools, removed 32 superseded scripts and the unused Lune pin, and consolidated RPC/source-inventory logic. Removed verified temporary checkouts/browser caches.
- Passed formatting, lint, strict analysis, both place builds, four tooling tests, reference/link checks and standalone UI export/browser checks. All 41 runtime scripts and both place build hashes are unchanged; read-only verification against the intended local BallVsSpace Studio confirmed all 41 sources match.

[Cleanup evidence](game/test-evidence/results/repository-cleanup.json) records scope and validation. This pass does not add new gameplay, multiplayer, physical-device or human acceptance claims.

## Implemented and previously verified

Twelve original ball appearances, 32 symbols, draft/aim/battle/results, Inventory/Store/utilities, responsive emulated-phone layouts and an interactive lobby run over two territory kits. The grid/area display is on by default. Profiles are session-only; one arena supports 1v1 and Practice.

The 17 October pass verified 11 logic groups, 400 mirrored rounds, a fresh two-client match with matching state/art, full actual-click Practice/UI, emulated layout checks and 100 menu/skin cycles without instance growth. The two-ball render fixture improved from 0.5116 to 0.1395 ms/call; this is not a whole-game or physical-phone FPS claim. Details and limits are in [testing](game/docs/testing.md) and the [evidence index](game/test-evidence/README.md).

GitHub source sharing and the brocoliman write invitation were completed in the earlier pass. Hosted build/artifact verification is recorded in history. No Roblox publication is included.

## UI redesign handoff review — 18 October 2026

The current request is to review Inventory and Store and agree on a visual target before implementation or an A/B/C workflow benchmark. Inspected the actual saved 17 October screenshots: desktop Inventory and Store, portrait Inventory and Store, and landscape Store in `game/test-evidence/screenshots/`; compared them with original references L2-044 and L2-047 in `Ball_VS_Space_Evidence/live-screenshots/`. Read the current UI guide and build specification. This was a visual review of existing evidence, not a new Studio or physical-device test.

Observed: small item/action text relative to artwork and tabs, weak emphasis on selected-item details, prominent equal-weight tab colors, and a sparse Store spotlight. Portrait layouts reflow, but labels remain visually small. Proposed direction, awaiting user preference: polished arcade styling with darker unified panels, clearer typography and selection/equipped states, restrained color accents, and a stronger composition using existing artwork. Existing selection, equip, navigation and preview behavior remains the functional scope; purchases and additional systems are excluded.

## Next work

Agree on the Inventory/Store visual direction, then prepare reviewable mockups before locking the same target and functional scope for the workflow comparison. Studio/Figma connectivity and benchmark setup are not verified in that UI review. The cleanup separately verified the local Studio source connection and link/tool/build/export checks. Human visual/territory comprehension, physical phones/gamepad, additional abilities, 2v2/parties and persistence remain in the [backlog](game/docs/backlog.md). Pixel-perfect identity and full-game completion are not claimed.
