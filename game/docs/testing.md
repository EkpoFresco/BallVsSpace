# Test and playtest instructions

All paths below are relative to `game/`. Use a local test place. Do not publish to a public experience or enable API access/purchases for this prototype.

## Automated checks

1. Run `./tools/verify.ps1`. This creates `builds/BallVsSpace.rbxl` and `.rbxlx`, and writes static-check logs.
2. Open the binary in Studio. In the **Edit** command bar run `require(game.ServerScriptService.Server.Tests.Suite).run()`. All groups must print `BVS PASS`. Alternatively set the explicit `BVSRunTests` game attribute before Play to run the Studio test runner.
3. Run `tools/mirrored-fixtures.luau` in the Edit command bar. It performs 200 opening-condition pairs, with a reflected court and headings. It asserts every reflected cell, final counts and result. Save the returned table; do not treat measured Edit-mode step time as phone frame time.
4. Run `tools/grid-fixture.luau` in the Edit command bar for before/after cell data. With MCP output saved at `test-evidence/grid-fixture.json`, run `node tools/render-grid-fixture.mjs` to regenerate the SVG.
5. Run `tools/start-multiplayer.luau` in the Edit command bar. Wait for the two clients to load. The test driver selects alternating kits, submits headings through normal remotes, honors normal clocks, rematches, and compares each client's grid hash/tick at round and match results. Ten complete matches are required. On the original Edit DataModel, inspect `game:GetAttribute("BVSMultiplayerResult")` after the child windows close. Any mismatch, missing second client, early exit or project error is a failure, not a partial pass.

MCP transport, if needed:

```powershell
node tools/studio-mcp.mjs list unused test-evidence/mcp-tools.json
node tools/studio-mcp.mjs call tools/request-list.json test-evidence/studio-instances.json
# Inspect identity before replacing source. Never reuse a previous session's IDs.
node tools/sync-studio.mjs <verified-local-edit-studio-id>
./tools/call-studio.ps1 -Tool execute_luau -StudioId <id> -DataModel Edit -CodeFile tools/run-studio-tests.luau -Out test-evidence/logic-run.json
```

MCP payloads have a JSON-RPC wrapper. The nested `result.content[].text` is often itself JSON; inspect `result.isError` as well as process exit code. An open place or successful build is not a gameplay pass.

## Manual desktop acceptance

Start two clients using Studio's Server & Clients mode **without** the automation test argument. Click Play in both. Check:

- Before draft closes, each player sees their own choice; the opponent's choice is hidden. Opponent aim is hidden until countdown. Unlocked choices default at deadlines.
- Both players can select each appearance through a card or All Balls and aim by clicking/dragging on the court. No input after the deadline changes the server's choice.
- Whole court, large ball models, outlined labels and avatar displays are readable. Territory overlay is on by default for territory-comprehension checks; the lobby gear can hide it for reference comparisons. Motion version 2 uses a 5.9-unit body radius; the base influence brush is independently defined and can be smaller than the body.
- Battle runs 30 seconds; scoring freezes before results. Space, rather than HP or remaining lives, determines the winner. Rematch and return to queue work. The reconstructed results screen does not currently expose the old replay control.
- Repeat through ten complete human matches as useful; keep test IDs, screenshots and Output logs. Stop tests before changing canonical source.

## Required M1 human gate — pending

Recruit ten unfamiliar observers; use anonymous IDs 01–10. Do not count the developer, bots or scripted clients. Record build/hash and device for each.

1. Show a live mid-round board for **2 seconds**, then hide it. Ask “Who is leading?” Record correct/incorrect and confidence. Threshold: **8/10** correct.
2. Let them read the prototype's coverage explanation and play. Ask “How do you steal a fully reinforced enemy cell?” Accept an explanation of repeated pressure weakening it through neutral before ownership changes; do not supply the answer first. Threshold: **8/10** understand. At base enemy pressure 1 against no opposing pressure, q=+3 takes four updates to become −1.
3. After a complete match, allow an unprompted choice to stop or play again. Record voluntary rematch requests. Threshold: **6/10**. An automated Rematch command is not evidence.
4. Record failed/defaulted selections, ability to explain aim, waiting frustration, visual confusion and suggested changes. Build 0.2.0-reference uses 20-second draft and 30-second aim limits for the reference presentation; early lock floors remain 3 and 2 seconds. Record this version separately from the old 12s/8s prototype.

Use `docs/human-playtest.csv` for raw entries. Leave cells blank until observed. Human gates remain pending. The user explicitly advanced visual reconstruction ahead of that gate; it must not be deferred to M3 again.

## Later gates, not claimed here

M2: four clients, 20 matches, 2v2/party/arena allocation, duplicate acknowledgment replay, disconnect/reconnect matrix, malformed-command and network fault tests. Measure actual RTT at 0/100/200/350 ms targets and label one-way vs RTT settings. Include loss 0/1/5%, jitter 0/30 ms, dropped territory delta recovery and reordered motion.

M3: at least one physical lower-tier Android and a small-screen iPhone. Record model/RAM/OS/graphics/thermal conditions, touch and gamepad behavior, orientations, safe areas and ten-minute frame-time/memory traces. A Studio device emulator cannot pass real-device performance.

M4–M6: durable profile/reward fault and recovery tests, real human beta observations, rollout/rollback and separate release authorization. Keep purchases disabled.

## Reference reconstruction checks

- Run `tools/replica-contract-tests.luau` in Edit for appearance validation, private draft/reveal and the visible body/wall projection assertions. Run the regular Suite after changing timer configuration; deadline tests use the actual deadline.
- Run `tools/start-replica-multiplayer.luau` for a one-match, two-client regression. Read `BVSReplicaMultiplayerResult` on the original Edit DataModel. Require zero grid/tick mismatches and zero appearance failures; this smoke test is additional to the older ten-match evidence.
- During normal Play run `node tools/replica-flow.mjs <verified-id> <evidence-prefix>`. It clicks Inventory, All Balls, Acid and Axe, changes aim on the court, locks, and captures each phase through a complete normal match. It asserts the acknowledged appearance and records actual cutoff counts.
- Compare captures in `test-evidence/replica-comparison.html`. Reference pictures have only the Windows title bar cropped in the viewer; game captures are rendered live, not composited screenshots. Different players, headings and match times are identified limitations of the comparison.
- Studio must be restored and its Client viewport selected. A 1×1 Camera.ViewportSize means the viewport is not rendering; do not accept those screenshots. Device simulation and a normal match are required after recovering it. Phone-emulated layout checks do not establish physical-phone performance or touch behavior.
