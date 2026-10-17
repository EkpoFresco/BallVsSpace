# Reference visual reconstruction — 0.2.0-reference

**Historical 0.2 record.** The current 0.3 work and validation are described in [presentation.md](presentation.md), with the [new comparison](../test-evidence/presentation-comparison.html). The unfinished items below describe the earlier baseline.

The user's current priority is reconstruction before differentiation. This pass replaces the previous small-ball presentation. The [six-phase comparison](../test-evidence/replica-comparison.html) provides matched-viewport pairs and an opacity slider; original reference files are unchanged.

October 17 update: the settings font glyph was replaced by an eight-tooth gear, the plain rotated-square gem by a five-facet cut gem, and the overlapping heart pieces by a continuous silhouette. These were inspected against L2-013 and L2-007. [Current lobby](../test-evidence/handoff-ui-03-lobby-0.jpg), [aim](../test-evidence/handoff-ui-15-aim-0.jpg) and [territory battle](../test-evidence/handoff-ui-20-territory-battle-0.jpg) show the update. These captures include Studio display scaling; the six-phase comparison remains the dated October 16 baseline. Typography, icon edge smoothing, store/inventory detail, missing authored top-bar controls and panel styling still need work. This is not 1:1 acceptance.

The capture grid and area scores are now on by default. The lobby gear can turn them off for reference comparisons. The live UI test independently counted visible cyan/coral tiles and matched those counts to the displayed area percentages; it also exercised both settings states with actual clicks.

## Implemented and inspected

| Surface | Current reconstruction | Remaining difference |
|---|---|---|
| Match court | Frontal 512×510 navy frame, 446×446 playfield, mitred bevel, inner shadow, sky backdrop | Lighting, sky cloud placement and surrounding world are approximations |
| Balls | Acid spots, luminous Axe seam and spinning curved blade, Cell membrane, Poison shell; 82.23-pixel main diameter | Original primitives approximate the source meshes/textures; full catalog is absent |
| Player display | Account avatars, profile portraits, side kit previews, red hearts | Practice opponent uses a generic rig; avatar appearance naturally differs by account |
| Draft | Three 132×212 cards, live square previews, outlined names/descriptions, All Balls and reroll controls | Seven appearances map to two actual territory kits; reference has a larger roster |
| Aim | Large white dashed arrow with triangular head, upper countdown, gold Lock Aim | Direction depends on the actual player's input; original hidden launch physics is not measured |
| Battle | Large moving bodies, rotating weapon, green bubble/white spark trails, outlined central labels | Labels are actual territory %, not reference HP; no copied damage system |
| Collection | Working modal with seven free appearances; layering and selection tested | All seven icons work; the catalog remains smaller than the full reference roster |
| Results | Purple striped panel, gold crown, real winner avatar, scores and rematch | 1v1 result composition; no reward animation or 2v2 team display |
| Lobby | Walkable blue plaza, kiosk, floating gold signs, arena rows, purple prop, Play/Practice, store/inventory/emotes, practice checklist | Environment is less detailed than the reference; party/trade/economy systems remain later work |
| Phone layouts | Court scales to the viewport; side avatars hide in portrait; primary control grows | Emulator-only checks; real touch, device performance and full accessibility acceptance remain pending |

## Evidence and limits

The `replica-release-*` captures show the final desktop art and compact collection. `replica-polished-*` preserves the preceding pass. `replica-final-*` documents the earlier full click-through regression; `replica-flow-*` retains the failed collection-stacking attempt. The latest full Practice run completed normally at tick 1800 with `match_points`. Desktop Settings clicks verified both territory-overlay and reduced-motion toggles. Successful phone layout evidence uses `replica-layout-*`; `replica-mobile-*` retains the unsuccessful MCP mouse-click attempt in phone mode. The final layout test used real desktop clicks before switching to phone views. Touch acceptance is not claimed.

A fresh two-client match had six matching server/client result checks and six correct appearance checks, with zero aborts or failures. Ten core logic groups and 400 mirrored-fixture rounds passed with the larger collision geometry. These establish implementation behavior, not a subjective fidelity score. No pixel-perfect or human acceptance claim is made.

The comparison deliberately shows all remaining differences. It must not be described as a complete clone of the original catalog, lobby or combat rules. The next visual refinement should target the lobby's prop density and lighting, then ball mesh/texture detail, using the comparison as the review baseline. The full original game specification remains unfinished.
