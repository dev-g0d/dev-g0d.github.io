# ====== Self-Elevate to Administrator ======
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Requesting Administrator privileges..."
    $myInvocation = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$myInvocation`"" -Verb RunAs
    exit
}

# ====== Check VLC Path ======
$vlcExePath = "C:\Program Files\VideoLAN\VLC\vlc.exe"
$batDir = "C:\Program Files\VideoLAN\VLC"
$batPath = "$batDir\v.g0d.bat"

If (-not (Test-Path $vlcExePath)) {
    Write-Host "VLC not found at $vlcExePath"
    Write-Host "Please install VLC before running this script."
    exit 1
}

If (-not (Test-Path $batDir)) {
    Write-Host "$batDir not found. Creating directory..."
    Try {
        New-Item -Path $batDir -ItemType Directory -Force | Out-Null
        Write-Host "Directory created: $batDir"
    } Catch {
        Write-Host "Failed to create directory $batDir: $_" -ForegroundColor Red
        exit 1
    }
}

# ====== Write .bat File ======
$batContent = @"
@echo off
REM Get the first argument (the url)
set url=%1
REM Remove 'vlcg0d:' prefix (convert vlcg0d:https://.... to https://....)
set url=%url:vlcg0d:=%
REM Launch VLC with the provided link
start "" "C:\Program Files\VideoLAN\VLC\vlc.exe" "%url%"
"@

Try {
    $batContent | Set-Content -Encoding ASCII -Path $batPath -Force
    Write-Host "v.g0d.bat file created successfully at $batPath."
} Catch {
    Write-Host "Error creating v.g0d.bat: $_" -ForegroundColor Red
    exit 1
}

# ====== Write .reg File ======
$regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\vlcg0d]
@="URL:VLCg0d Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\vlcg0d\DefaultIcon]
@="C:\\Program Files\\VideoLAN\\VLC\\vlc.exe,1"

[HKEY_CLASSES_ROOT\vlcg0d\shell]

[HKEY_CLASSES_ROOT\vlcg0d\shell\open]

[HKEY_CLASSES_ROOT\vlcg0d\shell\open\command]
@="\"C:\\Program Files\\VideoLAN\\VLC\\v.g0d.bat\" \"%1\""
"@
$regPath = "$env:TEMP\vlcg0d.reg"

Try {
    $regContent | Set-Content -Encoding UTF8 -Path $regPath
    Write-Host "vlcg0d.reg file created successfully."
} Catch {
    Write-Host "Error creating .reg file: $_" -ForegroundColor Red
    exit 1
}

# ====== Import .reg File ======
Try {
    Start-Process regedit.exe -ArgumentList "/s `"$regPath`"" -Wait -ErrorAction Stop
    Write-Host "Registry protocol added successfully."
} Catch {
    Write-Host "Error adding registry protocol: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n--- Setup completed! ---" -ForegroundColor Green
Write-Host "Test by typing vlcg0d:https://... in Run dialog or your browser."
