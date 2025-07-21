# 🚀 Quick Deploy Guide - Get Your COBOL Demo Online in 5 Minutes

## Option 1: Railway (Fastest - 2 minutes)
```bash
# One-line deploy
railway login && railway init && railway up
```
Your app will be live at: `https://your-app.railway.app`

## Option 2: Render (Free tier)
1. Push to GitHub
2. Connect at [render.com](https://render.com)
3. Click "New Web Service" → Connect repo
4. Auto-deploys with Dockerfile

## Option 3: DigitalOcean ($5/month)
```bash
doctl apps create --spec .do/app.yaml
```

## Option 4: Replit (Instant share)
1. Import to [replit.com](https://replit.com)
2. Click "Run"
3. Share the public URL

## Quick Test Your Deploy
```bash
# Test the deployed API
curl https://your-app.railway.app/api/v1/health

# View Swagger docs
open https://your-app.railway.app/api-docs
```

## Share Links for the Bounty
- Live Demo: `https://your-app.railway.app/api-docs`
- GitHub Repo: `https://github.com/yourusername/cobol-payroll`
- Video Demo: Record with Loom showing the Swagger UI

## Pro Tips
1. Railway gives you a free $5 credit - enough for the demo week
2. Add a custom domain for extra polish
3. Enable HTTPS (automatic on all platforms)
4. Set up monitoring to show uptime