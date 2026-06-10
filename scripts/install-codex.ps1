$ErrorActionPreference = "Stop"

$McpName = "personal-crm-intake"
$McpUrl = "https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $ScriptDir "install-codex-skill.ps1")

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
  Write-Warning "Codex CLI was not found. Install Codex, then run: codex mcp add $McpName --url $McpUrl"
  exit 0
}

codex mcp add $McpName --url $McpUrl
codex mcp list

Write-Host "Installed MCP: $McpName"
Write-Host 'Try: Use $start-crm-pipeline with the attached CSV. Event name: SaaStr 2026.'
