import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class EnergyTipsScreen extends StatelessWidget {
  const EnergyTipsScreen({super.key});

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
                      'Energy Saving Tips',
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
              
              // Tips & Notifications Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tips & Notifications',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Tips List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView(
                    children: [
                      _buildTipCard(
                        icon: Icons.power_settings_new,
                        title: 'Unplug idle devices',
                        subtitle: 'Save Power',
                        color: AppColors.primaryBlue,
                        onTap: () => _showTipDetails(context, 'Unplug idle devices',
                          'Unplugging devices when not in use can save significant energy. Many electronics continue to draw power even when turned off (standby mode). Consider using power strips to easily turn off multiple devices at once.'),
                      ),
                      const SizedBox(height: 16),
                      _buildTipCard(
                        icon: Icons.wb_sunny,
                        title: 'Use natural light',
                        subtitle: 'Save Power',
                        color: AppColors.primaryBlue,
                        onTap: () => _showTipDetails(context, 'Use natural light',
                          'Maximize the use of natural daylight to reduce the need for artificial lighting. Open curtains, use skylights, and arrange workspaces near windows. This can reduce your lighting electricity usage by up to 50%.'),
                      ),
                      const SizedBox(height: 16),
                      _buildTipCard(
                        icon: Icons.notifications_active,
                        title: 'SAME/C rice update!',
                        subtitle: 'View changes',
                        color: AppColors.accentGreen,
                        onTap: () async {
                          // Capture messenger before async gap
                          final messenger = ScaffoldMessenger.of(context);

                          // Open Facebook page
                          const url = 'https://www.facebook.com/ElectricitySaver2025';
                          try {
                            await launchUrl(Uri.parse(url));
                          } catch (e) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Could not open Facebook page')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // View on Facebook Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Capture messenger before async gap
                      final messenger = ScaffoldMessenger.of(context);

                      // Open Facebook page
                      const url = 'https://www.facebook.com/ElectricitySaver2025';
                      try {
                        await launchUrl(Uri.parse(url));
                      } catch (e) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Could not open Facebook page')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View on Facebook',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
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
  
  void _showTipDetails(BuildContext context, String title, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.primaryBlue,
            ),
          ),
          content: Text(
            details,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it!',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: Colors.white,
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
      ),
    );
  }
}
