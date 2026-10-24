n# Nightly MySQL backup job (used by DevKit_backup_db scheduled task).
$ErrorActionPreference = 'Stop'
$conf = Get-Content "$PSScriptRoot\..\config.ini" -Raw
function Get-IniValue([string]$section, [string]$key) {
    if ($conf -match "(?s)\[$section\].*?\b$key\s*=\s*(.+)") { $matches[1].Trim() } else { $null }
}
$dbName = Get-IniValue 'mysql' 'database'
$dbUser = Get-IniValue 'mysql' 'user'
$dbPwd  = Get-IniValue 'mysql' 'user_password'

$mysqldump = Get-ChildItem 'C:\Program Files\MySQL' -Recurse -Filter mysqldump.exe -ErrorAction SilentlyContinue |
             Select-Object -First 1 -ExpandProperty FullName
if (-not $mysqldump) { throw 'mysqldump.exe not found' }

New-Item -ItemType Directory -Force 'C:\DevKit\backups' | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$out = "C:\DevKit\backups\$dbName`_$stamp.sql"

& $mysqldump -u $dbUser -p"$dbPwd" $dbName | Out-File $out -Encoding utf8

# keep only the 14 most recent backups
Get-ChildItem 'C:\DevKit\backups\*.sql' | Sort-Object LastWriteTime -Descending |
    Select-Object -Skip 14 | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "backup written: $out"
