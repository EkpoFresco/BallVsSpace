# Ball VS Space — reference presentation build

The current build reconstructs the reference game's presentation first, following the user's revised priority. Large shaded Acid, Axe, Cell, Poison, Verity, Burst and Vampire balls, a beveled navy court, real avatar displays, three-card draft, white dashed aiming arrows and a blue walkable lobby replace the earlier small-ball prototype. All ball models and UI geometry are authored in this project. Avatar appearance comes from the participating Roblox accounts.

The existing authoritative territory game still runs underneath: Drift powers Acid/Cell/Poison appearances and Anchor powers Axe. This pass does not implement the reference's hidden HP, damage or weapon formulas. Ball numbers show actual territory percentages; the large hearts indicate rounds remaining. Progress is session-only and currency displays remain zero. No purchases are enabled.

## Play

Open `builds/BallVsSpace.rbxl` in Roblox Studio. Press **Play**, then the purple **Practice** button for a solo match. For human 1v1, use Studio **Test → Server & Clients**, select **2 clients**, start, and click the green **Play** button in each client. Ordinary Play never starts the automated test driver.

Click a ball card to select and lock it, or open **All Balls**, select an icon and press **YES** in the seven-appearance picker. Drag or click on the court to aim, then press **Lock Aim**. Draft allows 20 seconds and aim allows 30; both can finish early when everyone locks. Battles run automatically for 30 seconds. Exact ties enter overtime. A 2-cell lead held for 10 consecutive updates wins overtime; an unheld lead at the cap is a draw. Win = 1 match point, draw = ½ each; first to 2 points or the higher total after three rounds wins. The result screen offers **Rematch**.

The territory capture grid and area totals are visible by default. Before a match, open the lobby gear and disable **Territory overlay** for a clean reference comparison. The same settings panel offers reduced motion. Store and Inventory open the free appearance picker; there is no commercial store. The lobby practice checklist tracks the current session; it grants no currency or durable rewards.

## Build from source

Run commands from this `game/` directory, using PowerShell:

```powershell
rokit install
./tools/verify.ps1
```

The pinned tools are in the pack-root `../rokit.toml`. `verify.ps1` checks formatting, lint, strict types, and creates binary/XML place builds. Install Rokit if missing; the receiving machine must be audited again. Node is needed only for the optional MCP scripts. No Wally runtime dependencies are required. The whole pack is now one repository; see [partner onboarding](docs/partner-onboarding.md).

Canonical source maps through `default.project.json`. `src/shared` becomes ReplicatedStorage.Shared, `src/server` becomes ServerScriptService.Server, and `src/client` becomes StarterPlayerScripts.Client. All court geometry is generated from original primitives at runtime; client tiles and balls are visual proxies for the server's numerical simulation. `assets/runtime` is reserved for future original assets.

For normal live development, run `rojo serve default.project.json` and connect the Rojo Studio plugin to this project. If using the included Studio MCP fallback, first list and independently verify the intended local place, then pass its explicit ID to `node tools/sync-studio.mjs <studio-id>`. The sync refuses published PlaceIds and replaces only the project's named scripts. It is not a substitute for testing or saving a built file.

## Verify in Studio

The detailed commands and gates are in [docs/testing.md](docs/testing.md). The core test suite is `ServerScriptService.Server.Tests.Suite`; run in the Edit command bar:

```lua
require(game.ServerScriptService.Server.Tests.Suite).run()
```

For the ten-match automation, run the contents of `tools/start-multiplayer.luau` in the Edit command bar. It starts two actual clients through StudioTestService and ends after ten completed matches. The clients use ordinary remotes and standard clocks. Allow roughly 20–25 minutes. Do not count these as human testers.

Read [docs/replica-pass.md](docs/replica-pass.md) for this pass, [docs/decisions.md](docs/decisions.md) for implementation choices, and the pack-root `BUILD_STATUS.md` for current verification and the resume task. Human and real-device gates remain unvalidated; they no longer defer the user's requested visual reconstruction.

Keep Studio restored while capturing: a minimized Studio produced screenshots containing UI but no 3D world or ViewportFrame models. The `replica-*` evidence belongs to this build; `visual-qa-*` and the older two-client video show the superseded prototype.
