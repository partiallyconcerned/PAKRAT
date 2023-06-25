@echo off
setlocal enabledelayedexpansion

set "steam_library=%1"
shift

if "%1"=="/u" (
    set "uflag=1"
    shift
)
if "%1"=="/a" (
    set "mode=unpack_workshop_all"
) else (
    set "workshop_id=%1"
    set "mode=unpack_workshop"
)

if not defined steam_library goto :error_no_steam_library

if defined uflag (
    set "starbound=%steam_library%\steamapps\common\Starbound - Unstable"
) else (
    set "starbound=%steam_library%\steamapps\common\Starbound"
)
set "starbound_workshop=%steam_library%\steamapps\workshop\content\211820"
set "unpack=%starbound%\win32\asset_unpacker.exe"
set "starbound_assets=%starbound%\assets\packed.pak"

call :%mode% %workshop_id%
exit /b

:unpack_starbound
    if exist "%starbound_assets%" (
        if exist "%starbound%\_UnpackedAssets" (
            echo Removing Starbound's old unpacked assets...
            rd /s /q "%starbound%\_UnpackedAssets"
            echo Done.
        )
        
        echo Unpacking Starbound's assets...
        "%unpack%" "%starbound_assets%" "%starbound%\_UnpackedAssets" >nul
        echo Done.
    ) else (
        echo Starbound's assets not found.
    )
exit /b

:unpack_workshop
    set "workshop_id=%~1"
    if exist "%starbound_workshop%\%workshop_id%" (
        if exist "%starbound%\mods\%workshop_id%" (
            echo Removing %workshop_id%'s old unpacked assets...
            rd /s /q "%starbound%\mods\%workshop_id%"
            echo Done.
        )
        
        echo Unpacking %workshop_id%'s assets...
        "%unpack%" "%starbound_workshop%\%workshop_id%\contents.pak" "%starbound%\mods\%workshop_id%" >nul
        echo Done.
    ) else (
        echo %workshop_id%'s assets not found.
    )
exit /b

:unpack_workshop_all
    set num_loops=0
    for /f %%g in ('dir /b /a:d "%starbound_workshop%"') do (
        set /a "num_loops+=1"
        call :unpack_workshop %%g
    )
    
    if "!num_loops!"=="0" (
        echo No mods found.
    ) else (
        echo Finished unpacking !num_loops! mod(s).
    )
exit /b

:error_no_steam_library
    echo Error: No Steam Library specified.
    exit /b 1
