# Wolfram Alpha math query tool.
# Usage: powershell -ExecutionPolicy Bypass -File wolfram_query.ps1 -Query "integrate x^2 dx"
#        or: wolfram_query.ps1 -Query "2+2" -SaveImage
# Get free AppID: https://developer.wolframalpha.com/portal/  -> put it in DevKit\config.ini
param(
    [Parameter(Mandatory=$true)][string]$Query,
    [switch]$SaveImage
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$conf = Get-Content "$PSScriptRoot\..\config.ini" -Raw
if ($conf -match '(?s)\[wolfram\].*?\bappid\s*=\s*(\S+)') { $appid = $matches[1] } else { throw 'appid missing in config.ini' }
if ($appid -eq 'YOUR_WOLFRAM_APPID') { throw 'Set your Wolfram Alpha AppID in DevKit\config.ini first.' }

$api = "https://api.wolframalpha.com/v1/result?appid=$appid&i=" + [uri]::EscapeDataString($Query)
try {
    $answer = Invoke-RestMethod -Uri $api
    Write-Host "`n$Query" -ForegroundColor Cyan
    Write-Host "= $answer" -ForegroundColor Green
} catch {
    Write-Warning "plaintext API failed ($($_.Exception.Message)); trying short-answers endpoint..."
    try {
        $api2 = "https://api.wolframalpha.com/v1/spokent?appid=$appid&i=" + [uri]::EscapeDataString($Query)
        Write-Host "= $(Invoke-RestMethod -Uri $api2)" -ForegroundColor Green
    } catch { throw "Wolfram Alpha query failed: $_" }
}

# Optionally save the visual result pod
if ($SaveImage) {
    $imgApi = "https://api.wolframalpha.com/v1/simple?appid=$appid&i=" + [uri]::EscapeDataString($Query)
    $out = "$PSScriptRoot\..\last_query.png"
    Invoke-WebRequest -Uri $imgApi -OutFile $out
    Write-Host "Image saved: $out" -ForegroundColor Yellow
}
