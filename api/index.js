module.exports = (req, res) => {
  res.status(200).json({
    message: "E-Saver API is running",
    endpoints: {
      "GET /api/combined-notifications": "Send combined notifications",
      "GET /api/facebook-rate-monitor": "Monitor Facebook electricity rates",
      "GET /api/send-notification": "Send custom notification",
      "GET /api/scheduled-notifications": "Get scheduled notifications"
    }
  });
};
