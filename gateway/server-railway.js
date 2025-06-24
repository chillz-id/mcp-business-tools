const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    services: {
      notion: 'http://localhost:3001',
      github: 'http://localhost:3002', 
      filesystem: 'http://localhost:3003',
      metricool: 'http://localhost:3004',
      gdrive: 'http://localhost:3007'
    }
  });
});

// MCP Server Routes with SSE support
const createMCPProxy = (target, pathRewrite = {}) => {
  return createProxyMiddleware({
    target,
    changeOrigin: true,
    pathRewrite,
    ws: true, // Enable WebSocket proxying
    onProxyReq: (proxyReq, req, res) => {
      // Add MCP headers
      proxyReq.setHeader('Accept', 'text/event-stream, application/json');
      proxyReq.setHeader('Cache-Control', 'no-cache');
      if (req.headers['content-type']) {
        proxyReq.setHeader('Content-Type', req.headers['content-type']);
      }
    },
    onProxyRes: (proxyRes, req, res) => {
      // Handle SSE responses
      if (proxyRes.headers['content-type']?.includes('text/event-stream')) {
        res.setHeader('Content-Type', 'text/event-stream');
        res.setHeader('Cache-Control', 'no-cache');
        res.setHeader('Connection', 'keep-alive');
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.setHeader('Access-Control-Allow-Headers', 'Cache-Control');
      }
    },
    onError: (err, req, res) => {
      console.error(`Proxy error for ${req.url}:`, err);
      res.status(502).json({ 
        error: 'Bad Gateway', 
        message: 'MCP server unavailable',
        service: req.url.split('/')[1]
      });
    }
  });
};

// Working Business Tools Routes
app.use('/notion', createMCPProxy('http://localhost:3001', { '^/notion': '' }));
app.use('/github', createMCPProxy('http://localhost:3002', { '^/github': '' }));
app.use('/filesystem', createMCPProxy('http://localhost:3003', { '^/filesystem': '' }));

// Analytics & Social Media
app.use('/metricool', createMCPProxy('http://localhost:3004', { '^/metricool': '' }));

// Storage & Files
app.use('/gdrive', createMCPProxy('http://localhost:3007', { '^/gdrive': '' }));

// Mock responses for unavailable services
app.all('/canva/*', (req, res) => {
  res.status(503).json({
    error: 'Service Unavailable',
    message: 'Canva MCP service is not available - package @canva/mcp-server does not exist',
    status: 'unavailable'
  });
});

app.all('/wix/*', (req, res) => {
  res.status(503).json({
    error: 'Service Unavailable', 
    message: 'WIX MCP service is not available - package @wix/mcp does not exist',
    status: 'unavailable'
  });
});

// MCP Service Discovery Endpoint
app.get('/services', (req, res) => {
  res.json({
    available_services: {
      notion: {
        url: '/notion',
        description: 'Notion pages and databases',
        tools: ['create_page', 'read_page', 'update_page', 'query_database'],
        status: 'available'
      },
      github: {
        url: '/github', 
        description: 'GitHub repositories and issues',
        tools: ['create_repo', 'list_issues', 'create_pr', 'merge_pr'],
        status: 'available'
      },
      filesystem: {
        url: '/filesystem',
        description: 'File system operations', 
        tools: ['read_file', 'write_file', 'list_directory', 'search_files'],
        status: 'available'
      },
      metricool: {
        url: '/metricool',
        description: 'Social media analytics and scheduling',
        tools: ['get_analytics', 'schedule_post', 'get_competitors', 'get_best_time'],
        status: 'available'
      },
      gdrive: {
        url: '/gdrive',
        description: 'Google Drive file management', 
        tools: ['upload_file', 'download_file', 'share_file', 'search_files'],
        status: 'available'
      },
      canva: {
        url: '/canva',
        description: 'Design and creative tools',
        tools: ['create_design', 'export_design', 'list_templates'],
        status: 'unavailable',
        reason: 'Package @canva/mcp-server does not exist'
      },
      wix: {
        url: '/wix', 
        description: 'Wix website management',
        tools: ['update_site', 'get_analytics', 'manage_content'],
        status: 'unavailable',
        reason: 'Package @wix/mcp does not exist'
      }
    }
  });
});

// Catch-all route for MCP protocol
app.all('/:service/*', (req, res) => {
  const service = req.params.service;
  const validServices = ['notion', 'github', 'filesystem', 'metricool', 'gdrive'];
  const unavailableServices = ['canva', 'wix'];
  
  if (unavailableServices.includes(service)) {
    return res.status(503).json({ 
      error: 'Service Unavailable',
      message: `${service} MCP service is not available`,
      available_services: validServices
    });
  }
  
  if (!validServices.includes(service)) {
    return res.status(404).json({ 
      error: 'Service not found',
      available_services: validServices.concat(unavailableServices)
    });
  }
  
  // This should be handled by the proxy middleware above
  res.status(500).json({ error: 'Internal routing error' });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'MCP Business Tools Gateway',
    version: '1.0.0',
    description: 'Gateway for Model Context Protocol business tools',
    endpoints: {
      health: '/health',
      services: '/services', 
      notion: '/notion/*',
      github: '/github/*',
      filesystem: '/filesystem/*',
      metricool: '/metricool/*',
      gdrive: '/gdrive/*'
    },
    unavailable_services: {
      canva: '/canva/* (package does not exist)',
      wix: '/wix/* (package does not exist)'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Gateway error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: err.message
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 MCP Gateway running on port ${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/health`);
  console.log(`🔧 Services: http://localhost:${PORT}/services`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});
