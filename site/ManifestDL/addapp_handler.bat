@echo off
setlocal EnableDelayedExpansion

rem The full URL passed by the browser, e.g., "addapp_g0d:12345"
set "FULL_URL_ARG=%~1"

rem Extract the ID after "addapp_g0d:"
rem This assumes the format is always "addapp_g0d:XXXXX"
set "APP_ID=!FULL_URL_ARG:addapp_g0d:=!"

if not defined APP_ID (
    exit /b 1
)

rem Call addapp.bat with the extracted APP_ID
rem Assuming addapp.bat is in the same directory as this handler
call "%~dp0addapp.bat" "!APP_ID!"

endlocal
exit /b
