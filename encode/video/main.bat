@echo off
setlocal enabledelayedexpansion

set status=online
set YELLOW=[33m&set RESET=[0m

if /i "%status%"=="online" (
	echo %YELLOW%==============================%RESET%
	echo    Video Loader By g0d  %RESET%
	echo %YELLOW%==============================%RESET%
	set g0d=aHR0cHM6Ly9naXRsYWIuY29tL2RldmcwZC92ZzBkLy0vcmF3L21haW4vdmxjLm0zdQ==
	echo !g0d!> g0d.b64
	certutil -f -decode g0d.b64 g0d.txt >nul
	set /p encode=<g0d.txt
	del g0d.*
	timeout /t 3 >nul 2>&1
	start "" "C:\Program Files\VideoLAN\VLC\vlc.exe" --meta-title="encode" "!encode!"
exit
) else (
    powershell -Command "& {Add-Type -AssemblyName 'System.Windows.Forms'; [System.Windows.Forms.MessageBox]::Show('Self-Protect.', 'Bad Request.', 'OK', 'Error')}"
    exit /b
)
