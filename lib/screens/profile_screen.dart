import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/notification_service.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import 'energy_tips_screen.dart';
import 'settings_screen.dart';
import 'personal_information_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload profile data when returning to this screen
    _loadUserProfile();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final userProfileService = UserProfileService();
        _userProfile = await userProfileService.getUserProfile();

        // If no profile exists, create one from auth data
        _userProfile ??= await userProfileService.createDefaultProfile(
            userId: authProvider.user!.uid,
            name: authProvider.user!.displayName ?? 'User',
            email: authProvider.user!.email ?? '',
            photoUrl: authProvider.user!.photoURL,
          );
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showNotificationSettings(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Settings',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textDark,
                  ),
                ),
                subtitle: Text(
                  'Receive updates about electricity rates and energy tips',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : AppColors.textGray,
                  ),
                ),
                value: _notificationsEnabled,
                onChanged: (value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await NotificationService().setNotificationsEnabled(value);
                  this.setState(() {}); // Update parent state
                },
                activeThumbColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'Notification Types',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildNotificationTypeTile(
                context,
                icon: Icons.electrical_services,
                title: 'Electricity Rate Updates',
                subtitle: 'Get notified when SAMELCO updates rates',
                enabled: _notificationsEnabled,
              ),
              _buildNotificationTypeTile(
                context,
                icon: Icons.lightbulb,
                title: 'Energy Saving Tips',
                subtitle: 'Weekly tips to reduce your electricity bill',
                enabled: _notificationsEnabled,
              ),
              _buildNotificationTypeTile(
                context,
                icon: Icons.bar_chart,
                title: 'Weekly Reports',
                subtitle: 'Summary of your energy usage',
                enabled: _notificationsEnabled,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildNotificationTypeTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryBlue.withValues(alpha: 0.1)
              : AppColors.textGray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primaryBlue : AppColors.textGray,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: enabled ? (isDarkMode ? Colors.white : AppColors.textDark) : AppColors.textGray,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDarkMode ? Colors.white70 : AppColors.textGray,
        ),
      ),
      trailing: Icon(
        Icons.check_circle,
        color: enabled ? AppColors.primaryBlue : AppColors.textGray.withValues(alpha: 0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
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
                          settingsProvider.getLocalizedText('Profile'),
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
                            PopupMenuItem(
                              value: 'settings',
                              child: Text(settingsProvider.getLocalizedText('Settings')),
                            ),
                            PopupMenuItem(
                              value: 'help',
                              child: Text(settingsProvider.getLocalizedText('Help')),
                            ),
                            PopupMenuItem(
                              value: 'about',
                              child: Text(settingsProvider.getLocalizedText('About')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User Profile
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          image: DecorationImage(
                            image: _userProfile?.photoUrl != null
                                ? NetworkImage(_userProfile!.photoUrl!)
                                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLoading ? settingsProvider.getLocalizedText('Loading...') : (_userProfile?.name ?? settingsProvider.getLocalizedText('User')),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settingsProvider.getLocalizedText('Energy Saver'),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Profile Options
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          24,
                          24,
                          24,
                          24 + MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          children: [
                            _buildProfileOption(
                              icon: Icons.person,
                              title: settingsProvider.getLocalizedText('Personal Information'),
                              subtitle: settingsProvider.getLocalizedText('Update your profile details'),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PersonalInformationScreen(),
                                  ),
                                );

                                // If changes were saved, reload the profile data
                                if (result == true) {
                                  _loadUserProfile();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildProfileOption(
                              icon: Icons.notifications,
                              title: settingsProvider.getLocalizedText('Notifications'),
                              subtitle: settingsProvider.getLocalizedText('Manage notification preferences'),
                              onTap: () => _showNotificationSettings(context),
                            ),
                            const SizedBox(height: 16),
                            _buildProfileOption(
                              icon: Icons.lightbulb,
                              title: settingsProvider.getLocalizedText('Energy Tips'),
                              subtitle: settingsProvider.getLocalizedText('View energy saving tips'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EnergyTipsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildProfileOption(
                              icon: Icons.settings,
                              title: settingsProvider.getLocalizedText('Settings'),
                              subtitle: settingsProvider.getLocalizedText('App preferences and configuration'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
