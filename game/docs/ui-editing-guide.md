# Ball VS Space — UI editing handoff

Snapshot: **0.3 presentation, 17 October 2026**. The screenshots below come from the completed Studio validation pass; they are not new mockups. This guide documents the current implementation, including its shortcuts and remaining differences.

Open the **[clickable screenshot map](ui-map.html)** locally in a browser. Select a screen, then a numbered region to see its type, Explorer path and source file. On GitHub, download/clone the repository first; GitHub shows HTML as source. The [comparison gallery](../test-evidence/presentation-comparison.html) separately shows the original reference alongside this build.

## The distinction that matters most

| What you see | What it actually is | Main place to edit |
| --- | --- | --- |
| Walkable lobby, kiosks, arena pads, purple prop | 3D Parts in `Workspace.BVSCourt` | [CourtService](../src/server/Services/CourtService.luau), [LobbyDetailService](../src/server/Services/LobbyDetailService.luau) |
| Floating lobby signs and kiosk screens | BillboardGui / SurfaceGui attached to world Parts | LobbyDetailService; base boards in CourtService |
| Large navy match court, including its apparent depth | 2D Frames, gradients and bevel strips | [HudController](../src/client/Controllers/HudController.luau) |
| Cyan/coral territory | 1,024 screen-space Frames | [TerritoryRenderer](../src/client/Controllers/TerritoryRenderer.luau) |
| Shaded moving balls and rotating weapons | Primarily ImageLabels; a ViewportFrame holds a 3D fallback | [BallArt](../src/client/Controllers/BallArt.luau), [BallRenderer](../src/client/Controllers/BallRenderer.luau), [Artwork](../src/client/Controllers/Artwork.luau) |
| Standing avatars beside the court / winner in results | Actual 3D avatar models inside **ViewportFrames**, composited into UI | HudController's `avatar` / `loadAvatarAsync` helpers |
| Player's walking avatar in the lobby | World character Model | Normal Roblox character system; [CameraController](../src/client/Controllers/CameraController.luau) controls the view |
| Menus, cards, icons, hearts, buttons, labels, aim arrow | Screen UI | HudController, [LobbyPanels](../src/client/Controllers/LobbyPanels.luau), BallRenderer |
| Roblox menu/chat/top bar and native mobile controls | Platform CoreGui | Outside this project's authored frame tree |

The 3D arena pads visible in the lobby are decorative world geometry. They are **not** the large 2D match court. Match motion comes from the server simulation; dragging a lobby Part will not change ball collisions.

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
| `PlayerSide1` / `PlayerSide2` — Frames | PlayerName, Portrait, PlayerFigure, six Heart containers, KitIcon and KitName; side figures hidden in portrait | HudController |
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
| `Inventory` | Balls/Explosions/Flyers/Fusion tab buttons; `BallsPage.Grid` ScrollingFrame containing 12 appearance cards; `BallsPage.Details` with Name, Ball, Weapon, Description, Equipped and Equip; `PageExplosions`, `PageFlyers`, `PageFusion` | Ball selection/equipment; other categories show previews or availability text |
| `Store` | Balance; Events/Balls/Explosions/Flyers tabs; Offers with Laser/Ray/Balloons/Parasol cards, View… buttons, Spotlight; Footer | Free collection navigation and previews; no purchase system |
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
| Shared fonts, text outlines, button gradient/edge/hover | [ReferenceUi](../src/client/Controllers/ReferenceUi.luau): `displayFont` (Michroma), `cardFont` (FredokaOne), `text`, `button` |
| Main HUD, lobby overlay, draft, results | HudController: `Hud.new` creates; `Hud.layout` positions/reflows; `Hud.render` updates state and visibility |
| Inventory, Store, utility panels | LobbyPanels: `Panels.new` creates; `Panels.layout` controls desktop and phone reflow |
| Symbols, balls, weapon silhouettes | [Art generator](../tools/art/build.mjs), then [Artwork](../src/client/Controllers/Artwork.luau) for atlas coordinates/asset IDs |
| Names/descriptions and cosmetic-to-kit mapping | [AppearanceCatalog](../src/shared/AppearanceCatalog.luau) |
| Court projection and overall canvas | [ReferenceLayout](../src/client/Controllers/ReferenceLayout.luau), coordinated with HudController, TerritoryRenderer, BallRenderer and AimController |
| Button actions and phase connections | [Bootstrap.client](../src/client/Bootstrap.client.luau); retain action wiring when restyling |

The coordinate system is **803×602 design units**, scaled and centered to fit the viewport. The inner field is `(178, 78)` with size `446×446`. Screenshot pixels may differ because of window size or display scaling. Start with one panel, then check both desktop and portrait paths in its `layout` function. Constructor positions can be overwritten there.

Most authored TextButtons show a child **ButtonText**, while the button's native text is transparent. The helper mirrors Text/TextSize into that child. **ButtonFill** supplies the visible gradient; setting only the parent BackgroundColor3 may not change what you see. Edit the helper or its visible children intentionally.

The ball's container is larger than its visible sphere because atlas cells include padding and weapons. Resizing it casually can break the tested agreement between the visible diameter and simulation radius. Camera edits inside a ball ViewportFrame affect the fallback, not the loaded Sprite image.

## Editing icons and ball art

The source of truth is `game/tools/art/build.mjs`. It generates `icons.svg/png`, `balls.svg/png` and `atlas.json`. Directly editing generated SVG/PNG files is overwritten by regeneration. See the [art pipeline guide](../assets/art/README.md).

From the repository root:

```powershell
npm ci --prefix game/tools/art --no-audit --no-fund
node game/tools/art/build.mjs
```

A changed local PNG **does not automatically change the Roblox image**. Upload the revised atlas, update its ID in Artwork (and the world kiosk image in LobbyDetailService where applicable), then verify it loads in a real client. Keep the cell layout and ImageRect offsets/sizes consistent.

## Before you keep a UI edit

1. Save it in source, sync/rebuild, and reopen the affected screen through its real button.
2. Check desktop, portrait and landscape: text fit, scrolling, close controls, selection and 44+ UI-pixel touch targets.
3. For court/ball changes, check aim alignment and collision-size agreement; for menus, verify switching/closing and repeated opens leave no duplicate UI.
4. Compare the same phase, ball and viewport against the reference. Record remaining differences rather than labeling them exact.

Twelve appearances currently map to **two ability kits**. Hearts represent rounds; ball percentages and results represent territory. Cosmetic UI work should preserve those meanings. Purchases, trading, fusion, durable progression, 2v2 and physical-device acceptance remain separate work.

For the short process we can keep improving, read [the starter replication skill](skills/reference-ui-replication/SKILL.md). No gameplay or UI runtime code was changed to create this handoff.
