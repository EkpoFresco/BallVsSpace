# Ball VS Space — M1 playable build

An original territory auto-battler. Choose Drift or Anchor, aim the opening, then compete for a signed 32×32 court. This is the two-kit, one-arena vertical slice. Progress is deliberately session-only. No paid features or external art are included.

## Play

Open `builds/BallVsSpace.rbxl` in Roblox Studio. Press **Play**, then **Practice** for a solo match against a predictable bot. For human 1v1, use Studio **Test → Server & Clients**, select **2 clients**, start, and click **Play 1v1** in each client. Ordinary Play never starts the automated test driver.

During draft, click a kit and **Lock**. During aim, drag on the court or use the 15° buttons and lock. The line previews the first wall bounce. Battles run automatically for 30 seconds. The score bar includes neutral area; the larger final owned-cell count wins. Exact ties enter overtime. A 2-cell lead held for 10 consecutive updates wins overtime; an unheld lead at the cap is a draw. Win = 1 match point, draw = ½ each; first to 2 points or the higher total after three rounds wins. Result controls offer a two-second replay and rematch.

## Build from source

Run commands from this `game/` directory, using PowerShell:

```powershell
rokit install
./tools/verify.ps1
```

The pinned tools are in `rokit.toml`. `verify.ps1` checks formatting, lint, strict types, and creates binary/XML place builds. Install Rokit if missing; the receiving machine must be audited again. Node is needed only for the optional MCP scripts. No Wally runtime dependencies are required.

Canonical source maps through `default.project.json`. `src/shared` becomes ReplicatedStorage.Shared, `src/server` becomes ServerScriptService.Server, and `src/client` becomes StarterPlayerScripts.Client. All court geometry is generated from original primitives at runtime; client tiles and balls are visual proxies for the server's numerical simulation. `assets/runtime` is reserved for future original assets.

For normal live development, run `rojo serve default.project.json` and connect the Rojo Studio plugin to this project. If using the included Studio MCP fallback, first list and independently verify the intended local place, then pass its explicit ID to `node tools/sync-studio.mjs <studio-id>`. The sync refuses published PlaceIds and replaces only the project's named scripts. It is not a substitute for testing or saving a built file.

## Verify in Studio

The detailed commands and gates are in [docs/testing.md](docs/testing.md). The core test suite is `ServerScriptService.Server.Tests.Suite`; run in the Edit command bar:

```lua
require(game.ServerScriptService.Server.Tests.Suite).run()
```

For the ten-match automation, run the contents of `tools/start-multiplayer.luau` in the Edit command bar. It starts two actual clients through StudioTestService and ends after ten completed matches. The clients use ordinary remotes and standard clocks. Allow roughly 20–25 minutes. Do not count these as human testers.

Read [docs/playtest-report.md](docs/playtest-report.md) for actual evidence and limitations, [docs/decisions.md](docs/decisions.md) for implementation choices, and the pack-root `BUILD_STATUS.md` for the resume task. M2–M4 expansion is gated by the M1 human checks in the research specification.
