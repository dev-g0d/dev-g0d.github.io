# Define installation directory for the .bat files
$baseTargetDir = "C:\Program Files (x86)\Steam\config" # IMPORTANT: Change this to your desired path, e.g., "C:\Program Files (x86)\Steam\config"

# Define protocols and their respective handler scripts
$protocols = @(
    @{ Name = "addapp_g0d"; HandlerScript = "addapp_handler.bat"; MainScript = "addapp.bat" }
    @{ Name = "removeapp_g0d"; HandlerScript = "removeapp_handler.bat"; MainScript = "removeapp.bat" }
)

# Get the directory where this setup script is located (source for other .bat files)
$sourceDir = (Get-Item -Path $PSScriptRoot).FullName

# ====== Check Target Directory and Essential Files ======
Write-Host "Checking setup requirements..."
# Check if target directory exists and is writable (attempt to create if not)
try {
    if (-not (Test-Path $baseTargetDir)) {
        New-Item -ItemType Directory -Path $baseTargetDir -Force | Out-Null
        Write-Host "✅ Created target directory: $baseTargetDir" -ForegroundColor Green
    } else {
        Write-Host "✅ Target directory exists: $baseTargetDir" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed to create or access target directory: $baseTargetDir" -ForegroundColor Red
    Write-Host "Please ensure you have permissions to write to this location." -ForegroundColor Red
    exit 1
}

# Check if main .bat files exist in the source directory
$allRequiredSourceBatsExist = $true
foreach ($protocol in $protocols) {
    $mainScriptPath = Join-Path $sourceDir $protocol.MainScript
    if (-not (Test-Path $mainScriptPath)) {
        Write-Host "❌ Required script not found: $mainScriptPath" -ForegroundColor Red
        $allRequiredSourceBatsExist = $false
    } else {
        Write-Host "✅ Found required script: $mainScriptPath" -ForegroundColor Green
    }
}

if (-not $allRequiredSourceBatsExist) {
    Write-Host "Please ensure all essential .bat files (addapp.bat, removeapp.bat) are in the same directory as this setup script." -ForegroundColor Red
    exit 1
}

Write-Host "`nStarting protocol setup..."

# --- Create/Update handler .bat files and copy main .bat files ---
foreach ($protocol in $protocols) {
    $protocolName = $protocol.Name
    $handlerScriptFileName = $protocol.HandlerScript
    $mainScriptFileName = $protocol.MainScript
    $handlerBatPath = Join-Path $baseTargetDir $handlerScriptFileName
    $mainBatTargetPath = Join-Path $baseTargetDir $mainScriptFileName

    # ====== Write Handler .bat File ======
    $batContent = @"
@echo off
setlocal EnableDelayedExpansion

set "FULL_URL_ARG=%%~1"
set "APP_ID=!FULL_URL_ARG:%protocolName%:=!"

if not defined APP_ID (
    echo Error: No APP_ID found in the protocol URL for $($protocolName).
    exit /b 1
)

call "%~dp0$($mainScriptFileName)" "!APP_ID!"
endlocal
exit /b
"@

    try {
        $batContent | Set-Content -Encoding ASCII -Path $handlerBatPath -Force
        Write-Host "✅ Handler script created/updated: $handlerBatPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create handler script '$handlerScriptFileName': $_" -ForegroundColor Red
        exit 1
    }

    # ====== Copy Main .bat File ======
    try {
        Copy-Item -Path (Join-Path $sourceDir $mainScriptFileName) -Destination $baseTargetDir -Force | Out-Null
        Write-Host "✅ Copied main script: $mainBatTargetPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to copy main script '$mainScriptFileName': $_" -ForegroundColor Red
        exit 1
    }
}

# --- Create and import .reg Files ---
foreach ($protocol in $protocols) {
    $protocolName = $protocol.Name
    $handlerScriptFileName = $protocol.HandlerScript
    $handlerBatPath = Join-Path $baseTargetDir $handlerScriptFileName # Use the path where the handler is actually created

    # ====== Write .reg File ======
    $regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\$protocolName]
@="URL:$($protocolName) Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\$protocolName\DefaultIcon]
@="\"$handlerBatPath\",1"

[HKEY_CLASSES_ROOT\$protocolName\shell]

[HKEY_CLASSES_ROOT\$protocolName\shell\open]

[HKEY_CLASSES_ROOT\$protocolName\shell\open\command]
@="\"$handlerBatPath\" \"%1\""
"@

    $regPath = Join-Path $env:TEMP "$protocolName.reg"

    try {
        $regContent | Set-Content -Encoding UTF8 -Path $regPath -Force
        Write-Host "✅ Registry script saved to $regPath for '$protocolName'" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error writing .reg file for '$protocolName': $_" -ForegroundColor Red
        continue
    }

    # ====== Import .reg File ======
    try {
        Start-Process regedit.exe -ArgumentList "/s `"$regPath`"" -Wait -ErrorAction Stop
        Write-Host "✅ Protocol handler '$protocolName:' registered successfully." -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to import registry for '$protocolName': $_" -ForegroundColor Red
        Write-Host "   This operation often requires Administrator privileges." -ForegroundColor Red
    } finally {
        # Clean up .reg file
        if (Test-Path $regPath) {
            Remove-Item $regPath -Force | Out-Null
        }
    }
}

# ====== Finish ======
Write-Host "`n🎉 Setup completed!" -ForegroundColor Green
Write-Host "You can now test the protocols by typing these into your browser address bar:" -ForegroundColor Cyan
Write-Host "   addapp_g0d:3059400" -ForegroundColor Cyan
Write-Host "   removeapp_g0d:3059400" -ForegroundColor Cyan
Write-Host "`nAll necessary .bat files are located at: $baseTargetDir" -ForegroundColor Yellow
