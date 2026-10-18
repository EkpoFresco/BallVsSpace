param([Parameter(Mandatory=$true)][string]$Tool,[string]$DataModel='Edit',[string]$CodeFile,[string]$Out,[Parameter(Mandatory=$true)][string]$StudioId)
$ErrorActionPreference='Stop'
$arguments=@{studio_id=$StudioId}
if ($CodeFile) { $arguments.datamodel_type=$DataModel; $arguments.code=Get-Content -Raw -LiteralPath $CodeFile }
$requestPath=[IO.Path]::GetTempFileName()
try {
  @{name=$Tool;arguments=$arguments} | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $requestPath
  if ($Out) { node (Join-Path $PSScriptRoot 'studio-mcp.mjs') call $requestPath $Out } else { node (Join-Path $PSScriptRoot 'studio-mcp.mjs') call $requestPath }
  $code=$LASTEXITCODE
} finally { Remove-Item -LiteralPath $requestPath }
exit $code
