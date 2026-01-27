#
# ZERO-TRACE POLICY: Check for secrets and metadata leaks (PowerShell)
# Run this before committing
#

$ErrorActionPreference = "Stop"

Write-Host "🔍 Running Zero-Trace security checks..." -ForegroundColor Cyan

$Failed = $false

# Get staged diff
$StagedDiff = git diff --cached --diff-filter=ACMR 2>$null
$StagedFiles = git diff --cached --name-only --diff-filter=ACMR 2>$null

# Check for absolute paths
Write-Host -NoNewline "Checking for absolute paths... "
$AbsolutePathPatterns = @(
    '/Users/',
    '/home/',
    'C:\\Users\\',
    'C:/Users/',
    '/private/',
    '/var/',
    '\\AppData\\',
    '/AppData/'
)
$FoundAbsolutePath = $false
foreach ($pattern in $AbsolutePathPatterns) {
    if ($StagedDiff -match [regex]::Escape($pattern)) {
        $FoundAbsolutePath = $true
        break
    }
}
if ($FoundAbsolutePath) {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "❌ Found absolute paths in staged changes!" -ForegroundColor Red
    $Failed = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

# Check for secrets patterns
Write-Host -NoNewline "Checking for secret patterns... "
$SecretPatterns = @(
    'api[_-]?key\s*[:=]',
    'secret\s*[:=]',
    'token\s*[:=]',
    'password\s*[:=]',
    'passwd\s*[:=]'
)
$FoundSecret = $false
foreach ($pattern in $SecretPatterns) {
    if ($StagedDiff -match $pattern) {
        $FoundSecret = $true
        break
    }
}
if ($FoundSecret) {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "❌ Found potential secrets in staged changes!" -ForegroundColor Red
    $Failed = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

# Check for private keys
Write-Host -NoNewline "Checking for private keys... "
if ($StagedDiff -match '-----BEGIN (PRIVATE KEY|RSA PRIVATE KEY|EC PRIVATE KEY|OPENSSH PRIVATE KEY)-----') {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "❌ Found private keys in staged changes!" -ForegroundColor Red
    $Failed = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

# Check for forbidden file types
Write-Host -NoNewline "Checking for forbidden files... "
$ForbiddenExtensions = @('.p8', '.p12', '.cer', '.crt', '.der', '.mobileprovision', '.jks', '.keystore', '.env')
$ForbiddenFiles = @()
foreach ($file in $StagedFiles) {
    foreach ($ext in $ForbiddenExtensions) {
        if ($file -like "*$ext") {
            $ForbiddenFiles += $file
        }
    }
}
if ($ForbiddenFiles.Count -gt 0) {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "❌ Forbidden files detected:" -ForegroundColor Red
    $ForbiddenFiles | ForEach-Object { Write-Host "  $_" }
    $Failed = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

# Check for service accounts
Write-Host -NoNewline "Checking for service accounts... "
if ($StagedDiff -match '"type"\s*:\s*"service_account"') {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "❌ Found service account JSON in staged changes!" -ForegroundColor Red
    $Failed = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

# Check for sensitive filenames
Write-Host -NoNewline "Checking for sensitive filenames... "
$SensitivePatterns = @('google-services.json', 'GoogleService-Info.plist', 'local.properties', '.env')
$SensitiveFiles = @()
foreach ($file in $StagedFiles) {
    foreach ($pattern in $SensitivePatterns) {
        if ($file -like "*$pattern*") {
            $SensitiveFiles += $file
        }
    }
}
if ($SensitiveFiles.Count -gt 0) {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "❌ Sensitive files detected:" -ForegroundColor Red
    $SensitiveFiles | ForEach-Object { Write-Host "  $_" }
    $Failed = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

# Check for IDE user state
Write-Host -NoNewline "Checking for IDE user state... "
$IdePatterns = @('xcuserdata', '.idea', '.vscode', 'workspace.xml', '.iml')
$IdeFiles = @()
foreach ($file in $StagedFiles) {
    foreach ($pattern in $IdePatterns) {
        if ($file -like "*$pattern*") {
            $IdeFiles += $file
        }
    }
}
if ($IdeFiles.Count -gt 0) {
    Write-Host "WARNING" -ForegroundColor Yellow
    Write-Host "⚠️  IDE/workspace files detected (should be in .gitignore):" -ForegroundColor Yellow
    $IdeFiles | ForEach-Object { Write-Host "  $_" }
    $Failed = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

Write-Host ""
if ($Failed) {
    Write-Host "❌ Zero-Trace checks FAILED!" -ForegroundColor Red
    Write-Host "Please remove sensitive data before committing." -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ All Zero-Trace checks passed!" -ForegroundColor Green
    exit 0
}
