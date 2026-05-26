# 🚂 Railway Deployment - QUICK START

## Files Ready:
✅ `daemon-monitor.js` - Auto-update daemon (15 min interval)
✅ `tokopedia_scraper_production.js` - Main scraper
✅ `package.json` - Dependencies configured
✅ `.env` - DB credentials (keep this secure!)

---

## 3-Step Railway Setup:

### Step 1: Go to railway.app
```
1. Visit https://railway.app
2. Click "Start New Project"
3. Select "GitHub" or "Deploy from Repo"
4. Sign in with GitHub
```

### Step 2: Create New Project
```
Option A - From GitHub:
  1. Connect your GitHub account
  2. Select repository with scraper code
  3. Railway auto-configures Node.js

Option B - From CLI:
  1. npm install -g @railway/cli
  2. railway login
  3. railway init
  4. railway up
```

### Step 3: Configure Environment Variables
```
In Railway Dashboard:
  1. Go to "Variables" tab
  2. Add these:
  
  DB_HOST=alpha.cqvy5bhjcd1n.ap-southeast-1.rds.amazonaws.com
  DB_USER=root
  DB_PASS=your_password_here
  DB_NAME=vhelin
  NODE_ENV=production
```

---

## Done! 🎉

Railway automatically:
- ✅ Installs dependencies (`npm install`)
- ✅ Runs start script (`node daemon-monitor.js`)
- ✅ Manages logs and monitoring
- ✅ Keeps app running 24/7
- ✅ Auto-restarts on failure

---

## Monitor Your Scraper:

```bash
# View logs
railway logs --follow

# Check status
railway status

# View variables
railway var list

# Update variable
railway var set DB_PASS=newpassword
```

---

## What Happens Next:

✅ Daemon starts
✅ Every 15 minutes: Auto-search random product (laptop/smartphone/etc)
✅ Products saved to database
✅ Logs visible in Railway dashboard
✅ 24/7 updates running

---

## Cost:

- **$0 first month** (with $5 credit)
- **~$2-5/month** after (if you keep it running)
- Much cheaper than DigitalOcean ($8/mo)

---

## Need Help?

1. Check logs: `railway logs`
2. Verify DB connection in logs
3. Check variables: `railway var list`
4. Restart app: `railway redeploy`

---

## Files to Upload to Railway:

```
tokopedia-scraper/
├── daemon-monitor.js          (Main entry point)
├── tokopedia_scraper_production.js  (Scraper functions)
├── package.json               (Dependencies)
├── .env                       (DB credentials - add to Railway vars instead)
└── README.md                  (This file)
```

---

**Ready?** Go to railway.app and create your first project! 🚀
