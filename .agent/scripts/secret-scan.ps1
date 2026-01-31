# Secret Scanning Script
# Detects secrets and credentials in code before commit
# References: .agent/secret-scanning.yml

param(
    [switch]$Staged,
    [switch]$All,
    [string]$File,
    [switch]$Help
)

# Colors for output
$Red = "Red"
$Yellow = "Yellow"
$Green = "Green"
$Cyan = "Cyan"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "Secret Scanning Script" $Cyan
    Write-ColorOutput "======================" $Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\secret-scan.ps1 -Staged    # Scan staged files only"
    Write-Host "  .\secret-scan.ps1 -All       # Scan all files in project"
    Write-Host "  .\secret-scan.ps1 -File <path>  # Scan specific file"
    Write-Host "  .\secret-scan.ps1 -Help      # Show this help"
    Write-Host ""
}

# Secret patterns to detect
$Patterns = @(
    # Cloud Provider Keys
    @{ Name = "AWS Access Key ID"; Pattern = "AKIA[0-9A-Z]{16}"; Severity = "CRITICAL" },
    @{ Name = "AWS Secret Access Key"; Pattern = "[0-9a-zA-Z/+]{40}"; Severity = "CRITICAL"; Context = "aws|secret" },
    @{ Name = "GCP API Key"; Pattern = "AIza[0-9A-Za-z_-]{35}"; Severity = "CRITICAL" },
    
    # API Tokens
    @{ Name = "Stripe Live Key"; Pattern = "sk_live_[0-9a-zA-Z]{24,}"; Severity = "CRITICAL" },
    @{ Name = "Stripe Test Key"; Pattern = "sk_test_[0-9a-zA-Z]{24,}"; Severity = "WARNING" },
    @{ Name = "GitHub Token"; Pattern = "ghp_[0-9a-zA-Z]{36}"; Severity = "CRITICAL" },
    @{ Name = "GitHub OAuth"; Pattern = "gho_[0-9a-zA-Z]{36}"; Severity = "CRITICAL" },
    @{ Name = "GitLab Token"; Pattern = "glpat-[0-9a-zA-Z_-]{20}"; Severity = "CRITICAL" },
    @{ Name = "Slack Token"; Pattern = "xox[baprs]-[0-9a-zA-Z]{10,}"; Severity = "CRITICAL" },
    @{ Name = "SendGrid Key"; Pattern = "SG\.[0-9A-Za-z_-]{22}\.[0-9A-Za-z_-]{43}"; Severity = "CRITICAL" },
    
    # Database
    @{ Name = "Database URL with Password"; Pattern = "(mysql|postgres|mongodb)://[^:]+:[^@]+@"; Severity = "CRITICAL" },
    @{ Name = "Database Password"; Pattern = "DB_PASSWORD\s*=\s*[`"']?[^`"'\s]{8,}"; Severity = "CRITICAL" },
    
    # Private Keys
    @{ Name = "RSA Private Key"; Pattern = "-----BEGIN RSA PRIVATE KEY-----"; Severity = "CRITICAL" },
    @{ Name = "SSH Private Key"; Pattern = "-----BEGIN OPENSSH PRIVATE KEY-----"; Severity = "CRITICAL" },
    @{ Name = "PGP Private Key"; Pattern = "-----BEGIN PGP PRIVATE KEY BLOCK-----"; Severity = "CRITICAL" },
    
    # Generic
    @{ Name = "Password Assignment"; Pattern = "(password|passwd|pwd)\s*[=:]\s*[`"'][^`"']{8,}[`"']"; Severity = "HIGH" },
    @{ Name = "Secret Assignment"; Pattern = "(secret|api_key|apikey|access_token)\s*[=:]\s*[`"'][^`"']+[`"']"; Severity = "HIGH" },
    @{ Name = "Hardcoded Credential"; Pattern = "(credential|auth_token|private_key)\s*[=:]\s*[`"'][^`"']+[`"']"; Severity = "HIGH" }
)

# Excluded patterns (false positives)
$ExcludedPatterns = @(
    "test_",
    "example_",
    "sample_",
    "demo_",
    "fake_",
    "mock_",
    "placeholder",
    "your_api_key_here",
    "xxx",
    "YOUR_"
)

# Excluded files and directories
$ExcludedPaths = @(
    "node_modules",
    "vendor",
    ".git",
    "dist",
    "build",
    "coverage",
    "*.md",
    "*.txt",
    ".env.example",
    "*.test.*",
    "*.spec.*"
)

function Test-ExcludedPath {
    param([string]$Path)
    
    foreach ($excluded in $ExcludedPaths) {
        if ($Path -like "*$excluded*") {
            return $true
        }
    }
    return $false
}

function Test-ExcludedMatch {
    param([string]$Match)
    
    foreach ($excluded in $ExcludedPatterns) {
        if ($Match -like "*$excluded*") {
            return $true
        }
    }
    return $false
}

function Scan-File {
    param([string]$FilePath)
    
    $findings = @()
    
    if (-not (Test-Path $FilePath)) {
        return $findings
    }
    
    if (Test-ExcludedPath $FilePath) {
        return $findings
    }
    
    try {
        $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
        if (-not $content) {
            return $findings
        }
        
        $lineNumber = 0
        $lines = Get-Content $FilePath -ErrorAction SilentlyContinue
        
        foreach ($line in $lines) {
            $lineNumber++
            
            foreach ($patternInfo in $Patterns) {
                if ($line -match $patternInfo.Pattern) {
                    $match = $Matches[0]
                    
                    # Skip if excluded
                    if (Test-ExcludedMatch $match) {
                        continue
                    }
                    
                    # Check context if required
                    if ($patternInfo.Context) {
                        if ($content -notmatch $patternInfo.Context) {
                            continue
                        }
                    }
                    
                    $findings += @{
                        File = $FilePath
                        Line = $lineNumber
                        Pattern = $patternInfo.Name
                        Severity = $patternInfo.Severity
                        Match = $match.Substring(0, [Math]::Min(20, $match.Length)) + "..."
                    }
                }
            }
        }
    }
    catch {
        # Skip unreadable files
    }
    
    return $findings
}

function Get-FilesToScan {
    if ($File) {
        return @($File)
    }
    elseif ($Staged) {
        $stagedFiles = git diff --cached --name-only 2>$null
        return $stagedFiles
    }
    else {
        # All files in project (excluding common non-code)
        $files = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { 
                $_.Extension -match '\.(php|js|ts|tsx|jsx|json|yml|yaml|env|py|rb|go|java|cs|sh|ps1)$' -and
                -not (Test-ExcludedPath $_.FullName)
            } |
            Select-Object -ExpandProperty FullName
        return $files
    }
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Write-ColorOutput "🔐 Secret Scanning Started..." $Cyan
Write-Host ""

$files = Get-FilesToScan
$allFindings = @()

$fileCount = 0
foreach ($file in $files) {
    $fileCount++
    $findings = Scan-File $file
    $allFindings += $findings
}

Write-Host "Scanned $fileCount files"
Write-Host ""

# Report findings
$criticalCount = ($allFindings | Where-Object { $_.Severity -eq "CRITICAL" }).Count
$highCount = ($allFindings | Where-Object { $_.Severity -eq "HIGH" }).Count
$warningCount = ($allFindings | Where-Object { $_.Severity -eq "WARNING" }).Count

if ($allFindings.Count -eq 0) {
    Write-ColorOutput "✅ Secret Scan: PASSED" $Green
    Write-Host "No secrets detected in $fileCount files"
    exit 0
}
else {
    Write-ColorOutput "❌ Secret Scan: FAILED" $Red
    Write-Host ""
    Write-Host "Issues Found:"
    Write-Host "  🔴 CRITICAL: $criticalCount"
    Write-Host "  🟠 HIGH: $highCount"
    Write-Host "  🟡 WARNING: $warningCount"
    Write-Host ""
    
    # Group by severity
    $grouped = $allFindings | Group-Object Severity
    
    foreach ($group in $grouped) {
        $color = switch ($group.Name) {
            "CRITICAL" { $Red }
            "HIGH" { $Yellow }
            "WARNING" { $Yellow }
            default { "White" }
        }
        
        Write-ColorOutput "=== $($group.Name) ===" $color
        
        foreach ($finding in $group.Group) {
            Write-Host ""
            Write-Host "File: $($finding.File)"
            Write-Host "Line: $($finding.Line)"
            Write-Host "Type: $($finding.Pattern)"
            Write-Host "Match: $($finding.Match)"
        }
        Write-Host ""
    }
    
    Write-ColorOutput "To fix:" $Cyan
    Write-Host "1. Remove the secret from code"
    Write-Host "2. Use environment variables instead"
    Write-Host '3. Add to .env (never commit .env!)'
    Write-Host ""
    Write-Host "If false positive, add to .secretscanignore"
    
    if ($criticalCount -gt 0 -or $highCount -gt 0) {
        exit 1
    }
    else {
        exit 0
    }
}
