param()
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force places, builds, test-evidence/runs | Out-Null
# Rojo turns empty source directories into Folders, but Git does not retain them.
# Reject these local-only Instances so saved binaries match clean-checkout builds.
$emptySourceDirectories = @(Get-ChildItem -LiteralPath src -Directory -Recurse | Where-Object {
  @(Get-ChildItem -LiteralPath $_.FullName -Force).Count -eq 0
})
if ($emptySourceDirectories.Count -gt 0) {
  throw ('Empty source directories produce local-only Rojo Folders. Remove them or declare intended Folders in the project file: ' + ($emptySourceDirectories.FullName -join ', '))
}
# Quiet successful tools must not leave a prior failure in their log.
foreach ($checkName in 'format', 'lint', 'typecheck') {
  Set-Content -LiteralPath "test-evidence/runs/$checkName.log" -Value ''
}
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
rojo build default.project.json -o places/BallVsSpace.rbxl
CheckExit 'Binary build'
rojo build default.project.json -o builds/BallVsSpace.rbxlx
CheckExit 'XML build'
# One ready-to-open binary; the XML build is generated inspection output.
Get-FileHash places/BallVsSpace.rbxl, builds/BallVsSpace.rbxlx | Select-Object Algorithm,Hash,Path | ConvertTo-Json | Set-Content test-evidence/runs/build-hashes.json
Write-Output 'Static checks and both place builds passed. Run the Studio tests separately.'
