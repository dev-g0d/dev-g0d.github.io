# Define installation directory for the .bat files
$baseTargetDir = "C:\Program Files (x86)\Steam\config" # IMPORTANT: Change this to your desired path, e.g., "C:\Program Files (x86)\Steam\config"

# Define protocols and their respective handler scripts with their GitHub Raw download URLs
$protocols = @(
    @{
        Name = "addapp_g0d";
        HandlerScript = "addapp_handler.bat";
        MainScript = "addapp.bat";
        HandlerDownloadUrl = "https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/main-site/site/ManifestDL/addapp_handler.bat";
        MainScriptDownloadUrl = "https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/main-site/site/ManifestDL/addapp.bat"
    },
    @{
        Name = "removeapp_g0d";
        HandlerScript = "removeapp_handler.bat";
        MainScript = "removeapp.bat";
        HandlerDownloadUrl = "https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/main-site/site/ManifestDL/removeapp_handler.bat";
        MainScriptDownloadUrl = "https://raw.githubusercontent.com/dev-g0d/dev-g0d.github.io/main-site/site/ManifestDL/removeapp.bat"
    }
)

# ====== Check Target Directory ======
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

Write-Host "`nStarting protocol setup..."

# --- Download and Create/Update handler .bat files and main .bat files ---
foreach ($protocol in $protocols) {
    $protocolName = $protocol.Name
    $handlerScriptFileName = $protocol.HandlerScript
    $mainScriptFileName = $protocol.MainScript
    $handlerDownloadUrl = $protocol.HandlerDownloadUrl
    $mainScriptDownloadUrl = $protocol.MainScriptDownloadUrl

    $handlerBatPath = Join-Path $baseTargetDir $handlerScriptFileName
    $mainBatTargetPath = Join-Path $baseTargetDir $mainScriptFileName

    # ====== Download Handler .bat File ======
    try {
        Write-Host "Downloading handler script '$handlerScriptFileName' from '$handlerDownloadUrl'..."
        (New-Object System.Net.WebClient).DownloadFile($handlerDownloadUrl, $handlerBatPath)
        Write-Host "✅ Handler script downloaded/updated: $handlerBatPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to download handler script '$handlerScriptFileName' from '$handlerDownloadUrl': $_" -ForegroundColor Red
        exit 1
    }

    # ====== Download Main .bat File ======
    try {
        Write-Host "Downloading main script '$mainScriptFileName' from '$mainScriptDownloadUrl'..."
        (New-Object System.Net.WebClient).DownloadFile($mainScriptDownloadUrl, $mainBatTargetPath)
        Write-Host "✅ Main script downloaded/updated: $mainBatTargetPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to download main script '$mainScriptFileName' from '$mainScriptDownloadUrl': $_" -ForegroundColor Red
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
