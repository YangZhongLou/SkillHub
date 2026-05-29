@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
  echo Usage: install.bat ^<target-project-dir^>
  echo   Copies .common/skills, merges CLAUDE.md and .claude/settings.json into the target.
  exit /b 1
)

set "TARGET=%~1"
set "HUB_DIR=%~dp0.."

if not exist "%TARGET%\" (
  echo Error: %TARGET% does not exist or is not a directory
  exit /b 1
)

echo ==^> SkillHub install to %TARGET%

:: 1. Copy skills
if exist "%HUB_DIR%\.common\" (
  if not exist "%TARGET%\.common\" mkdir "%TARGET%\.common"
  xcopy /E /I /Y "%HUB_DIR%\.common\skills" "%TARGET%\.common\skills" >nul
  echo     .common/skills/ copied
)

:: 2. Merge CLAUDE.md
findstr /C:"SkillHub" "%TARGET%\CLAUDE.md" >nul 2>&1
if errorlevel 1 (
  if exist "%TARGET%\CLAUDE.md" (
    echo. >> "%TARGET%\CLAUDE.md"
    echo ^<!-- Managed by SkillHub --^> >> "%TARGET%\CLAUDE.md"
    type "%HUB_DIR%\CLAUDE.md" >> "%TARGET%\CLAUDE.md"
    echo     CLAUDE.md merged ^(appended^)
  ) else (
    copy /Y "%HUB_DIR%\CLAUDE.md" "%TARGET%\" >nul
    echo     CLAUDE.md created
  )
) else (
  echo     CLAUDE.md already has SkillHub content, skipped
)

:: 3. Merge permissions
if exist "%HUB_DIR%\.claude\settings.json" (
  if not exist "%TARGET%\.claude\" mkdir "%TARGET%\.claude"
  if exist "%TARGET%\.claude\settings.json" (
    echo     .claude/settings.json exists, merge manually to avoid overwriting
  ) else (
    copy /Y "%HUB_DIR%\.claude\settings.json" "%TARGET%\.claude\" >nul
    echo     .claude/settings.json created
  )
)

echo ==^> Done.
