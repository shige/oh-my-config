#!/usr/bin/env bash
set -euo pipefail

# Check for required argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <owner/repo> or <github-url>"
  echo "Example: $0 shige/oh-my-config"
  echo "         $0 https://github.com/shige/oh-my-config"
  exit 1
fi

# --- Input Variables ---
INPUT="$1"

# Normalize input to owner/repo
if [[ "$INPUT" =~ ^https?:// ]]; then
  # Strip protocol and domain, remove trailing slash or .git
  REPO_PATH="${INPUT#*://github.com/}"
  REPO_PATH="${REPO_PATH%.git}"
  REPO_PATH="${REPO_PATH%/}"
  REPO="$REPO_PATH"
else
  REPO="$INPUT"
fi

# Split owner and repository name
OWNER="${REPO%/*}"
REPO_NAME="${REPO##*/}"

# Base directory, generated dynamically from REPO
BASE_DIR="${HOME}/works/${OWNER}/${REPO_NAME}"

# List of subdirectories to create under worktree
SUBDIRS=(
  claude-code
  cline
  cursor
  github-copilot
  openai-codex
  roo-code
  vscode
  windsurf
  zed
)

# --- Execution ---
echo "🔧 Creating worktree directory: ${BASE_DIR}/worktree"
mkdir -p "${BASE_DIR}/worktree"

for name in "${SUBDIRS[@]}"; do
  TARGET_DIR="${BASE_DIR}/worktree/${name}"
  echo "📁 Creating directory: ${TARGET_DIR}"
  mkdir -p "${TARGET_DIR}"

  echo "⏬ Cloning ${REPO} into ${TARGET_DIR}"
  gh repo clone "${REPO}" "${TARGET_DIR}"
done

echo "✅ Setup complete."
