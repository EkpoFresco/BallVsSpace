param()
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force builds, test-evidence/runs | Out-Null
function CheckExit([string]$name) { if ($LASTEXITCODE -ne 0) { throw "$name failed with exit $LASTEXITCODE" } }
stylua --check src 2>&1 | Tee-Object test-evidence/runs/format.log
CheckExit 'Formatting'
selene src 2>&1 | Tee-Object test-evidence/runs/lint.log
CheckExit 'Lint'
rojo sourcemap default.project.json --output sourcemap.json
CheckExit 'Sourcemap'
if (-not (Test-Path -LiteralPath tools/types/roblox-types.d.luau)) {
  throw 'Missing checked-in Roblox type definitions: tools/types/roblox-types.d.luau'
}
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json --definitions=tools/types/roblox-types.d.luau src 2>&1 | Tee-Object test-evidence/runs/typecheck.log
CheckExit 'Strict type analysis'
rojo build default.project.json -o builds/BallVsSpace.rbxl
CheckExit 'Binary build'
rojo build default.project.json -o builds/BallVsSpace.rbxlx
CheckExit 'XML build'
Get-FileHash builds/BallVsSpace.rbxl, builds/BallVsSpace.rbxlx | Select-Object Algorithm,Hash,Path | ConvertTo-Json | Set-Content test-evidence/runs/build-hashes.json
Write-Output 'Static checks and both place builds passed. Run the Studio tests separately.'
