# Partner onboarding

The shared repository is [EkpoFresco/BallVsSpace](https://github.com/EkpoFresco/BallVsSpace). Source, references, tools and review history travel in one clone. BUILD_STATUS records the push, Actions run and collaborator invitation. Accept the invitation for **brocoliman** to gain write access; a pending invitation is not accepted access.

## Clone and run

Install Git, PowerShell 7, Roblox Studio and [Rokit](https://github.com/rojo-rbx/rokit), then:

```powershell
git clone https://github.com/EkpoFresco/BallVsSpace.git
cd BallVsSpace
rokit install
pwsh -File game/tools/verify.ps1
```

Open `game/builds/BallVsSpace.rbxl`, press Play, then Practice. Choose a ball, aim and lock. Territory is on by default. Start two Studio clients and click Play in both for 1v1. [Testing](testing.md) explains runtime checks and remaining gates. Successful Actions runs also contain downloadable place builds.

The root `rokit.toml` pins the toolchain. No Wally dependencies or API keys are needed to build. Optional Studio MCP scripts require Node.js 24 and the installed Studio MCP executable; rediscover and verify the intended place before using its ID.

## Edit and collaborate

```powershell
rojo serve game/default.project.json
```

Connect the Rojo plugin in the intended local place. Canonical changes belong in `game/src/`; Studio-only edits are overwritten on sync. See [art delivery](../assets/art/README.md) for editable SVGs, atlases, regeneration and asset IDs. A Roblox owner/experience change may require granting asset access or republishing the included original images.

Use branches and PRs as described in [CONTRIBUTING.md](../../CONTRIBUTING.md). Open the [presentation comparison](../test-evidence/presentation-comparison.html) locally. Read the [code review](code-review.md) and [backlog](backlog.md) before selecting work. Avoid editing the same controller simultaneously.

GitHub collaboration and Roblox Team Create are separate. This source handoff does not publish a Roblox experience or configure Team Create. The owner can configure main-branch review rules when both collaborators are ready; no restrictive repository rules are silently applied.
