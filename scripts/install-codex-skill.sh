#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/skills/start-crm-pipeline"
TARGET_DIR="${CODEX_HOME:-"${HOME}/.codex"}/skills/start-crm-pipeline"

if [[ ! -f "${SOURCE_DIR}/SKILL.md" ]]; then
  echo "Cannot find bundled skill at ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "$(dirname "${TARGET_DIR}")"
rm -rf "${TARGET_DIR}"
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

echo "Installed Codex skill: ${TARGET_DIR}"
echo 'Use it with: Use $start-crm-pipeline with the attached CSV. Event name: SaaStr 2026.'
