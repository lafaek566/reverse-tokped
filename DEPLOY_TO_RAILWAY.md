# 🚂 Deploy to Railway (5 Minutes)

## Repository Ready!
✅ https://github.com/lafaek566/reverse-tokped

Files uploaded:
- `daemon-monitor.js` - Auto-update daemon
- `tokopedia_scraper_production.js` - Main scraper
- `package.json` - Dependencies
- `.env.example` - Environment template
- Deployment guides

---

## Railway Setup (3 Steps)

### Step 1: Go to Railway
```
1. Visit https://railway.app
2. Click "Start New Project"
3. Select "Deploy from GitHub"
```

### Step 2: Connect GitHub
```
1. Click "GitHub" option
2. Authorize Railway to access your GitHub
3. Select repository: lafaek566/reverse-tokped
4. Click "Deploy"
```

Railway automatically:
- ✅ Detects Node.js
- ✅ Installs dependencies (npm install)
- ✅ Sets up deployment

### Step 3: Add Environment Variables
```
In Railway Dashboard:
1. Go to "Variables" tab
2. Click "Add Variable"
3. Add these 4 variables:

DB_HOST     = alpha.cqvy5bhjcd1n.ap-southeast-1.rds.amazonaws.com
DB_USER     = root
DB_PASS     = [your_db_password]
DB_NAME     = vhelin
NODE_ENV    = production
```

---

## Done! 🎉

Railway will:
- ✅ Deploy your app
- ✅ Start daemon automatically
- ✅ Run 24/7
- ✅ Auto-update every 15 minutes

**Monitor:** https://railway.app → Your Project → Logs

---

## Cost

- First month: **FREE** ($5 credit)
- After: ~$2-5/month
- Can scale up if needed

---

## Troubleshooting

### App keeps restarting?
```
Check logs in Railway dashboard
Look for database connection errors
Verify environment variables are correct
```

### Database connection failing?
```
1. Check DB_HOST, DB_USER, DB_PASS in Variables
2. Verify password is correct
3. Check if RDS is accessible from Railway
```

### App not starting?
```
1. railway logs --follow
2. Look for error messages
3. Check package.json "start" script
```

---

## What's Running

```
✅ Daemon: daemon-monitor.js
✅ Interval: Every 15 minutes
✅ Action: Search random products → Save to DB
✅ Log: Visible in Railway dashboard
✅ Uptime: 24/7
```

---

## Next Steps (Optional)

1. Setup database backups
2. Add monitoring alerts
3. Scale to production plan
4. Add more search keywords
5. Setup data export/reports

---

## Support

If Railway deployment fails:
1. Check logs: `railway logs --follow`
2. Verify environment variables
3. Check GitHub repo has all files
4. Try redeploying

---

**Ready to deploy?** Go to railway.app now! 🚀
