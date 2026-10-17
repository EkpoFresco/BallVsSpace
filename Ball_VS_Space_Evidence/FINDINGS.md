# Live test findings and build handoff

16 October 2026 · [Full specification](../BALL_VS_SPACE_RESEARCH_AND_BUILD_SPEC.md) · [Screenshot gallery](README.md)

The research now includes direct 1v1 and 2v2 observations. It gives an implementation agent a much stronger reference for the visible game loop and presentation. It cannot reproduce undisclosed physics, ability formulas or balance exactly, and no Ball VS Space build has been made or tested yet.

## What was actually tested

Across the recorded sessions, the account completed five 1v1 matches with varying observation gaps and one five-round 2v2 match. Two initial duels were sampled in every round. The team match was sampled in all five rounds, including its final loss panel and lobby return. These are screenshot observations, not continuous recordings.

The folder contains **48 live screenshots**, the original supplied video, **six upright video frames**, two observation logs, public metadata, the supplied brief and integrity hashes. The territory video is a separate reference, not footage established to be Ball VS Ball.

## Findings that matter for the build

| Finding | Design implication |
|---|---|
| The reference uses choose → aim → automatic HP fight → life loss. Three lives were visible; five-round matches occurred. | Ball VS Space's timed territory scoring and three-round format are intentional design changes. Do not accidentally implement HP elimination because it appears in screenshots. |
| 2v2 has a Lv 5 entry gate, a portal, and a direct button beside Play. Entry succeeded later. | Keep mode selection visible and any unlock condition clear. |
| Four balls share a court; friendly aim arrows are visible together and each ball has its own HP. | Preserve teammate coordination cues, clear ball identity and whole-court framing. |
| A ball can disappear while the team fight continues. After a team loss, both teammates lose a heart by the next draft. | Model individual ball state and team result separately if building an HP variant. The proposed territory game keeps both balls active. |
| Beams, rings, projectiles and damage numbers can obscure each other. | Enforce effect budgets and keep the territory score legible. |
| WDC creates a numbered court grid; its description links the cell number to damage. | This is not evidence of territory victory in the reference. |
| The sampled team loss raised the visible balance by 30 coins. Collection and store screens show ownership, variants, paid choices and disclosed gacha odds. | Use the screenshots as economy/UI observations. Ball VS Space retains its original all-kit access and cosmetic progression decisions. |

## What remains uncertain

- Exact movement, collisions, masses, damage, healing, cooldowns and balance formulas.
- Reliable automated aiming, touch controls, continuous phase timing and live audio.
- Friendly fire, ties, simultaneous defeat, reconnects and partner disconnects.
- XP rules: the result briefly displayed Lv 1→2 while the lobby displayed Lv 6 Reward after the Lv 5 gate had been cleared.
- Repeatability across more team matches and devices. One completed team sample is not a validation suite.

## Tools used

The live test used the Computer Use plugin to inspect and operate the native Roblox Player through screenshots and normal inputs. Some later team-round inputs were manual and are explicitly identified in the notes. Public web research and local video analysis supplied separate context. No Roblox Studio MCP connection, private game scripts, hidden runtime state or creator analytics were available.

For implementation, start with the specification's small playable territory slice and validate it in Studio. A prompt plus these materials can guide a faithful adaptation of the visible structure; playable iteration is still needed to reproduce the desired feel.

## Start here in the evidence

- [Level gate](live-screenshots/L2-003-2v2-level-gate.jpg), then [successful team lobby](live-screenshots/L2-026-2v2-lobby-loaded.jpg).
- [Team draft](live-screenshots/L2-028-2v2-first-draft.jpg), [aim](live-screenshots/L2-029-2v2-aim-four-balls.jpg), [individual HP](live-screenshots/L2-031-2v2-distinct-health-and-effects.jpg).
- [Teammate life counts after a loss](live-screenshots/L2-034-2v2-round-two-lives.jpg), [final result](live-screenshots/L2-042-2v2-final-result-loss.jpg), [lobby reward delta](live-screenshots/L2-043-2v2-lobby-result-balance.jpg).
- [Effect-density example](live-screenshots/L2-041-2v2-final-round-effect-density.jpg), [WDC description](live-screenshots/L2-046-wdc-description.jpg), [store odds](live-screenshots/L2-048-gacha-prices-and-disclosed-odds.jpg).
