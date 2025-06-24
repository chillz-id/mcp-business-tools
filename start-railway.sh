#!/bin/sh

# Railway-compatible startup script for MCP Business Tools
echo "🚀 Starting MCP Business Tools for Railway..."

# Start MCP servers in background on different ports
echo "📝 Starting Notion MCP server on port 3001..."
PORT=3001 NOTION_API_KEY="$NOTION_API_KEY" npx @modelcontextprotocol/server-notion &

echo "🐙 Starting GitHub MCP server on port 3002..."
PORT=3002 GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" npx @modelcontextprotocol/server-github &

echo "📁 Starting Filesystem MCP server on port 3003..."
PORT=3003 npx @modelcontextprotocol/server-filesystem &

echo "📊 Starting Metricool MCP server on port 3004..."
PORT=3004 METRICOOL_USER_TOKEN="$METRICOOL_USER_TOKEN" METRICOOL_USER_ID="$METRICOOL_USER_ID" /root/.local/bin/mcp-metricool &

echo "💾 Starting Google Drive MCP server on port 3007..."
PORT=3007 GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" GOOGLE_REFRESH_TOKEN="$GOOGLE_REFRESH_TOKEN" npx @modelcontextprotocol/server-gdrive &

# Wait a moment for services to start
echo "⏳ Waiting for MCP services to initialize..."
sleep 10

# Start the gateway with Railway configuration
echo "🌐 Starting MCP Gateway on port 8080..."
cd /app/gateway

# Copy the Railway-specific server file
cp server-railway.js server.js

# Set environment variables for Railway
export NODE_ENV=production
export PORT=8080

# Start the gateway (this runs in foreground to keep container alive)
echo "✅ All services started, launching gateway..."
node server.js
