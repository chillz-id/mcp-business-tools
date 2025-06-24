#!/bin/bash

echo "🚀 Starting MCP Business Tools Gateway..."

# Ensure virtual environment is active
export PATH="/opt/venv/bin:$PATH"

# Check if Metricool MCP is available and install it
echo "📦 Installing Metricool MCP server..."
if command -v uv &> /dev/null; then
    uv tool install mcp-metricool || echo "⚠️  Metricool MCP installation failed"
else
    echo "⚠️  uv not available"
fi

# Show status
echo "📋 Service Status:"
echo "✅ MCP Gateway will start on port 8080"
echo "📊 Metricool MCP server available via gateway"
echo "🔧 Add more MCP servers as packages become available"

# Start the gateway
echo "🌐 Starting MCP Gateway on port 8080..."
cd /app/gateway
exec node server.js