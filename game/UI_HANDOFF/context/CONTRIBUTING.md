# Contributing

Clone the whole repository and follow [the README](README.md). Read [BUILD_STATUS.md](../docs/build-status-snapshot.md), [the backlog](../docs/backlog.md) and [AGENTS.md](AGENTS.md) before choosing work. Do not restart completed milestones because the original handoff describes an empty pack.

## Change and review

1. Update `main` and create a branch, for example `git switch -c ui/collection-icons`.
2. Make canonical changes under `game/`. Keep research evidence unchanged and record corrections separately. Avoid working on the same UI controller simultaneously; agree on a file owner for overlapping work.
3. Run `pwsh -File game/tools/verify.ps1`. For runtime changes, run the relevant [Studio tests](../docs/testing.md). UI changes need a matching reference capture and an inspected current capture at the same viewport.
4. Update BUILD_STATUS with what passed, what failed, and the next step. Keep new logs in `game/test-evidence/`; add only useful screenshots explicitly with `git add -f <path>` because exploratory captures are ignored.
5. Commit, push the branch, and open a pull request to `main`. Explain the player-visible change, evidence and remaining limits. Have the other partner review it before merging.

Do not commit generated places, credentials or personal Studio settings. A `.rbxl` from another computer is a build output; merge the Luau/source changes and rebuild. For authored models, save a reviewable asset under `game/assets/runtime/` and wire it through the existing Rojo project.

## Contracts

Preserve section 6's signed 32×32 influence grid, maximum pressure per team, team-union scoring, exact cutoff and overtime/draw rules unless the owner explicitly revises the design. The server owns gameplay. Client presentation must reflect its results. Reference HP/lives and proposed kit tuning are not recovered proprietary rules.

Visual replication remains a priority. Placeholder geometry, substituted glyphs, estimated fonts, missing screens and approximate ball art must be recorded as gaps, not described as 1:1 completion. The native Roblox top bar and account avatars vary with the platform/account and should be separated from authored UI in comparisons.

GitHub Actions checks source and creates artifacts. It does not replace Studio multiplayer, human comprehension or physical-device tests. Keep those gates pending until they have actual evidence.
