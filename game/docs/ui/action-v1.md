# Current action-v1 build

Open **`game/builds/BallVsSpace.rbxl`** in Roblox Studio and press **Play / F5**. The UI is created during Play; Edit mode does not show the menus. Permanent source is under `game/src/`.

1. Open **Inventory** on the lobby's left. Select a ball, then Equip. Selection and equipment have separate markers. All twelve appearances remain free and map to the same two gameplay kits.
2. Try Balls, Explosions, Flyers and Fusion. Preview/availability copy describes the systems that exist.
3. Use **Store >** in the compact header (desktop footer), or the lobby Store button. View Laser/Ray and Preview Balloons/Parasol open their Inventory pages.
4. Check Settings and the utility buttons. Use **Practice**, then **All Balls** for the enlarged draft picker. Choose, confirm, aim and Lock Aim. Round results show territory; match results show match points. **Replay** shows the last two seconds. **Rematch** changes to **Queued ✓** after server acceptance.
5. In Studio's device emulator select a phone and **landscape**. Inventory uses two to four columns beside fixed details; scroll the grid for later balls. Store keeps its feature beside its offers and scrolls on very short screens. Test both landscape directions.

The project sets StarterGui and PlayerGui orientation to `LandscapeSensor`. Authored UI layers share `DeviceSafeInsets` so the court, territory and balls remain aligned while avoiding landscape cutouts. Phone means a compact horizontal view. This is the user's later amendment; the approved JSON files retain their original inputs.

## Visible changes

- Inventory, Store and categories use approved charcoal surfaces, diagonal crimson headers, Montserrat text, cyan actions and canonical artwork.
- Compact menus keep the horizontal composition and 44-pixel actions.
- The lobby, three-card draft, All Balls picker, match HUD/results and every existing utility dialog share the temporary action theme. All Balls keeps four columns; Settings has large toggles and an explicit Close button.
- Practice sits beside Play in the bottom action bar. Native movement controls hide during matches and return in the lobby. World signs and instruction boards use the matching theme. Compact lobby actions fit above the bottom edge. Device-safe margins protect controls near cutouts.
- Selected/equipped markers no longer collide on narrow cards. Notifications use a readable temporary banner. Descriptions wrap naturally instead of retaining old forced line breaks.
- Delayed artwork continues checking until loaded or removed, avoiding overlapping fallback/artwork previews.
- Inventory details and Equip stay fixed on desktop as well as phone; scroll the collection grid. Store rows share aligned bottoms at intermediate desktop heights.
- Player badges show actual match points instead of hearts. Compact result cards retain readable labels, while connection/replay status has a readable banner.

Editable design: [Inventory](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=11-3), [Store](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=11-212). [Full-game UI](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=25-112) contains twelve additional editable screens and [small landscape Draft variants](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=37-286). Earlier portrait frames are on a superseded archive page.

## Verification and limits

See [test evidence](../../test-evidence/README.md) for current receipts and captures. Studio emulation does not establish physical touch or low-end phone performance. Those gates remain pending. Gameplay authority and territory rules are unchanged.

Native implementation and Figma authoring were completed while repairing the visible game. They are not independent measured A/B/C trials: reliable time/cost logs are unavailable, B's earlier local-browser restriction remains, and C has no independent native translation. No comparison winner is claimed.
