eander # Create Windows scheduled tasks (cronjobs) from config.ini [cronjobs] section.
# Usage (as Administrator): powershell -ExecutionPolicy Bypass -File cron_setup.ps1
# Schedules supported: @hourly | daily:HH:MM | every:Nm  (minutes)
$ErrorActionPreference = 'Stop'
$conf = Get-Content "$PSScriptRoot\..\config.ini" -Raw

# extract [cronjobs] section
if ($conf -match '(?s)\[cronjobs\]\s*(.*?)(\n\[|\z)') { $section = $matches[1] } else { throw 'No [cronjobs] section in config.ini' }
New-Item -ItemType Directory -Force 'C:\DevKit\logs' | Out-Null

$created = 0
foreach ($line in ($section -split "`n")) {
    $line = $line.Trim()
    if (-not $line -or $line.StartsWith('#')) { continue }
    if ($line -notmatch '^([\w\-]+)\s*=\s*(.+)\|(.+)$') { Write-Warning "skipping bad line: $line"; continue }
    $name = 'DevKit_' + $matches[1]
    $sched = $matches[2].Trim()
    $cmd = $matches[3].Trim()

    # remove previous version
    Unregister-ScheduledTask -TaskName $name -Confirm:$false -ErrorAction SilentlyContinue

    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`""
    $trigger =
    if ($sched -eq '@hourly') { New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1) }
    elseif ($sched -match '^every:(\d+)m$') { New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes ([int]$matches[1])) }
    elseif ($sched -match '^daily:(\d{1,2}):(\d{2})$') { New-ScheduledTaskTrigger -Daily -At ([datetime]::Today.AddHours([int]$matches[1]).AddMinutes([int]$matches[2])) }
    else { Write-Warning "unknown schedule '$sched' for $name"; continue }

    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest | Out-Null
    Write-Host "created task: $name  ($sched)" -ForegroundColor Green
    $created++
}
Write-Host "`n$created scheduled tasks installed. View with: Get-ScheduledTask -TaskName 'DevKit_*'" -ForegroundColor Yellow
