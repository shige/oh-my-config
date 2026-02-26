#!/usr/bin/env bash
set -euo pipefail

echo "=== Git Commit Signing Setup ==="

# Git user config
GIT_NAME=$(git config --global user.name 2>/dev/null || true)
GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [[ -n "${GIT_NAME}" ]]; then
  echo "Git user.name already set: ${GIT_NAME}"
else
  read -rp "Git user.name: " GIT_NAME
  git config --global user.name "${GIT_NAME}"
fi

if [[ -n "${GIT_EMAIL}" ]]; then
  echo "Git user.email already set: ${GIT_EMAIL}"
else
  read -rp "Git user.email: " GIT_EMAIL
  git config --global user.email "${GIT_EMAIL}"
fi

# Generate SSH key for commit signing
SSH_KEY="${HOME}/.ssh/id_ed25519"
if [[ -f "${SSH_KEY}" ]]; then
  echo "SSH key already exists at ${SSH_KEY}, skipping generation"
else
  echo "Generating SSH key"
  ssh-keygen -t ed25519 -C "${GIT_EMAIL}" -f "${SSH_KEY}" -N ""
fi

# Configure Git to use SSH signing
git config --global gpg.format ssh
git config --global user.signingkey "${SSH_KEY}.pub"
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# Set up allowed_signers for local signature verification
ALLOWED_SIGNERS="${HOME}/.ssh/allowed_signers"
SIGNER_ENTRY="${GIT_EMAIL} $(cat "${SSH_KEY}.pub")"
if [[ -f "${ALLOWED_SIGNERS}" ]] && grep -qF "${GIT_EMAIL}" "${ALLOWED_SIGNERS}"; then
  echo "allowed_signers entry already exists, skipping"
else
  echo "${SIGNER_ENTRY}" >> "${ALLOWED_SIGNERS}"
fi
git config --global gpg.ssh.allowedSignersFile "${ALLOWED_SIGNERS}"

# Register signing key on GitHub
echo "Registering SSH signing key on GitHub"
if ! gh auth status &>/dev/null; then
  echo "GitHub CLI is not authenticated. Run 'gh auth login' first."
  exit 1
fi

# Ensure the required scope is available
if ! gh ssh-key list --type signing &>/dev/null 2>&1; then
  echo "Adding admin:ssh_signing_key scope to GitHub CLI"
  gh auth refresh -h github.com -s admin:ssh_signing_key
fi

FINGERPRINT=$(ssh-keygen -lf "${SSH_KEY}.pub" | awk '{print $2}')
if gh ssh-key list --type signing 2>/dev/null | grep -q "${FINGERPRINT}"; then
  echo "SSH signing key already registered on GitHub, skipping"
else
  read -rp "GitHub signing key title (e.g. 'MacBook Pro 2023'): " KEY_TITLE
  gh ssh-key add "${SSH_KEY}.pub" --title "${KEY_TITLE}" --type signing
fi

echo "Done. All commits will now be signed automatically."
