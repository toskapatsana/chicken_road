# Zero-Trace Security Policy

This repository follows a **Zero-Trace Policy** to prevent any metadata leaks, local paths, IDE traces, build artifacts, logs, caches, machine identifiers, or any environment artifacts from entering version control.

## Principles

1. **Repository contains ONLY source code and deterministic configs**
2. **All generated/local files are excluded from git**
3. **All builds, signing, and uploads happen ONLY in CI**

## What is NEVER Allowed in Git

### Secrets (Critical)
- `.env` files of any kind
- API keys, tokens, passwords
- Certificate files (`.p8`, `.p12`, `.cer`, `.crt`, `.der`)
- Provisioning profiles (`.mobileprovision`)
- Keystore files (`.jks`, `.keystore`)
- Service account JSONs
- Private keys (SSH, GPG, PGP)

### Local Paths / Machine-Specific Data
- Absolute paths (`/Users/`, `/home/`, `C:\Users\`)
- `local.properties`
- Any auto-generated configs with machine-specific values

### IDE / Editor Artifacts
- Xcode: `xcuserdata`, `xcschemes`, user state
- Android Studio/IntelliJ: `.idea`, `*.iml`
- VS Code: `.vscode`
- Any workspace files or user preferences

### Build Artifacts
- Compiled apps (`.ipa`, `.apk`, `.aab`)
- Build directories
- Derived data
- Pods (iOS)
- Gradle cache (Android)

## How Secrets Are Handled

All secrets are managed through:
1. **CI Environment Variables** (masked, protected)
2. **Runtime injection** via `--dart-define` or CI secure files
3. **Rotation** upon any suspected leak

## Pre-Commit Checks

This repository includes pre-commit hooks that block:
- Absolute paths in staged changes
- Common secret patterns
- Private keys
- Forbidden file types
- Service account markers
- Sensitive filenames
- IDE user state files

### Installing Hooks

```bash
# On macOS/Linux
./scripts/install-hooks.sh

# On Windows (PowerShell)
# Run check-secrets.ps1 manually before commits
```

### Manual Check

```bash
# On macOS/Linux
./scripts/check-secrets.sh

# On Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File scripts\check-secrets.ps1
```

## CI Requirements

1. Every build executes from a clean checkout (no reused workspace)
2. All CI caches are isolated and never committed
3. Generated files must be reproducible or ignored
4. No local release builds - only CI

## Reporting Security Issues

If you discover any security vulnerabilities or accidental secrets exposure:
1. **Do NOT create a public issue**
2. Contact the maintainers privately
3. If secrets were committed, rotate them immediately

## Compliance Checklist

Before every commit, ensure:
- [ ] No absolute paths in code
- [ ] No secrets or tokens
- [ ] No IDE/editor files
- [ ] No build artifacts
- [ ] Pre-commit hooks pass
