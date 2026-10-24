# Install top 25 programming languages as toolchains.
# Usage:  powershell -ExecutionPolicy Bypass -File install_languages.ps1 [-Only python,rust] [-List]
# All installers are run silently where possible. Requires internet.
param(
    [string]$Only = "",
    [switch]$List
)

$ErrorActionPreference = 'Continue'
$Root = 'C:\DevKit'
New-Item -ItemType Directory -Force "$Root\langs", "$Root\logs" | Out-Null

# Top 25 languages: name -> silent-install command (winget package id preferred)
$LANGS = [ordered]@{
    'python'     = 'winget install -e --id Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements'
    'javascript' = 'winget install -e --id OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements'
    'typescript' = 'npm install -g typescript'
    'java'       = 'winget install -e --id EclipseAdoptium.Temurin.21.JDK --silent --accept-package-agreements --accept-source-agreements'
    'csharp'     = 'winget install -e --id Microsoft.DotNet.SDK.8 --silent --accept-package-agreements --accept-source-agreements'
    'cpp'        = 'winget install -e --id MSYS2.MSYS2 --silent --accept-package-agreements --accept-source-agreements'
    'go'         = 'winget install -e --id GoLang.Go --silent --accept-package-agreements --accept-source-agreements'
    'rust'       = 'winget install -e --id Rustlang.Rustup --silent --accept-package-agreements --accept-source-agreements'
    'php'        = 'winget install -e --id PHP.PHP.8.3 --silent --accept-package-agreements --accept-source-agreements'
    'ruby'       = 'winget install -e --id RubyInstallerTeam.Ruby.3.3 --silent --accept-package-agreements --accept-source-agreements'
    'kotlin'     = 'winget install -e --id JetBrains.Kotlin --silent --accept-package-agreements --accept-source-agreements'
    'swift'      = 'winget install -e --id Swift.Toolchain --silent --accept-package-agreements --accept-source-agreements'
    'dart'       = 'winget install -e --id Dart.Dart --silent --accept-package-agreements --accept-source-agreements'
    'scala'      = 'winget install -e --id Contoso.Scala.Scoop -v 0.0.1 --silent'  # fallback: manual
    'perl'       = 'winget install -e --id StrawberryPerl.StrawberryPerl --silent --accept-package-agreements --accept-source-agreements'
    'haskell'    = 'winget install -e --id Haskell.GHC --silent --accept-package-agreements --accept-source-agreements'
    'lua'        = 'winget install -e --id DEVCOM.Lua --silent --accept-package-agreements --accept-source-agreements'
    'r'          = 'winget install -e --id RProject.R --silent --accept-package-agreements --accept-source-agreements'
    'julia'      = 'winget install -e --id JuliaLang.Julia --silent --accept-package-agreements --accept-source-agreements'
    'elixir'     = 'winget install -e --id ElixirLang.Elixir --silent --accept-package-agreements --accept-source-agreements'
    'clojure'    = 'winget install -e --id Clojure.Clojure --silent --accept-package-agreements --accept-source-agreements'
    'fsharp'     = 'winget install -e --id Microsoft.DotNet.SDK.8 --silent --accept-package-agreements --accept-source-agreements'  # dotnet F#
    'groovy'     = 'winget install -e --id Apache.Groovy --silent --accept-package-agreements --accept-source-agreements'
    'fortran'    = 'winget install -e --id GnuWin32.GnuFortran -v 0.0.1 --silent'  # fallback: MSYS2 mingw-w64 gcc-fortran
    'zig'        = 'winget install -e --id Zig.Zig --silent --accept-package-agreements --accept-source-agreements'
}

if ($List) {
    $LANGS.Keys | ForEach-Object { $_ }
    exit 0
}

$sel = if ($Only) { $Only.Split(',') | ForEach-Object { $_.Trim().ToLower() } } else { $LANGS.Keys }

foreach ($lang in $sel) {
    if (-not $LANGS.Contains($lang)) { Write-Warning "unknown language: $lang"; continue }
    Write-Host "==> installing $lang ..." -ForegroundColor Cyan
    $log = "$Root\logs\install_$lang.log"
    try {
        Invoke-Expression $LANGS[$lang] 2>&1 | Tee-Object -FilePath $log -Append
        Write-Host "    $lang done" -ForegroundColor Green
    } catch {
        Write-Warning "$lang failed: $_"
        "FAILED $lang : $_" | Out-File $log -Append
    }
}

Write-Host "`nAll requested languages processed. Logs: $Root\logs" -ForegroundColor Yellow
Write-Host "Note: 'scala' and 'fortran' have winget fallbacks; if they fail install manually:" -ForegroundColor Yellow
Write-Host "  scala  -> https://www.scala-lang.org/download/" -ForegroundColor Yellow
Write-Host "  fortran-> inside MSYS2: pacman -S mingw-w64-x86_64-gcc-fortran" -ForegroundColor Yellow
