# Define the path for the log file
$logFilePath = "$env:TEMP\run_ps1_log.txt"

# Clear previous log content
Clear-Content $logFilePath | Out-Null

# Command to execute run.ps1 and redirect all output (including errors) to the log file
# It also includes Read-Host to keep the main launcher window open briefly to show completion/error.
$command = "irm https://github.com/dev-g0d/dev-g0d.github.io/raw/refs/heads/main-site/site/ManifestDL/run.ps1 | iex *> `"$logFilePath`" 2>&1; Write-Host 'Installation/Removal process finished. Check log at $logFilePath. Press Enter to exit.'"

# Start a new PowerShell process with Administrator privileges
# This new process will execute the command and redirect its output to the log file.
Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
