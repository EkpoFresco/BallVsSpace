---
name: reference-ui-replication
description: Reconstruct a game's visible presentation from screenshots and recordings, then compare it in the running build. Use for reference matching, UI anatomy, and visual fidelity passes before design differentiation. Distinguish observed presentation from inferred behavior and unrecovered source or physics.
---

# Reference UI replication — starter skill

## What worked on Ball VS Space

We rebuilt the visible composition from the supplied screenshots and video: measured framing, separated rendering layers, authored consistent symbols and shaded ball images, then compared actual Studio screens against the references. Earlier primitive balls and rough symbols captured the idea but missed the silhouette, scale and finish. A shared art atlas and repeated same-state comparisons improved those details.

This was **visual reconstruction**, with original code and art. REA was reviewed as a reference; it was not used to extract the original game's source or binaries. Hidden physics, exact meshes, animation timing and pixel-perfect equivalence were not recovered.

## Repeatable process

1. **Collect states before building.** List lobby, menus, selection, aim, battle and results. Save reference images and identify viewport size, camera, selection and phase. Label evidence as observed, inferred or unknown.
2. **Measure the composition.** Record court bounds, ball diameter, margins, panel sizes, typography and icon silhouettes on one design canvas. Match major proportions before polishing small details. Ball VS Space uses an 803×602 canvas; that is a project measurement, not a universal preset.
3. **Choose each rendering layer deliberately.** Separate world geometry, screen UI, world-attached UI and 3D previews inside UI. Here the match court and territory are Frames; shaded balls are atlas images with a 3D fallback; side avatars use ViewportFrames; the walkable lobby uses Parts.
4. **Build shared visual primitives.** Centralize fonts, outlines, gradients and button treatment. Author consistent icons and ball art in a reproducible pipeline. Avoid substituting unrelated font glyphs for distinctive reference symbols. Keep source assets editable.
5. **Wire real states and actions.** Implement opening, closing, selection, confirmation, waiting and results. Keep server rules separate from presentation. A cosmetic ball does not imply a recovered ability; an attractive store does not establish purchases.
6. **Compare the running build.** Capture the same state at a comparable viewport. Use side-by-side and overlay views; prioritize framing, silhouette, layering, then fine detail. Check that images actually loaded. Repeat after each focused correction. Keep original references untouched.
7. **Verify interaction and hand off.** Exercise real clicks, portrait/landscape layouts and input alignment. Check cleanup, repeated rendering and multiplayer consistency where affected. Record remaining differences honestly, preserve screenshots and map visible elements to editable source.

## Keep improving this skill

For each iteration, add one concrete mistake, its fix and a before/after capture. Keep measured facts separate from subjective acceptance. Stop expanding the checklist when a short example explains the lesson better.

Project example: [UI editing guide](../../ui-editing-guide.md) and [reference/current comparisons](../../../test-evidence/presentation-comparison.html). This is a portable project-local draft, not an installed global skill.
