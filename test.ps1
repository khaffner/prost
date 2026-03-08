#!/usr/bin/env pwsh
#Requires -Version 7.4

<#
.SYNOPSIS
    Run local tests for Prost project
.DESCRIPTION
    This script runs the same tests that GitHub Actions runs in CI.
    Use this before committing to catch issues early.
#>

$ErrorActionPreference = "Stop"

Write-Host "`n🧪 Running Prost Tests`n" -ForegroundColor Cyan

# Check if PSScriptAnalyzer is installed
Write-Host "📦 Checking for PSScriptAnalyzer..." -ForegroundColor Yellow
if (!(Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Host "Installing PSScriptAnalyzer..." -ForegroundColor Yellow
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
}

# Test 1: PSScriptAnalyzer
Write-Host "`n1️⃣  Running PSScriptAnalyzer..." -ForegroundColor Yellow
$results = Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSGallery
if ($results) {
    $results | Format-Table -AutoSize
    Write-Host "❌ PSScriptAnalyzer found $($results.Count) issue(s)" -ForegroundColor Red
    $failed = $true
}
else {
    Write-Host "✅ No issues found by PSScriptAnalyzer" -ForegroundColor Green
}

# Test 2: Syntax Validation
Write-Host "`n2️⃣  Validating PowerShell Syntax..." -ForegroundColor Yellow
$files = Get-ChildItem -Path . -Filter *.ps1 -Recurse
$syntaxErrors = @()
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null)
        Write-Host "  ✅ $($file.Name)" -ForegroundColor Green
    }
    catch {
        $syntaxErrors += $file.Name
        Write-Host "  ❌ $($file.Name) - $_" -ForegroundColor Red
        $failed = $true
    }
}

# Test 3: Version Requirements
Write-Host "`n3️⃣  Checking PowerShell Version Requirements..." -ForegroundColor Yellow
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match '#Requires -Version (\d+\.\d+)') {
        $requiredVersion = [version]$matches[1]
        $currentVersion = $PSVersionTable.PSVersion
        Write-Host "  $($file.Name) requires PS $requiredVersion (current: $currentVersion)" -ForegroundColor Gray
        if ($currentVersion -lt $requiredVersion) {
            Write-Host "  ⚠️  PowerShell $requiredVersion required but $currentVersion detected" -ForegroundColor Yellow
        }
    }
}

# Test 4: Security Scan
Write-Host "`n4️⃣  Running Security Analysis..." -ForegroundColor Yellow
$results = Invoke-ScriptAnalyzer -Path . -Recurse -Severity Error, Warning
$securityIssues = $results | Where-Object { 
    $_.RuleName -like '*Security*' -or 
    $_.RuleName -like '*Credential*' -or 
    $_.RuleName -like '*Password*'
}

if ($securityIssues) {
    Write-Host "⚠️  Security concerns found:" -ForegroundColor Yellow
    $securityIssues | Format-Table -AutoSize
}
else {
    Write-Host "✅ No obvious security issues detected" -ForegroundColor Green
}

# Summary
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
if ($failed) {
    Write-Host "❌ TESTS FAILED" -ForegroundColor Red
    Write-Host "Please fix the issues above before committing." -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "✅ ALL TESTS PASSED" -ForegroundColor Green
    Write-Host "Ready to commit! 🎉" -ForegroundColor Cyan
    exit 0
}
