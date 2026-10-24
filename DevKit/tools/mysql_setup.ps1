# Install + configure MySQL, create database and app user.
# Usage: powershell -ExecutionPolicy Bypass -File mysql_setup.ps1
# Reads config from DevKit\config.ini
$ErrorActionPreference = 'Stop'
$Root = 'C:\DevKit'
$conf = Get-Content "$PSScriptRoot\..\config.ini" -Raw

function Get-IniValue([string]$section, [string]$key) {
  if ($conf -match "(?s)\[$section\].*?\b$key\s*=\s*(.+)") { $matches[1].Trim() } else { $null }
}

$rootPwd = Get-IniValue 'mysql' 'root_password'
$dbName = Get-IniValue 'mysql' 'database'
$dbUser = Get-IniValue 'mysql' 'user'
$dbPwd = Get-IniValue 'mysql' 'user_password'

Write-Host '==> Installing MySQL via winget ...' -ForegroundColor Cyan
winget install -e --id Oracle.MySQL --silent --accept-package-agreements --accept-source-agreements

# Locate mysql client
$mysqlExe = (Get-Command mysql -ErrorAction SilentlyContinue).Source
if (-not $mysqlExe) {
  $mysqlExe = Get-ChildItem 'C:\Program Files\MySQL' -Recurse -Filter mysql.exe -ErrorAction SilentlyContinue |
  Select-Object -First 1 -ExpandProperty FullName
}
if (-not $mysqlExe) { throw 'mysql.exe not found after install; check MySQL installer output.' }
$mysqlDir = Split-Path (Split-Path $mysqlExe)
Write-Host "MySQL found: $mysqlDir" -ForegroundColor Green

# Ensure service is running
$svc = Get-Service | Where-Object { $_.Name -like 'MySQL*' } | Select-Object -First 1
if ($svc -and $svc.Status -ne 'Running') { Start-Service $svc.Name; Start-Sleep 5 }

# Set root password (fresh installs have empty root password)
Write-Host '==> Configuring root password and database ...' -ForegroundColor Cyan
$sql = @"
ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootPwd';
CREATE DATABASE IF NOT EXISTS ``$dbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$dbUser'@'localhost' IDENTIFIED BY '$dbPwd';
GRANT ALL PRIVILEGES ON ``$dbName``.* TO '$dbUser'@'localhost';
FLUSH PRIVILEGES;
"@
$sqlFile = "$Root\init.sql"
$sql | Out-File $sqlFile -Encoding utf8

& $mysqlExe -u root --execute="ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootPwd';" 2>$null

# Reconnect using the new root password and create db/user
& $mysqlExe -u root -p"$rootPwd" --execute="
CREATE DATABASE IF NOT EXISTS ``$dbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$dbUser'@'localhost' IDENTIFIED BY '$dbPwd';
GRANT ALL PRIVILEGES ON ``$dbName``.* TO '$dbUser'@'localhost';
FLUSH PRIVILEGES;" 2>&1

# Sample table so the DB is usable right away
& $mysqlExe -u "$dbUser" -p"$dbPwd" $dbName --execute="
CREATE TABLE IF NOT EXISTS math_queries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  expression VARCHAR(512) NOT NULL,
  result TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"
Write-Host "Database '$dbName' and user '$dbUser' ready." -ForegroundColor Green

# Write a client config the other tools can use
@"
[client]
host=127.0.0.1
port=3306
user=$dbUser
password=$dbPwd
database=$dbName
"@ | Out-File "$Root\mysql.cnf" -Encoding ascii

Write-Host "Client config: $Root\mysql.cnf" -ForegroundColor Green
