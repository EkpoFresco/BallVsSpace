# Armory UI icons and board studs

Original SVG artwork authored in [build-icons.mjs](../../../tools/art/build-icons.mjs), using the flat heroes' dark outlines, cream, steel, gold, mint and coral. No reference-game artwork is embedded. Run `node game/tools/art/build-icons.mjs` from the repository root to reproduce these SVG/PNG files and the atlas manifest (requires `@resvg/resvg-js`).

The 32 icons occupy 128-pixel cells in a 1024×512 atlas. [atlas.json](atlas.json) records their rectangles. The transparent 1024×1024 stud image contains a 32×32 pattern aligned with the ownership grid. A single image replaces decorative per-cell Instances; ownership colors remain native GUI cells underneath it.

Uploaded 21 October 2026: icons `rbxassetid://90376324892151`, studs `rbxassetid://77193408549941`. [Artwork.luau](../../../src/client/Controllers/Artwork.luau) owns the bindings and preload list. Rebuilding the local files does not update uploaded assets: upload replacements, update the bindings, and verify loading in Studio.

See the [polish review](../../../docs/design/armory-polish-v4.md) and [runtime evidence](../../../test-evidence/README.md).
