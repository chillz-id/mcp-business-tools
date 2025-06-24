#!/bin/bash

echo "🚀 Starting MCP Business Tools Gateway with ALL services..."

# Ensure virtual environment is active
export PATH="/opt/venv/bin:$PATH"

# Create logs directory
mkdir -p /app/logs

# Function to start a service and log output
start_service() {
    local name=$1
    local command=$2
    local port=$3
    
    echo "📦 Starting $name on port $port..."
    $command > /app/logs/${name}.log 2>&1 &
    local pid=$!
    echo "$name started with PID $pid"
    
    # Give service time to start
    sleep 2
    
    # Check if process is still running
    if ps -p $pid > /dev/null; then
        echo "✅ $name is running"
    else
        echo "❌ $name failed to start"
        cat /app/logs/${name}.log
    fi
}

# Install and start MCP services
echo "📋 Installing MCP packages..."

# Install Node.js MCP servers globally
npm install -g @modelcontextprotocol/server-notion @modelcontextprotocol/server-github @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-gdrive @canva/mcp-server @wix/mcp 2>/dev/null || echo "⚠️  Some npm packages may not be available yet"

# Install Python MCP servers
pip install uv 2>/dev/null || echo "⚠️  UV already installed"
uv tool install mcp-metricool 2>/dev/null || echo "⚠️  Metricool MCP installation failed"

echo "🔧 Starting individual MCP services..."

# Start services on different ports (Railway will expose via localhost)
# Note: Using different ports to avoid conflicts

# Core Business Tools
if command -v npx &> /dev/null; then
    start_service "notion-mcp" "npx @modelcontextprotocol/server-notion" 3001
    start_service "github-mcp" "npx @modelcontextprotocol/server-github" 3002  
    start_service "filesystem-mcp" "npx @modelcontextprotocol/server-filesystem" 3003
    start_service "gdrive-mcp" "npx @modelcontextprotocol/server-gdrive" 3007
    start_service "canva-mcp" "npx @canva/mcp-server" 3005
    start_service "wix-mcp" "npx @wix/mcp" 3006
fi

# Analytics & Social Media (Python)
if command -v uvx &> /dev/null; then
    start_service "metricool-mcp" "uvx mcp-metricool" 3004
fi

# Wait for all services to fully initialize
echo "⏳ Waiting for services to initialize..."
sleep 10

# Show service status
echo "📊 Service Status:"
for port in 3001 3002 3003 3004 3005 3006 3007; do
    if netstat -tuln 2>/dev/null | grep ":$port " > /dev/null; then
        echo "✅ Service running on port $port"
    else
        echo "❌ No service on port $port"
    fi
done

# Start the gateway (foreground process)
echo "🌐 Starting MCP Gateway on port 8080..."
cd /app/gateway

# Update gateway to use localhost instead of container names
export NODE_ENV=production
export MCP_NOTION_URL="http://localhost:3001"
export MCP_GITHUB_URL="http://localhost:3002"
export MCP_FILESYSTEM_URL="http://localhost:3003"
export MCP_METRICOOL_URL="http://localhost:3004"
export MCP_CANVA_URL="http://localhost:3005"
export MCP_WIX_URL="http://localhost:3006"
export MCP_GDRIVE_URL="http://localhost:3007"

echo "🎯 Gateway will proxy to localhost services"
echo "📍 Health check: http://localhost:8080/health"

# Start gateway in foreground
exec node server.js