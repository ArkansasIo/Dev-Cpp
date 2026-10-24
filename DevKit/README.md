d math# DevKit — Dev-C++ companion toolkit

Sits next to `C:\Dev-C++` (the IDE installed earlier). Install, configure, automate.

## Layout
```
DevKit/
  config.ini                 <- all settings (Wolfram AppID, MySQL creds, cronjobs)
  tools/
    install_languages.ps1    <- top 25 programming languages
    mysql_setup.ps1          <- MySQL install + config + database creation
    wolfram_query.ps1        <- math via Wolfram Alpha API
    cron_setup.ps1           <- cron jobs -> Windows Task Scheduler
    mysql_backup.ps1         <- nightly DB backup (runs via cronjob)
```

## 1. Top 25 languages
```powershell
# list them
powershell -ExecutionPolicy Bypass -File tools\install_languages.ps1 -List
# install all 25 (silent, via winget)
powershell -ExecutionPolicy Bypass -File tools\install_languages.ps1
# or just a few
powershell -ExecutionPolicy Bypass -File tools\install_languages.ps1 -Only python,rust,go
```
Covers: python, javascript, typescript, java, csharp, cpp, go, rust, php, ruby,
kotlin, swift, dart, scala, perl, haskell, lua, r, julia, elixir, clojure,
fsharp, groovy, fortran, zig.

## 2. Math via Wolfram Alpha
1. Get a free AppID: https://developer.wolframalpha.com/portal/
2. Put it in `config.ini` under `[wolfram] appid=...`
3. Run:
```powershell
powershell -ExecutionPolicy Bypass -File tools\wolfram_query.ps1 -Query "integrate x^2 dx"
powershell -ExecutionPolicy Bypass -File tools\wolfram_query.ps1 -Query "solve 2x+5=15" -SaveImage
```

## 3. MySQL database
```powershell
# run PowerShell as Administrator
powershell -ExecutionPolicy Bypass -File tools\mysql_setup.ps1
```
Installs MySQL via winget, sets root password, creates `devkit_db` with a
dedicated `devkit_user`, adds a sample `math_queries` table (which the Wolfram
tool results can be logged into), and writes client config to `C:\DevKit\mysql.cnf`.
Edit credentials in `config.ini` **before** running.

## 4. Cron jobs (Windows Task Scheduler)
```powershell
# run PowerShell as Administrator
powershell -ExecutionPolicy Bypass -File tools\cron_setup.ps1
```
Creates `DevKit_*` tasks from the `[cronjobs]` section of `config.ini`:
- `backup_db`  — daily 02:00 mysqldump backup (keeps last 14)
- `cleanup_temp` — daily 03:30 temp cleanup
- `ping_log` — every 15 min connectivity log

Add your own jobs in `config.ini` (`name = schedule|command`) and rerun.
Inspect tasks: `Get-ScheduledTask -TaskName 'DevKit_*'`

## Order of first-run
1. `install_languages.ps1`
2. `mysql_setup.ps1` (admin)
3. `cron_setup.ps1` (admin)
4. set Wolfram AppID, then `wolfram_query.ps1`
