#!/bin/bash
# ZERO-TRACE POLICY: CI Gate Script
# Run this in CI pipeline to enforce all security requirements

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=============================================="
echo "  ZERO-TRACE POLICY: CI Security Gate"
echo "=============================================="
echo ""

FAILED=0

# ============================================
# A) BLOCK ABSOLUTE PATHS
# ============================================
echo "🔍 [1/6] Checking for absolute paths..."
PATHS_FOUND=$(git grep -r -l -E '(/Users/|/home/|C:\\Users\\|/private/|/var/|\\AppData\\|[A-Z]:\\)' -- '*.dart' '*.swift' '*.kt' '*.java' '*.plist' '*.xml' '*.json' '*.yaml' '*.yml' 2>/dev/null | grep -v '.gitignore' | grep -v 'ci-gate.sh' | grep -v 'pre-commit' | grep -v 'pre-push' || true)
if [ -n "$PATHS_FOUND" ]; then
    echo -e "${RED}   FAILED: Found absolute paths${NC}"
    echo "$PATHS_FOUND"
    FAILED=1
else
    echo -e "${GREEN}   PASSED${NC}"
fi

# ============================================
# B) BLOCK SECRET PATTERNS
# ============================================
echo "🔍 [2/6] Checking for secret patterns..."

# Check for API keys, secrets, tokens with values
SECRETS_FOUND=$(git grep -r -l -iE '(api_key|secret_key|api_secret|private_key|auth_token)\s*[:=]\s*["\047][A-Za-z0-9+/=_-]{10,}["\047]' -- '*.dart' '*.swift' '*.kt' '*.java' '*.json' '*.yaml' '*.yml' 2>/dev/null || true)
if [ -n "$SECRETS_FOUND" ]; then
    echo -e "${RED}   FAILED: Found potential secrets${NC}"
    echo "$SECRETS_FOUND"
    FAILED=1
fi

# Check for private keys
KEYS_FOUND=$(git grep -r -l '-----BEGIN.*PRIVATE KEY-----' 2>/dev/null || true)
if [ -n "$KEYS_FOUND" ]; then
    echo -e "${RED}   FAILED: Found private keys${NC}"
    echo "$KEYS_FOUND"
    FAILED=1
fi

# Check for service account JSON
SA_FOUND=$(git grep -r -l '"type".*:.*"service_account"' 2>/dev/null || true)
if [ -n "$SA_FOUND" ]; then
    echo -e "${RED}   FAILED: Found service account JSON${NC}"
    echo "$SA_FOUND"
    FAILED=1
fi

if [ -z "$SECRETS_FOUND" ] && [ -z "$KEYS_FOUND" ] && [ -z "$SA_FOUND" ]; then
    echo -e "${GREEN}   PASSED${NC}"
fi

# ============================================
# C) CHECK FOR SENSITIVE FILES
# ============================================
echo "🔍 [3/6] Checking for sensitive files..."
SENSITIVE=$(git ls-files | grep -iE '\.(p8|p12|cer|crt|der|mobileprovision|jks|keystore|pem)$' || true)
GOOGLE=$(git ls-files | grep -iE '(GoogleService-Info\.plist|google-services\.json)$' || true)
ENV_FILES=$(git ls-files | grep -iE '^\.env' || true)

if [ -n "$SENSITIVE" ] || [ -n "$GOOGLE" ] || [ -n "$ENV_FILES" ]; then
    echo -e "${RED}   FAILED: Found sensitive files${NC}"
    [ -n "$SENSITIVE" ] && echo "   Certificates/Keys: $SENSITIVE"
    [ -n "$GOOGLE" ] && echo "   Google Services: $GOOGLE"
    [ -n "$ENV_FILES" ] && echo "   Env files: $ENV_FILES"
    FAILED=1
else
    echo -e "${GREEN}   PASSED${NC}"
fi

# ============================================
# D) CHECK iOS DEVICE FAMILY (iPhone only)
# ============================================
echo "🔍 [4/6] Checking iOS device family..."
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    IPAD_FAMILY=$(grep -c 'TARGETED_DEVICE_FAMILY.*=.*"1,2"' ios/Runner.xcodeproj/project.pbxproj 2>/dev/null || echo "0")
    IPAD_FAMILY2=$(grep -c 'TARGETED_DEVICE_FAMILY.*=.*1,2' ios/Runner.xcodeproj/project.pbxproj 2>/dev/null || echo "0")
    
    if [ "$IPAD_FAMILY" -gt 0 ] || [ "$IPAD_FAMILY2" -gt 0 ]; then
        echo -e "${RED}   FAILED: TARGETED_DEVICE_FAMILY includes iPad (should be \"1\" only)${NC}"
        FAILED=1
    else
        echo -e "${GREEN}   PASSED${NC}"
    fi
else
    echo -e "${YELLOW}   SKIPPED: iOS project not found${NC}"
fi

# ============================================
# E) CHECK FOR iPad REFERENCES
# ============================================
echo "🔍 [5/6] Checking for iPad references in iOS..."
if [ -d "ios" ]; then
    IPAD_REFS=$(grep -r -l -i 'ipad' ios/ --include="*.plist" --include="*.json" --include="*.pbxproj" 2>/dev/null | grep -v 'Pods' || true)
    if [ -n "$IPAD_REFS" ]; then
        echo -e "${RED}   FAILED: Found iPad references${NC}"
        echo "$IPAD_REFS"
        FAILED=1
    else
        echo -e "${GREEN}   PASSED${NC}"
    fi
else
    echo -e "${YELLOW}   SKIPPED: iOS directory not found${NC}"
fi

# ============================================
# F) ENFORCE CLEAN WORKTREE
# ============================================
echo "🔍 [6/6] Checking git worktree status..."
DIRTY=$(git status --porcelain 2>/dev/null | grep -v '^??' || true)
if [ -n "$DIRTY" ]; then
    echo -e "${RED}   FAILED: Worktree is dirty${NC}"
    echo "$DIRTY"
    FAILED=1
else
    echo -e "${GREEN}   PASSED${NC}"
fi

# ============================================
# FINAL RESULT
# ============================================
echo ""
echo "=============================================="
if [ $FAILED -eq 1 ]; then
    echo -e "${RED}  ❌ CI GATE FAILED${NC}"
    echo "=============================================="
    exit 1
else
    echo -e "${GREEN}  ✅ CI GATE PASSED${NC}"
    echo "=============================================="
    exit 0
fi
