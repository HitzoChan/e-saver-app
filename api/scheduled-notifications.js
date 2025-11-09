const { sendOneSignalNotification, createScheduledNotificationData } = require('./shared-notification-utils');

// Scheduled notification messages
const SCHEDULED_MESSAGES = {
  morning: {
    heading: "🌅 Good Morning!",
    message: "Start your day by checking your energy usage. Small changes add up!",
    segment: "general"
  },
  afternoon: {
    heading: "☀️ Afternoon Check-in",
    message: "How's your energy usage today? Remember to unplug unused devices!",
    segment: "general"
  },
  evening: {
    heading: "🌙 Evening Reminder",
    message: "Before bed, make sure all appliances are turned off to save energy.",
    segment: "general"
  },
  weekly: {
    heading: "📊 Weekly Energy Report",
    message: "Check your weekly energy usage and see how much you've saved!",
    segment: "general"
  },
  energy_tips: {
    heading: "💡 Energy Saving Tip",
    message: "Did you know? Unplugging your charger when not in use can save up to PHP 50/month!",
    segment: "energy_tips"
  }
};

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { type } = req.body;

    if (!type || !SCHEDULED_MESSAGES[type]) {
      return res.status(400).json({
        error: 'Invalid notification type. Available types: ' +
               Object.keys(SCHEDULED_MESSAGES).join(', ')
      });
    }

    const messageConfig = SCHEDULED_MESSAGES[type];

    const notificationData = createScheduledNotificationData(
      type,
      messageConfig.heading,
      messageConfig.message,
      messageConfig.segment
    );

    console.log(`Sending scheduled notification: ${type}`);

    const response = await sendOneSignalNotification(notificationData);

    if (response.success) {
      res.status(200).json({
        success: true,
        message: `Scheduled ${type} notification sent successfully`,
        response_id: response.id,
        type: type
      });
    } else {
      res.status(500).json({
        success: false,
        error: `Failed to send ${type} notification`,
        details: response.error
      });
    }

  } catch (error) {
    console.error('Error sending scheduled notification:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      details: error.message
    });
  }
}
