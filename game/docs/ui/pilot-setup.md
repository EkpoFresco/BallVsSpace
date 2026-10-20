# action-v1 implementation and pilot status

The latest user instruction expands the approved Inventory/Store theme to all existing game UI and authorizes implementation without another design approval. Phone layouts are horizontal. The original [design](../../assets/ui-concepts/action-v1/design.json) and [pilot contract](../../assets/ui-concepts/action-v1/pilot.json) remain unchanged as historical inputs.

## Current working version

Use the canonical `game/src/` and `game/places/BallVsSpace.rbxl`, following the [play guide](action-v1.md). Inventory/Store have been implemented natively; the same theme now covers the lobby controls, draft, picker, match HUD/results, Settings and utility dialogs. This is the working implementation, not a completed independent A/B/C benchmark.

The [Figma file](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=11-3) contains editable Inventory/Store screens, shared tokens/components and a [full-game UI page](https://www.figma.com/design/oOA0AIBygAKBqgHUtdhwkz?node-id=25-112). Earlier portrait explorations are archived. Figma screenshots are design evidence; only Studio captures establish native rendering.

Figma authentication, write/read access, Montserrat font loading, components, variables and screenshots were exercised successfully. The original empty-page receipt below is historical. The full-page audit is [recorded here](../../test-evidence/results/full-ui-figma-final.json).

## Baseline and comparison limits

The [setup receipt](../../test-evidence/results/action-v1-pilot-setup.json) and [baseline manifest](../../test-evidence/results/action-v1-baseline-manifest.json) preserve the original 107-file, 41-script inputs from commit `eb21fc7ca7993aaf2ee6e80b3f8d8fee196a629f`. All six initial place builds matched by format. The current implementation adds ActionMenus and has 42 runtime scripts.

Prepared workspaces live under `game/pilots/action-v1/routes/`. Route A is a convenience snapshot of the current implementation; B/C retain their initial runtime baseline. Do not open B/C expecting the redesign. Figma authoring and native repair happened together, so neither a separate C translation nor reliable route time/cost comparisons are claimed. No route winner has been selected.

The prior local-browser preview restriction still applies to B. No alternate renderer was used to bypass it. Re-running `node game/tools/pilot/prepare.mjs` deliberately refuses to overwrite existing pilot work.

## Continue safely

Re-discover Studio sessions and confirm the local BallVsSpace file before sync. Session IDs and cached tool titles can become stale: the 20 October save check identified the actual primary file through its window path, then verified PlaceId/GameId 0 and all 42 sources. The local CLI requires the real LOCALAPPDATA; the sandbox redirects it, so authorized Studio commands were run outside that redirection.

Follow the current [evidence index](../../test-evidence/README.md) and BUILD_STATUS resume step. The downloadable saved primary place is `game/places/BallVsSpace.rbxl`; `verify.ps1` refreshes it from canonical source. Preserve all twelve appearances, two kit mappings, selection/equipment, Store navigation and territory rules. Physical phone/gamepad tests and human acceptance are separate pending gates. Public release, purchases and new gameplay systems are outside this pass.
