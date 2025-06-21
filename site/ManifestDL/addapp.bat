@echo off
setlocal EnableDelayedExpansion

rem Accept GAME_ID as the first argument from the calling handler/script
set "GAME_ID=%~1"

rem Base URL constructed using the GAME_ID
set "BASE_URL=https://raw.githubusercontent.com/dev-g0d/steam-mnf/main/%GAME_ID%/"
rem List file URL constructed using the GAME_ID
set "LIST_FILE_URL=https://raw.githubusercontent.com/dev-g0d/steam-mnf/main/%GAME_ID%/file_list.txt"

set "TEMP_LIST_FILE=temp_github_file_list.txt"
set "TEMP_LIST_PATH=%~dp0%TEMP_LIST_FILE%"

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%LIST_FILE_URL%', '%TEMP_LIST_PATH%')" >nul 2>&1

if not exist "%TEMP_LIST_PATH%" (
    goto :end
)

for /F "tokens=*" %%A in ('type "%TEMP_LIST_PATH%"') do (
    set "CURRENT_FILE_NAME=%%A"

    if not "!CURRENT_FILE_NAME!"=="" (
        set "DOWNLOAD_URL=%BASE_URL%!CURRENT_FILE_NAME!"

        rem Determine save path based on file extension
        set "SAVE_SUBDIR="
        if /i "!CURRENT_FILE_NAME:~-4!"==".lua" (
            set "SAVE_SUBDIR=stplug-in\"
        ) else if /i "!CURRENT_FILE_NAME:~-9!"==".manifest" (
            set "SAVE_SUBDIR=depotcache\"
        )
        
        rem Create subdirectory if it doesn't exist
        if not "!SAVE_SUBDIR!"=="" (
            if not exist "%~dp0!SAVE_SUBDIR!" (
                mkdir "%~dp0!SAVE_SUBDIR!" >nul 2>&1
            )
        )

        set "SAVE_PATH=%~dp0!SAVE_SUBDIR!!CURRENT_FILE_NAME!"

        powershell -Command "(New-Object System.Net.WebClient).DownloadFile('!DOWNLOAD_URL!', '!SAVE_PATH!')" >nul 2>&1
    )
)

if exist "%TEMP_LIST_PATH%" (
    del "%TEMP_LIST_PATH%" >nul 2>&1
)

:end
endlocal
exit /b
