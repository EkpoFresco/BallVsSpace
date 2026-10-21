# Flat armory visual build — 21 October 2026

The user approved [direction A](../../assets/ui-concepts/weapon-heroes-v3/a-refined-six.png) and then authorized the build. Version `0.4.1-flat-armory` implements that direction across all 30 heroes and restores the earlier action-v1 menu styling. The weapon-v2 rules, damage, reach, spin rates, timers and wire formats are unchanged.

## Artwork

Plain colored balls have dark outlines, one shaded edge and a small highlight. Faces, crowns, helmets and the old capsule artwork are retired. Astra, Korra, Bram, Nix, Nerio and Kesh use the six approved concept colors. The remaining heroes retain their original palette.

The [editable vector source builder](../../tools/art/build-weapons.mjs) produces the [38-sprite atlas](../../assets/art/weapon-v3/weapons.png): thirty weapon heads, a shield, seed patch, grip, metal shaft, linked chain, collar, body and highlight. These are original production paths based on the approved direction, not copied reference-game sprites or crops of the concept board. Build with `node game/tools/art/build-weapons.mjs`; asset metadata is in [atlas.json](../../assets/art/weapon-v3/atlas.json).

[WeaponArt](../../src/client/Controllers/WeaponArt.luau) assembles the same sprites in portraits and combat. Heads follow shared geometry, including projectiles, changing reach and width. Grips and chains are inert. Shields fade during recovery; reinforcing heads receive a warm tint. [HeroPortrait](../../src/client/Controllers/HeroPortrait.luau) keeps the body circular in rectangular UI slots, fits each whole weapon assembly, and renders the body separately from the rotating weapon.

Damage and paint still use the existing swept-capsule approximation. Sprite bounds match each active capsule's center, length and width; the collision is not per-pixel. Cosmetic cutouts, blade tips and spikes do not create new damage rules. The shield represents the existing directional guard, with no painting or damage of its own.

The atlas is `rbxassetid://77146942181804`; the existing project icon atlas remains `rbxassetid://105537358583136`. Both preload through Artwork. No experience was publicly published. Initial upload processing briefly returned a failed fetch before the new atlas became available; final checks require visible ImageLabels to report loaded, not merely a successful upload response.

## UI restoration

Charcoal surfaces, magenta headers, mint primary actions, cream showcases and Montserrat heavy italic headings match the earlier approved action-v1 design. Existing responsive layout, modal handling, selection state, real server offers and the 30-hero scrolling roster remain. The arena backdrop now uses the same charcoal palette; the studded territory board and team colors remain.

## Verification and next work

See [current evidence](../../test-evidence/README.md) for final results and captures. The new art review renders all 30 assemblies in three native Studio sheets, checks circular bodies, loaded sprites, the restored palette and heading style. The expanded weapon fixture checks 90 poses, including extensions, powered heads, projectiles and spent shields.

Human acceptance of the implemented artwork, broad matchup balance, physical-phone touch/FPS and gamepad checks remain open. Existing Figma frames preserve the earlier menu design; this sprite/implementation pass does not claim a new Figma roster transfer. Additional Elemental Armory channel browsing was throttled, so the approved concepts and the pack's existing image/video evidence remained the visual inputs.
