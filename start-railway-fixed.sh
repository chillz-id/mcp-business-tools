#!/bin/sh

# Fixed Railway-compatible startup script for MCP Business Tools
echo "🚀 Starting MCP Business Tools for Railway..."

# Railway Port Configuration
export RAILWAY_PORT=${PORT:-8080}
echo "📍 Railway assigned port: $RAILWAY_PORT"

# Start MCP servers in background on different internal ports
echo "📝 Starting Notion MCP server on port 3001..."
PORT=3001 NOTION_API_KEY="$NOTION_API_KEY" npx @modelcontextprotocol/server-notion &
NOTION_PID=$!

echo "🔗 Starting GitHub MCP server on port 3002..."
PORT=3002 GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" npx @modelcontextprotocol/server-github &
GITHUB_PID=$!

echo "📁 Starting Filesystem MCP server on port 3003..."
PORT=3003 npx @modelcontextprotocol/server-filesystem &
FS_PID=$!

echo "📊 Starting Metricool MCP server on port 3004..."
PORT=3004 METRICOOL_USER_TOKEN="$METRICOOL_USER_TOKEN" METRICOOL_USER_ID="$METRICOOL_USER_ID" /root/.local/bin/mcp-metricool &
METRICOOL_PID=$!

echo "💾 Starting Google Drive MCP server on port 3007..."
PORT=3007 GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" GOOGLE_REFRESH_TOKEN="$GOOGLE_REFRESH_TOKEN" npx @modelcontextprotocol/server-gdrive &
GDRIVE_PID=$!

# Enhanced health checking for services
echo "⏳ Waiting for MCP services to initialize..."
sleep 15

# Check if services are running
check_service() {
    local port=$1
    local service_name=$2
    if nc -z localhost $port 2>/dev/null; then
        echo "✅ $service_name service is running on port $port"
        return 0
    else
        echo "❌ $service_name service failed to start on port $port"
        return 1
    fi
}

# Install netcat for health checks if not available
apk add --no-cache netcat-openbsd 2>/dev/null || true

# Verify all services are running
echo "🔍 Checking service health..."
check_service 3001 "Notion"
check_service 3002 "GitHub" 
check_service 3003 "Filesystem"
check_service 3004 "Metricool"
check_service 3007 "Google Drive"

# Start the gateway with proper Railway configuration
echo "🌐 Starting MCP Gateway on Railway port $RAILWAY_PORT..."
cd /app/gateway

# Use the fixed Railway server configuration
cp server-railway-fixed.js server.js

# Set environment variables for Railway
export NODE_ENV=production
export PORT=$RAILWAY_PORT
export HOST=0.0.0.0

# Graceful shutdown handler
trap 'echo "Shutting down services..." && kill $NOTION_PID $GITHUB_PID $FS_PID $METRICOOL_PID $GDRIVE_PID 2>/dev/null && exit 0' TERM INT

# Start the gateway (this runs in foreground to keep container alive)
echo "✅ All services started, launching gateway on 0.0.0.0:$RAILWAY_PORT..."
node server.js
