#!/bin/bash

echo "🚀 Starting MCP Business Tools..."

# Function to start MCP server with retry logic
start_mcp_server() {
    local name=$1
    local command=$2
    local port=$3
    
    echo "Starting $name on port $port..."
    
    # Start the server in background
    eval "$command" &
    local pid=$!
    
    # Wait a moment for startup
    sleep 2
    
    # Check if process is still running
    if kill -0 $pid 2>/dev/null; then
        echo "✅ $name started successfully (PID: $pid)"
    else
        echo "❌ $name failed to start"
    fi
}

# Start core business tools
start_mcp_server "Notion MCP" "PORT=3001 npx @modelcontextprotocol/server-notion" 3001
start_mcp_server "GitHub MCP" "PORT=3002 npx @modelcontextprotocol/server-github" 3002
start_mcp_server "Filesystem MCP" "PORT=3003 npx @modelcontextprotocol/server-filesystem" 3003

# Start analytics tools
if command -v uvx &> /dev/null; then
    start_mcp_server "Metricool MCP" "PORT=3004 uvx mcp-metricool" 3004
else
    echo "⚠️  uvx not found, skipping Metricool MCP"
fi

# Start creative tools (these might not be available yet)
if npm list -g @canva/mcp-server &> /dev/null; then
    start_mcp_server "Canva MCP" "PORT=3005 npx @canva/mcp-server" 3005
else
    echo "⚠️  Canva MCP not available, skipping"
fi

if npm list -g @wix/mcp &> /dev/null; then
    start_mcp_server "WIX MCP" "PORT=3006 npx @wix/mcp" 3006
else
    echo "⚠️  WIX MCP not available, skipping"
fi

# Start storage tools
start_mcp_server "Google Drive MCP" "PORT=3007 npx @modelcontextprotocol/server-gdrive" 3007

# Wait for services to fully start
echo "⏳ Waiting for MCP servers to initialize..."
sleep 5

# Start the gateway
echo "🌐 Starting MCP Gateway..."
cd /app/gateway
exec node server.js