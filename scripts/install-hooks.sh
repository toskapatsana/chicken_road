#!/bin/bash
# Install git hooks for Zero-Trace Policy

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

echo "Installing Zero-Trace git hooks..."

# Copy pre-commit hook
cp "$SCRIPT_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
chmod +x "$GIT_HOOKS_DIR/pre-commit"
echo "✅ Installed pre-commit hook"

# Copy pre-push hook
cp "$SCRIPT_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"
chmod +x "$GIT_HOOKS_DIR/pre-push"
echo "✅ Installed pre-push hook"

echo ""
echo "🎉 Git hooks installed successfully!"
echo "   Hooks will run automatically on commit and push."
