> Historical 0.2 notes. Use the current UI guide and presentation notes for today's renderer.

# Reference reconstruction pass

The user's 16 October direction supersedes the earlier presentation schedule: reconstruct the reference appearance first, then differentiate. Visual work is active now; it does not wait for M1 human testing. Original territory scoring remains the running game underneath the presentation.

Primary visual evidence: L2-006 draft, L2-007 aim, L2-008 combat, L2-011 collection, L2-013 lobby, L2-042 results. Images remain research, never flattened into the playable UI.

Measured target at the 803×602 game viewport (excluding Windows title bar): outer court x145–657, y45–555, 512×510; inner court about446×446; sphere diameter82, 18.4% of inner width; top countdown at y21; aim button centered at y469. Draft: three 132×212 cards centered across the court, white outlined names and short descriptions, square gray model previews, purple controls beneath. Match: sky backdrop, player portraits at upper corners, full avatars on each side, three red heart shapes. Gold aim button 136×44. Reference-style typography and frame depth are essential.

Implementation direction: native Roblox GUI court with shaded bevels and live 3D ball ViewportFrames, original reconstructed Acid/Cell/Poison/Axe models, replicated appearance selection, real avatar models, dashed white aim arrow, reference-proportioned draft/collection/results, blue walkable lobby. A visible presentation setting can expose the existing territory visualization. No hidden reference physics or private source was obtained.

REA was reviewed at https://github.com/morluto/rea. Its code/binary and browser tooling does not provide the unavailable reference experience source; saved visual evidence is the reconstruction input for this pass. No REA installation or binary inspection was necessary.

The reconstruction is implemented in build 0.2.0-reference. The main sphere diameter is 82.23 design pixels on the 446-pixel court. Motion version 2 aligns collision radius with that presentation: radius 5.9, wall center bound 26.1, mirrored spawn ±19. Signed influence, union scoring and exact cutoff/overtime rules remain unchanged. Speeds and abilities are proposed game values, not measured hidden reference behavior.

Runtime verification: ten Studio logic groups, 200 mirrored pairs / 400 rounds, eight appearance/privacy/projection assertions, one fresh two-client match with six matching grid/tick comparisons and six correct appearance comparisons, and a complete Practice match through actual GUI clicks. Failed collection stacking, avatar bounds, late-input fixture and Studio rendering captures were diagnosed and retained separately. Static formatting, lint, strict type analysis and both Rojo builds pass.

The final comparison and remaining differences are documented in visual-fidelity.md and test-evidence/replica-comparison.html. This is a reconstructed visual baseline, not a claim that all reference content or proprietary physics has been recovered.
