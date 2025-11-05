const https = require('https');

const FACEBOOK_APP_ID = process.env.FACEBOOK_APP_ID;
const FACEBOOK_APP_SECRET = process.env.FACEBOOK_APP_SECRET;
const SAMELCO_PAGE_ID = process.env.SAMELCO_PAGE_ID || 'samElcoPage'; // Replace with actual page ID
const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID;
const ONESIGNAL_REST_API_KEY = process.env.ONESIGNAL_REST_API_KEY;

// Get Facebook access token
async function getFacebookAccessToken() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'graph.facebook.com',
      port: 443,
      path: `/oauth/access_token?client_id=${FACEBOOK_APP_ID}&client_secret=${FACEBOOK_APP_SECRET}&grant_type=client_credentials`,
      method: 'GET'
    };

    const req = https.request(options, (res) => {
      let body = '';

      res.on('data', (chunk) => {
        body += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(body);
          if (response.access_token) {
            resolve(response.access_token);
          } else {
            reject(new Error('Failed to get access token'));
          }
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.end();
  });
}

// Fetch recent posts from SAMELCO Facebook page
async function fetchFacebookPosts(accessToken) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'graph.facebook.com',
      port: 443,
      path: `/v18.0/${SAMELCO_PAGE_ID}/posts?fields=id,message,created_time,permalink_url&access_token=${accessToken}&limit=10`,
      method: 'GET'
    };

    const req = https.request(options, (res) => {
      let body = '';

      res.on('data', (chunk) => {
        body += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(body);
          if (response.data) {
            resolve(response.data);
          } else {
            reject(new Error('Failed to fetch posts'));
          }
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.end();
  });
}

// Analyze post for rate updates
function analyzePost(post) {
  const message = post.message || '';
  const postId = post.id;
  const permalinkUrl = post.permalink_url;
  const createdTime = post.created_time;

  // Check if post contains rate-related keywords
  const rateKeywords = [
    'rate', 'rates', 'electricity rate', 'power rate',
    'samelco rate', 'rate update', 'new rate', 'rate change',
    '₱', 'peso', 'centavo', 'per kwh', '/kWh', 'kwh'
  ];

  const lowerMessage = message.toLowerCase();
  const containsRateKeyword = rateKeywords.some(keyword =>
    lowerMessage.includes(keyword.toLowerCase())
  );

  if (containsRateKeyword) {
    // Extract rate information if possible
    const extractedRate = extractRateFromMessage(message);

    return {
      isRateUpdate: true,
      postId: postId,
      message: message,
      permalinkUrl: permalinkUrl,
      createdTime: createdTime,
      extractedRate: extractedRate
    };
  }

  return null;
}

// Extract rate from message
function extractRateFromMessage(message) {
  // Simple regex to extract rate patterns
  const ratePatterns = [
    /₱(\d+\.?\d*)\/kWh/i,
    /₱(\d+\.?\d*)\s*per\s*kWh/i,
    /(\d+\.?\d*)\s*peso.*kWh/i,
    /rate.*₱(\d+\.?\d*)/i,
    /(\d+\.?\d*)\s*per\s*kilowatt/i,
    /(\d+\.?\d*)\s*\/kWh/i
  ];

  for (const pattern of ratePatterns) {
    const match = message.match(pattern);
    if (match && match[1]) {
      const rate = parseFloat(match[1]);
      if (!isNaN(rate)) {
        return rate;
      }
    }
  }

  return null;
}

// Send OneSignal notification
function sendOneSignalNotification(notificationData) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(notificationData);

    const options = {
      hostname: 'onesignal.com',
      port: 443,
      path: '/api/v1/notifications',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`,
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let body = '';

      res.on('data', (chunk) => {
        body += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(body);
          if (res.statusCode === 200 && response.id) {
            resolve({ success: true, id: response.id });
          } else {
            resolve({ success: false, error: response });
          }
        } catch (e) {
          resolve({ success: false, error: 'Invalid response from OneSignal' });
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

export default async function handler(req, res) {
  // Only allow GET requests for manual triggering
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed. Use GET to trigger monitoring.' });
  }

  try {
    console.log('Starting Facebook rate monitoring...');

    // Get Facebook access token
    const accessToken = await getFacebookAccessToken();
    console.log('Got Facebook access token');

    // Fetch recent posts
    const posts = await fetchFacebookPosts(accessToken);
    console.log(`Fetched ${posts.length} posts from SAMELCO page`);

    let rateUpdatesFound = 0;

    // Analyze each post
    for (const post of posts) {
      const analysis = analyzePost(post);

      if (analysis && analysis.isRateUpdate) {
        rateUpdatesFound++;
        console.log(`Rate update found in post ${analysis.postId}`);

        // Prepare notification
        const notificationData = {
          app_id: ONESIGNAL_APP_ID,
          headings: { en: '⚡ SAMELCO Rate Update' },
          contents: {
            en: analysis.extractedRate
              ? `New electricity rate detected: ₱${analysis.extractedRate.toFixed(2)}/kWh. Tap to view details.`
              : 'SAMELCO has posted about electricity rates. Tap to view details.'
          },
          included_segments: ['general'],
          data: {
            type: 'rate_update',
            postUrl: analysis.permalinkUrl || `https://www.facebook.com/samelco/posts/${analysis.postId}`,
            updateId: analysis.postId,
            extractedRate: analysis.extractedRate
          },
          url: analysis.permalinkUrl || `https://www.facebook.com/samelco/posts/${analysis.postId}`
        };

        // Send notification
        const result = await sendOneSignalNotification(notificationData);

        if (result.success) {
          console.log(`Notification sent successfully for post ${analysis.postId}`);
        } else {
          console.error(`Failed to send notification for post ${analysis.postId}:`, result.error);
        }
      }
    }

    res.status(200).json({
      success: true,
      message: `Monitoring complete. Found ${rateUpdatesFound} rate updates.`,
      postsAnalyzed: posts.length,
      rateUpdatesFound: rateUpdatesFound
    });

  } catch (error) {
    console.error('Error in Facebook rate monitoring:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      details: error.message
    });
  }
}
