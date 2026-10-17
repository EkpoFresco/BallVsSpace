# Setup on the receiving computer

Guidance checked on 16 October 2026. Prefer the current installed application's instructions if its menus differ. Do not copy the research computer's application paths or credentials.

## Recommended workspace: VS Code and Codex CLI

1. Install VS Code, Codex CLI and Roblox Studio. For Codex, use the installer appropriate to your operating system in the [official CLI guide](https://learn.chatgpt.com/docs/codex/cli).
2. In VS Code, open the extracted `Ball_VS_Space_Build_Pack` folder containing START_HERE.md, RUN_PROMPT.txt and AGENTS.md. Keep the pack root as the workspace so the agent can read all evidence while creating `game/` beneath it.
3. Select **Terminal → New Terminal**. VS Code's integrated terminal normally starts at the workspace root; verify the directory. [VS Code terminal guide](https://code.visualstudio.com/docs/terminal/basics)
4. Run `codex` and complete sign-in. The CLI uses the directory where it starts as the project. [Codex project guidance](https://learn.chatgpt.com/docs/projects?surface=app)
5. Connect Studio as below, then paste RUN_PROMPT.txt into the Codex session. The Codex VS Code extension is an optional alternative interface; it is not required to run the CLI in the terminal.

On Windows, I recommend starting with a native PowerShell terminal for this project so Codex, Rojo and the Windows Studio connection run on the same host. If you deliberately use WSL, verify the Windows Studio bridge separately rather than assuming the Windows MCP command will work unchanged.

For later iterations, keep one terminal for Codex and a second for `rojo serve` from `game/` after the agent creates that project. Review source changes in VS Code and play the game in Studio. Rojo moves project content; Studio MCP lets the agent inspect, operate and test the open place. Neither replaces runtime verification.

## Studio connection

In Roblox Studio, open **Assistant → … → Manage MCP Servers**, then enable **Studio as MCP server**. Its panel provides connection instructions and shows a green indicator when connected. Quick connect supports Codex CLI when installed. [Roblox's official MCP guide](https://create.roblox.com/docs/studio/mcp)

**For the recommended CLI workflow:** expand Studio's **Quick connect** dropdown and enable **Codex CLI**. If absent, install the CLI and restart Studio. Start a fresh Codex session after configuration changes and verify the intended Studio instance is available before making edits. Use Studio's current manual connection instructions if Quick connect is unavailable. [Roblox connection steps](https://create.roblox.com/docs/studio/mcp)

For the desktop app, open **Settings → MCP servers → Add server**, choose **STDIO**, enter the command and arguments below, save and restart the connection. The desktop app and CLI share MCP configuration on the same host. [OpenAI MCP setup](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)

| System | Command | Arguments |
|---|---|---|
| Windows | `cmd.exe` | `/c` and `%LOCALAPPDATA%\Roblox\mcp.bat` as two separate arguments |
| macOS | `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP` | None |

These paths are from [Roblox's connection guide](https://create.roblox.com/docs/studio/mcp); verify they exist on the receiving machine. Use the Studio-provided configuration if they differ. Keep existing unrelated MCP entries.

Once connected, ask the agent to list available Studio instances, identify the new Ball VS Space place and read its state. A configured entry or green indicator is not a substitute for a successful tool call. The agent must discover the actual available tool names and schemas before using them. Target this project's place explicitly.

## Rojo

The agent should check whether the Rojo CLI is installed and record its version. Install a supported version from the [official installation guide](https://rojo.space/docs/v7/getting-started/installation/) if needed, using the permissions available on that machine. Rojo's CLI and Studio plugin are separate pieces; the plugin is needed for live sync. Blender and Blender MCP are optional later art tools, not prerequisites for the prototype.

After the agent has created `game/default.project.json` and its source tree, these commands can be run **from the `game` folder**:

```text
rojo build default.project.json -o builds/BallVSSpace.rbxlx
rojo serve default.project.json
```

The agent must create the output directory first. Open the built place in Studio, or connect the matching Rojo Studio plugin for live sync. Keep script files as the source of truth. [Official build and sync workflow](https://rojo.space/docs/v7/getting-started/new-game/)

## If something is missing

| Missing capability | What the agent should do |
|---|---|
| Studio MCP | Continue source and logic work; build a local place through Rojo when available. Supply exact manual Studio test steps and keep those tests pending. |
| Rojo CLI | Prepare the source/project tree; resolve installation or record the exact blocker. Do not claim a place build exists. |
| Studio itself | Continue files and pure logic checks; the user installs/signs into Studio before runtime validation. |
| Python | Skip the optional archived design-check rerun until an interpreter is available; it is not the game runtime. Create/run implementation tests in the selected Roblox/Luau workflow. |
| Blender | Use original Roblox primitives and procedural visuals. |
| Human testers or a real phone | Keep the related milestone criteria pending and collect feedback later; automated screenshots do not meet those gates. |

Use a local development place and test data for early work. Public release, real purchases and changes to an unrelated existing experience are outside the starter build request. If a platform action becomes necessary, prepare the concrete result and explain the exact remaining action.
