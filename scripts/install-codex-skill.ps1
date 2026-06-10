$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SourceDir = Join-Path $RepoRoot "skills/start-crm-pipeline"

if ($env:CODEX_HOME) {
  $CodexHome = $env:CODEX_HOME
} else {
  $CodexHome = Join-Path $HOME ".codex"
}

$TargetDir = Join-Path $CodexHome "skills/start-crm-pipeline"

if (-not (Test-Path (Join-Path $SourceDir "SKILL.md"))) {
  throw "Cannot find bundled skill at $SourceDir"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TargetDir) | Out-Null
if (Test-Path $TargetDir) {
  Remove-Item -Recurse -Force $TargetDir
}
Copy-Item -Recurse $SourceDir $TargetDir

Write-Host "Installed Codex skill: $TargetDir"
Write-Host 'Use it with: Use $start-crm-pipeline with the attached CSV. Event name: SaaStr 2026.'
