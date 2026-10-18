# Ball VS Space — everything for UI work

**Share this entire UI_HANDOFF folder, or upload UI_HANDOFF.zip.** The packet is self-contained for reviewing UI: guides, screenshots, reference comparisons, artwork and source context are included. If a chat cannot accept the ZIP, attach this file, the UI guide and the screenshots relevant to your change.

## Start with these

1. [UI_MAP.html](UI_MAP.html) — double-click to explore 15 screens and 50 labeled regions.
2. [UI editing guide](docs/ui-editing-guide.md) — what each frame does, UI vs Parts, and where to edit.
3. [Reference comparison](REFERENCE_COMPARISON.html) — current build beside the original screenshots.
4. [All visuals](ALL_VISUALS.html) — browsable index of every included image.
5. [CHAT_PROMPT.txt](CHAT_PROMPT.txt) — paste into another chat and replace the final line with your request.
6. [Replication starter skill](docs/skills/reference-ui-replication/SKILL.md) — the condensed method to improve over time.

## Folder map

| Folder | Contents |
| --- | --- |
| docs/ | Current UI guide, presentation notes, review, backlog and build-status snapshot |
| docs/history/ | Clearly dated 0.2 notes and earlier comparison |
| docs/reference/ | Original observation notes and findings |
| visuals/current/ | 34 current desktop, phone-emulated and lobby/world captures |
| visuals/reference/ | 48 original Ball VS Ball screenshots |
| visuals/territory-video-stills/ | 6 stills from the separate territory concept video |
| visuals/history/ | 9 older build images used by the historical notes |
| art/ | Original icons/balls as PNG + SVG, atlas metadata and pipeline notes |
| source/ | All 41 runtime Luau scripts, included so UI dependencies are available |
| source-art/ | Art generator and pinned dependency manifests |
| validation/ | Selected saved UI, asset and review results |

## Editing facts to carry into every chat

- **Screen UI:** match court, territory, ball images, menus, labels, icons and aim guide.
- **World geometry:** walkable lobby, kiosks, pads and props. Signs are world-attached UI.
- **ViewportFrames:** actual 3D avatars inside the HUD; ball components retain a 3D fallback behind loaded sprites.
- UI is generated during Play under Players → your player → PlayerGui. Changes made there disappear on Stop.
- Main UI source: [HudController](source/client/Controllers/HudController.luau), [LobbyPanels](source/client/Controllers/LobbyPanels.luau), [ReferenceUi](source/client/Controllers/ReferenceUi.luau), [ReferenceLayout](source/client/Controllers/ReferenceLayout.luau).
- Change both constructor and responsive layout where needed. Twelve cosmetic balls do not mean twelve implemented ability kits.

## Snapshot, not a second editable game

The canonical project stays in **game/src/**, **game/assets/art/** and **game/tools/art/**. These copies are for chat context and review. Request patches against canonical paths. [MANIFEST.json](MANIFEST.json) records every copied file's original path and SHA-256; [FILE_INDEX.md](FILE_INDEX.md) links every included file. A place build and the full video are intentionally not included. No credentials or local machine configuration are copied.

The current screenshots date from 17 October 2026. This packaging pass does not claim a new Studio test or exact visual identity.

To refresh from the main repository root after future UI changes:

```powershell
node game/tools/build-ui-handoff.mjs
```

The exporter refuses to overwrite a modified file from a previous packet; preserve those edits and apply them to canonical source first. It also creates game/UI_HANDOFF.zip for attachment.
