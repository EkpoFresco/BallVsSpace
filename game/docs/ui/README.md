# Ball VS Space — UI editing handoff

Current presentation: **flat armory v3**, 21 October 2026: 30 plain-ball heroes with crisp weapon sprites, studded arena, HP panels and restored charcoal/magenta/mint menus. See the [visual build guide](../design/flat-armory-v3.md) and [unchanged rules](../design/weapon-territory-v2-build.md). The action-v1 menu design remains the visual target; its old roster examples and screenshot map are historical.

The [approved design](../../assets/ui-concepts/action-v1/design.json) and [pilot contract](../../assets/ui-concepts/action-v1/pilot.json) remain unchanged. The user's later requirement supersedes their old portrait examples: **phones keep the desktop's horizontal composition**. Inventory keeps two to four columns beside the selected item. Store keeps its feature beside the offers. The compact collection scrolls; actions remain visible.

The [editable Figma file](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=11-3) is populated with canonical artwork, Inventory, Store, category views and twelve full-game screens plus two landscape Draft variants. Portrait explorations are archived as superseded. [Pilot status](pilot-setup.md) separates this working native candidate from the unfinished independent A/B/C comparison.

The [clickable screenshot map](map.html) and [reference comparison](reference-comparison.html) retain the prior presentation. Open downloaded HTML locally; GitHub displays its source.

## The distinction that matters most

| What you see | What it actually is | Main place to edit |
| --- | --- | --- |
| Walkable lobby, kiosks, arena pads, purple prop | 3D Parts in `Workspace.BVSCourt` | [Authored lobby](../../assets/world/Lobby.rbxm) |
| Floating lobby signs and kiosk screens | BillboardGui / SurfaceGui attached to world Parts | The same authored lobby asset |
| Large charcoal match court, including its apparent depth | 2D Frames, gradients and bevel strips | [HudController](../../src/client/Controllers/HudController.luau) |
| Cyan/coral territory | 1,024 screen-space Frames | [TerritoryRenderer](../../src/client/Controllers/TerritoryRenderer.luau) |
| Original moving heroes and rotating weapons | Separate atlas sprites assembled from hero definitions and authoritative weapon geometry | [HeroPortrait](../../src/client/Controllers/HeroPortrait.luau), [WeaponArt](../../src/client/Controllers/WeaponArt.luau), [BallRenderer](../../src/client/Controllers/BallRenderer.luau) |
| Standing avatars beside the court / winner in results | Actual 3D avatar models inside **ViewportFrames**, composited into UI | HudController's `avatar` / `loadAvatarAsync` helpers |
| Player's walking avatar in the lobby | World character Model | Normal Roblox character system; [CameraController](../../src/client/Controllers/CameraController.luau) controls the view |
| Menus, cards, icons, hearts, buttons, labels, aim arrow | Screen UI | HudController, [LobbyPanels](../../src/client/Controllers/LobbyPanels.luau), BallRenderer |
| Roblox menu/chat/top bar and native mobile controls | Platform CoreGui | Outside this project's authored frame tree |

The 3D arena pads visible in the lobby are decorative world geometry. They are **not** the large 2D match court. Match motion comes from the server simulation; dragging a lobby Part will not change ball collisions.

The lobby is saved in `Workspace.BVSCourt` and remains visible in Edit mode. Its canonical model is `game/assets/world/Lobby.rbxm`; lighting lives in `game/default.project.json`. Export intentional Studio world edits with `node game/tools/studio/save-world.mjs VERIFIED_STUDIO_ID` before syncing or rebuilding. Runtime scripts no longer rebuild or replace the map.

## Where to find the frames in Studio

The UI is **created by scripts during Play**. There is no complete editable screen tree saved under StarterGui. In the running **client**, expand `Players → your player → PlayerGui`. You can inspect or temporarily tweak the generated instances there. **Stop discards those changes.** Save permanent edits in `game/src/`, then sync with Rojo and restart the test.

These are the four root ScreenGuis, from back to front. Each contains a `ReferenceCanvas` Frame with a UIScale.

```text
PlayerGui
├─ BVSReferenceCourt                         DisplayOrder 1
│  └─ ReferenceCanvas
│     ├─ Court                              Frame: navy bevel strips
│     └─ Playfield                          Frame: inner floor + shadows
├─ BVSTerritory                             DisplayOrder 2
│  └─ ReferenceCanvas
│     └─ Cell0 … Cell1023                    Frames: territory tiles
├─ BVSBallLabels                            DisplayOrder 10
│  └─ ReferenceCanvas
│     ├─ Ball1 / Ball2                      Frames
│     │  ├─ Shadow / AbilityPulse           Frames
│     │  ├─ Model                           ViewportFrame (despite its name)
│     │  │  ├─ Sprite                       ImageLabel: visible ball art
│     │  │  ├─ WeaponOrbit → WeaponSprite   Frame → ImageLabel
│     │  │  ├─ Unknown                      TextLabel: hidden-choice mark
│     │  │  └─ Camera / WorldModel          3D fallback contents
│     │  └─ Coverage                        TextLabel: territory percentage
│     ├─ Aim1_1 … Aim1_7 / Aim2_1 … Aim2_7   Frames: dashed aiming guide
│     └─ Trail                              Repeated Frames: motion trail
└─ BallVsSpace                              DisplayOrder 20
   └─ ReferenceCanvas                      Main menus and HUD; see below
```

`DisplayOrder` controls stacking **between ScreenGuis**; `ZIndex` controls objects within them. Raising a territory tile's ZIndex alone will not put it over the ball ScreenGui.

## All main screens and containers

Paths in this table start at `BallVsSpace.ReferenceCanvas`. A “screen” can be a group of Frames and buttons rather than one full-screen Frame.

| Path / instance | Contents and behavior | Source |
| --- | --- | --- |
| `Lobby` — Frame | Store, Inventory, Emotes, Trade, Invite and Mode buttons; QuickJoin, Quests and Reward | HudController |
| `Lobby.Quests` — Frame | Tab, Quest1/2/3 with Title, Progress and Reward labels; session checklist | HudController |
| `Profile`, `Rewards`, `Settings`, `HelpButton` — TextButtons | Top icons and instructions button; Profile opens Inventory | HudController |
| `Currency` — Frame | Coin/gem images, fallback shapes, Coins/Gems labels and Plus | HudController |
| `Controls` — transparent Frame | Left = Play; Right = Practice; Primary = phase action such as Lock Aim or Rematch | HudController + Bootstrap |
| `SettingsPanel` — Frame | Title, Territory and Motion toggle buttons; opened by gear | HudController |
| `DraftShade` — Frame | Dark backdrop behind draft selection | HudController |
| `Draft` — Frame | Title/countdown, three appearance-named card TextButtons, AllBalls, Free, Reroll | HudController |
| Draft card children | Title, CardDivider strips, PreviewBackground → KitPreview, Description | HudController + BallArt |
| `Collection` — Frame | Compact **draft picker**, distinct from Inventory. Header → Title, 12 appearance buttons → Preview and BallName, Close = No, Confirm = Yes | HudController |
| `PlayerSide1` / `PlayerSide2` — Frames | PlayerName, Portrait, PlayerFigure, three Heart containers, KitIcon and KitName; large side figures hidden in short landscape views | HudController |
| `Results` — Frame | Purple background, repeated Stripe Frames, Crown → CrownArt, PlayerFigure, ResultTitle, ResultScore | HudController |
| `Phase`, `Clock`, `Hint`, `Status`, `Help`, `Points`, `ScoreA`, `ScoreB` — TextLabels | Phase feedback, timer, instructions, round points and area totals | HudController |
| `BarA` / `BarB` — Frames | Territory area bars | HudController |
| `Panels` — Frame | Modal group containing the eight utility windows below and full-screen `Dismiss` TextButton | LobbyPanels |
| `Toast` — TextLabel | Temporary feedback above the modal layer | LobbyPanels |

**Two easy-to-miss relationships:** the Practice button is `Controls.Right`, although it visually sits in the lobby's QuickJoin box. Rematch is `Controls.Primary`, **outside** Results. Moving only their apparent parent will not move those buttons with it.

## Utility windows inside `Panels`

Every window has `Heading`, `Close` (with a Cross image), a UIStroke and UIScale. `Panels.open` / `Panels.close` maintain which window is active; changing `Visible` alone bypasses that state.

| Window Frame | Important children | What works now |
| --- | --- | --- |
| `Inventory` | Balls/Explosions/Flyers/Fusion tab buttons; `Content.BallsPage.Grid` ScrollingFrame containing 12 appearance cards; `Content.BallsPage.Details` with Name, Ball, Weapon, Description, Equipped and Equip; `Content.PageExplosions`, `Content.PageFlyers`, `Content.PageFusion` | Ball selection/equipment; other categories show previews or availability text |
| `Store` | Balance; Events/Balls/Explosions/Flyers tabs; Content.Offers with Laser/Ray/Balloons/Parasol cards, View… buttons, Spotlight; Footer | Free collection navigation and previews; no purchase system |
| `Rewards` | Gift, Headline, Body, Explore | Opens the free collection; no durable reward claim |
| `Play` | 1v1, Practice, Description | Queue or start Practice |
| `How to play` | Step1/Step2/Step3, each with Number/Title/Body; Foot | Instructions for selection, aiming and territory |
| `Trade` | TradeArt, Title, Body | Availability explanation; trading is unfinished |
| `Emotes` | Wave, Cheer, Dance, Laugh buttons with Pose images | Calls Roblox character emotes where supported |
| `Invite friends` | Envelope, Body, Invite | Roblox invitation prompt where supported; handles unpublished-place failure |

Names containing spaces are literal. Use `FindFirstChild("Invite friends")`. A child called `Name` also needs `FindFirstChild("Name")`: `instance.Name` is the instance's own string property. Appearance card names change with the selected skin; repeated Heart/Stripe/Trail names are not unique identifiers.

## What to edit first

| Desired change | Edit here |
| --- | --- |
| Shared fonts, text outlines, button gradient/edge/hover | [ReferenceUi](../../src/client/Controllers/ReferenceUi.luau): `displayFont` (Michroma), `cardFont` (FredokaOne), `text`, `button` |
| Main HUD, lobby overlay, draft, results | HudController: `Hud.new` creates; `Hud.layout` positions/reflows; `Hud.render` updates state and visibility |
| Inventory, Store, utility panels | LobbyPanels wires actions; [ActionMenus](../../src/client/Controllers/ActionMenus.luau) styles and lays out Inventory/Store; `Panels.layout` handles utilities |
| Symbols, balls, weapon silhouettes | [Art generator](../../tools/art/build.mjs), then [Artwork](../../src/client/Controllers/Artwork.luau) for atlas coordinates/asset IDs |
| Names/descriptions and cosmetic-to-kit mapping | [AppearanceCatalog](../../src/shared/AppearanceCatalog.luau) |
| Court projection and overall canvas | [ReferenceLayout](../../src/client/Controllers/ReferenceLayout.luau), coordinated with HudController, TerritoryRenderer, BallRenderer and AimController |
| Button actions and phase connections | [Bootstrap.client](../../src/client/Bootstrap.client.luau); retain action wiring when restyling |

The coordinate system is **803×602 design units**, scaled and centered to fit the viewport. The inner field is `(178, 78)` with size `446×446`. Screenshot pixels may differ because of window size or display scaling. Start with one panel, then check desktop and compact landscape paths in its `layout` function. Constructor positions can be overwritten there.

Most authored TextButtons show a child **ButtonText**, while the button's native text is transparent. The helper mirrors Text/TextSize into that child. **ButtonFill** supplies the visible gradient; setting only the parent BackgroundColor3 may not change what you see. Edit the helper or its visible children intentionally.

The ball's container is larger than its visible sphere because atlas cells include padding and weapons. Resizing it casually can break the tested agreement between the visible diameter and simulation radius. Camera edits inside a ball ViewportFrame affect the fallback, not the loaded Sprite image.

## Editing icons and ball art

The source of truth is `game/tools/art/build.mjs`. It generates `icons.svg/png`, `balls.svg/png` and `atlas.json`. Directly editing generated SVG/PNG files is overwritten by regeneration.

The icon atlas has 32 symbols in 128-pixel cells (8 columns); ball art has twelve portraits in 256-pixel cells (4 columns). Body circles occupy 88/128 of a cell and the renderer compensates for this padding. Cell clipping prevents icons bleeding into adjacent atlas rectangles.

From the repository root:

```powershell
npm ci --prefix game/tools/art --no-audit --no-fund
node game/tools/art/build.mjs
```

A changed local PNG **does not automatically change the Roblox image**. Upload the revised atlas, update its ID in Artwork (and the world kiosk ImageLabel in the authored lobby where applicable), then verify it loads in a real client. Keep the cell layout and ImageRect offsets/sizes consistent. On an owner/group change, verify images load and update image IDs if new uploads are required.

## Before you keep a UI edit

1. Save it in source, sync/rebuild, and reopen the affected screen through its real button.
2. Check desktop and both phone landscape orientations: text fit, scrolling, close controls, selection and 44+ UI-pixel touch targets.
3. For court/ball changes, check aim alignment and collision-size agreement; for menus, verify switching/closing and repeated opens leave no duplicate UI.
4. Compare the same phase, ball and viewport against the reference. Record remaining differences rather than labeling them exact.

Twelve appearances currently map to **two ability kits**. Hearts represent rounds; ball percentages and results represent territory. Cosmetic UI work should preserve those meanings. Purchases, trading, fusion, durable progression, 2v2 and physical-device acceptance remain separate work.

For the condensed method, read [the replication skill](replication-skill/SKILL.md). Generate the portable folder/ZIP with `node game/tools/build-ui-handoff.mjs`; outputs are in `game/exports/`.

## Presentation status

| Surface | Implementation |
| --- | --- |
| Court | Measured 512×510 navy frame, 446×446 playfield, mitred bevels, inner shadows and sky backdrop |
| Balls | Twelve shaded atlas portraits, Acid spots, luminous Axe/Blade seams, separate rotating weapons, Cell membrane and other collection surfaces; 82.23125-unit main diameter matches the solver |
| Symbols | 32 antialiased authored symbols: continuous hearts, faceted gems, gear, store, inventory, gifts, invite, crown, emote and category art |
| Draft and aim | Three cards, actual reroll, private opponent choice, twelve-ball compact selector, dashed arrow and cyan Lock Aim |
| Inventory | Illustrated tabs, scrolling collection, selected outline, large detail preview and functional Equip feedback |
| Store | Daily offers, collection spotlight, balance treatment and working navigation to ball/cosmetic previews |
| Utilities | Rewards, mode selection, instructions, emotes, invitations and explicit trade availability; real emote/invite APIs where supported |
| Results | Purple striped panel, proportioned crown, actual winner avatar, local victory/defeat, area totals and rematch |
| Lobby | Blue plaza, detailed collection kiosks, framed arena pads, instructional boards, illuminated portals and normal proximity prompts |
| Phone | Horizontal desktop composition in the device-safe area; adaptive two-to-four-column Inventory with adjacent details, Store feature beside offers, readable picker/settings and larger actions |

Native Roblox controls and participating avatars belong to the platform/account and are not impersonated with copied UI.

## Deliberate game differences

- Balls report owned territory, not reference HP. The grid and area totals are on by default; View Settings can hide them for composition comparisons.
- Twelve appearances map to **two** territory kits. Names and silhouettes do not imply twelve recovered reference abilities.
- Descriptions, free-collection buttons and session quests describe actual behavior. Trading, fusion, purchases, durable rewards and 2v2 are not presented as implemented systems.
- Hearts show remaining rounds. Victory follows the specification's territory/round rule.
- Phones retain the horizontal desktop composition; compact geometry and scrolling keep controls usable.

Reference lighting, cloud placement, individual mesh/weapon curves, original animation timing and full catalog are not exact recoveries. No measured source-physics equivalence or pixel-perfect acceptance is claimed. Original research and the distinction between observed and proposed values remain intact.
