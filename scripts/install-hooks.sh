#!/bin/bash
#
# Install git hooks for Zero-Trace Policy
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

echo "Installing Zero-Trace git hooks..."

# Create pre-commit hook
cat > "$GIT_HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Zero-Trace Policy: Pre-commit hook

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

if [ -f "$PROJECT_ROOT/scripts/check-secrets.sh" ]; then
    bash "$PROJECT_ROOT/scripts/check-secrets.sh"
else
    echo "Warning: check-secrets.sh not found"
    exit 0
fi
EOF

chmod +x "$GIT_HOOKS_DIR/pre-commit"

# Create pre-push hook
cat > "$GIT_HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash
# Zero-Trace Policy: Pre-push hook

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

echo "🔍 Running pre-push Zero-Trace checks..."

# Run the same checks as pre-commit
if [ -f "$PROJECT_ROOT/scripts/check-secrets.sh" ]; then
    bash "$PROJECT_ROOT/scripts/check-secrets.sh"
fi

# Additional check: ensure no untracked files that should be ignored
echo -n "Checking for files that should be ignored... "
UNTRACKED=$(git status --porcelain | grep '^??' | grep -E '\.(env|p8|p12|cer|mobileprovision|jks|keystore)$' || true)
if [ -n "$UNTRACKED" ]; then
    echo "WARNING"
    echo "⚠️  Untracked sensitive files found (consider adding to .gitignore):"
    echo "$UNTRACKED"
fi

echo "OK"
EOF

chmod +x "$GIT_HOOKS_DIR/pre-push"

echo "✅ Git hooks installed successfully!"
echo "   - pre-commit: Checks for secrets and metadata"
echo "   - pre-push: Additional verification before push"
