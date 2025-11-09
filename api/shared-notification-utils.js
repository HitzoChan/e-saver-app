// Shared notification utilities for OneSignal API calls
const https = require('https');

const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID || '418744e0-0f43-40b7-ab7b-70c2748fe2f9';
const ONESIGNAL_REST_API_KEY = process.env.ONESIGNAL_REST_API_KEY || 'p3us5d5f7esyvyrket4lbcf7q';

// Send OneSignal notification - shared utility
function sendOneSignalNotification(data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);

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

// Create rate update notification data
function createRateUpdateNotificationData(extractedRate, postUrl, postId) {
  return {
    app_id: ONESIGNAL_APP_ID,
    headings: { en: '⚡ SAMELCO Rate Update' },
    contents: {
      en: extractedRate
        ? `New electricity rate detected: PHP ${extractedRate.toFixed(2)}/kWh. Tap to view details.`
        : 'SAMELCO has posted about electricity rates. Tap to view details.'
    },
    included_segments: ['general'],
    data: {
      type: 'rate_update',
      postUrl: postUrl || `https://www.facebook.com/samelco/posts/${postId}`,
      updateId: postId,
      extractedRate: extractedRate,
      timestamp: new Date().toISOString()
    },
    url: postUrl || `https://www.facebook.com/samelco/posts/${postId}`
  };
}

// Create scheduled notification data
function createScheduledNotificationData(type, heading, message, segment = 'general') {
  return {
    app_id: ONESIGNAL_APP_ID,
    headings: { en: heading },
    contents: { en: message },
    included_segments: [segment],
    data: {
      type: type,
      timestamp: new Date().toISOString()
    }
  };
}

module.exports = {
  sendOneSignalNotification,
  createRateUpdateNotificationData,
  createScheduledNotificationData
};
