[CmdletBinding(PositionalBinding = $false)]
param(
  [string]$Account = 'EkpoFresco',
  [Parameter(Position = 0, ValueFromRemainingArguments = $true)][string[]]$GhArgs
)
$ErrorActionPreference = 'Stop'
if (-not $GhArgs) { throw 'Pass a GitHub CLI command, for example: api user --jq .login' }
$previousToken = $env:GH_TOKEN
try {
  # Use Git's configured credential helper. Never print or persist its credential output.
  $request = [string]::Join([Environment]::NewLine, @('protocol=https', 'host=github.com', 'path=EkpoFresco/BallVsSpace.git', '', ''))
  $response = @($request | git -c credential.interactive=never credential fill)
  if ($LASTEXITCODE -ne 0) { throw 'Git credential helper could not authenticate this account.' }
  $passwordLine = $response | Where-Object { $_.StartsWith('password=') } | Select-Object -First 1
  if (-not $passwordLine) { throw 'Git credential helper returned no usable credential.' }
  $env:GH_TOKEN = $passwordLine.Substring(9)
  $login = & gh api user --jq .login
  if ($LASTEXITCODE -ne 0 -or $login -ine $Account) { throw 'Credential does not authenticate the requested GitHub account.' }
  & gh @GhArgs
  $code = $LASTEXITCODE
} finally {
  $env:GH_TOKEN = $previousToken
  $response = $null
  $passwordLine = $null
}
exit $code
