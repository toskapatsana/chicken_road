#!/bin/bash
#
# ZERO-TRACE POLICY: Check for secrets and metadata leaks
# Run this before committing
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Running Zero-Trace security checks..."

FAILED=0

# Check for absolute paths
echo -n "Checking for absolute paths... "
if git diff --cached --diff-filter=ACMR | grep -E '(/Users/|/home/|C:\\Users\\|/private/|/var/|\\AppData\\|[A-Z]:\\)' > /dev/null 2>&1; then
    echo -e "${RED}FAILED${NC}"
    echo "❌ Found absolute paths in staged changes!"
    git diff --cached --diff-filter=ACMR | grep -n -E '(/Users/|/home/|C:\\Users\\|/private/|/var/|\\AppData\\|[A-Z]:\\)' || true
    FAILED=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for secrets patterns
echo -n "Checking for secret patterns... "
if git diff --cached --diff-filter=ACMR | grep -iE '(api_key|apikey|secret|token|password|passwd|pwd)\s*[:=]\s*["\x27]?[a-zA-Z0-9]' > /dev/null 2>&1; then
    echo -e "${RED}FAILED${NC}"
    echo "❌ Found potential secrets in staged changes!"
    FAILED=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for private keys
echo -n "Checking for private keys... "
if git diff --cached --diff-filter=ACMR | grep -E '-----BEGIN (PRIVATE KEY|RSA PRIVATE KEY|EC PRIVATE KEY|OPENSSH PRIVATE KEY)-----' > /dev/null 2>&1; then
    echo -e "${RED}FAILED${NC}"
    echo "❌ Found private keys in staged changes!"
    FAILED=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for forbidden file types
echo -n "Checking for forbidden files... "
FORBIDDEN_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(p8|p12|cer|crt|der|mobileprovision|jks|keystore|env)$' || true)
if [ -n "$FORBIDDEN_FILES" ]; then
    echo -e "${RED}FAILED${NC}"
    echo "❌ Forbidden files detected:"
    echo "$FORBIDDEN_FILES"
    FAILED=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for Google/Firebase service accounts
echo -n "Checking for service accounts... "
if git diff --cached --diff-filter=ACMR | grep -E '"type"\s*:\s*"service_account"' > /dev/null 2>&1; then
    echo -e "${RED}FAILED${NC}"
    echo "❌ Found service account JSON in staged changes!"
    FAILED=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for sensitive file names
echo -n "Checking for sensitive filenames... "
SENSITIVE_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -iE '(google-services\.json|GoogleService-Info\.plist|local\.properties|\.env)' || true)
if [ -n "$SENSITIVE_FILES" ]; then
    echo -e "${RED}FAILED${NC}"
    echo "❌ Sensitive files detected:"
    echo "$SENSITIVE_FILES"
    FAILED=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for IDE user state
echo -n "Checking for IDE user state... "
IDE_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '(xcuserdata|\.idea|\.vscode|workspace\.xml|\.iml)' || true)
if [ -n "$IDE_FILES" ]; then
    echo -e "${YELLOW}WARNING${NC}"
    echo "⚠️  IDE/workspace files detected (should be in .gitignore):"
    echo "$IDE_FILES"
    FAILED=1
else
    echo -e "${GREEN}OK${NC}"
fi

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}❌ Zero-Trace checks FAILED!${NC}"
    echo "Please remove sensitive data before committing."
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ All Zero-Trace checks passed!${NC}"
    exit 0
fi
