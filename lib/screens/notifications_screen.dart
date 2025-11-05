import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ],
                )
              : AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        switch (value) {
                          case 'settings':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                            break;
                          case 'help':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpSupportScreen(),
                              ),
                            );
                            break;
                          case 'about':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'settings',
                          child: Text('Settings'),
                        ),
                        const PopupMenuItem(
                          value: 'help',
                          child: Text('Help'),
                        ),
                        const PopupMenuItem(
                          value: 'about',
                          child: Text('About'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notifications Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Notifications',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Notifications List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView(
                    children: [
                      _buildNotificationCard(
                        icon: Icons.notifications_active,
                        title: 'Electricity Rate Update',
                        subtitle: 'New rate available for Meralco',
                        time: '2 hours ago',
                        color: AppColors.accentGreen,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCard(
                        icon: Icons.lightbulb,
                        title: 'Energy Saving Tip',
                        subtitle: 'Unplug idle devices to save power',
                        time: '1 day ago',
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCard(
                        icon: Icons.warning,
                        title: 'Budget Alert',
                        subtitle: 'You\'ve exceeded 80% of your monthly budget',
                        time: '3 days ago',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationCard(
                        icon: Icons.calendar_today,
                        title: 'Weekly Report',
                        subtitle: 'Your energy usage report is ready',
                        time: '1 week ago',
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Clear All Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Clear all notifications functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications cleared')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}
