# Facebook Graph API Setup Guide

## Step 1: Create Facebook App
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Click "My Apps" → "Create App"
3. Choose "Business" as app type
4. Fill in app details:
   - App name: "E-Saver Rate Monitor"
   - App contact email: Your email
   - Business account: Select/create if needed

## Step 2: Add Facebook Login Product
1. In your app dashboard, click "Add Product"
2. Find "Facebook Login" and click "Set Up"
3. Choose "Web" platform
4. Enter your Vercel domain: `https://e-saver-7oqvwydfb-jakemontejos-projects.vercel.app`

## Step 3: Configure App Permissions
1. Go to App Settings → Permissions
2. Add these permissions:
   - `pages_read_engagement`
   - `pages_read_user_content`
   - `pages_show_list`

## Step 4: Generate Access Token
1. Go to [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Select your app from dropdown
3. Click "Generate Access Token"
4. Add permissions: `pages_read_engagement`, `pages_read_user_content`
5. Copy the generated token

## Step 5: Get Page Access Token
1. Make a Graph API call to get page access token:
```
GET https://graph.facebook.com/v18.0/{user-id}/accounts?access_token={user-access-token}
```
2. Find the SAMELCO page and copy its `access_token`

## Step 6: Test the Token
Use the token in your API endpoint and test it.

## Step 7: Set Environment Variables in Vercel
1. Go to Vercel Dashboard → Your project
2. Settings → Environment Variables
3. Add: `FACEBOOK_ACCESS_TOKEN` = your_page_access_token

---

# OneSignal Setup Guide

## Step 1: Create OneSignal Account
1. Go to [OneSignal](https://onesignal.com/)
2. Sign up for free account
3. Verify your email

## Step 2: Create App
1. Click "New App/Website"
2. App name: "E-Saver"
3. Platform: Select "Web Push"

## Step 3: Configure Web Push
1. Site URL: `https://e-saver-7oqvwydfb-jakemontejos-projects.vercel.app`
2. Choose "Typical Site" setup
3. Configure labels and click "Save"

## Step 4: Get API Keys
1. Go to Settings → Keys & IDs
2. Copy:
   - **App ID**: `733af534-3c80-4a46-b0d3-63bb2ec6a158`
   - **REST API Key**: You'll need to generate this

## Step 5: Generate REST API Key
1. Go to Account → Keys & IDs (account level)
2. Click "Create Key"
3. Name: "E-Saver API Key"
4. Copy the generated REST API Key

## Step 6: Set Environment Variables in Vercel
1. Go to Vercel Dashboard → Your project
2. Settings → Environment Variables
3. Add:
   - `ONESIGNAL_APP_ID` = your_app_id
   - `ONESIGNAL_REST_API_KEY` = your_rest_api_key

## Step 7: Configure Segments (Optional)
1. In OneSignal dashboard, go to Audience → Segments
2. Create segments like:
   - "general" - All users
   - "energy_tips" - Users interested in tips

---

# Testing Setup

## Test Facebook API
```bash
curl "https://graph.facebook.com/v18.0/117290636838993/posts?fields=id,message,created_time&access_token=YOUR_TOKEN&limit=5"
```

## Test OneSignal API
```bash
curl -X POST "https://onesignal.com/api/v1/notifications" \
  -H "Authorization: Basic YOUR_REST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "contents": {"en": "Test notification"},
    "included_segments": ["All"]
  }'
```

## Test Your Vercel Endpoint
```bash
curl -X GET "https://e-saver-7oqvwydfb-jakemontejos-projects.vercel.app/api/facebook-rate-monitor"
```

---

# Troubleshooting

## Facebook API Issues
- **Token expired**: Generate new token
- **Permissions error**: Check app permissions
- **Rate limiting**: Facebook limits API calls

## OneSignal Issues
- **Invalid API key**: Check REST API key
- **Wrong app ID**: Verify app ID matches
- **CORS issues**: Ensure domain is whitelisted

## Vercel Issues
- **Environment variables not updating**: Redeploy after changing env vars
- **Cold starts**: First request may be slow
