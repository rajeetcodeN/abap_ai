# ==============================================================================
# abap_ai: Automated 1-Click Setup Script for Windows
# ==============================================================================
# This script sets up the SAP ADT MCP server and automatically registers it
# with Antigravity on your machine.
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "`nStarting abap_ai automated setup..." -ForegroundColor Cyan

# 1. Check Node.js
Write-Host "`n[1/5] Checking Node.js runtime..." -ForegroundColor Yellow
try {
    $nodeVersion = node -v
    Write-Host "  [OK] Node.js is installed ($nodeVersion)" -ForegroundColor Green
} catch {
    Write-Error "[ERROR] Node.js is not found in PATH! Please install Node.js v18+ from https://nodejs.org"
    exit 1
}

# 2. Install dependencies & build MCP server
Write-Host "`n[2/5] Installing MCP server dependencies and compiling TypeScript..." -ForegroundColor Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mcpDir = Join-Path $scriptDir "mcp-sap-adt"

if (-not (Test-Path $mcpDir)) {
    Write-Error "[ERROR] Directory '$mcpDir' does not exist!"
    exit 1
}

Push-Location $mcpDir
try {
    Write-Host "  -> Running npm install in $mcpDir..."
    npm install
    Write-Host "  -> Running npm run build..."
    npm run build
    Write-Host "  [OK] MCP server compiled successfully!" -ForegroundColor Green
} finally {
    Pop-Location
}

# 3. Setup .env file
Write-Host "`n[3/5] Setting up environment credentials..." -ForegroundColor Yellow
$envFile = Join-Path $mcpDir ".env"
$envExample = Join-Path $mcpDir ".env.example"

if (-not (Test-Path $envFile)) {
    if (Test-Path $envExample) {
        Copy-Item $envExample $envFile
        Write-Host "  [OK] Created .env from .env.example" -ForegroundColor Green
        Write-Host "  [NOTICE] Please edit '$envFile' to set your SAP host, user & password!" -ForegroundColor Magenta
    }
} else {
    Write-Host "  [OK] Existing .env found" -ForegroundColor Green
}

# 4. Automatically Register in Antigravity mcp_config.json
Write-Host "`n[4/5] Configuring Antigravity MCP integration..." -ForegroundColor Yellow

$userHome = [System.Environment]::GetFolderPath('UserProfile')
$geminiConfigDir = Join-Path $userHome ".gemini\config"
$mcpConfigFile = Join-Path $geminiConfigDir "mcp_config.json"

if (-not (Test-Path $geminiConfigDir)) {
    New-Item -ItemType Directory -Path $geminiConfigDir -Force | Out-Null
}

$mcpIndexPath = (Join-Path $mcpDir "dist\index.js") -replace '\\', '/'

$configObj = @{ mcpServers = @{} }

if (Test-Path $mcpConfigFile) {
    try {
        $rawJson = Get-Content $mcpConfigFile -Raw
        if ($rawJson -and $rawJson.Trim().Length -gt 0) {
            $parsed = $rawJson | ConvertFrom-Json
            if ($parsed.mcpServers) {
                foreach ($prop in $parsed.mcpServers.psobject.Properties) {
                    $configObj.mcpServers[$prop.Name] = $prop.Value
                }
            }
        }
    } catch {
        Write-Warning "Could not parse existing mcp_config.json, initializing fresh configuration."
    }
}

# Register sap-adt server with dynamic local path
$configObj.mcpServers["sap-adt"] = @{
    command = "node"
    args = @($mcpIndexPath)
}

$updatedJson = $configObj | ConvertTo-Json -Depth 10
Set-Content -Path $mcpConfigFile -Value $updatedJson -Encoding utf8

Write-Host "  [OK] Registered 'sap-adt' MCP server in: $mcpConfigFile" -ForegroundColor Green
Write-Host "  Target script: $mcpIndexPath" -ForegroundColor Gray

# 5. Summary
Write-Host "`n==============================================================================" -ForegroundColor Green
Write-Host "abap_ai Setup Complete!" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  1. Open '$envFile' and configure your SAP URL, client, user, and password."
Write-Host "  2. Test connection: cd mcp-sap-adt; npm run test:ping"
Write-Host "  3. Open this folder in Antigravity and start pair programming with ABAP!"
Write-Host "==============================================================================`n"
