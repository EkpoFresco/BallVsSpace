# Development and collaboration

Read [BUILD_STATUS](BUILD_STATUS.md), [the backlog](game/docs/backlog.md) and [AGENTS.md](AGENTS.md) before choosing work. This is an implemented game; the initial handoff's empty-project instructions are historical.

## Setup and play

Install Git, PowerShell 7, Roblox Studio and Rokit. The root `rokit.toml` pins Rojo, StyLua, Selene and Luau LSP; no Wally packages or API keys are required for a build.

```powershell
git clone https://github.com/EkpoFresco/BallVsSpace.git
cd BallVsSpace
rokit install
pwsh -File game/tools/verify.ps1
```

Open `game/places/BallVsSpace.rbxl`; verification rebuilds this same primary file. Play → Practice runs a solo match. Test → Server & Clients → 2 clients, then Play in both, runs 1v1. Successful GitHub Actions runs also attach place builds. CI does not run Studio multiplayer or human tests.

## Edit the canonical project

```powershell
rojo serve game/default.project.json
```

Connect the Rojo Studio plugin to the intended local place. Edit `game/src/`; Studio-only script edits are overwritten by sync. UI frames are generated during client Play, so Explorer tweaks disappear on Stop. See the [UI guide](game/docs/ui/README.md) and [architecture](game/docs/architecture.md).

Original artwork is in `game/assets/art/`; [its pipeline](game/docs/ui/README.md#editing-icons-and-ball-art) explains regeneration and Roblox image delivery. Node.js 24 and Python 3 are used by the portable UI exporter; Node.js also runs optional Studio QA tools. Generate the sharing folder/ZIP with:

```powershell
node game/tools/build-ui-handoff.mjs
```

Outputs live in `game/exports/` and are ignored by Git. Share the ZIP; apply proposed edits back to canonical source. The exporter checks previously exported files before replacing them.

## Optional Studio MCP

`game/tools/studio/` contains discovery, explicit-place sync and verification. The transport discovers the installed `StudioMCP.exe` on the current machine; `BVS_STUDIO_MCP` can point to a verified executable. Never reuse an old session's Studio ID. From the repository root:

```powershell
node game/tools/studio/studio-mcp.mjs list unused game/test-evidence/runs/mcp-tools.json
node game/tools/studio/studio-mcp.mjs call game/tools/studio/request-list.json game/test-evidence/runs/studios.json
```

Inspect the returned schema, list and place identity before using an ID. Source sync refuses published PlaceIds. See [testing](game/docs/testing.md) for commands. The `types/` definitions are vendored tooling data with their license; update them deliberately alongside the pinned toolchain.

## Branch and review

1. Update `main`, then create a branch such as `git switch -c ui/inventory`.
2. Agree on file ownership when both partners work on the same UI controller.
3. Run `pwsh -File game/tools/verify.ps1`, `node --test game/tools/tests/*.test.mjs`, and `node game/tools/audit-repository.mjs`. Run affected Studio checks for runtime/UI changes.
4. Keep exploratory output in `game/test-evidence/runs/`. Promote useful final results to `results/` and images to `screenshots/`; update the evidence index and BUILD_STATUS.
5. Commit, push your branch and open a PR describing the player-visible change, evidence and remaining limits. Have the other partner review it before merging.

Preserve the signed 32×32 grid, maximum team pressure, team-union scoring, exact cutoffs and overtime/draw rules unless the owner revises the design. The server owns game state. UI must distinguish implemented systems from previews, and territory from reference HP/lives.

Keep one current binary place at `game/places/BallVsSpace.rbxl` in the same commit as its source. `verify.ps1` refreshes it, and CI checks it matches a clean build. Other generated builds, XML copies, exports, credentials and personal Studio settings remain ignored. Original research stays untouched. GitHub access and Roblox Team Create are separate; the pending invitation recorded in history is not proof of accepted access. Publication, economy and Team Create configuration require their own instructions.
