# Follow-up visual evidence session — 16 October 2026

Times in the screenshot manifest are UTC; subtract four hours for EDT on this date. Screenshots are preserved only after visually checking that they show Roblox. A capture returned the foreground Codex app before Roblox activation; it was excluded from the evidence library.

## Confirmed 2v2 entry and access gate

- The user navigated the avatar to the mode selector and handed control back. The walking route from spawn was not recorded.
- L2-001 shows Select Mode, 1V1 and 2V2 cards, a My Party 1/4 panel with addition slots, and a message that the party will teleport together. No party invite was sent.
- Selecting 2V2 briefly displayed Teleporting (L2-002), then a modal stating **2V2 unlocks at Lv 5** (L2-003). The teleport did not complete. This resolves the entry location but does not validate 2v2 gameplay.
- L2-004 shows the glowing 2V2 portal between leaderboard displays with an E interaction prompt.
- The follow-up balance was 730 coins / 0 diamonds versus 430 / 0 at the earlier handoff. Intervening actions were not observed; do not attribute that difference to a specific match reward.
- The Lv 5 Reward label was visible, but clicking it did not reveal an XP meter in the sampled screens.

## Capture method

Native Player screenshots are original returned image files, with timestamped captions in manifest.json. They are point-in-time samples, not continuous video or audio. The original supplied video and selected upright frames remain a separate reference source. No reference assets were extracted from game files.

## User pause and later resume

The user stopped Computer Use and requested a pause during the fourth account match. At 23:17:59 UTC (19:17:59 EDT), after an explicit request to continue, the lobby showed 4/10 plays and 3/3 wins. The balance was 1470 coins / 0 diamonds. Remaining fourth-match rounds, result and intervening account changes were not observed. L2 numbering continues across this documented gap; timestamps identify each capture.

- Resumed match (fifth account match): draft offered Poison Spike, Axe, Burst. Chose Burst against Orbit. Later hearts showed local two/opponent three, so round-one loss is inferred; the exact result and next draft were missed. Round two Burst versus Ray ended with a camera shift toward the opponent; next draft showed two lives each, supporting a round-two win. Round three selected Poison Spike versus Thief. The offer set repeated in the sampled drafts. L2-016 records both launch directions and 100 HP each; L2-017 through L2-020 show Burst trails, Orbit satellites and Ray wall emitters/beam. L2-021 records the between-round camera shift.

- Fifth-match continuation: the third round was lost (one local life versus two opposing lives at the next draft). Round four was Poison Spike versus Ray; the attempted free Vampire selection was not confirmed before the deadline. The next draft showed one life each, supporting a fourth-round win. Round five selected Axe versus Blade. Its final combat/result was missed; the lobby then showed Play 5/10 and 1,570 coins, 100 above the pre-match balance. This is a balance delta, not a verified payout formula. The overhead crown counter was two, but was not used as a level indicator.
- Free WDC and Blade Ball Receive cards appeared in sequence and were collected. The next reward label changed to Lv 6 Reward. No currency was spent.

## Successful team entry and first 2v2 match

- At approximately 23:26 UTC the lobby's **2V2 button beside Play** opened Select Mode directly. Selecting 2V2 now completed a loading sequence, reaching a lobby with the switch button labelled 1V1. This supersedes the earlier blocked entry; the exact XP threshold calculation remains unknown.
- Play entered a /4 PLAYERS pad, displaying Win 100 coins, Invite and Leave. The account queued solo; no party invitations were sent. First draft was captured at 23:27:54 UTC, about 38 seconds after the initial queue screenshot. This is one sampled wait, not a matchmaking estimate.
- Four avatars flank a single court, two on each side, with three hearts each initially. Local player was lower right, teammate upper right. The first offer set was Blade/Axe/Verity, with All Balls Free and reroll 3 diamonds. The same set recurred in the second draft. A small teammate portrait and question-mark ball appeared beneath the choices.
- Selected Blade in round one. Both friendly aiming arrows were visible; all four launch arrows and 100 HP each appeared at release. Opposing balls had red HP numerals/outlines, friendly HP numerals were white. These cues may be supplemented by ability/status outlines; do not treat every later red outline as a team change.
- Round-one main-ball count fell to three while fighting continued. Friendly HP values differed, establishing separate ball health. The subsequent loss transition briefly showed different teammate heart counts; by the next draft both teammates had two hearts and both opponents still had three. This supports a team round loss deducting one heart from each teammate, rather than an immediate life deduction on each ball's disappearance. Other edge cases remain untested.
- Round two selected Axe. A native drag from the local ball toward the upper-left did not visibly change its horizontal aim. The window became larger between captures without an agent resize action; subsequent screenshots preserve the returned native dimensions. No game-control settings were changed during this resumed segment.
- Second-round opponent lineup included WDC and a pink orbital-effect ball. A numbered 3 by 3 overlay appeared while HP combat continued. It is recorded as an ability effect, not evidence for territory scoring. Exact trigger, numbers, damage and friendly-fire rules remain unknown.

- Round two was lost: the next captured aim screen showed one heart for both friendlies and three for both opponents. Its result/draft were missed. Local ball was Verity, teammate an icy-pattern ball. Round three was won, inferred from both opponents dropping to two hearts in the fourth draft.
- The tool detected manual input before the attempted fourth-round agent selection. Local Verity and a teammate with a bright red/white emblem then fought a green ball and Bomb. The opposing bomb disappeared while combat continued. After another observation gap, round five showed one heart for all four avatars, supporting a fourth-round win. Both friendly arrows were now angled; the local angle change is not attributed to the earlier failed automated drag.
- Round five started with four 100 HP labels. A late combat screenshot shows overlapping red rings, beams and damage numbers. At 23:32:38 UTC the result displayed the opposing pair on a crown panel, one heart each, and skulls over both friendly avatars. This confirms the team match ended in a loss. Sampled round sequence: L, L, W, W, L. No universal five-round cap or tie behavior is established.
- The result bar briefly showed **Lv 1 → Lv 2, 10/30**. The lobby still displayed **Lv 6 Reward** and the earlier gate had explicitly required Lv 5. These observations are inconsistent enough that the account/mode XP formula must remain unknown. Do not silently reconcile them as separate mode levels or a confirmed UI bug.
- Lobby return at 23:32:47 UTC showed Play 6/10 and 1,600 coins / 0 diamonds, versus 1,570 before the team match. The observed loss balance increase is 30 coins. The Quick Join panel displayed four slots grouped by red/blue outlines and Win 100. No reward-formula generalization is made from one result.

## Final menu evidence and handoff state

- L2-044 confirms WDC and Blade in inventory alongside the earlier visible roster; more cards continue below the viewport. No exact total roster count is inferred from this single frame.
- L2-045 preserves collection-help claims about rarity, choices and tradability. These remain published claims, not verified equal win rates or tested trade rules.
- L2-046 gives WDC's description: “Your cell's number = your damage.” This supports connecting the numbered grid with a damage ability, not territory scoring. Underlying implementation remains untested.
- L2-047 and L2-048 preserve store prices and disclosed gacha odds. No purchase, paid reroll, paid exact selection, fusion, trade, invite, group join or chat message was sent.
- Testing ended in the 2v2 lobby, outside a queue, with Store closed and 1,600 coins / 0 diamonds. No game setting was changed in the resumed segment. The larger window state introduced during manual input was left in place.
- Coverage is one completed 2v2 match sampled in all five rounds and at its final result/lobby return. A second uninterrupted team recording, continuous audio/timing, precise controls, phone play and edge cases remain future work. These gaps do not prevent using the evidence for the original territory-game specification.
