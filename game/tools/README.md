# Development tools

Run from the repository root unless a command says otherwise. Canonical gameplay is in `game/src/`; the Luau here is manual Studio testing/diagnostics.

| Path | Use |
| --- | --- |
| `verify.ps1` | Format/lint/typecheck and binary/XML builds |
| `audit-repository.mjs` | Reference hashes, links and repository structure |
| `build-ui-handoff.mjs` | Regenerate ignored UI folder and ZIP |
| `build-presentation-comparison.mjs` | Rebuild current reference/current gallery |
| `studio/` | Official MCP transport, explicit-place sync/verify and client focus |
| `qa/` | Current UI flow, layout, lobby and mirrored-fixture drivers |
| `qa/fixtures/` | Logic, multiplayer, client regression and profiler snippets |
| `qa/devices/` | Desktop/portrait/landscape emulation and reset snippets |
| `art/` | Original vector/atlas generator and temporary image server |
| `ci/` | Pinned Rokit installer and authenticated GitHub CLI wrapper |
| `lib/` | Shared paths, source inventory, response parsing and safe Luau quoting |
| `tests/` | Node tests for shared tooling |
| `types/` | Vendored Roblox analyzer definitions and license |

The three UI QA drivers share one RPC helper. Request files are temporary, output goes to `test-evidence/runs/`, and Studio IDs must be explicitly verified. [Testing](../docs/testing.md) lists supported commands. Superseded diagnostics are recoverable in Git history.
