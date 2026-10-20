---
name: roblox-ui-pipeline
description: Turn an approved GPT visual reference into editable Figma screens and native Roblox UI, then refine it through rendered scaling and interaction checks.
---

# Reference → Figma → Roblox

1. Read the project status and approved reference. Preserve approved inputs and canonical artwork; separate new refinements from historical proposals. Identify the existing screens and interactions before adding UI.
2. Verify Figma access with an actual read/write, and identify the intended Studio place. Use the available Figma and Roblox skills for their tool/API details. An installed plugin or generated build is not runtime evidence.
3. Build editable Figma frames with reusable colors, typography and components. Match the reference with real project assets. Inspect rendered frames, including long labels and alternate states; a flattened screenshot is reference material, not editable implementation.
4. Implement in the canonical Roblox source. Use supported font families and real weights, readable body text, device-safe insets and stable selection/equipped states. For landscape games, retain the horizontal composition on phones. Let artwork, columns and scrolling adapt before shrinking text or essential actions.
5. Render every screen at small landscape phone, notched phone, tablet and desktop sizes, including resize round trips. Measure effective font and target sizes, text fit, bounds and overlaps. Aim for body copy around 13–16 pixels and touch actions at least 44 pixels. Keep important actions reachable and clear of Roblox controls. Inspect screenshots; geometry alone misses visual collisions.
6. Exercise real clicks/touches, scrolling, close/back routes and a complete game flow. Check font/art loading, settings, repeated opens and stale-state races. Treat isolated layout fixtures, live input, multiplayer and physical-device performance as separate evidence.
7. Review the code after refinement. Remove dead UI, duplicated styling and obsolete layout branches; clean up external event connections. Run the relevant static/build checks and affected runtime tests again. Update Figma refinements, project status and concise evidence with exact limits—do not call untested scales or physical devices passed.

Keep one current design and implementation source of truth. Record fixes and useful receipts without accumulating approval gates, duplicate instructions or speculative features. Continue within the user's existing authorization.
