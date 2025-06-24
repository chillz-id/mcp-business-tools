#!/bin/sh

# Railway-compatible startup script for MCP Business Tools
echo "🚀 Starting MCP Business Tools for Railway..."

# Start MCP servers in background on different ports
echo "📝 Starting Notion MCP server on port 3001..."
NOTION_API_KEY="$NOTION_API_KEY" npx @modelcontextprotocol/server-notion &

echo "🐙 Starting GitHub MCP server on port 3002..."
GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" npx @modelcontextprotocol/server-github &

echo "📁 Starting Filesystem MCP server on port 3003..."
npx @modelcontextprotocol/server-filesystem &

echo "📊 Starting Metricool MCP server on port 3004..."
METRICOOL_USER_TOKEN="$METRICOOL_USER_TOKEN" METRICOOL_USER_ID="$METRICOOL_USER_ID" uv run mcp-metricool &

echo "🎨 Starting Canva MCP server on port 3005..."
CANVA_CLIENT_ID="$CANVA_CLIENT_ID" CANVA_CLIENT_SECRET="$CANVA_CLIENT_SECRET" npx @canva/mcp-server &

echo "🌐 Starting WIX MCP server on port 3006..."
WIX_API_KEY="$WIX_API_KEY" npx @wix/mcp &

echo "💾 Starting Google Drive MCP server on port 3007..."
GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" GOOGLE_REFRESH_TOKEN="$GOOGLE_REFRESH_TOKEN" npx @modelcontextprotocol/server-gdrive &

# Wait a moment for services to start
sleep 5

# Start the gateway with local service endpoints
echo "🌐 Starting MCP Gateway on port 8080..."
cd /app/gateway

# Update the gateway to use localhost instead of container names
export NODE_ENV=production
export PORT=8080

# Start the gateway (this should run in foreground to keep container alive)
npm start
