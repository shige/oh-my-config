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

echo "Installing AWS CLI"
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
rm -f /tmp/AWSCLIV2.pkg

echo "Installing Claude Code"
# https://code.claude.com/docs/en/setup#installation
curl -fsSL https://claude.ai/install.sh | bash

echo "Installing Gemini CLI security extension"
# https://codenote.net/en/posts/gemini-cli-security-extension/
gemini extensions install https://github.com/gemini-cli-extensions/security

echo "Setting up Git commit signing"
bash "${SCRIPT_DIR}/setup-git-signing.sh"

echo "Done"
