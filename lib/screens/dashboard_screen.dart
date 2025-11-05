import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_utils.dart';
import '../widgets/wave_graph.dart';
import '../providers/dashboard_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../screens/electricity_rate_screen.dart';
import '../screens/track_save_screen.dart';
import '../screens/add_appliance_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/planner_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/about_screen.dart';
import '../screens/help_support_screen.dart';
import '../screens/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoadingProfile = true);

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
      setState(() => _isLoadingProfile = false);
    }
  }

  void _openDrawer(BuildContext context) {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Consumer<SettingsProvider>(
        builder: (context, settings, child) => _buildDrawer(context, settings),
      ),
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
          child: Consumer<DashboardProvider>(
            builder: (context, dashboardProvider, child) {
              if (dashboardProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (dashboardProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return Text(
                            settings.getLocalizedText('Error loading dashboard'),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: dashboardProvider.refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox.expand(
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => _openDrawer(context),
                          ),
                          Expanded(
                            child: Consumer<SettingsProvider>(
                              builder: (context, settings, child) {
                                return Text(
                                  settings.getLocalizedText('E-Saver Dashboard'),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: context.responsiveFontSize(18),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                          Consumer<DashboardProvider>(
                            builder: (context, dashboardProvider, child) {
                              return Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                    onPressed: () {
                                      // Open notifications screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationsScreen(),
                                        ),
                                      ).then((_) {
                                        // Refresh notifications when returning from notifications screen
                                        dashboardProvider.loadRecentNotifications();
                                      });
                                    },
                                  ),
                                  if (dashboardProvider.hasUnreadNotifications)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
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

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Logo and Title - Reduced space
                            SizedBox(height: context.responsiveSize(10)),
                            Container(
                              width: context.responsiveSize(80),
                              height: context.responsiveSize(80),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(context.responsiveBorderRadius(20)),
                              ),
                              child: Icon(
                                Icons.eco,
                                size: context.responsiveIconSize(50),
                                color: AppColors.accentGreen,
                              ),
                            ),
                            SizedBox(height: context.responsiveSize(8)),
                            Text(
                              'E-Saver',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: context.responsiveFontSize(32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: context.responsiveSize(20)),

                            // Appliance Count
                            Padding(
                              padding: context.responsivePadding(horizontal: 24.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${dashboardProvider.applianceCount} Appliances',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: context.responsiveFontSize(14),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: context.responsiveSize(10)),

                            // Wave Graph with dynamic data - Reduced height for mobile
                            WaveGraph(
                              dataPoints: dashboardProvider.weeklyUsageData,
                              labels: dashboardProvider.applianceLabels,
                              height: context.isMobile ? context.responsiveSize(140) : context.responsiveSize(180),
                            ),

                            // Stats Row with three cards
                            Container(
                              padding: context.responsivePadding(horizontal: 20.0, vertical: 16.0),
                              child: context.isMobile
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: Consumer<SettingsProvider>(
                                                builder: (context, settings, child) {
                                                  return _buildStatCard(
                                                    '${dashboardProvider.averageDailyUsage.toStringAsFixed(1)} kW',
                                                    settings.getLocalizedText('Daily Usage'),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: context.responsiveSize(16)),
                                            Expanded(
                                              child: Consumer<SettingsProvider>(
                                                builder: (context, settings, child) {
                                                  return _buildStatCard(
                                                    '${settings.currencySymbol}${dashboardProvider.totalMonthlyCost.toStringAsFixed(0)}',
                                                    settings.getLocalizedText('Monthly Cost'),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: context.responsiveSize(16)),
                                        Consumer<SettingsProvider>(
                                          builder: (context, settings, child) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const ElectricityRateScreen(),
                                                  ),
                                                ).then((_) {
                                                  // Refresh dashboard data when returning from rate screen
                                                  dashboardProvider.loadDashboardData();
                                                });
                                              },
                                              child: _buildStatCard(
                                                dashboardProvider.currentRate != null
                                                    ? '${settings.currencySymbol}${dashboardProvider.currentRate!.ratePerKwh.toStringAsFixed(2)}/kWh'
                                                    : settings.getLocalizedText('Set Rate'),
                                                settings.getLocalizedText('Electricity Rate'),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Consumer<SettingsProvider>(
                                            builder: (context, settings, child) {
                                              return _buildStatCard(
                                                '${dashboardProvider.averageDailyUsage.toStringAsFixed(1)} kW',
                                                settings.getLocalizedText('Daily Usage'),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: context.responsiveSize(16)),
                                        Expanded(
                                          child: Consumer<SettingsProvider>(
                                            builder: (context, settings, child) {
                                              return _buildStatCard(
                                                '${settings.currencySymbol}${dashboardProvider.totalMonthlyCost.toStringAsFixed(0)}',
                                                settings.getLocalizedText('Monthly Cost'),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: context.responsiveSize(16)),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const ElectricityRateScreen(),
                                                ),
                                              ).then((_) {
                                                // Refresh dashboard data when returning from rate screen
                                                dashboardProvider.loadDashboardData();
                                              });
                                            },
                                            child: Consumer<SettingsProvider>(
                                              builder: (context, settings, child) {
                                                return _buildStatCard(
                                                  dashboardProvider.currentRate != null
                                                      ? '${settings.currencySymbol}${dashboardProvider.currentRate!.ratePerKwh.toStringAsFixed(2)}/kWh'
                                                      : settings.getLocalizedText('Set Rate'),
                                                  settings.getLocalizedText('Electricity Rate'),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),

                            // Add some bottom padding to ensure content doesn't get cut off
                            SizedBox(height: context.responsiveSize(20)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          value.contains('/kWh')
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value.split('/')[0],
                        style: GoogleFonts.poppins(
                          fontSize: value.length > 6 ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '/kWh',
                        style: GoogleFonts.poppins(
                          fontSize: (value.length > 6 ? 14 : 16) * 0.75,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: value.length > 6 ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, SettingsProvider settings) {
    return Drawer(
      child: Container(
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
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
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
                      _isLoadingProfile ? settings.getLocalizedText('Loading...') : (_userProfile?.name ?? settings.getLocalizedText('User')),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.getLocalizedText('Energy Saver'),
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.home,
                            title: settings.getLocalizedText('Dashboard'),
                            onTap: () {
                              Navigator.pop(context); // Close drawer
                            },
                          );
                        },
                      ),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.bar_chart,
                            title: settings.getLocalizedText('Statistics'),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to stats screen (TrackSaveScreen)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TrackSaveScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.add_circle,
                            title: settings.getLocalizedText('Add Appliance'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddApplianceScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.calendar_today,
                            title: settings.getLocalizedText('Planner'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PlannerScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.person,
                            title: settings.getLocalizedText('Profile'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const Divider(color: Colors.white30, height: 32),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.settings,
                            title: settings.getLocalizedText('Settings'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.help,
                            title: settings.getLocalizedText('Help & Support'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HelpSupportScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return _buildDrawerItem(
                            icon: Icons.info,
                            title: settings.getLocalizedText('About'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Logout Button
              Container(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // Close drawer
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppColors.primaryBlue),
                  label: Text(
                    settings.getLocalizedText('Logout'),
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
