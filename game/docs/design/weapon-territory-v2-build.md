# Weapon territory v2 — implemented build

The rules below remain current. Presentation is superseded by the [flat armory v3 build](flat-armory-v3.md), version `0.4.1-flat-armory` with 43 scripts. The dates and validation scope below record the original v2 implementation.

20 October 2026. Local playable build `0.4.0-weapon-heroes`, rules `bvs-rules-2-weapon`, motion `bvs-motion-3`. The user approved implementation, UX review and local launch after the [planning pass](weapon-territory-v2-plan.md). The canonical saved place is [BallVsSpace.rbxl](../../places/BallVsSpace.rbxl); source is under `game/src/` with 42 Rojo-managed scripts. The original research/evidence is preserved.

## Play and win

Use Practice for a bot match, or queue two local clients. Choose one of three offered heroes, or spend the single match wildcard in All Heroes. Lock an aim direction. Balls then move and bounce automatically throughout the arena; territory ownership does not constrain movement.

Every hero starts with 100 HP, a 3-stud body radius and 18-stud/s movement. Only active weapon blades/heads, projectiles and explicitly visible ability footprints paint. Bodies, inert handles, shields and decorative effects do not. Equal starting territory is seeded before combat. The signed 32×32 influence grid, maximum pressure per team and team-union scoring remain; enemy ground must be neutralized before it changes ownership.

A KO ends the round early; simultaneous lethal hits draw. Otherwise the round ends at 45 seconds: more territory wins, then greater remaining health, then a draw if both are equal. There is no territory overtime. Matches retain the existing best-of-three points format: a win is one point and a draw half a point, with an early finish at two points. Final score and result reason are locked by the server.

## Thirty original heroes

These are original primitive portraits and weapon silhouettes, with distinct geometry, spin patterns, hit values and automatic abilities. They replace the former appearance-to-two-kit mapping. Names and tuning are design choices, not reference-game measurements. The source of truth for current values and player-facing descriptions is [HeroDefinitions](../../src/shared/HeroDefinitions.luau).

| Family | Heroes | Implemented differences |
| --- | --- | --- |
| Polearms | Astra, Nerio, Veyra, Oren, Sola | Extending spear, three tines, alternating crescent, long damaging pike tip, periodic reinforcing lance tip |
| Heavy | Bram, Korra, Dorrin, Tala, Mako | Charged hammer, widened axe after a hit, outward velocity bend, high-pressure narrow head, windup and release |
| Fast | Nix, Iria, Zefi, Perri, Rook | Paired daggers, pause/reversal, fan width/speed cycle, hit-triggered spin burst, extending blade |
| Flexible | Kesh, Mira, Toren, Vaska, Edda | Long/short flail cycle, bent whip segments, inward velocity bend, temporary spin slow, alternating weighted ends |
| Guards | Luma, Bori, Cira, Fen, Runa | Recovering directional guard, guarded-hit pressure bonus, projectile deflection, guarded-hit damage bonus, low-health hit healing |
| Ranged and unusual | Ravi, Tavi, Suri, Enna, Pax | Returning disc, paired returning blades, outbound projectile, visible pressure patch, telescoping blade |

Implementation details matter when comparing with the proposal: Cira cancels a guarded projectile rather than reflecting a new projectile; Tavi launches two opposite blades together; Sola's reinforcing tip remains attached; Rook's extension remains attached; Enna's visible patch paints but does not damage. These bounded versions are the current implementation. There are no collectible weapon upgrades or pickups.

The four directional guards reduce one eligible hit, then recover for two seconds; their arc becomes translucent while recovering. Runa instead heals five HP from a qualifying clean hit when at or below 40 HP, at most once per three seconds; healing cannot undo a lethal hit. Multi-edge weapons share hit cooldowns and require separation before another contact episode. Haste/slow effects are bounded and do not stack indefinitely.

## Simulation and presentation

The server advances motion and weapon angles at 60 Hz. Combat samples the actual collision-split paths, then applies gathered hits together. The same capsule geometry drives painting, damage and visible weapons. Territory resolves at 10 Hz, with a final partial interval flushed on KO. Snapshot ticks identify the last resolved territory state, including snapshots sent immediately after a health change.

Spin accumulation is independent of starting orientation, so mirrored sides enter charged cycles together. Weapon state, HP, projectile origin and status timers replicate with a versioned motion payload; reliable state supplies authoritative HP after dropped motion packets. The old Drift/Anchor runtime modules are removed.

The arena has a quiet studded background, cyan/coral territory, centered controls, compact HP panels and original hero portraits. All 30 heroes are reachable in scrolling Inventory and wildcard selection. Draft shows the actual server offers; the obsolete cosmetic reroll is hidden. Results show the deciding metric: HP for KO/health decisions, percentages for area, and points for the whole match. Replay uses recorded poses without reopening the result.

UX review corrected detached weapon rendering, portraits obscuring their weapons, the obsolete reroll overlap, clipped short-screen help, replay bodies disappearing and HP decisions displaying area percentages. Reference ball artwork is no longer loaded by the roster; the project's existing UI icon atlas remains.

## Validation and remaining work

Current test receipts are indexed in [test evidence](../../test-evidence/README.md), with exact reproduction commands in [testing](../testing.md). Engine tests, actual mouse input, emulated layouts and visual inspection are separate evidence categories. The original v1 receipts remain historical.

This is a playable first tuning pass. Sixty mirrored accelerated rounds check determinism and side symmetry; they do not establish balance across all 435 distinct pairings, angles or player strategies. Physical phone touch/FPS, gamepad and human play acceptance remain pending. The original primitive heroes were rejected and replaced in the linked v3 visual pass; audio and a broader balance pass remain future work. No public release or purchases occurred.
