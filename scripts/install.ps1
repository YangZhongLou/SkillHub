param(
  [Parameter(Mandatory=$true)]
  [string]$Target
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HubDir = Split-Path -Parent $ScriptDir

if (-not (Test-Path $Target -PathType Container)) {
  Write-Error "$Target does not exist or is not a directory"
  exit 1
}

Write-Host "==> SkillHub install to $Target"

# 1. Copy skills
if (Test-Path "$HubDir\.agent") {
  New-Item -ItemType Directory -Force -Path "$Target\.agent" | Out-Null
  Copy-Item -Recurse -Force "$HubDir\.agent\skills" "$Target\.agent\"
  Write-Host "    .agent/skills/ copied"
}

# 2. Merge CLAUDE.md
if (Test-Path "$Target\CLAUDE.md") {
  $existing = Get-Content "$Target\CLAUDE.md" -Raw
  if ($existing -notmatch "SkillHub") {
    Add-Content "$Target\CLAUDE.md" "`n<!-- Managed by SkillHub -->`n"
    Get-Content "$HubDir\CLAUDE.md" | Add-Content "$Target\CLAUDE.md"
    Write-Host "    CLAUDE.md merged (appended)"
  } else {
    Write-Host "    CLAUDE.md already has SkillHub content, skipped"
  }
} else {
  Copy-Item "$HubDir\CLAUDE.md" "$Target\"
  Write-Host "    CLAUDE.md created"
}

# 3. Merge permissions
if (Test-Path "$HubDir\.claude\settings.json") {
  New-Item -ItemType Directory -Force -Path "$Target\.claude" | Out-Null
  if (Test-Path "$Target\.claude\settings.json") {
    Write-Host "    .claude/settings.json exists, merge manually to avoid overwriting"
  } else {
    Copy-Item "$HubDir\.claude\settings.json" "$Target\.claude\"
    Write-Host "    .claude/settings.json created"
  }
}

$skillList = (Get-ChildItem "$Target\.agent\skills" -Name) -replace '\.md$', '' -join ', '
Write-Host "==> Done. Skills: $skillList"
