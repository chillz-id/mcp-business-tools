#!/bin/bash

echo "🚀 Starting MCP Business Tools Gateway (Minimal Working Version)..."

# Ensure virtual environment is active
export PATH="/opt/venv/bin:$PATH"

# Create logs directory
mkdir -p /app/logs

# Function to start a service and log output (Fixed for Alpine Linux)
start_service() {
    local name=$1
    local command=$2
    local port=$3
    
    echo "📦 Starting $name on port $port..."
    $command > /app/logs/${name}.log 2>&1 &
    local pid=$!
    echo "$name started with PID $pid"
    
    # Give service time to start
    sleep 3
    
    # Check if process is still running (Alpine Linux compatible)
    if kill -0 $pid 2>/dev/null; then
        echo "✅ $name is running (PID: $pid)"
    else
        echo "❌ $name failed to start"
        echo "📋 Error log:"
        cat /app/logs/${name}.log | tail -10
    fi
}

echo "📋 Installing ONLY available MCP packages..."

# Install Python MCP servers (these actually exist)
pip install uv 2>/dev/null || echo "⚠️  UV already installed"

# Try to install Metricool MCP (this one actually works)
echo "🔧 Installing Metricool MCP..."
uv tool install mcp-metricool 2>/dev/null || echo "⚠️  Metricool MCP installation failed"

echo "🎯 Starting ONLY working MCP services..."

# Start Metricool MCP (the only one that actually works reliably)
if command -v uvx &> /dev/null; then
    # Set required environment variables for Metricool
    export METRICOOL_USER_TOKEN=${METRICOOL_USER_TOKEN:-"demo-token"}
    export METRICOOL_USER_ID=${METRICOOL_USER_ID:-"demo-user"}
    
    start_service "metricool-mcp" "uvx mcp-metricool --host 0.0.0.0 --port 3004" 3004
fi

# Create mock services for the others (so gateway doesn't crash)
echo "🔧 Creating mock services for non-existent MCP packages..."

# Simple HTTP servers that respond with "service not available"
for port in 3001 3002 3003 3005 3006 3007; do
    cat > /tmp/mock_${port}.js << EOF
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({
    error: 'Service not available',
    message: 'This MCP service is not yet available',
    status: 'mock'
  }));
});
server.listen(${port}, () => console.log('Mock service on port ${port}'));
EOF
    
    echo "🔄 Starting mock service on port ${port}..."
    node /tmp/mock_${port}.js > /app/logs/mock_${port}.log 2>&1 &
done

# Wait for all services to initialize
echo "⏳ Waiting for services to initialize..."
sleep 5

# Show service status (Alpine Linux compatible)
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

# Set environment variables for service URLs
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
echo "🔥 Metricool MCP: REAL service"
echo "🔄 Other services: Mock responses (packages not available yet)"

# Start gateway in foreground
exec node server.js