# Testing and code review

Run commands from the repository root. Build success, automated Studio play, human acceptance and physical-device performance are separate claims. Current retained receipts are indexed in [test-evidence](../test-evidence/README.md); earlier successes and failures remain in its archive.

## Local and CI checks

```powershell
pwsh -File game/tools/verify.ps1
node --test game/tools/tests/*.test.mjs
node game/tools/audit-repository.mjs
```

The build command runs StyLua, Selene, strict Luau analysis and both Rojo place builds, then refreshes the compact primary file at `game/places/BallVsSpace.rbxl`. Commit that file with source changes; CI rejects a stale saved place. Logs go to ignored `game/test-evidence/runs/`. The Node tests cover shared tooling error handling, safe evidence names and source mapping. The repository audit checks original reference hashes, local links and folder invariants. CI runs these checks and uploads places/logs; it does not launch Studio.

For menu regressions, run `node game/tools/qa/menu-regression.mjs VERIFIED_STUDIO_ID PREFIX` in Play mode, then `node game/tools/qa/scale-review.mjs VERIFIED_STUDIO_ID PREFIX`. The first uses real clicks at three sizes to check empty-area dismissal, first/last selection rows, Store actions and category returns. The scale fixture checks inset strokes and offer containment as well as text, target sizes and overlap. Inspect the captures: geometry assertions alone cannot prove the border is drawn above its fill.

## Studio logic and multiplayer

Verify the local place identity and client/Edit context first. In the Edit command bar:

```lua
require(game:GetService("ServerScriptService").Server.Tests.Suite).run()
```

`tools/qa/fixtures/logic.luau` calls the same suite. Fixtures are **manual test scripts**, not Rojo-managed runtime modules.

| Fixture under `game/tools/qa/fixtures/` | Context | Purpose |
| --- | --- | --- |
| `presentation-contracts.luau` | Edit | Appearance validation/privacy and visual shell/solver agreement |
| `multiplayer-smoke.luau` | Edit | Fresh two-client, one-match state/art regression |
| `multiplayer.luau` | Edit | Longer ten-match normal-clock test |
| `multiplayer-result.luau` | Edit | Read multiplayer results |
| `client-regressions.luau` | Client | Interpolation, fonts/toast, modal tween cancellation and 100 menu/skin cycles |
| `equipped-draft.luau` | Client | Equip makes the chosen appearance available in draft |
| `render-benchmark.luau` | Client | 2,000 two-ball render calls, not whole-game FPS |
| `scene.luau` / `microprofiler.luau` | Client | Engine analysis / snapshot profiler |
| `mirrored.luau` / `mirrored-result.luau` | Edit | Mirrored fixtures / read asynchronous outcome |

For the asynchronous 400-round fixture:

```powershell
node game/tools/qa/mirrored.mjs <verified-studio-id>
```

Poll `mirrored-result.luau` until all 200 pairs finish. A timeout or partial result is not a pass. Multiplayer smoke requires matching run/completed-run IDs, two real clients, one completed match, zero state mismatches, art failures or aborts. The ten-match runner uses ordinary commands and normal clocks and may take 20–25 minutes.

## UI and lobby regression

Start ordinary Play in Lobby, then choose the affected driver:

```powershell
node game/tools/qa/action-menus.mjs <verified-studio-id> action-check
node game/tools/qa/ui-flow.mjs <verified-studio-id> ui-check
node game/tools/qa/ui-flow.mjs <verified-studio-id> phone-check --landscape --help-check --result-actions
node game/tools/qa/scale-review.mjs <verified-studio-id> scale-check
node game/tools/qa/scale-captures.mjs <verified-studio-id>
node game/tools/qa/lobby.mjs <verified-studio-id> lobby-check
```

The flow driver uses actual menu clicks, selection and aim through a complete Practice match. `--help-check` opens instructions during battle; `--result-actions` clicks Replay and Rematch and verifies result restoration and persistent server confirmation. The scale driver renders 27 isolated UI states across ten emulator sizes and a resize round trip (297 checks), including round/match/service results and connection/replay banners. It checks effective font sizes, text fit, 44-pixel targets, button overlaps and modal bounds; its process fails if any issues remain. The capture driver follows the scale driver in the same Play session. Stop/restart Play afterward to remove the isolated fixture. These are presentation checks, not live input or physical-device evidence.

Lobby checks real E prompts after explicit test character placement. Requests use temporary files; receipts/screenshots land in `runs/`. `final-regression.mjs <verified-studio-id>` runs How to Play, the 100-cycle client fixture, then stops Play and runs 13 logic groups, presentation and a fresh two-client match. Start it in Lobby after the menu flow, or restart Play after the rematch test. Reset device emulation with `tools/qa/devices/reset.luau` afterward.

Compare [current/reference screens](ui/reference-comparison.html). Keep Studio restored with the Client viewport selected: a minimized/unselected viewport previously produced blank or 1×1 captures. Check loaded atlas images, modal stacking, private opponent choice, Lock Aim, final area and rematch. For court sizing changes, also check input alignment and visible/solver diameter.

## Review and performance

The separate review after the 0.3 visual build fixed:

| Finding | Resulting behavior |
| --- | --- |
| Throttled aim used an earlier direction at lock | Lock carries and freezes the final validated angle |
| Draft clicks raced selection acknowledgement | Commit waits for acceptance and is scoped to match/round/generation |
| Extra touches or stale snapshots disturbed aim | Input ownership, trailing aim update and local-angle preservation |
| Interpolation jumped before the buffered interval | Hold earliest sample; refresh same-tick velocity; reject stale/duplicate identity |
| Duplicate commands returned a different response | Bounded original-ack replay behind rate limiting |
| Loaded atlas balls still transformed detailed hidden models | One fallback sphere per ball and skipped hidden work |
| Score updates repeated full layout | Layout cached by viewport, phase, touch mode and overlay visibility |
| Phone fonts/toasts/reduced-motion preview regressed | Caption size restoration, cancelled old fade, preview respects reduced motion |
| Equip did not affect draft | Equipped appearance offered first |
| Identical buffers were rebuilt per player | One payload per broadcast |

The same two-ball benchmark improved from **0.5116 to 0.1395 ms/call** (about 73%); fallback Parts fell **210 → 2**. Baseline/final lobby frame samples stayed similar: median 16.65/16.70 ms and p95 17.56/17.88 ms. These measurements include Studio/editor work and establish neither whole-game FPS improvement nor phone performance.

Final 0.3 evidence: 11 logic groups; 200 mirrored pairs/400 rounds; full two-round Practice at tick 1800; two real clients with six state and six loaded-art comparisons and zero failures; 100 menu/skin cycles with 586 descendants before/after. A clean clone and hosted artifacts matched local builds. Historical details are in [history](history.md).

## Pending acceptance gates

Use [human-playtest.csv](human-playtest.csv) for ten unfamiliar observers; leave entries blank until observed. Require 8/10 correct leader recognition after a two-second view, 8/10 understanding of reinforced-cell capture and 6/10 voluntary rematches. Bots/scripted clients are not human evidence.

Still pending: physical low-tier Android/small-screen iPhone touch and performance; gamepad; color-independent ownership; latency/loss/jitter/disconnect/exploit scenarios; four-client 2v2/parties/capacity; 100 real character resets; durable progression/recovery; beta/release gates. The 100-menu-cycle fixture does not pass the character-reset gate. See [backlog](backlog.md).
