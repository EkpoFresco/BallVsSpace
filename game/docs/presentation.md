# Presentation reconstruction — 0.3

The [current comparison](../test-evidence/presentation-comparison.html) pairs eight live Studio surfaces with untouched reference evidence and includes phone captures. The project prioritizes matching the recorded presentation before further concept changes. All runtime art is original; the reference's private models, source and hidden physics were not recovered.

## Implemented presentation

| Surface | Implementation |
| --- | --- |
| Court | Measured 512×510 navy frame, 446×446 playfield, mitred bevels, inner shadows and sky backdrop |
| Balls | Twelve shaded atlas portraits, Acid spots, luminous Axe/Blade seams, separate rotating weapons, Cell membrane and other collection surfaces; 82.23125-unit main diameter matches the solver |
| Symbols | 32 antialiased authored symbols: continuous hearts, faceted gems, gear, store, inventory, gifts, invite, crown, emote and category art |
| Draft and aim | Three cards, actual reroll, private opponent choice, twelve-ball compact selector, dashed arrow and gold Lock Aim |
| Inventory | Illustrated tabs, scrolling collection, selected outline, large detail preview and functional Equip feedback |
| Store | Daily offers, collection spotlight, balance treatment and working navigation to ball/cosmetic previews |
| Utilities | Rewards, mode selection, instructions, emotes, invitations and explicit trade availability; real emote/invite APIs where supported |
| Results | Purple striped panel, proportioned crown, actual winner avatar, local victory/defeat, area totals and rematch |
| Lobby | Blue plaza, detailed collection kiosks, framed arena pads, instructional boards, illuminated portals and normal proximity prompts |
| Phone | Inventory details stack below the collection; Store reflows to two columns; bounded panels, larger actions, court/aim mapping and visible invite access |

[Editable art and its generator](../assets/art/README.md) are included. Cell clipping prevents icons bleeding into adjacent atlas rectangles. Native Roblox controls and participating avatars belong to the platform/account and are not impersonated with copied UI.

## Deliberate game differences

- Balls report owned territory, not reference HP. The grid and area totals are on by default; View Settings can hide them for composition comparisons.
- Twelve appearances map to **two** territory kits. Names and silhouettes do not imply twelve recovered reference abilities.
- Descriptions, free-collection buttons and session quests describe actual behavior. Trading, fusion, purchases, durable rewards and 2v2 are not presented as implemented systems.
- Hearts show remaining rounds. Victory follows the specification's territory/round rule.
- Phone layouts reflow for readability instead of shrinking the whole desktop store.

Reference lighting, cloud placement, individual mesh/weapon curves, original animation timing and full catalog are not exact recoveries. No measured source-physics equivalence or pixel-perfect acceptance is claimed. Original research and the distinction between observed and proposed values remain intact.

## Runtime evidence

- `visual-v3-acceptance-result.json`: real menu clicks, equipment, store navigation, queue/cancel, private draft, shell diameter and complete Practice match at tick 1800 with `match_points`.
- `visual-v3-layout-final-result.json`: portrait/landscape bounds, 44.32–50.65 UI-pixel tested targets, successful phone-emulated close input, reroll, court bounds and aim mapping. Physical touch and device performance remain unvalidated.
- `visual-v3-world-result.json`: Store/Inventory/duel selection and Practice portal through normal E input after documented character-placement setup.
- `replica-v3-core-tests.json` and `replica-v3-contract-tests.json`: ten core logic groups and eight appearance/privacy/projection contracts.

Failed attempts remain preserved: hidden-image loading assumptions, selectors conflicting with Instance properties, a Play event/window name collision, overly broad draft privacy assertion, test-runner table serialization, and a stale result-phase assertion. Corrected reruns above establish the results; failures are not counted as passes.

The [0.2 comparison](../test-evidence/replica-comparison.html) remains historical. Review findings, optimization measurements, multiplayer results and final repository state are recorded in BUILD_STATUS and the code review report.
