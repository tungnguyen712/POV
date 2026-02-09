# Deployment Guide for Landmark Lens

This guide will help you deploy your backend to Render and frontend to Vercel.

## Prerequisites

1. GitHub account with your code pushed to a repository
2. Render account (sign up at https://render.com)
3. Vercel account (sign up at https://vercel.com)
4. All necessary API keys ready:
   - GEMINI_API_KEY
   - SUPABASE_URL
   - SUPABASE_PUBLISHABLE_KEY
   - SUPABASE_SECRET_KEY
   - GOOGLE_PLACES_API_KEY
   - TICKETMASTER_API_KEY

## Part 1: Deploy Backend to Render

### Step 1: Push Your Code to GitHub
```bash
# If you haven't already, initialize git and push to GitHub
git init
git add .
git commit -m "Initial commit for deployment"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

### Step 2: Create New Web Service on Render

1. Go to https://dashboard.render.com
2. Click "New +" and select "Web Service"
3. Connect your GitHub repository
4. Render will detect the `render.yaml` file automatically

### Step 3: Configure Render Service

Render should auto-populate settings from `render.yaml`, but verify:

- **Name**: landmark-lens-backend
- **Environment**: Python
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn backend.main:app --host 0.0.0.0 --port $PORT`
- **Plan**: Free (or your preferred plan)

### Step 4: Add Environment Variables

In the Render dashboard, add these environment variables:

- `GEMINI_API_KEY` = your_gemini_api_key
- `SUPABASE_URL` = your_supabase_url
- `SUPABASE_PUBLISHABLE_KEY` = your_supabase_publishable_key
- `SUPABASE_SECRET_KEY` = your_supabase_secret_key
- `GOOGLE_PLACES_API_KEY` = your_google_places_api_key
- `TICKETMASTER_API_KEY` = your_ticketmaster_api_key

### Step 5: Deploy

1. Click "Create Web Service"
2. Wait for the deployment to complete (5-10 minutes)
3. Once deployed, copy your backend URL (e.g., `https://landmark-lens-backend.onrender.com`)

**Important**: Save this URL - you'll need it for the frontend deployment!

## Part 2: Deploy Frontend to Vercel

### Step 1: Prepare Frontend for Deployment

The `vercel.json` file has already been created in the `frontend/` directory.

### Step 2: Deploy to Vercel via CLI (Recommended)

```bash
# Install Vercel CLI if you haven't already
npm i -g vercel

# Navigate to frontend directory
cd frontend

# Login to Vercel
vercel login

# Deploy
vercel --prod
```

During the deployment, Vercel will ask you some questions:
- Set up and deploy: Yes
- Which scope: Your personal account
- Link to existing project: No
- Project name: landmark-lens (or your preferred name)
- In which directory is your code located: ./
- Want to override settings: No

### Step 3: Configure Environment Variable

After initial deployment:

1. Go to https://vercel.com/dashboard
2. Select your project
3. Go to Settings → Environment Variables
4. Add variable:
   - **Name**: `API_URL`
   - **Value**: Your Render backend URL (e.g., `https://landmark-lens-backend.onrender.com`)
   - **Environment**: Production, Preview, Development (select all)
5. Click "Save"

### Step 4: Redeploy

After adding the environment variable, trigger a new deployment:

```bash
vercel --prod
```

Or through the Vercel dashboard:
1. Go to Deployments tab
2. Click "..." on the latest deployment
3. Click "Redeploy"

## Alternative: Deploy Frontend via Vercel Dashboard

If you prefer using the web interface:

1. Go to https://vercel.com/new
2. Import your GitHub repository
3. Configure project:
   - **Framework Preset**: Other
   - **Root Directory**: `frontend`
   - **Build Command**: `flutter build web --release --web-renderer canvaskit --dart-define=API_URL=$API_URL`
   - **Output Directory**: `build/web`
   - **Install Command**: Use the one from vercel.json
4. Add Environment Variable:
   - `API_URL` = your Render backend URL
5. Click "Deploy"

## Part 3: Verify Deployment

### Test Backend
Visit your Render URL in a browser:
```
https://your-backend.onrender.com
```

You should see:
```json
{"message": "Landmark Lens API", "status": "running"}
```

### Test Frontend
Visit your Vercel URL in a browser:
```
https://your-app.vercel.app
```

The app should load and be able to communicate with the backend.

## Troubleshooting

### Backend Issues

**Build fails on Render:**
- Check that all dependencies in `requirements.txt` are valid
- Review build logs in Render dashboard

**Backend runs but APIs don't work:**
- Verify all environment variables are set correctly
- Check Render logs for errors

### Frontend Issues

**Flutter build fails on Vercel:**
- Ensure Flutter SDK is being installed correctly
- Check Vercel build logs
- Try using the CLI deployment method first

**App loads but can't connect to backend:**
- Verify `API_URL` environment variable is set correctly in Vercel
- Check browser console for CORS errors
- Ensure backend CORS settings allow your Vercel domain

**White screen or loading issues:**
- Clear browser cache
- Try different web renderer: change `canvaskit` to `html` in vercel.json
- Check browser console for JavaScript errors

### CORS Issues

If you get CORS errors after deployment, update your backend CORS settings in `backend/main.py` to include your Vercel domain:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "*",  # Remove this in production
        "https://your-app.vercel.app",  # Add your Vercel domain
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Your Deployment URLs

After successful deployment, you'll have:

- **Backend URL**: `https://landmark-lens-backend.onrender.com` (or your custom name)
- **Frontend URL**: `https://your-app.vercel.app` (or your custom name)

Use the Frontend URL for your hackathon submission! 🚀

## Notes

- **Render Free Tier**: Services spin down after 15 minutes of inactivity and may take 30-60 seconds to wake up
- **Vercel**: Provides automatic SSL certificates and global CDN
- **Updates**: Push to your GitHub main branch to trigger automatic redeployments on both platforms

Good luck with your hackathon! 🎉
