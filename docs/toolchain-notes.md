# Receiving-machine audit — 16 October 2026

Verified executables: Node 24.16.0; Rojo 7.7.1; Lune 0.10.5; StyLua 2.5.2; Selene 0.32.0; Luau LSP 1.69.0; Roblox Studio 0.743.0.7431133. `rokit.toml` pins development tools. Run them from `game/` so Rokit's project resolution applies. Lune is available but the authoritative logic tests ran in actual Studio Luau.

Studio process 15808 initially had the window title `C:\Users\nsidi\Desktop\VibeCode\Reaction Game\BallVsSpace.rbxl - Roblox Studio`. The sole original MCP instance was `d5ad0dce-42df-4cbf-b5d6-d9859f35c7e0`. Read-only inspection confirmed PlaceId 0, GameId 0, internal name Place1 and an empty template. The internal name differed from the local filename; both were checked before editing. The original file is backed up at `builds/original-empty-BallVsSpace.rbxl`.

This session did not expose direct Roblox tool functions. `tools/studio-mcp.mjs` initializes the installed official `StudioMCP.exe` stdio transport, discovers its tools and uses their returned schemas. It now discovers the executable under the receiving user's LOCALAPPDATA, with an explicit `BVS_STUDIO_MCP` override. It does not assume the old research machine's path. Studio IDs are ephemeral: list and verify them on each session. `call-studio.ps1` and `sync-studio.mjs` require an explicit ID.

The final two-client run used StudioTestService on the verified Edit place. It created a dedicated server and two child Studio processes. A game attribute on the original Edit model did not propagate to those processes in the first attempt. The corrected harness uses `StudioTestService:GetTestArgs()` on the server and the explicit Studio-only telemetry remote on the clients. Earlier exploratory attempts are preserved as separate evidence.

Roblox API type definitions are vendored at `tools/roblox-types.d.luau` for reproducible offline static analysis. Retrieved from the Luau LSP project's `scripts/globalTypes.d.lua` on 16 October 2026. SHA-256: `F2C5CA08F17A08E9EC43EE998F0ED2825B00B4ADEA83ECE4775B21719E280765`. They are tooling metadata, not gameplay source or art. Update deliberately with the pinned toolchain and rerun analysis.

FFmpeg 8.1.1 captured the two client windows by their observed native window handles. The inspected final recording is 130 seconds at 8 fps, with unused padding cropped into a side-by-side MP4. This records the running test; it is not a reconstruction from simulated frames. Window handles are ephemeral and must not be reused. Some capture frames were dropped under four Studio processes; recording time remains normal and this is not a frame-rate benchmark. The earlier 12 fps attempt cropped the emulated viewport and is retained as failed capture evidence.

MCP screen captures in the initial evidence use `.png` filenames even though the returned MIME type is JPEG. The helper was corrected to preserve the actual extension for new captures; the originals are retained.

Useful primary documentation: [Studio MCP](https://create.roblox.com/docs/studio/mcp), [Studio testing modes](https://create.roblox.com/docs/studio/testing-modes), [StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService), [StudioDeviceSimulatorService](https://create.roblox.com/docs/reference/engine/classes/StudioDeviceSimulatorService), [Rojo project format](https://rojo.space/docs/v7/project-format/).
