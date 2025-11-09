const { sendOneSignalNotification, createScheduledNotificationData } = require('./shared-notification-utils');

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { message, heading, segment } = req.body;

    // Default values if not provided
    const notificationData = createScheduledNotificationData(
      "manual_notification",
      heading || "E-Saver Reminder",
      message || "Time to check your energy usage!",
      segment || "All"
    );

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
