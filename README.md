# Ball VS Space

A Roblox weapon-and-territory battler: choose a hero, aim, then compete for space and survive. **Current build: weapon v2, 30 original heroes, 1v1 and solo Practice.** Only weapon contact paints; KO wins early, otherwise territory wins at 45 seconds with health breaking ties. Human acceptance, physical-device testing, balance, 2v2 and durable progression remain open.

The current [armory polish update](game/docs/design/armory-polish-v4.md) adds matching icons, smooth weapon/replay poses, hit feedback and a lighter studded board to the approved [flat armory](game/docs/design/flat-armory-v3.md). See the [implemented rules and roster](game/docs/design/weapon-territory-v2-build.md) and [current test evidence](game/test-evidence/README.md).

**Play the saved game:** download [BallVsSpace.rbxl](game/places/BallVsSpace.rbxl), open it in Roblox Studio, press **Play / F5**, then **Practice**. The map is saved in the place and visible in Edit mode; menus appear during Play. Every verification build refreshes this same primary file; CI rejects a saved place that differs from the source build.

## Find what you need

| I want to… | Start here |
| --- | --- |
| Build, run or work with a partner | [Development guide](CONTRIBUTING.md) |
| Edit UI or identify a frame | [UI guide](game/docs/ui/README.md) · [clickable map](game/docs/ui/map.html) |
| Compare the game with the reference | [Reference comparison](game/docs/ui/reference-comparison.html) |
| Share UI context in another chat | `node game/tools/build-ui-handoff.mjs` → `game/exports/UI_HANDOFF.zip` |
| Understand the code and rules | [Architecture](game/docs/architecture.md) |
| Run tests or assess validation | [Testing and review](game/docs/testing.md) · [evidence index](game/test-evidence/README.md) |
| Choose the next task | [Build status](BUILD_STATUS.md) · [backlog](game/docs/backlog.md) |

## Run locally

Install Git, PowerShell 7, Roblox Studio and Rokit. From the repository root:

```powershell
rokit install
pwsh -File game/tools/verify.ps1
```

Open `game/places/BallVsSpace.rbxl`, press **Play**, then **Practice**. For 1v1, start two Studio clients and click Play in both. Source changes belong in `game/src/`; use `rojo serve game/default.project.json` for live sync.

## Repository layout

```text
game/
  src/             Canonical client, server and shared Luau
  assets/          Original artwork and runtime assets
  docs/            Architecture, testing, backlog, history and UI guide
  tools/           Build/export commands; studio/, qa/, art/, ci/, lib/, types/
  test-evidence/   Selected screenshots/results; earlier runs in one indexed archive
  places/         One current, ready-to-open binary place saved in Git
  builds/          Generated XML inspection build (ignored)
  exports/         Generated UI folder/ZIP (ignored)
Ball_VS_Space_Evidence/   Untouched original research and references
.local/                  Ignored temporary work and recovery files
```

The root `START_HERE.md`, `RUN_PROMPT.txt`, `SETUP.md`, specification and transfer manifest are the **original research handoff**. Their empty-project statements are historical. Use the guides above for current development; [history](game/docs/history.md) preserves earlier implementation records. The [full specification](BALL_VS_SPACE_RESEARCH_AND_BUILD_SPEC.md) is preserved; the user's approved v2 rules replace its body-painting and victory contracts as documented in the linked build guide.

The source repository is [EkpoFresco/BallVsSpace](https://github.com/EkpoFresco/BallVsSpace). Runtime art is original; private reference source/physics were not recovered and pixel-perfect identity is not claimed. No project license has been selected. Roblox publication remains separate from source sharing.
