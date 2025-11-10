import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/onesignal_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  bool _isRequestingPermission = false;
  String _permissionStatus = 'unknown';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final hasPermission = await OneSignalService().hasPermission();
      setState(() {
        _permissionStatus = hasPermission ? 'granted' : 'denied';
      });
    } catch (e) {
      setState(() {
        _permissionStatus = 'error';
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      final granted = await OneSignalService().requestPermission();
      setState(() {
        _permissionStatus = granted ? 'granted' : 'denied';
      });

      if (granted && mounted) {
        // Initialize OneSignal fully if permission granted
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user != null) {
          await OneSignalService().setUserId(authProvider.user!.uid);
          OneSignalService().setCurrentUserId(authProvider.user!.uid);

          // Enable notifications and subscribe to topics
          await NotificationService().setNotificationsEnabled(true);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications enabled! You\'ll now receive updates.'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. You can enable notifications in settings.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permission: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enable Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                size: 60,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Stay Updated!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Get notified about electricity rate updates, energy-saving tips, and important alerts to help you save money.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Permission Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Benefits List
            Column(
              children: [
                _buildBenefitItem(
                  Icons.electric_bolt,
                  'Electricity Rate Updates',
                  'Get instant alerts when rates change',
                ),
                const SizedBox(height: 16),
                _buildBenefitItem(
                  Icons.lightbulb,
                  'Energy Saving Tips',
                  'Weekly tips to reduce your consumption',
                ),
                const SizedBox(height: 16),
                _buildBenefitItem(
                  Icons.warning,
                  'Budget Alerts',
                  'Notifications when you\'re over budget',
                ),
              ],
            ),
            const Spacer(),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _permissionStatus == 'granted' || _isRequestingPermission
                    ? null
                    : _requestPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isRequestingPermission
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _permissionStatus == 'granted'
                            ? 'Notifications Enabled ✓'
                            : 'Enable Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Skip Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Maybe Later',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_permissionStatus) {
      case 'granted':
        return AppColors.accentGreen;
      case 'denied':
        return Colors.red;
      case 'error':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_permissionStatus) {
      case 'granted':
        return Icons.check_circle;
      case 'denied':
        return Icons.cancel;
      case 'error':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getStatusText() {
    switch (_permissionStatus) {
      case 'granted':
        return 'Permission Granted';
      case 'denied':
        return 'Permission Denied';
      case 'error':
        return 'Check Settings';
      default:
        return 'Checking...';
    }
  }
}
