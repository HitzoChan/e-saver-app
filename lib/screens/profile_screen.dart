import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
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
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final userProfileService = UserProfileService();
        _userProfile = await userProfileService.getUserProfile();

        _userProfile ??= await userProfileService.createDefaultProfile(
          userId: authProvider.user!.uid,
          name: authProvider.user!.displayName ?? 'User',
          email: authProvider.user!.email ?? '',
          photoUrl: authProvider.user!.photoURL,
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                ],
              ) : AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  /// ==========================
                  /// FIXED CLEAN CENTERED TITLE
                  /// ==========================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // left spacer

                        Expanded(
                          child: Text(
                            settingsProvider.getLocalizedText('Profile'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) {
                            switch (value) {
                              case 'settings':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                                break;
                              case 'help':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                                break;
                              case 'about':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
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

                  /// ==========================
                  /// USER PROFILE SECTION
                  /// ==========================
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
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
                        _isLoading
                            ? settingsProvider.getLocalizedText('Loading...')
                            : (_userProfile?.name ?? settingsProvider.getLocalizedText('User')),
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

                  /// ==========================
                  /// OPTIONS PANEL
                  /// ==========================
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
                                  MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
                                );
                                if (result == true) _loadUserProfile();
                              },
                            ),

                            const SizedBox(height: 16),

                            _buildProfileOption(
                              icon: Icons.lightbulb,
                              title: settingsProvider.getLocalizedText('Energy Tips'),
                              subtitle: settingsProvider.getLocalizedText('View energy saving tips'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EnergyTipsScreen()),
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
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
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

  /// =============================
  /// REUSABLE PROFILE OPTION TILE
  /// =============================
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
              child: Icon(icon, color: AppColors.primaryBlue),
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
            const Icon(Icons.arrow_forward_ios, color: AppColors.textGray, size: 16),
          ],
        ),
      ),
    );
  }
}
