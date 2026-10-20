# UI development history through the initial 19 October pass

Historical record; current instructions and verification are in [BUILD_STATUS](../../BUILD_STATUS.md). Relative inline paths in this archive refer to the pack root.

# Build status

Updated 19 October 2026. **The approved action-v1 menus and temporary full-game UI theme are implemented locally.** Canonical source is `game/src/` (42 runtime scripts); open `game/builds/BallVsSpace.rbxl` and press F5. The latest user instruction authorizes the whole existing UI and landscape phone layouts. Original research and approved JSON inputs remain unchanged. Final verification is recorded below.

## Repository cleanup — 18 October 2026

- Reduced tracked files from 1,560 to 243. Current guides cover development, architecture, UI and testing; earlier milestones are consolidated in [history](../docs/history.md).
- Replaced the tracked UI source/image duplicate with a generated folder and ZIP under `game/exports/`. The portable packet contains 155 files and 90 gallery images.
- Kept current evidence in `screenshots/` and `results/`; 1,096 earlier tracked artifacts are preserved in an indexed ZIP. New exploratory output goes to ignored `runs/`.
- Grouped Studio, QA, CI and type tools, removed 32 superseded scripts and the unused Lune pin, and consolidated RPC/source-inventory logic. Removed verified temporary checkouts/browser caches.
- Passed formatting, lint, strict analysis, both place builds, four tooling tests, reference/link checks and standalone UI export/browser checks. All 41 runtime scripts and both place build hashes are unchanged; read-only verification against the intended local BallVsSpace Studio confirmed all 41 sources match.

[Cleanup evidence](../test-evidence/results/repository-cleanup.json) records scope and validation. This pass does not add new gameplay, multiplayer, physical-device or human acceptance claims.

## Implemented and previously verified

Twelve original ball appearances, 32 symbols, draft/aim/battle/results, Inventory/Store/utilities, responsive emulated-phone layouts and an interactive lobby run over two territory kits. The grid/area display is on by default. Profiles are session-only; one arena supports 1v1 and Practice.

The 17 October pass verified 11 logic groups, 400 mirrored rounds, a fresh two-client match with matching state/art, full actual-click Practice/UI, emulated layout checks and 100 menu/skin cycles without instance growth. The two-ball render fixture improved from 0.5116 to 0.1395 ms/call; this is not a whole-game or physical-phone FPS claim. Details and limits are in [testing](../docs/testing.md) and the [evidence index](../test-evidence/README.md).

GitHub source sharing and the brocoliman write invitation were completed in the earlier pass. Hosted build/artifact verification is recorded in history. No Roblox publication is included.

## UI redesign handoff review — 18 October 2026

The current request is to review Inventory and Store and agree on a visual target before implementation or an A/B/C workflow benchmark. Inspected the actual saved 17 October screenshots: desktop Inventory and Store, portrait Inventory and Store, and landscape Store in `game/test-evidence/screenshots/`; compared them with original references L2-044 and L2-047 in `Ball_VS_Space_Evidence/live-screenshots/`. Read the current UI guide and build specification. This was a visual review of existing evidence, not a new Studio or physical-device test.

Observed: small item/action text relative to artwork and tabs, weak emphasis on selected-item details, prominent equal-weight tab colors, and a sparse Store spotlight. Portrait layouts reflow, but labels remain visually small. Proposed direction, awaiting user preference: polished arcade styling with darker unified panels, clearer typography and selection/equipped states, restrained color accents, and a stronger composition using existing artwork. Existing selection, equip, navigation and preview behavior remains the functional scope; purchases and additional systems are excluded.

## UI concept revisions — 18 October 2026

The user chose colorful arcade, requested a more Roblox-like treatment, then supplied stud-style references. The latest correction calls for much crisper edges and many more colors. The latest proposed [Inventory](../assets/ui-concepts/stud-v2/inventory-desktop.png) and [Store](../assets/ui-concepts/stud-v2/store-desktop.png) use square corners, defined black outlines, fine stud texture, saturated multicolor card/tab surfaces, magenta headers and green primary actions. Card colors are decorative, not rarity. Selected Axe and equipped Verity remain explicit. The latest user reference is preserved alongside them. [Exact prompts and review limits](../assets/ui-concepts/stud-v2/prompts.json) record built-in image generation and visual checks; earlier concepts remain in sibling folders.

Both latest desktop images were visually inspected for content, labels, selected/equipped state and consistency. These are generated design proposals awaiting user review, not implemented GUI or runtime test evidence. Generated sprite approximations do not replace canonical artwork. No game scripts changed; phone adaptation and the A/B/C benchmark remain pending.

## Shared theme proposal — 18 October 2026

The user selected the soft-yellow header and likes the current overall direction. Their latest refinement asks for gray studs on every gray surface and matching yellow outlines on selected boxes. The current [theme specification](../assets/ui-concepts/theme-proposal/tokens-v5.json) uses exact BrickColor base values: Royal purple structure, Cool yellow headers/selection, Medium stone grey stud surfaces, Bright bluish green actions and Bright red Close. The existing font theme, layout and confirmed Balls category tab are retained. Bevel shading uses derived tints. Earlier proposals, including the [smooth gray revision](../assets/ui-concepts/theme-proposal/tokens-v4.json), are preserved with the supplied references. The latest instruction supersedes the earlier request to remove studs from gray ball surfaces.

Typography uses Fredoka One for chunky outlined titles, item names and buttons, with Source Sans Pro Semibold for small descriptions/status. The exact installed Roblox font files and family mappings were inspected; two unmodified fonts plus their license notices are preserved in [fonts](../assets/ui-concepts/theme-proposal/fonts/). The inline preview embeds those exact fonts and canonical artwork, with no external font dependency. Display text uses normal tracking and the font's real weight, not synthetic bold. Small copy sits on recessed gray surfaces with half-strength stud relief for legibility.

The contained style sample retains working Balls/Explosions/Flyers/Fusion category buttons, canonical artwork, existing source copy, local selection/equip and close/reopen behavior. Balls shows six canonical appearances in a three-column grid and an adjacent detail panel, stacked on narrow screens. Gray stud relief now covers card faces, item label bands, selected-ball details, description wells, inactive category buttons and other gray panels. The selected card, selected detail and active tab use the same soft-yellow outline as the header, with matching selection markers. Fonts, artwork and layout were preserved. The supplied crop remains [feedback evidence](../assets/ui-concepts/theme-proposal/reference-ball-panel-feedback.png). Static markup, script syntax, default state, surface coverage and embedded-asset identity were checked; rendered browser inspection remains unavailable under the browser URL policy. Solid-color contrast calculations in the specification do not certify the textured rendered UI. This is a design discussion aid, not a completed web-first benchmark or native game implementation. Full layouts and native validation remain pending. Existing cyan/coral gameplay team identities remain outside this menu proposal.

## Expanded arcade menu proposal — 18 October 2026

The user clarified that these previews establish a shared visual direction, then requested abandoning the minimal composition for a substantially fuller game UI. The latest [design specification](../assets/ui-concepts/theme-proposal/tokens-v6.json) supersedes the six-ball style sample. It retains the accepted soft yellow, Royal purple, gray studs, teal actions and red Close, with the exact Fredoka One and Source Sans Pro files.

The new inline proposal replaces swatches/font specimens with an Inventory/Store menu shell: thicker raised framing, illustrated category tabs, all twelve canonical appearances, explicit selected/equipped states and a large gray stud showcase. Axe/Blade details include their existing separate weapon icons. Inventory uses four columns on larger layouts and three on narrower layouts, with details stacked below on phones. Store includes the existing four offers, a larger illustrated collection spotlight, zero-value preview balances and view/preview navigation. Existing category limitations and free-collection copy remain. All gray surfaces receive material-matched stud relief; small description copy uses reduced relief. Ball and icon atlases are unchanged.

The self-contained 909 KB fragment is saved in the thread's authorized visualization directory; its exact path is recorded in tokens-v6. Checked JavaScript syntax, literal markup/selector targets, embedded asset identity, canonical names/descriptions/kit mapping, and representative narrow-layout font widths. The fragment has responsive rules and local interaction wiring, but rendered browser inspection remains unavailable under the earlier URL-policy restriction. No rendered layout, browser interaction, Studio, physical-phone or visual-acceptance pass is claimed. No runtime source changed, and the A/B/C benchmark has not started.

## Visual direction reset — 18 October 2026

**The user rejected the stud approach and asked to disregard earlier stud-style instructions. The previous tokens-v1 through tokens-v6 and mockups are historical proposals, not approved active targets.** They requested research into practical, pleasing UI, then supplied an angular action/anime-style Inventory and Store example. The [new reference](../assets/ui-concepts/research-reset/user-action-ui-reference.png) and [research record](../assets/ui-concepts/research-reset/research.json) preserve that steering. The earlier texture, palette and font choices are no longer mandatory. Existing behavior and canonical game assets remain the functional scope.

Researched actual game screenshots and designer portfolios, then visually inspected remote images through the browser. Closest useful references: OTRON_TV's Character Choosing and Anime Shop; Solys Design's ACX system informs consistent reusable layouts/states. The user's example is the primary visual-direction reference: bold italic headings, angular shaped framing, coordinated graphic headers, a clear item grid/detail split and a featured Store composition. Recommendation is original coordinated header/frame/button artwork with simpler readable body text and clear actions. Reference rarity, levels/XP, purchasing and gifting do not authorize adding those features. Exact palette/font and the new design remain unapproved; no mockup or game source was changed this turn. Remote research inspection does not remove the earlier restriction on local-fragment browser preview or establish runtime quality.

## Angular action menu proposal — 18 October 2026

The user authorized building the newly researched direction. The fresh [proposal specification](../assets/ui-concepts/action-v1/design.json) and portable [preview source](../assets/ui-concepts/action-v1/preview.template.html) replace the stud concept as the current review candidate. This is still a design discussion preview, awaiting visual acceptance, not the shared benchmark target or an implemented Roblox redesign.

Inventory and Store now share a crisp charcoal frame, original diagonal crimson/magenta header graphics, heavy real Montserrat Black Italic display lettering and upright Montserrat Regular body copy. Quiet neutral collection tiles and a pale selected-ball showcase separate the artwork from the interface. Cyan marks selection and primary actions; Close is red. There are no studs. Store uses a tall illustrated collection feature with four consistent offers. The two exact font files and SIL OFL notices are preserved alongside the source. Existing canonical ball/icon atlases are embedded unchanged.

The preview includes all twelve appearances, local selection/equip, Inventory category and Store navigation, matching category previews, close/reopen and Escape. Responsive rules change the collection from four to three columns and stack the detail on phones; Store reflows its feature above the offers. Native button semantics and minimum 44px coarse-pointer action targets are included. No rarity, XP, purchases, gifting, economy, extra kits or fusion mechanic is added. Gameplay team colors remain outside this menu proposal.

Rebuilt the self-contained fragment with [build-preview.mjs](../assets/ui-concepts/action-v1/build-preview.mjs): 998,516 bytes. JavaScript syntax, 27 literal selector targets, canonical names, four embedded asset/font hashes, sample narrow-width font metrics and solid-color text contrast passed static checks. This does not establish rendered layout, interactions or native quality: the prior local-browser URL-policy restriction remains, so no rendered desktop/phone, Studio or human acceptance pass is claimed. Source and reproducible input data are preserved in the portable pack. Runtime source and the A/B/C benchmark remain unchanged.

## Action-menu direction approved — 18 October 2026

The user accepted the action-v1 design and asked to apply it across in-progress pages or identify the next step. Audited the active preview source: Inventory Balls/details/equipped state, Explosions, Flyers, Fusion, Store offers/spotlight and their navigation already share its headers, fonts, surfaces, buttons and selection rules. There are no additional active preview pages requiring migration. Earlier previews remain historical evidence. Marked [action-v1](../assets/ui-concepts/action-v1/design.json) approved and added the active-design pointer to the UI guide; the preview itself is unchanged.

Prepared the compact [pilot contract](../assets/ui-concepts/action-v1/pilot.json): one common target, baseline commit, existing behavior checks and consistent evaluation for direct Roblox, web-first and Figma-to-Roblox routes. No implementation route has started. Plugin discovery confirms Figma is available but not installed; it was already suggested on 17 October, so no duplicate suggestion was issued. Studio target verification must be refreshed before runtime work. This approval records the visual direction, not phone-layout or final native-runtime acceptance.

## Figma access and pilot setup — 18 October 2026

Verified 48 exposed Figma tools and authenticated access. Created the dedicated [action-v1 pilot C Design file](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz), saved a setup-page rename and confirmed it in a separate readback. Both approved Montserrat styles listed and loaded successfully. The reported Starter/View seat permitted these actual edits; Code Layers are unavailable and are not required by route C. The file remains an empty setup page, with no route design work claimed.

Prepared independent A/B/C runtime workspaces under `game/pilots/action-v1/routes/` from the pilot's exact baseline commit. Each contains 107 identical input files and 41 runtime scripts, plus the unchanged approved target, fonts, canonical art and action reference. All six Rojo builds passed; binary hashes match across all routes and XML hashes match across all routes. Rebuilding the approved preview reproduced its exact SHA-256. `design.json`, `pilot.json`, preview sources/fonts and canonical runtime sources remain unchanged. Generated copies/builds are ignored; [preparation script](../tools/pilot/prepare.mjs), [setup receipt](../test-evidence/results/action-v1-pilot-setup.json) and [file manifest](../test-evidence/results/action-v1-baseline-manifest.json) preserve reproducibility.

Refreshed Studio target verification: the connected listing called it Place1, while read-only DataModel inspection identified local `BallVsSpace.rbxl`, PlaceId/GameId 0, in Edit. The final source comparison passed for all 41 scripts. Initial CLI discovery failed because the Windows sandbox redirected LOCALAPPDATA; a sandbox retry with the discovered executable timed out. The same read-only comparison succeeded outside the sandbox. These are setup failures/recovery, not gameplay test results; no Studio source was edited.

No implementation route or new gameplay/phone acceptance test has started. The [setup and resume guide](../docs/ui/pilot-setup.md) records route paths, evidence, Figma access and the remaining browser restriction. Prior connection notes in the unchanged pilot contract are historical and superseded by this receipt.

## Action-v1 native implementation and full UI expansion — 19 October 2026

The latest user instruction supersedes the earlier Inventory/Store-only scope. Implemented the approved charcoal/crimson/cyan menus with Montserrat, canonical art, distinct selected/equipped markers and existing navigation. Extended that temporary theme across lobby controls, draft, All Balls, match HUD/results, Settings, Rewards, Emotes, Trade, Invite and How to Play. No economy, new kits, purchases, trading mechanics or persistence was added.

Phone layouts preserve the horizontal composition. StarterGui and PlayerGui use LandscapeSensor, authored layers use DeviceSafeInsets, Inventory keeps its four-column scrolling grid beside details, and Store keeps its feature beside four offers. Fixed description wrapping, delayed-art fallback overlap, touch sizes, Settings Close, modal sizing and draft readability. Practice is grouped beside Play in the clear bottom action area after right-side input failures in the emulator. The corrected actual phone aim reached the server at 315° for a visible 315° drag.

The Figma file is populated: [approved Inventory/Store](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=11-3) and [twelve editable full-game screens](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=25-112), using shared variables, components and canonical artwork. Portrait explorations are archived. The full-game page has 16 components, 46 instances and the same 20 color variables. Design screenshots were inspected and targeted clipping fixes applied. This is design evidence, separate from native Studio captures.

Static formatting, lint, strict analysis, both Rojo builds, four tooling tests and the repository/reference/link audit passed. Current native flow and regression receipts will be retained in [test evidence](../test-evidence/README.md). Intermediate failed input attempts remain in ignored runs; they are not passing evidence. Phone emulation does not certify physical touch, low-end FPS or human acceptance.

The independent A/B/C comparison is not complete. Native repair and Figma authoring were done together; reliable route time/cost logs and an independent C implementation are unavailable. B's earlier local-browser restriction remains. Approved design.json/pilot.json hashes are preserved; no benchmark winner is claimed. [Current play guide](../docs/ui/action-v1.md) and [pilot status](../docs/ui/pilot-setup.md) supersede the historical empty-file/setup notes above.

## Next work

Finish and retain the current desktop/landscape Studio validation, then continue the physical-device and human acceptance gates in the [backlog](../docs/backlog.md). Open the canonical game/builds place, not a B/C baseline copy. Keep the approved theme and territory/replication contracts. Do not treat emulator screenshots as physical-phone performance evidence or publish the experience without a separate release instruction.
