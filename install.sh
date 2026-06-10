#!/usr/bin/env bash
set -euo pipefail

MCP_NAME="personal-crm-intake"
MCP_URL="https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp"
RAW_BASE="${PERSONAL_CRM_MCP_RAW_BASE:-https://cdn.jsdelivr.net/gh/zabrodsk/personal-crm-mcp@main}"
CODEX_HOME_DIR="${CODEX_HOME:-"${HOME}/.codex"}"
SKILL_DIR="${CODEX_HOME_DIR}/skills/start-crm-pipeline"

download() {
  local url="$1"
  local target="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$target"
    return
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -qO "$target" "$url"
    return
  fi
  echo "Install needs curl or wget to download the bundled skill." >&2
  exit 1
}

mkdir -p "${SKILL_DIR}/agents"
download "${RAW_BASE}/skills/start-crm-pipeline/SKILL.md" "${SKILL_DIR}/SKILL.md"
download "${RAW_BASE}/skills/start-crm-pipeline/agents/openai.yaml" "${SKILL_DIR}/agents/openai.yaml"

echo "Installed Codex skill: ${SKILL_DIR}"

if command -v codex >/dev/null 2>&1; then
  if codex mcp add "${MCP_NAME}" --url "${MCP_URL}"; then
    echo "Configured Codex MCP: ${MCP_NAME}"
  else
    echo "Codex MCP add did not complete. If it already exists, run: codex mcp list" >&2
  fi
else
  echo "Codex CLI not found; installed the skill only."
fi

if command -v claude >/dev/null 2>&1; then
  if claude mcp add --transport http --scope user "${MCP_NAME}" "${MCP_URL}"; then
    echo "Configured Claude Code MCP: ${MCP_NAME}"
  else
    echo "Claude MCP add did not complete. If it already exists, run /mcp in Claude Code." >&2
  fi
fi

echo
echo 'Try in Codex: Use $start-crm-pipeline with the attached CSV. Event name: SaaStr 2026.'
