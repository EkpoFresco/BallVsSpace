# Flat weapon atlas

Original project artwork for the approved flat-ball direction, generated from editable SVG path definitions in [build-weapons.mjs](../../../tools/art/build-weapons.mjs). Run that script to reproduce `weapons.svg`, `weapons.png` and `atlas.json`. No reference-game sprites are embedded.

The current Roblox image is `rbxassetid://77146942181804`, uploaded 21 October 2026. [WeaponArt.luau](../../../src/client/Controllers/WeaponArt.luau) owns the runtime binding. A rebuild changes local files; it does not update the uploaded image automatically. Upload a changed atlas, update that binding and verify actual image loading in Studio.

Eight columns of 128-pixel cells. Weapon/source rectangles use the top 128×64 region; Body and Glint use 128×128. Padding keeps adjacent rows from bleeding into scaled sprites. `atlas.json` records exact rectangles. Runtime weapon slots stretch the normalized silhouettes to authoritative capsule bounds. Grips, chains and body highlights remain separate layers.

The six-character approved concept remains under [weapon-heroes-v3](../../ui-concepts/weapon-heroes-v3/a-refined-six.png). Native roster captures and test results are indexed in [test evidence](../../../test-evidence/README.md).
