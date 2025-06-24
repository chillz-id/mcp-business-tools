# 🚀 MCP Business Tools

Complete Model Context Protocol (MCP) server setup for business automation with container isolation on Railway.

![MCP Business Stack](https://img.shields.io/badge/MCP-Business%20Stack-blue) ![Railway](https://img.shields.io/badge/Railway-Deployment-purple) ![Docker](https://img.shields.io/badge/Docker-Compose-blue)

## 🎯 What This Does

Transform your business automation with **all your tools connected to AI**:

- **📝 Notion** - Pages, databases, content management
- **🐙 GitHub** - Repository management, issues, PRs  
- **📊 Metricool** - Social media analytics, scheduling, competitor analysis
- **🎨 Canva** - Design creation, templates, exports
- **🌐 WIX** - Website management and API access
- **📁 Google Drive** - File management, sharing, search
- **💾 Filesystem** - File operations and storage

## 🏗️ Architecture

```
Railway Service: "mcp-business-servers"
├── notion-mcp (Container 1)      - Port 3001
├── github-mcp (Container 2)      - Port 3002  
├── filesystem-mcp (Container 3)  - Port 3003
├── metricool-mcp (Container 4)   - Port 3004
├── canva-mcp (Container 5)       - Port 3005
├── wix-mcp (Container 6)         - Port 3006
├── gdrive-mcp (Container 7)      - Port 3007
└── mcp-gateway (Container 8)     - Port 8080 (Public)
```

### ✅ **Key Benefits:**
- **Container Isolation** - If Canva crashes, Notion keeps working!
- **Cost Effective** - Single Railway service (~$20-30/month)
- **Auto Recovery** - Failed containers restart automatically  
- **Universal Access** - Use from Claude web/mobile via N8N
- **Business Continuity** - Critical tools stay online

## 🚀 Quick Deploy to Railway

### Step 1: Get Your API Keys (15 minutes)

You'll need API credentials for each service:

| Service | Get API Key From | Required Plan |
|---------|------------------|---------------|
| **Notion** | [notion.so/my-integrations](https://www.notion.so/my-integrations) | Free |
| **GitHub** | [github.com/settings/tokens](https://github.com/settings/tokens) | Free |
| **Metricool** | [metricool.com/api](https://metricool.com/api) | Advanced Tier |
| **Canva** | [canva.com/developers](https://www.canva.com/developers/) | Pay-per-use |
| **WIX** | [dev.wix.com](https://dev.wix.com/) | Site plan |
| **Google Drive** | [console.developers.google.com](https://console.developers.google.com/) | Free |

### Step 2: Deploy to Railway (5 minutes)

1. **Go to Railway Dashboard**
   - Visit [railway.app](https://railway.app)
   - Select your project (e.g., "courageous-renewal")

2. **Deploy from GitHub**
   - Click "Deploy from GitHub repo"
   - Select `chillz-id/mcp-business-tools`
   - Railway will auto-detect Docker Compose

3. **Set Environment Variables**
   - Go to Variables tab in Railway
   - Copy values from `.env.example`
   - Add your actual API keys

**Critical Variables:**
```env
N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true
NOTION_API_KEY=secret_your_integration_token
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token
METRICOOL_USER_TOKEN=your_metricool_token
METRICOOL_USER_ID=your_metricool_id
CANVA_CLIENT_ID=your_canva_client_id
CANVA_CLIENT_SECRET=your_canva_client_secret
WIX_API_KEY=your_wix_api_key
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REFRESH_TOKEN=your_google_refresh_token
```

### Step 3: Verify Deployment (2 minutes)

1. **Check Service Status** - Railway dashboard shows "Active"
2. **Test Gateway** - Visit: `https://your-service.railway.app/health`
3. **View Services** - Visit: `https://your-service.railway.app/services`

## 🔌 Connect to N8N

### Configure MCP Client Credentials

Create separate MCP Client credentials in N8N for each service:

**Example: Notion MCP**
- Credential Type: `MCP Client (SSE) API`
- SSE URL: `https://your-service.railway.app/notion/sse`

**Repeat for all services:**
- GitHub: `/github/sse`
- Metricool: `/metricool/sse`
- Canva: `/canva/sse`
- WIX: `/wix/sse`
- Google Drive: `/gdrive/sse`
- Filesystem: `/filesystem/sse`

### Build Business Workflows

**Social Media Management:**
```
1. Metricool → Get best posting times
2. Canva → Create visual content
3. Metricool → Schedule posts
4. Metricool → Analyze competitors
```

**Client Project Setup:**
```
1. Notion → Create project database
2. GitHub → Set up repository
3. WIX → Deploy client site
4. Drive → Create shared folder
5. Metricool → Set up social tracking
```

### AI Agent Integration

1. **Add AI Agent Node** in N8N
2. **Enable MCP Tools** in AI Agent settings
3. **Configure Claude API** as your model
4. **Test with business prompt:**

```
"I need to start a new client project. Create a Notion page for project tracking, 
set up a GitHub repository for the code, create a shared Google Drive folder 
for assets, and schedule a social media announcement about the project launch."
```

## 💰 Cost Breakdown

### Railway Hosting
- **8 containers** running 24/7
- **Estimated cost:** $20-35/month
- **Resource usage:** ~2GB RAM, shared CPU

### API Costs (Monthly)
- **Notion:** Free (personal/small team)
- **GitHub:** Free (public repos)
- **Metricool:** $49-99 (Advanced tier required)
- **Canva:** Pay-per-API-call (~$0.01-0.10 per call)
- **WIX:** Based on site plan ($14-39/month)
- **Google Drive:** Free tier (15GB)

**Total Monthly:** $85-175 (mostly API subscriptions)

## 📞 Next Steps

1. **Deploy to Railway** using this repository
2. **Get your API keys** for the services you want to use
3. **Configure N8N MCP credentials** for each service
4. **Build your first automation workflow**
5. **Scale and add more services** as needed

---

**Ready to automate your business? 🚀**

## 📋 Quick Reference

### Service URLs (after deployment)
```
Gateway:    https://your-service.railway.app
Health:     https://your-service.railway.app/health
Services:   https://your-service.railway.app/services
```

### Repository Structure
```
├── docker-compose.yml     # Main orchestration
├── railway.json          # Railway configuration
├── .env.example          # Environment variables template
├── gateway/              # MCP Gateway service
│   ├── Dockerfile       
│   ├── server.js        # Express proxy server
│   └── package.json     
└── README.md            # This file
```

Happy automating! 🎯