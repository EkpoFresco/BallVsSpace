# Authored presentation art

These atlases are original project artwork drawn in `../../tools/art/build.mjs`. Reference screenshots are research evidence and are not embedded in runtime art.

| Atlas | Layout | Roblox image |
| --- | --- | --- |
| `icons.png` | 32 symbols, 128-pixel cells, 8 columns | `rbxassetid://105537358583136` |
| `balls.png` | 12 portraits, 256-pixel cells, 4 columns | `rbxassetid://132245039697166` |

`atlas.json` contains exact source rectangles. `Artwork.luau` maps names to those rectangles. Body circles occupy 88/128 of a ball cell; the renderer compensates for that padding to preserve the collision-to-display diameter. Weapons use separate icon cells so they rotate independently.

Rebuild from the repository root with Node.js 24:

```powershell
npm ci --prefix game/tools/art --no-audit --no-fund
node game/tools/art/build.mjs
```

The PNGs and editable SVGs are checked in, so a normal Rojo build needs no npm installation. The image IDs were returned by Studio MCP's image upload tool and their loaded rendering was tested in the local place. The upload receipt is `../../test-evidence/visual-v3-art-upload.json`.

When moving the game to a different Roblox owner or group, confirm these images load in that destination. If permissions require a new upload, publish these same original PNGs under the intended owner and update the two image IDs in `Artwork.luau` and the kiosk atlas ID in `LobbyDetailService.luau`. Recheck an actual client; a generated place alone cannot verify asset delivery.
