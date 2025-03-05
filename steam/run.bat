@echo off
cd /d "%~dp0"
set "currentFileName=%~nx0"

:: ตรวจสอบว่า Steam เปิดอยู่หรือไม่
tasklist | find /i "steam.exe" >nul
if errorlevel 1 (
    powershell -Command "& {Add-Type -AssemblyName 'System.Windows.Forms'; [System.Windows.Forms.MessageBox]::Show('Steam not launch.', 'Error', 'OK', 'Error')}"
    exit /b
)

:: โหลดค่าจาก g0d.ini
for /f "tokens=1,2 delims==" %%i in (g0d.ini) do (
    if "%%i"=="Start" set Start=%%j
    if "%%i"=="RealappId" set RealappId=%%j
    if "%%i"=="FakeappId" set FakeappId=%%j
    if "%%i"=="g0d" set g0d=%%j
)

:: ตรวจสอบว่า Start ต้องเป็น .org เท่านั้น
if not "%Start:~-4%"==".org" (
    powershell -Command "& {Add-Type -AssemblyName 'System.Windows.Forms'; [System.Windows.Forms.MessageBox]::Show('Self-protect.', 'Access denied', 'OK', 'Error')}"
    exit /b
)

:: ใช้ directory ปัจจุบันเสมอ
set "ExeFile=%CD%\%Start:.org=.exe%"
set "ExpectedBat=%CD%\%Start:.org=.g0d.bat%"

:: ตรวจสอบว่าไฟล์ bat ต้องเป็นชื่อที่ถูกต้อง
if /i not "%currentFileName%"=="%~nx0" (
    powershell -Command "& {Add-Type -AssemblyName 'System.Windows.Forms'; [System.Windows.Forms.MessageBox]::Show('You are not authorized to access.', 'Access denied', 'OK', 'Error')}"
    exit /b
)

:: ตรวจสอบว่าไฟล์ exe และ bat ต้องมีอยู่จริง
if not exist "%ExeFile%" (
    powershell -Command "& {Add-Type -AssemblyName 'System.Windows.Forms'; [System.Windows.Forms.MessageBox]::Show('Self-protect', 'Access denied', 'OK', 'Error')}"
    exit /b
)

if not exist "%ExpectedBat%" (
    powershell -Command "& {Add-Type -AssemblyName 'System.Windows.Forms'; [System.Windows.Forms.MessageBox]::Show('Self-protect', 'Access denied', 'OK', 'Error')}"
    exit /b
)

:: ตรวจสอบค่าความถูกต้องของ g0d
if not "%g0d%"=="E1hXIoygVoUEECRmbZcj0wyoz2reU03DKz+vlrMULRw" (
    powershell -Command "& {Add-Type -AssemblyName 'System.Windows.Forms'; [System.Windows.Forms.MessageBox]::Show('Self-protect.', 'Access denied', 'OK', 'Error')}"
    exit /b
)

:: ตั้งค่า Steam
set STEAM_RUNTIME=1
set SteamGameId=%RealappId%
set SteamAppId=%FakeappId%

:: เริ่มรันไฟล์
start "" "%ExeFile%"
exit
