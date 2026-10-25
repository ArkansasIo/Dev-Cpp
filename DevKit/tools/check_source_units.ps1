[CmdletBinding()]
param(
  [string]$Project = (Join-Path $PSScriptRoot '..\..\Source\devcpp.dpr')
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $Project
$text = Get-Content -LiteralPath $Project -Raw
$matches = [regex]::Matches($text, "(?m)^\s*[A-Za-z0-9_]+\s+in\s+'([^']+)'", 'IgnoreCase')
$missing = New-Object System.Collections.Generic.List[string]
foreach ($m in $matches) {
  $relative = $m.Groups[1].Value -replace '\\','\'
  $candidate = Join-Path $root $relative
  if (-not (Test-Path -LiteralPath $candidate)) {
    $missing.Add($relative)
  }
}
if ($missing.Count -gt 0) {
  Write-Error ("Missing Delphi project units:`n" + ($missing -join "`n"))
  exit 1
}
Write-Host "Source unit completeness check passed."
