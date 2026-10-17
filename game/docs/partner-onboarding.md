# Partner onboarding

The repository root is `Ball_VS_Space_Build_Pack/`, containing this guide, the source and the references. The earlier Git history was retained when the repository moved from `game/` to the pack root. Source paths inside the project have not changed.

## Owner: publish the prepared repository

Create an empty GitHub repository under your chosen account or organization. Do not initialize it with a README, license or `.gitignore`; these would create a separate initial history. Choose visibility yourself. From the local pack root, replace `OWNER` and `REPOSITORY` below:

```powershell
git remote add origin https://github.com/OWNER/REPOSITORY.git
git push -u origin main
```

Then open repository **Settings → Collaborators** (or the organization's access settings), invite your partner's GitHub account, and grant write access. The invitation is sent by you; none was sent during local preparation. After the first successful Actions run, configure a rule for `main` requiring pull requests, one review and the `build` check if your GitHub plan supports it.

This publishes source to GitHub. It does not publish a Roblox experience. Roblox collaboration permissions and Team Create are separate; add those when you choose a shared Roblox experience. No remote URL, visibility, partner identity or Roblox publishing destination has been assumed.

## Partner: clone and run

```powershell
git clone https://github.com/OWNER/REPOSITORY.git
cd REPOSITORY
rokit install
pwsh -File game/tools/verify.ps1
```

Prerequisites: Git, PowerShell 7, Roblox Studio and [Rokit](https://github.com/rojo-rbx/rokit). The project pins the tools in the root `rokit.toml`; no Wally dependencies or Roblox API keys are needed for a local build. Node.js 24 is only needed for the optional Studio MCP scripts.

Open `game/builds/BallVsSpace.rbxl`, press Play and choose Practice. Verify the territory overlay is on, select a ball, aim, lock, and watch the round finish. Then run two local clients for a normal queue match. Read [testing.md](testing.md) for the logic suite, evidence requirements and pending gates.

For live code updates, run `rojo serve game/default.project.json` at the root, then connect the Rojo Studio plugin in the intended local place. Edit `game/src/` files. Studio MCP sync is an optional fallback; rediscover and verify the place before passing its ID. IDs and executable paths in old evidence are historical.

## First shared work

Use [backlog.md](backlog.md) to claim a small issue with observable acceptance. The highest presentation priority is exact symbols, typography and spacing against the saved reference. The territory priority is clearer ownership/pressure feedback and real-player comprehension, followed by the unfinished M2 networking work. Keep the core design contracts intact.

Use branches and PRs as described in [CONTRIBUTING.md](../../CONTRIBUTING.md). Avoid editing the same controller at once. Share reproducible source revisions and test evidence; exchange generated places only as previews.
