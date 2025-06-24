FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    curl \
    wget \
    bash

# Set working directory
WORKDIR /app

# Install Python dependencies (for Metricool)
RUN pip3 install uv

# Install all MCP servers globally
RUN npm install -g \
    @modelcontextprotocol/server-notion \
    @modelcontextprotocol/server-github \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-gdrive

# Install Metricool MCP server
RUN uvx install mcp-metricool

# Try to install Canva and WIX (may need different approach)
RUN npm install -g @canva/mcp-server || echo "Canva MCP not available yet"
RUN npm install -g @wix/mcp || echo "WIX MCP not available yet"

# Copy gateway application
COPY gateway/ ./gateway/
WORKDIR /app/gateway
RUN npm install

# Copy startup script
COPY start-services.sh /app/start-services.sh
RUN chmod +x /app/start-services.sh

# Expose the gateway port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start all services
CMD ["/app/start-services.sh"]