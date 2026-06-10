$ErrorActionPreference = "Stop"

$McpName = "personal-crm-intake"
$McpUrl = "https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp"
$RawBase = if ($env:PERSONAL_CRM_MCP_RAW_BASE) { $env:PERSONAL_CRM_MCP_RAW_BASE } else { "https://raw.githubusercontent.com/zabrodsk/personal-crm-mcp/main" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$SkillDir = Join-Path $CodexHome "skills/start-crm-pipeline"
$AgentsDir = Join-Path $SkillDir "agents"

New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null

Invoke-WebRequest -UseBasicParsing -Uri "$RawBase/skills/start-crm-pipeline/SKILL.md" -OutFile (Join-Path $SkillDir "SKILL.md")
Invoke-WebRequest -UseBasicParsing -Uri "$RawBase/skills/start-crm-pipeline/agents/openai.yaml" -OutFile (Join-Path $AgentsDir "openai.yaml")

Write-Host "Installed Codex skill: $SkillDir"

if (Get-Command codex -ErrorAction SilentlyContinue) {
  try {
    codex mcp add $McpName --url $McpUrl
    Write-Host "Configured Codex MCP: $McpName"
  } catch {
    Write-Warning "Codex MCP add did not complete. If it already exists, run: codex mcp list"
  }
} else {
  Write-Host "Codex CLI not found; installed the skill only."
}

if (Get-Command claude -ErrorAction SilentlyContinue) {
  try {
    claude mcp add --transport http --scope user $McpName $McpUrl
    Write-Host "Configured Claude Code MCP: $McpName"
  } catch {
    Write-Warning "Claude MCP add did not complete. If it already exists, run /mcp in Claude Code."
  }
}

Write-Host ""
Write-Host 'Try in Codex: Use $start-crm-pipeline with the attached CSV. Event name: SaaStr 2026.'
