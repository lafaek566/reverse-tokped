# 🚂 Railway Deployment Guide - Tokopedia Scraper

## Step 1: Prepare Files (5 menit)

Buat folder baru untuk deployment:
```bash
mkdir tokopedia-scraper-railway
cd tokopedia-scraper-railway
```

Copy files yang diperlukan:
```
tokopedia_scraper_production.js
package.json
.env (DB credentials)
merchants_list.txt (if needed)
```

---

## Step 2: Create package.json

```json
{
  "name": "tokopedia-scraper",
  "version": "1.0.0",
  "description": "Tokopedia API Scraper with auto-updates",
  "main": "tokopedia_scraper_production.js",
  "scripts": {
    "start": "node tokopedia_scraper_production.js",
    "dev": "NODE_ENV=development node tokopedia_scraper_production.js"
  },
  "dependencies": {
    "mysql2": "^3.6.5"
  },
  "engines": {
    "node": "20.x"
  }
}
```

---

## Step 3: Setup Railway Account

1. **Go to railway.app**
2. **Click "Start New Project"**
3. **Select "Deploy from GitHub" (recommended) OR "Deploy from Repo"**
4. **If using GitHub:**
   - Connect GitHub account
   - Select repository with scraper code
   - Railway auto-detects Node.js
5. **If uploading files:**
   - Use Railway CLI: `npm install -g @railway/cli`
   - Login: `railway login`
   - Init project: `railway init`

---

## Step 4: Configure Environment Variables

1. **In Railway dashboard:**
   - Go to "Variables" tab
   - Add environment variables:

```
NODE_ENV=production
DB_HOST=alpha.cqvy5bhjcd1n.ap-southeast-1.rds.amazonaws.com
DB_USER=your_db_user
DB_PASS=your_db_password
DB_NAME=vhelin
```

2. **Upload .env file alternative:**
   - Create `.env` in project root
   - Railway will load it automatically

---

## Step 5: Deploy

**Option A: GitHub Integration**
```bash
1. Push code to GitHub
2. Railway auto-deploys on push
3. Done! 🎉
```

**Option B: Railway CLI**
```bash
railway login
railway link (select project)
railway up
```

**Option C: Web UI**
```bash
1. Upload files via web UI
2. Click "Deploy"
3. Monitor logs in "Logs" tab
```

---

## Step 6: Verify Deployment

```bash
# Check logs
railway logs

# Test scraper
curl https://your-railway-app.up.railway.app/status

# Or check Railway dashboard:
railway status
```

---

## Step 7: Setup Auto-Updates (Optional)

Create `daemon-script.js` untuk auto-run setiap 15 menit:

```javascript
const scraper = require('./tokopedia_scraper_production.js');

setInterval(async () => {
  console.log(`[${new Date().toISOString()}] Running auto-update...`);
  try {
    await scraper.search('laptop', 1, 10);
    console.log('✅ Update complete');
  } catch (err) {
    console.error('❌ Update failed:', err.message);
  }
}, 15 * 60 * 1000); // 15 minutes

console.log('🚂 Daemon started on Railway');
```

Then update package.json:
```json
{
  "scripts": {
    "start": "node daemon-script.js"
  }
}
```

---

## Step 8: Monitoring & Logs

**Railway provides:**
- ✅ Real-time logs
- ✅ CPU/Memory monitoring
- ✅ Deployment history
- ✅ Easy rollback

Access via: `railway.app` dashboard

---

## Cost

| Plan | Price | Includes |
|------|-------|----------|
| Free | $0 | Starting credit, limited |
| Pay-as-you-go | $5/mo starting | $5 monthly credits |

**Your scraper should cost:** ~$0-2/month (CPU + storage minimal)

---

## Troubleshooting

### App keeps crashing?
```bash
railway logs --follow
# Check error messages
```

### Database connection failing?
```bash
# Verify .env variables
railway var list

# Update if needed
railway var set DB_HOST=xxx
```

### Not starting?
```bash
# Check Node version
railway var set NODE_VERSION=20

# Check main file
railway var set RAILWAY_ENTRYPOINT=tokopedia_scraper_production.js
```

---

## Next Steps

1. ✅ Create account on railway.app
2. ✅ Create new project
3. ✅ Upload files or connect GitHub
4. ✅ Set environment variables
5. ✅ Deploy!
6. ✅ Monitor logs
7. ✅ Done! 🚀

**Ready to deploy?**
