@echo off
setlocal enabledelayedexpansion

set APP_ID_SFX=.dear.google.why
set DIR=%cd%
set DEST_DIR=%DIR%\dist
mkdir "%DEST_DIR%" 2>nul
set NO_GS=true
set CLEAN=clean

:loop
if "%1"=="" goto endloop
if "%1"=="-nc" (
    set CLEAN=
) else if "%1"=="-a" (
    set ARM=true
) else (
    echo Unknown argument: %1
    goto fim
)
shift
goto loop
:endloop

if "%ANDROID_SDK_ROOT%"=="" (
    for /f "tokens=2 delims==" %%a in ('findstr "sdk.dir=" local.properties') do set ANDROID_SDK_ROOT=%%a
)

if "%ANDROID_SDK_ROOT%"=="" (
    echo ANDROID_SDK_ROOT environment variable is not set
    exit /b 1
) else (
    echo ANDROID_SDK_ROOT=%ANDROID_SDK_ROOT%
)

for /f "delims=" %%a in ('dir /s /b /ad /o-d "%ANDROID_SDK_ROOT%\cmake\bin"') do (
    set CMAKE_PATH="%%~a"
    goto endFor
)
:endFor
echo CMAKE_PATH=%CMAKE_PATH%
set PATH=%CMAKE_PATH%;%PATH%

:build_apk
set sfx=arm64
set abi=arm64-v8a

if "%1"=="arm" (
    set sfx=arm
    set abi=armeabi-v7a
)

call gradlew.bat %CLEAN% fermata:packageAutoReleaseUniversalApk -PABI=%abi% -PAPP_ID_SFX=%APP_ID_SFX%

for /f %%a in ('dir /b /a-d "fermata\build\outputs\apk_from_bundle\autoRelease\fermata-*.apk"') do set path=%%a
for %%F in (%path%) do set name=%%~nxF
set name=%name:auto-release-universal.apk=%

move "fermata\build\outputs\apk_from_bundle\autoRelease\%path%" "%DEST_DIR%\%name%auto-universal-%sfx%.apk"

@echo APK Build "%DEST_DIR%\%name%auto-universal-%sfx%.apk"

if "%sfx%"=="arm64" goto :fim

:arm64
call :build_apk arm64

:fim