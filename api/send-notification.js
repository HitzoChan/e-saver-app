const https = require('https');

const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID || '418744e0-0f43-40b7-ab7b-70c2748fe2f9';
const ONESIGNAL_REST_API_KEY = process.env.ONESIGNAL_REST_API_KEY || 'p3us5d5f7esyvyrket4lbcf7q';

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { message, heading, segment } = req.body;

    // Default values if not provided
    const notificationData = {
      app_id: ONESIGNAL_APP_ID,
      headings: { en: heading || "E-Saver Reminder" },
      contents: { en: message || "Time to check your energy usage!" },
      included_segments: segment ? [segment] : ["All"],
      // Add data for app handling
      data: {
        type: "manual_notification",
        timestamp: new Date().toISOString()
      }
    };

    // Send notification via OneSignal REST API
    const response = await sendOneSignalNotification(notificationData);

    if (response.success) {
      res.status(200).json({
        success: true,
        message: 'Notification sent successfully',
        response_id: response.id
      });
    } else {
      res.status(500).json({
        success: false,
        error: 'Failed to send notification',
        details: response.error
      });
    }

  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      details: error.message
    });
  }
}

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
