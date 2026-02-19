#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MISE_CONFIG_DIR="${HOME}/.config/mise"

echo "Creating ${MISE_CONFIG_DIR}"
mkdir -p "${MISE_CONFIG_DIR}"

echo "Linking config.toml"
ln -sf "${SCRIPT_DIR}/config.toml" "${MISE_CONFIG_DIR}/config.toml"

echo "Trusting config"
mise trust "${MISE_CONFIG_DIR}/config.toml"

echo "Installing tools"
mise install

echo "Installing Claude Code"
# https://code.claude.com/docs/en/setup#installation
curl -fsSL https://claude.ai/install.sh | bash

echo "Done"
