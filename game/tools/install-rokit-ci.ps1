# CI bootstrap; local developers should use Rokit's normal installation instructions.
param()
$ErrorActionPreference = 'Stop'
if ($env:GITHUB_ACTIONS -ne 'true' -or -not $env:RUNNER_TEMP) {
    throw 'This installer is for GitHub Actions. Install Rokit normally on a developer machine.'
}
$toolDirectory = Join-Path $env:RUNNER_TEMP 'ball-vs-space-rokit'
New-Item -ItemType Directory -Force $toolDirectory | Out-Null
$archivePath = Join-Path $toolDirectory 'rokit.zip'
Invoke-WebRequest 'https://github.com/rojo-rbx/rokit/releases/download/v1.2.0/rokit-1.2.0-windows-x86_64.zip' -OutFile $archivePath
$expectedHash = 'F9BA1704014FF67D51E8005F605955C7C26D2429A5312A9419DC477FC310E96D'
if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash -ne $expectedHash) {
    throw 'Rokit archive checksum mismatch'
}
Expand-Archive -LiteralPath $archivePath -DestinationPath $toolDirectory -Force
& (Join-Path $toolDirectory 'rokit.exe') self-install
if ($LASTEXITCODE -ne 0) { throw 'Rokit self-install failed' }
Join-Path $env:USERPROFILE '.rokit/bin' | Out-File -FilePath $env:GITHUB_PATH -Append -Encoding utf8
