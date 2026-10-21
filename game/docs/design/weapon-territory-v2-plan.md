# Ball VS Space weapon combat redesign proposal

20 October 2026. Initial design proposal, retained as the planning record. The user subsequently authorized implementation and local launch. See the [implemented v2 build](weapon-territory-v2-build.md) for actual mechanics, validation and remaining gates. Proposed abilities and acceptance criteria below are not a claim that every proposal has shipped.

Ball VS Space becomes a weapon combat and territory game with 30 original ball heroes. A hero's weapon geometry, spin, damage and automatic ability determine how it fights and takes space. The existing twelve appearances and their two shared kits are retired from the new roster.

The user has chosen **KO before the timer; territory at the timer; health breaks an area tie**, **original named heroes inspired by myths and historical weapon styles**, and **free movement across the whole arena with capture driven by weapon contact**. The user subsequently authorized local implementation, UX review and launching the build. Names, numbers and abilities below remain tunable design decisions, not measured reference stats or proven balance.

## What changes and what remains useful

| Current implementation | Proposed replacement |
| --- | --- |
| Twelve appearances map to Drift or Anchor | Thirty character IDs with distinct weapon definitions and abilities; cosmetics belong to a character |
| A broad brush follows the ball's movement | Only the swept active weapon geometry and explicitly marked abilities claim cells |
| Weapon spin is largely presentation | Server-owned weapon angle, spin rate, attack windows and contact history |
| No combat HP in Ball state | Health, shields, damage, healing, KO and bounded status effects |
| Area result at 30 seconds, then territory overtime | Early KO; proposed 45-second cutoff; area then health then draw |
| Large bodies, current radius 5.9 | Test a smaller equal body radius, initially 3 studs, with clearly larger weapon reach |
| Dark court, large side avatars, percentages on balls, heart motifs | Centered studded board, compact hero HP panels, readable territory score and separate round markers |

Retain the 32×32 equal-cell board, integer counts, simultaneous maximum-per-team pressure, server authority, fixed-step simulation, snapshot recovery, aim validation, reusable lobby infrastructure and canonical Rojo source. The grid is still useful; the geometry feeding it must change.

The implementation uses `bvs-rules-2-weapon` and `bvs-motion-3`. The original research specification remains historical evidence; the linked build record explicitly documents the approved replacement rules.

## Reference findings

The primary reference is [Elemental Armory League](https://www.youtube.com/@ElementalArmoryLeague). This pass inspected the channel and samples from [Territory War 112](https://www.youtube.com/watch?v=dfZ8YX5XOY0) at 0:00, 0:24, 2:02, 3:40 and 4:00, plus the pack's [opening frame](../../../Ball_VS_Space_Evidence/video-reference/upright_000.jpg) and [22-second frame](../../../Ball_VS_Space_Evidence/video-reference/upright_022.jpg).

Visible: distinct attached weapons, colored grid regions, overhead bars, changing weapon orientation and size, pickups/status messages, and fewer visible competitors in late samples. The channel describes weapon-ball battles and labels the video as animation. These samples establish presentation, not exact collision, damage, pickup, elimination or winner formulas. The final result was not established by these samples.

Balls appear within their corresponding colored regions in the samples. This suggests territory borders may constrain motion, but sampled frames do not prove the rule. This is a consequential design choice, separated below rather than assumed.

Adapt the readable rotating weapons, visible recapture and character identity. Author our own names, silhouettes, weapon designs, faces, effects, sounds and interface. Roblox-style studs are our proposed treatment of the grid, not a claim that the reference uses studs.

## Confirmed movement rule

Balls roam the whole arena, crossing friendly, enemy and neutral cells freely. They rebound from the outer walls and collide with other living bodies. Ownership boundaries do not block, slow, damage or redirect a ball. Losing the ground underneath a ball does not trap it or move it elsewhere.

Only active weapon contact paints territory. A special attack must define its visible active weapon or projectile footprint; body movement and decorative trails never claim cells. Preserve equal starting territory and mirrored weapon orientation. The existing symmetric spawn seeding is a setup rule, not a continuing body brush, and should be audited with the proposed smaller bodies.

This retains the existing solver's open movement model while replacing its capture input with weapon sweeps. Territory is the score surface, not a movement boundary.

## Proposed round and match rules

1. Choose a hero, aim the opening, then watch automatic combat. Keep manual combat inputs out of this first redesign so weapon behavior can be evaluated clearly.
2. Start the first pilot with 100 HP per ball. Shields are a separate, capped resource. Healing cannot exceed maximum HP; no resurrection in the pilot.
3. When one side has no living balls, the surviving side wins the round immediately. In 2v2, losing one teammate does not end the round.
4. Resolve all valid hits from the same simulation tick together. If both sides lose their last ball in that tick, the round is a draw, regardless of iteration order or territory.
5. Proposed battle length: 45 seconds, or 2,700 ticks at 60 Hz. At the cutoff, complete that tick's combat and territory resolution. A KO on that tick has priority over the area comparison. Nothing from the next tick counts.
6. If both sides survive, compare exact owned-cell counts. Even one cell wins; displayed rounded percentages never determine the result.
7. If area is exactly tied, compare remaining health percentage. Start with equal HP, but define the rule for future different maximum HP: sum each original team member's `remainingHP / maximumHP`, divided by original team size. Eliminated members contribute zero; shields are excluded. Use a specified fixed precision in the implementation rather than displayed percentages.
8. If both comparisons tie, draw. Recommend removing the old territory overtime to keep this hierarchy clear and bounded.
9. Preserve up to three rounds, a win worth one point and a draw worth half a point; stop at two points or compare after round three. A KO wins a round, not all remaining rounds of a match. Replace the old three-heart visual with honest round markers.

Owned cells remain after a ball is knocked out and can be stolen normally. The defeated ball stops moving, attacking and generating effects. Clear its remaining projectiles and persistent effects after its lethal tick in the baseline; death-triggered attacks would need an explicit later exception. No friendly damage. Friendly bodies can still collide. Owning 100% does not independently end the round under these rules.

Examples: 51% area with 10 HP beats 49% with 90 HP at time. Exact equal area with 60% remaining health beats 40%. An early KO wins even while trailing in area. A simultaneous final KO draws. In 2v2, one survivor at 100/100 HP and one eliminated teammate have 50% team health.

The 45-second timer is a tuning candidate, not a user-selected duration. Compare 30/45/60-second runs. Recalculate the match watchdog and reward eligibility when timing changes: the existing minimum battle-time reward threshold could incorrectly exclude a legitimate fast KO. Keep practice/test matches ineligible, and design fast-KO completion eligibility explicitly.

## Weapon and territory model

Each character definition owns a body size, travel speed, maximum HP, weapon geometry, weapon reach, spin rate, damage per valid hit, territory pressure, hit rearm rule and one signature ability. Body travel speed and weapon spin are separate stats. Decorative rolling never drives combat.

**Contact geometry must match what the player sees.** A spear's active tip makes a narrow sweep. A hammer head makes a shorter broad sweep. Twin blades make two short sweeps. A flail uses an articulated head path. Handles and chains can be inert, visibly distinguished from the active head. Do not give every weapon a filled circular hitbox equal to its reach.

Compute the sweep between previous and current authoritative weapon poses, including ball translation and spin. A fast weapon must not miss a target merely because it passed between rendered frames. A broad-phase bound can find candidates, but the actual tip, blade or head geometry must decide hits and cells. Rotational sweeps need bounded, tested subdivisions or an appropriate continuous test; joining two tip endpoints with a straight chord is insufficient for a large rotation.

The same authoritative geometry produces two different outputs:

- Weapon versus enemy body: a combat contact candidate, subject to shield, attack window and rearm rules.
- Weapon versus cell center: a territory pressure contribution for that interval.

Retain the signed influence range −3 to +3 and maximum pressure per team for the first prototype. Normal contact contributes 1; selected, telegraphed attacks contribute 2. Combine all contributions simultaneously at 10 Hz. No body brush, passive aura or automatic circle fill remains. Initial seeding is a separate setup rule.

This means a normal contact on reinforced enemy ground weakens it before stealing it. Four separated normal passes can take +3 through +2, +1, 0 to −1. A sweep can touch several cells, but repeated substeps or multiple allied blades do not add pressure on one cell within the same interval. Thin, fast weapons and slow, broad weapons therefore have different capture patterns without breaking team-union accounting.

Keep reinforcement visible with modest stud brightness/edge changes and a short tutorial. If testing shows this is too slow or confusing, evaluate immediate ownership as a separately versioned experiment. Do not silently switch to last-writer-wins painting or make the client decide ownership.

### Damage and spin

Use authored damage per contact. Faster spin primarily creates more attack opportunities and changes sweep coverage; it should not also multiply damage without a cap. The pilot uses fixed per-hit damage. A later spin-powered damage bonus must have an explicit ceiling and a reduced base damage budget.

Continuous overlap is one hit, not damage every frame. Rearm requires separation and a minimum per-attacker/per-target interval. A full revolution while still embedded does not automatically count as a new hit. Each multi-part attack shares an attack ID so trident tines or overlapping shapes cannot multiply the same impact accidentally. Twin blades can make distinct contacts only under their shared rearm limit.

Begin without general weapon-versus-weapon physics. Shield guards are explicit angular defenses; other weapons pass visually without a simulated clash response. Add parries or spin reversal only where a character explicitly owns that mechanic, with a distinct cue.

At each tick, collect contacts from all balls alive at its start, evaluate pre-existing guards, aggregate damage, determine lethal outcomes, then apply eligible heals to survivors. Healing cannot rescue a ball already reduced to zero by that tick's damage. Secondary triggered attacks start on a later tick and cannot recursively trigger an unbounded chain. Lifesteal is based on actual damage and has a per-activation cap.

## Thirty character concepts

These are working original names and fictional characters. Inspiration describes a broad mythic or weapon tradition, not a historical claim about a named person's equipment. A character must have a distinctive silhouette, active weapon shape, motion pattern, signature behavior and a weakness; a recolor does not qualify.

The ranges below are starting design bands. Reach is measured from the ball center to the outer active edge, not from the surface of the ball. Body radius starts at 3. Travel speeds initially stay close to 18 studs/s while weapon interactions are tuned.

| Weapon family | Spin in revolutions/s | Outer reach in studs | Damage per valid base contact |
| --- | --- | --- | --- |
| Spears and polearms | 0.65–1.0 | 8–10 | 12–18 |
| Heavy heads | 0.45–0.7 | 6–8 | 18–26 |
| Short blades | 1.1–1.6 | 4.5–6 | 6–10 |
| Chains and hooks | 0.65–1.0 | 7–10 | 10–16 |
| Guards and counters | 0.7–1.0 | 5–7 | 8–14 |
| Returning and unusual weapons | 0.8–1.2 while attached | 6–9 | 8–14 |

Thrown weapons need their own travel speed, lifetime and maximum distance; attached spin is not projectile speed. Every roster entry still has a visible attached weapon state, with a meaningful vulnerability while it is away.

| # | Hero and visual cue | Weapon and inspiration | Signature behavior | Tradeoff or counterplay |
| --- | --- | --- | --- | --- |
| 1 | **Astra Dawnward** — sun crest, determined eyes | Long spear; dawn champion | A clearly signaled third rotation extends the tip for one sweep | Narrow capture lane and an unprotected gap inside the tip |
| 2 | **Nerio Tideguard** — wave crown | Trident; sea guardian | Three separated tine tracks paint a fork; periodic tide thrust extends them together | Shared hit ID prevents triple damage; gaps between tines stay real |
| 3 | **Veyra Reedwind** — reed plume | Crescent glaive; wandering sentinel | Alternates a broad outward cut with a narrower return stroke | Predictable weak return arc |
| 4 | **Oren Peakwatch** — tall triangular helm | Long pike; mountain lookout | The tiny outer tip has a stronger precision hit than the inner head | Slow turn, narrow sweet spot and an inert shaft |
| 5 | **Sola Bannerheart** — small pennant | Banner lance; rallying standard bearer | Periodic planted tip briefly reinforces only the nearby cells its weapon already reaches | Loses mobile reach while planted; no large passive aura |
| 6 | **Bram Stormforge** — square brow, copper bands | Hammer; storm smith | Periodic charged hammer-head contact applies stronger territory pressure | Slow rotation and long intervals between clean hits |
| 7 | **Korra Flintcrest** — chipped stone crest | Broad axe; frontier champion | A clean enemy hit primes one wider next blade sweep | Width expires; misses provide no growth |
| 8 | **Dorrin Bellguard** — bell-shaped helm | Flanged mace; fortress keeper | A clean hit gives a short, bounded push along the contact normal | Short reach; push creates no invisible extra paint |
| 9 | **Tala Sunsmith** — forge visor | War pick; forge guardian | Pick head strips reinforced enemy cells with stronger pressure | Tiny active head and weak fresh-space coverage |
| 10 | **Mako Stonewake** — stacked stone collar | Heavy maul; giant-slayer archetype | Telegraphs a pause followed by one heavy sweep | Stationary weapon wind-up leaves a clear opening |
| 11 | **Nix Quickstep** — split scarf | Twin daggers; trickster duelist | Two short offset blades create frequent separate contact opportunities | Low damage per hit and poor reach; shared rearm limit |
| 12 | **Iria Mooncut** — crescent fringe | Curved saber; moonlit duelist | Every few rotations the saber reverses spin after a brief tell | Reversal pause; no free damage from changing direction |
| 13 | **Zefi Silkstep** — ribbon crest | Bladed fan; court dancer | Fan opens into a wide short sweep, then closes into a thin fast sweep | Open stance loses spin speed |
| 14 | **Perri Ashwing** — feathered mask | Paired sickles; firebird guardian | A successful alternating left/right sequence primes one brief spin burst | Repeated hits from the same blade do not build the sequence |
| 15 | **Rook Lantern** — lantern visor | Short sword; night watch | Every fourth rotation projects one brief straight blade beam from the tip | Weak ordinary reach; beam direction is telegraphed and cannot track |
| 16 | **Kesh Suncoil** — spiral headband | Chain flail; desert champion | Head orbits between short and long reach on a visible cycle | Inert chain; long form turns more slowly |
| 17 | **Mira Thornline** — rose crest | Segmented thorn whip; garden warden | A traveling bend creates a curved thin capture path | Low direct damage; segment cap prevents unlimited collision cost |
| 18 | **Toren Anchorfall** — anchor crest | Chain hook; harbor defender | A clean hook hit briefly pulls along its current chain direction | Limited pull and cooldown; no indefinite pinning |
| 19 | **Vaska Rimebell** — frosted bell | Ball-and-chain; winter guardian | Heavy head contact briefly slows enemy weapon spin | Does not stop movement or stack freezes; low coverage rate |
| 20 | **Edda Starbind** — knotted star ribbon | Weighted cord; celestial knot-keeper | Two weights alternate a linked arc and an extended sweep | Cord is inert; both weights share a bounded contact budget |
| 21 | **Luma Aegis** — bright round brow plate | Shield and short spear; guardian archetype | A rotating frontal shield blocks a limited hit, then exposes a weak recovery interval | Limited guard angle and charge; short offensive reach |
| 22 | **Bori Hearthwall** — chimney crest | Buckler and mallet; hearth keeper | A successful block primes one reinforcing mallet contact | Slow expansion; block does not automatically claim a disk |
| 23 | **Cira Mirrorwake** — mirrored cheek plates | Reflector shield and baton; mirror guardian | Reflects one eligible projectile during a ready window | No reflection of melee or terrain effects; capped projectile ownership changes |
| 24 | **Fen Oathkeeper** — wolf clasp | Crossguard sword; oathbound knight | A visible facing guard reduces one hit and primes the next sword edge | Narrow timing and angle; plain damage outside the counter |
| 25 | **Runa Emberheart** — ember lantern core | Hooked sword; returning-flame archetype | A low-health clean hit heals a small capped amount once per cooldown | Short range; cannot heal from terrain, shields or lethal damage already received |
| 26 | **Ravi Sunwheel** — wheel crown | Returning disc; solar champion | Disc leaves the orbit on a short out-and-back track, painting only its blade path | Reduced defense and capture near the body while disc is away |
| 27 | **Tavi Twinflight** — paired wing crest | Two returning blades; wind messenger | Alternates outbound and returning lanes instead of throwing both together | Each blade has low damage and a bounded range |
| 28 | **Suri Cometcall** — star cap | Sling; sky traveler | Attached sling spins, then releases one visible shot that paints a narrow track | Telegraph and reload; one projectile active |
| 29 | **Enna Oakspell** — leaf hood | Forked staff; grove keeper | Staff-tip contact can leave one brief seed patch that reinforces its small footprint | Weak direct combat; patch expires and cannot multiply |
| 30 | **Pax Clockwork** — winding-key crest | Telescoping baton; ingenious artificer | Alternates long slow and short fast phases on a visible clock | Opponents can predict the next gap; cannot combine both strengths |

Proposed six-character pilot: **Astra, Bram, Nix, Kesh, Luma and Ravi**. First implement Astra and Bram as the two-client slice. The six cover narrow reach, heavy heads, multiple blades, articulation, defense and returning projectiles. All thirty remain the target; staged construction is a dependency order, not a reduction of the request.

Initial individual candidate stats for Astra/Bram: 100 HP each, travel speed 18 each, body radius 3 each; Astra 0.9 rev/s, reach 9, 14 damage; Bram 0.55 rev/s, reach 7, 22 damage. Tune active-head width and signature cooldowns using swept-area and hit-rate measurements before filling final numeric sheets for the other 28.

No permanent spin/damage snowball from every successful hit. Temporary boosts have explicit caps, expiries and nonstacking rules. Do not add random pickups to the first pilot just because they appear in the reference. Character kits must be understandable before introducing shared pickup variance.

## Centered Roblox presentation

Use a toy-arena direction: rounded original ball faces, chunky readable weapon silhouettes, molded plastic surfaces, bright team accents and a subtle stud pattern. Show the studded territory as the arena surface behind the fight; generic menu backgrounds can echo the pattern without pretending to be scored territory.

| Surface | Proposed treatment |
| --- | --- |
| Battle | Center the largest possible whole-board view; reduce giant side avatar panels and decorative margins |
| Top center | Large timer with round markers; two compact hero portraits with HP bars and numeric HP |
| Territory | Neutral studs visible from launch; team color and pattern on claimed cells; modest strength treatment |
| Score | One area bar with neutral share and two percentages; exact cell counts in the result |
| Ball labels | Small HP bar and identity marker; remove large ownership percentages drawn over the ball |
| Hero selection | Three large cards: name, visible weapon, spin/reach/power summary and one short ability sentence |
| Full collection | Thirty heroes grouped by weapon role; character details distinguish gameplay from cosmetic choices |
| Main menu | Centered Play and Practice, a clear Heroes entry, secondary options grouped away from the fight |
| Results | Explicit reason: Knockout, Most space, Health tiebreak or Draw; show area and health together |

Team identity controls floor ownership. In 2v2, teammates share a territory color/pattern; character identity lives in face, weapon, crest and portrait. A thirty-character roster does not require thirty ownership colors. A free-for-all would require a separate multi-owner territory schema and is not implicitly included.

Keep landscape as the current phone target, with 568×320 and 1920×1080 as useful edge layouts plus existing intermediate sizes. Touch actions should remain generous and spaced; passive HP/score labels need not be buttons. Preserve the tested modal dismissal, selection and safe-area fixes while replacing their visual style.

Compare two modest stud renderers on device: one shared repeated stud pattern with dynamic cell fills, and per-cell stud marks. Avoid 1,024 new animated 3D stud objects. Patterns, HP changes and capture feedback must remain legible under reduced effects and without color alone. Teach “Your weapon takes space. Knock them out, or own more when time ends.”

Concept review should show a battle, a three-card draft and the thirty-hero collection at small landscape and desktop sizes before replacing all existing UI. This planning pass does not generate final artwork or rewrite the approved Figma work.

## Engineering work map

| Area | Required work |
| --- | --- |
| `shared/BallCatalog`, `AppearanceCatalog`, `Types` | Separate CharacterDefinition, WeaponDefinition and cosmetic choice; add health, angular state, attack IDs and bounded statuses |
| New pure weapon geometry modules | Swept heads, blades, tips, articulated segments and projectiles, with identical gameplay and debug geometry |
| `SimService` | Keep fixed-step open-arena body motion; expose exact body segments; add authoritative spin and KO state; ownership never constrains motion |
| New combat service | Contact batching, rearm, guard, damage, healing, status bounds and simultaneous KO |
| `AbilityService` | Replace two kit branches with a bounded registry using shared weapon behaviors and per-character parameters |
| `TerritoryService` | Replace automatic body-path claims with weapon/effect claims; retain simultaneous pressure and count auditing |
| `RoundRules`, `MatchService` | Parameterized cutoff, KO priority, health tie, explicit result reasons, no old overtime under v2 |
| `Protocol`, `ReplicationService`, `MatchController` | Versioned motion and combat state; reliable HP/KO baseline and result; correct reconnect recovery |
| `BallRenderer`, `BallArt` | Independent body and weapon pivots; show authoritative angle/ability state and readable active edges |
| `TerritoryRenderer`, HUD, draft and collection | Stud surface, compact HP, character catalog and accurate area/health result copy |
| Profiles and rewards | Handle retired IDs safely; preserve currency/settings; update eligibility for valid fast KO matches |
| Tests and evidence | Extend existing Luau fixtures, Studio multiplayer checks and visual/device checks; record new rules version |

Do not interpolate an angle from 359° to 1° through a backward full turn. Replicate an unwrapped phase or rotation count with angular velocity and tick. Damage and KO cannot depend on a lossy motion packet. Render body, weapon, territory and combat events on the same presentation timeline.

Keep simulation and rendering independent. A future 3D mesh or a sharper atlas must not change a hero's reach, HP or collision shape. Reuse six weapon behavior families with authored differences, rather than thirty independent physics systems.

On a KO between scheduled territory updates, flush the accumulated valid weapon claims through that terminal tick once before freezing and publishing the result. Do not run a normal full-strength territory interval twice. At the regular cutoff the final combat and scheduled territory update must be resolved once in a specified order. Every result carries terminal tick, reason, counts, health and rules version.

For saved selections, maintain a documented legacy-ID migration table or use an explicit safe default. Do not pretend old Acid/Axe/other cosmetics are the new heroes. Current profiles are session-only, so there is no established production inventory migration to execute now. Inspect the real profile schema again before any durable migration work.

## Build order and acceptance

| Stage | Concrete deliverable | Gate before expansion |
| --- | --- | --- |
| Design review | Confirmed free movement and rule hierarchy; review six pilot concepts and UI direction | User authorized implementation; exact timers/stats remain tunable |
| Two-character kernel | Astra/Bram with original primitives, weapon sweeps, HP, territory and results | Two actual Studio clients complete matches; geometry, double KO and cutoff fixtures pass |
| Six-character pilot | Nix/Kesh/Luma/Ravi and small landscape HUD | All six mechanisms show clear strengths/weaknesses; understandable capture and result |
| Multiplayer reliability | Reconnects, degraded network, terminal snapshots; then 2v2 | Four real clients verify team KO, union territory, health tie and independent matches |
| Roster waves | Add six heroes per wave: 12, 18, 24, then 30 | Each hero has a model/portrait, numeric spec, ability tell, counterplay and deterministic fixtures |
| Presentation and balance | Full collection, onboarding, audio and polished stud arena | Human comprehension, phone performance and repeat-play evidence |

No public release or purchases are part of this plan. Existing infrastructure test results remain historical evidence for the old build and do not validate the new combat system.

### Tests that resolve the real risks

- Thin tips, fast rotation, high travel speed, tangencies, wall clipping, extended weapons, angle wrap, spin reversal, multiple heads and moving targets. Test against independent geometry expectations, not only against the implementation itself.
- Weapon visibly misses means no damage/capture; handle-only contact behaves as declared. A weapon passing between ticks still registers. A full bounding disk must not paint behind an unswept blade.
- Continuous overlap does not tick damage; separation rearms correctly; duplicate shapes and events do not duplicate a hit. No friendly damage. Guards use the incoming angle and their actual active interval.
- Both lethal contacts in the same tick draw; last-tick KO outranks area; next-tick damage is excluded; dead bodies/effects cannot act afterward. Healing, shields and projectiles respect the stated KO ordering.
- Territory pressure remains order independent, teammate overlap does not stack, counts sum to 1,024, and no body movement paints by itself. Terminal partial intervals are not processed twice.
- Changing ownership underneath or ahead of a ball cannot alter its motion. With weapon and body interactions held constant, board colors do not affect trajectories. Enemy and neutral ground produce no automatic damage or painting.
- Two clients agree on HP, weapon state, board and result under packet loss, late snapshots and reconnect. Four-client tests are required before claiming 2v2 works.
- Compare capture per second, unique enemy contacts, KO fraction, timeout fraction, lead changes and matchup extremes. Thirty characters imply 435 distinct unordered 1v1 pairs plus 30 self-matchups; report draw rates and mirrored sides. Automated seeds do not prove human balance.
- Human testers can identify who leads, explain what painted a tile, recognize a weapon's weakness and explain the result. Physical phone touch, performance and gamepad gates remain pending until exercised.

## Inspection record and next step

Read the handoff, build status, original specification, evidence gallery, current architecture/backlog and the relevant catalog, simulation, territory, rules and renderer sources. The current build has two gameplay kits, twelve appearances, one 1v1 arena and Practice; 2v2 and durable progression remain unfinished. Its actual body radius is 5.9, not the original research proposal's 1.5. Its court and territory are already rendered as 2D UI.

Receiving-machine check: Rojo 7.7.1, StyLua 2.5.2 and Selene 0.32.0 ran. A Lune shim exists but `lune --version` failed because this project's manifest has no Lune entry; standalone Lune tests were not available through that command. Studio MCP listed `BallVsSpace.rbxl`, reported an active Play session, and a targeted read-only call returned PlaceId 0 and the Shared container present. This was an inspection, not a new runtime test. The Play session was left running as found.

Next: execute the authorized UX review, then implement and validate the two-character experiment before expanding the weapon families and roster. Free movement is settled. Do not resume cosmetic expansion of the old twelve appearances as the next task. Launch the resulting local build after verification; public release remains outside scope.
