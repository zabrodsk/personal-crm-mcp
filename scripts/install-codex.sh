#!/usr/bin/env bash
set -euo pipefail

MCP_NAME="personal-crm-intake"
MCP_URL="https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/install-codex-skill.sh"

if ! command -v codex >/dev/null 2>&1; then
  echo "Codex CLI was not found. Install Codex, then run:" >&2
  echo "  codex mcp add ${MCP_NAME} --url ${MCP_URL}" >&2
  exit 0
fi

codex mcp add "${MCP_NAME}" --url "${MCP_URL}"
codex mcp list

echo "Installed MCP: ${MCP_NAME}"
echo 'Try: Use $start-crm-pipeline with the attached CSV. Event name: SaaStr 2026.'
