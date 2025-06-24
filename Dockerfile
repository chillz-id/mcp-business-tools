FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    py3-virtualenv \
    curl \
    wget \
    bash \
    git

# Set working directory
WORKDIR /app

# Create Python virtual environment for uv and Metricool
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies in virtual environment
RUN pip install uv

# Install ONLY the MCP servers that actually exist
# Note: Most MCP servers are still in development, so we'll start with a minimal set

# Copy gateway application first
COPY gateway/ ./gateway/
WORKDIR /app/gateway
RUN npm install

# Copy startup script
COPY start-services.sh /app/start-services.sh
RUN chmod +x /app/start-services.sh

# Expose the gateway port
EXPOSE 8080

# Ensure virtual environment is active for runtime
ENV PATH="/opt/venv/bin:$PATH"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start all services
CMD ["/app/start-services.sh"]