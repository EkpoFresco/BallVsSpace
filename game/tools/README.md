# Development tools

Run from the repository root unless a command says otherwise. Canonical gameplay is in `game/src/`; the Luau here is manual Studio testing/diagnostics.

| Path | Use |
| --- | --- |
| `verify.ps1` | Format/lint/typecheck, binary/XML builds and refresh the saved primary place |
| `audit-repository.mjs` | Reference hashes, links and repository structure |
| `build-ui-handoff.mjs` | Regenerate ignored UI folder and ZIP |
| `build-presentation-comparison.mjs` | Rebuild current reference/current gallery |
| `studio/` | Official MCP transport, explicit-place sync/verify and client focus |
| `qa/` | Current UI flow, layout, lobby and mirrored-fixture drivers |
| `qa/fixtures/` | Logic, multiplayer, client regression and profiler snippets |
| `qa/devices/` | Desktop and landscape phone emulation and reset snippets |
| `art/` | Original vector/atlas generator and temporary image server |
| `ci/` | Pinned Rokit installer and authenticated GitHub CLI wrapper |
| `lib/` | Shared paths, source inventory, response parsing and safe Luau quoting |
| `tests/` | Node tests for shared tooling |
| `types/` | Vendored Roblox analyzer definitions and license |

The UI QA drivers share one RPC helper. Request files are temporary, output goes to `test-evidence/runs/`, and Studio IDs must be explicitly verified. [Testing](../docs/testing.md) lists supported commands. Superseded diagnostics are recoverable in Git history.

The primary place is `game/places/BallVsSpace.rbxl`; verification writes that file directly. The lobby is a static Rojo asset at `game/assets/world/Lobby.rbxm`, with lighting in `default.project.json`. To retain intentional Edit-mode changes to `Workspace.BVSCourt`, run `node game/tools/studio/save-world.mjs VERIFIED_STUDIO_ID`, then rebuild. Sync imports this canonical scene, so export intended world edits before syncing. Play never regenerates it.
