@echo off
set "LINK=.claude\skills"
set "TARGET=.common\skills"

if /i "%1"=="remove" goto :remove
if /i "%1"=="/remove" goto :remove
if /i "%1"=="-remove" goto :remove

if exist "%LINK%" (
    echo Already exists: %LINK%
    exit /b 0
)

mklink /J "%LINK%" "%TARGET%"
if %errorlevel% equ 0 echo Linked: %LINK% -^> %TARGET%
exit /b %errorlevel%

:remove
if exist "%LINK%" (
    rmdir "%LINK%"
    if %errorlevel% equ 0 echo Removed: %LINK%
) else (
    echo Not found: %LINK%
)
exit /b 0
