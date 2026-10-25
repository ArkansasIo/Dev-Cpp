# Engine test build script (Explorer suite)
# Usage: powershell -File .\build.ps1 [-Debug]
param(
    [switch]$Debug
)

$inc = "$PSScriptRoot\include"
$lib = if (Test-Path "C:\Users\Shadow\AppData\Local\Temp\d3dx\extracted\build\native\release\lib\x64\d3dx9.lib") {
    "C:\Users\Shadow\AppData\Local\Temp\d3dx\extracted\build\native\release\lib\x64"
}
else {
    # Local fallback if you download the NuGet package yourself
    "$PSScriptRoot\lib\x64"
}
$files = @('float2.cpp', 'float3.cpp', 'float4.cpp', 'float4x4.cpp', 'FXHandle.cpp',
    'Dropdown.cpp', 'Edit.cpp', 'Dirlight.cpp', 'FXShader.cpp', 'FXVariable.cpp',
    'globals.cpp', 'test_main.cpp')

$cc = "C:\Program Files\LLVM\bin\clang++.exe"
$base = @('-std=c++17', '-I', "$inc")

$out = "engine_test.exe"
$flags = @('-O2')
if ($Debug) {
    $out = "engine_debug.exe"
    $flags = @('-g', '-O0', '-fsanitize=address', '-fno-omit-frame-pointer')
}

$all = $base + $flags + $files + @('-o', "$out",
    '-lUser32', '-lGdi32', '-lShell32', '-lD3d9',
    "$lib\d3dx9.lib",
    'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.26100.0\um\x64\d3d9.lib')

& $cc @all 2>&1 | Select-String "error" | Select-Object -First 8
if (Test-Path $out) {
    Write-Output "Built $out ($((Get-Item $out).Length) bytes)"
}
else {
    Write-Output "Build FAILED"
    exit 1
}
