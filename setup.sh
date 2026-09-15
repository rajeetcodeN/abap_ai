#!/usr/bin/env bash
# ==============================================================================
# abap_ai: Automated 1-Click Setup Script for macOS / Linux / WSL
# ==============================================================================

set -e

echo ""
echo "🚀 Starting abap_ai automated setup..."
echo ""

# 1. Check Node.js
echo "[1/5] Checking Node.js runtime..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed! Please install Node.js v18+ from https://nodejs.org"
    exit 1
fi
echo "  ✅ Node.js is installed ($(node -v))"

# 2. Install dependencies & build MCP server
echo ""
echo "[2/5] Installing MCP server dependencies and compiling TypeScript..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
MCP_DIR="$SCRIPT_DIR/mcp-sap-adt"

if [ ! -d "$MCP_DIR" ]; then
    echo "❌ Directory '$MCP_DIR' does not exist!"
    exit 1
fi

cd "$MCP_DIR"
npm install
npm run build
echo "  ✅ MCP server compiled successfully!"

# 3. Setup .env file
echo ""
echo "[3/5] Setting up environment credentials..."
ENV_FILE="$MCP_DIR/.env"
ENV_EXAMPLE="$MCP_DIR/.env.example"

if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_EXAMPLE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        echo "  ✅ Created .env from .env.example"
        echo "  ⚠️  IMPORTANT: Please edit '$ENV_FILE' to set your SAP host, user & password!"
    fi
else
    echo "  ✅ Existing .env found"
fi

# 4. Automatically Register in Antigravity mcp_config.json
echo ""
echo "[4/5] Configuring Antigravity MCP integration..."
CONFIG_DIR="$HOME/.gemini/config"
CONFIG_FILE="$CONFIG_DIR/mcp_config.json"
mkdir -p "$CONFIG_DIR"

MCP_INDEX_PATH="$MCP_DIR/dist/index.js"

# Use node to safely inject the configuration into mcp_config.json
node -e "
const fs = require('fs');
const path = '$CONFIG_FILE';
let data = { mcpServers: {} };
if (fs.existsSync(path)) {
  try {
    const raw = fs.readFileSync(path, 'utf8');
    if (raw && raw.trim().length > 0) data = JSON.parse(raw);
  } catch (e) {}
}
if (!data.mcpServers) data.mcpServers = {};
data.mcpServers['sap-adt'] = {
  command: 'node',
  args: ['$MCP_INDEX_PATH']
};
fs.writeFileSync(path, JSON.stringify(data, null, 2), 'utf8');
"

echo "  ✅ Registered 'sap-adt' MCP server in: $CONFIG_FILE"
echo "  Target script: $MCP_INDEX_PATH"

# 5. Summary
echo ""
echo "=============================================================================="
echo "🎉 abap_ai Setup Complete!"
echo "=============================================================================="
echo "Next steps:"
echo "  1. Open '$ENV_FILE' and configure your SAP URL, client, user, and password."
echo "  2. Test connection: cd mcp-sap-adt && npm run test:ping"
echo "  3. Open this folder in Antigravity and start pair programming with ABAP!"
echo "=============================================================================="
echo ""
