# Ascend Flutter CLI wrapper.
#
# This environment occasionally leaves `ios/Flutter/ephemeral` in a state the
# Flutter CLI cannot delete (interrupted iOS tooling invocations). Wiping the
# ephemeral tree before every Flutter command makes builds deterministic.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tool\flutter.ps1 pub get
#   powershell -ExecutionPolicy Bypass -File tool\flutter.ps1 run -d chrome
#
# All repository docs must use this wrapper when running Flutter commands.

param([Parameter(ValueFromRemainingArguments = $true)][string[]]$FlutterArgs)

$ErrorActionPreference = "Stop"

function Remove-Quiet([string]$Path) {
  if (Test-Path -LiteralPath $Path) {
    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
  }
}

Remove-Quiet (Join-Path (Get-Location) ".dart_tool")
Remove-Quiet (Join-Path (Get-Location) "ios\Flutter\ephemeral")

if ($FlutterArgs.Count -eq 0) {
  Write-Host "No flutter arguments provided."
  exit 1
}

& flutter @FlutterArgs
exit $LASTEXITCODE