# Start here — Ball VS Space

This is the complete research and implementation handoff. Transfer this entire folder, or extract `Ball_VS_Space_Build_Pack.zip` on the other computer. Keep the folders together so the evidence links work.

The pack contains the build specification, original brief, supplied video, six video frames, 48 live screenshots, observation notes, source links, design checks and a ready-to-paste development prompt. It does **not** contain a built Roblox game, installed applications, account sign-ins or a configured MCP connection. Those depend on the receiving computer.

## What you need to do

1. Extract the ZIP somewhere you can edit, such as your Documents folder. Open the folder containing this `START_HERE.md`.
2. Install/update Roblox Studio, sign in, and open a new empty Baseplate for this project. The normal Roblox Player app cannot replace Studio for building.
3. **Recommended: open this entire folder in VS Code and run Codex CLI in its integrated terminal.** Install Codex CLI using the [official CLI guide](https://learn.chatgpt.com/docs/codex/cli), then choose Terminal → New Terminal in VS Code and run `codex` from the folder containing this file. Sign in when prompted. Codex uses its starting directory as the project. [Project-directory guidance](https://learn.chatgpt.com/docs/projects?surface=app)
4. For direct Studio editing and testing, connect Studio MCP using [SETUP.md](SETUP.md). Codex can begin writing the project before that connection is ready, but must mark Studio tests pending until they actually run. Keep Roblox Studio open alongside VS Code.
5. Paste the complete contents of [RUN_PROMPT.txt](RUN_PROMPT.txt) into the Codex terminal session. It tells the agent to begin implementation, verify tools and continue through the staged build.

VS Code displays and edits the files; Codex CLI implements and runs commands; Rojo builds/syncs the source into Studio; Studio runs the Roblox game. The Codex desktop app remains an alternative local-project interface, but is not required for this terminal workflow.

If you want a short starter message instead, send: **“Read START_HERE.md and RUN_PROMPT.txt in this project. Execute RUN_PROMPT.txt now.”**

You do not need to repeat the research or explain the game again. The agent should handle normal code, build and dependency work within the permissions available. You may still need to sign in, approve a requested local setup step, open Studio, and play the prototype. A copied folder cannot supply those actions or replace human playtest feedback.

## What each file is for

| File or folder | Purpose |
|---|---|
| [RUN_PROMPT.txt](RUN_PROMPT.txt) | The development request to paste into the receiving agent |
| [AGENTS.md](AGENTS.md) | Project working instructions and implementation boundaries |
| [BALL_VS_SPACE_RESEARCH_AND_BUILD_SPEC.md](BALL_VS_SPACE_RESEARCH_AND_BUILD_SPEC.md) | Complete rules, architecture, roster, milestones and acceptance criteria |
| [Ball_VS_Space_Evidence/FINDINGS.md](Ball_VS_Space_Evidence/FINDINGS.md) | Concise live-test findings and key screenshots |
| [Ball_VS_Space_Evidence/README.md](Ball_VS_Space_Evidence/README.md) | Full visual gallery and source records |
| [SETUP.md](SETUP.md) | Studio MCP, Rojo and missing-tool fallback |
| [BUILD_STATUS.md](BUILD_STATUS.md) | Honest starting state; agent updates progress here |
| [checks/verify_spec.py](checks/verify_spec.py) | Portable structure and territory-math checks; not a game test |
| [checks/verify_transfer.py](checks/verify_transfer.py) | Checks transfer hashes before the first edit; needs Python 3 |
| [TRANSFER_MANIFEST.json](TRANSFER_MANIFEST.json) | Pack file hashes |

The original brief contains an old `C:\Users\ekpom\...` video path. On this computer use the included file at `Ball_VS_Space_Evidence/video-reference/original-territory-reference.mp4`. The old environment audit in the specification describes the research computer, not this one.

The first real deliverable should be a playable 1v1 territory prototype with Drift and Anchor, a place file, source code and test evidence. Later milestones add reliable 2v2, all eight kits, presentation and progression. The final game requires iteration; this handoff makes the work startable, not already complete.
