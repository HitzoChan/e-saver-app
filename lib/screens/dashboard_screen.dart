// lib/screens/dashboard_screen.dart
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  bool _showGetStarted = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
      _loadUserProfile();
      _triggerGetStartedPopup();
    });
  }

  void _triggerGetStartedPopup() {
    if (!mounted) return;
    setState(() => _showGetStarted = true);
    _fadeController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _showGetStarted = false);
      });
    });
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoadingProfile = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user != null) {
        final userProfileService = UserProfileService();
        final profile = await userProfileService.getUserProfile();

        if (!mounted) return;
        _userProfile = profile;

        if (_userProfile == null) {
          final created = await userProfileService.createDefaultProfile(
            userId: authProvider.user!.uid,
            name: authProvider.user!.displayName ?? 'User',
            email: authProvider.user!.email ?? '',
            photoUrl: authProvider.user!.photoURL,
          );

          if (!mounted) return;
          _userProfile = created;
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    if (!mounted) return;
    setState(() => _isLoadingProfile = false);
  }

  void _openDrawer(BuildContext context) {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Consumer<SettingsProvider>(
        builder: (context, settings, child) =>
            _buildDrawer(context),
      ),
      body: Stack(
        children: [
          _buildDashboardContent(),

          if (_showGetStarted)
            Positioned(
              bottom: 20,
              right: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AddApplianceScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "Get Started",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------- MAIN CONTENT ----------------------

  Widget _buildDashboardContent() {
    return Container(
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
              return _buildErrorState(dashboardProvider);
            }

            return _buildDashboard(dashboardProvider);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(DashboardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            "Error loading dashboard",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: provider.refresh,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildDashboard(DashboardProvider dashboardProvider) {
    return Column(
      children: [
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
              const SizedBox(width: 40),
              _buildPopupMenu(),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: context.responsiveSize(10)),
                _buildLogo(),
                SizedBox(height: context.responsiveSize(20)),
                _buildApplianceCount(dashboardProvider),
                SizedBox(height: context.responsiveSize(10)),
                _buildWaveGraph(dashboardProvider),
                _buildStatCards(dashboardProvider),
                SizedBox(height: context.responsiveSize(40)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        switch (value) {
          case 'settings':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
            break;
          case 'help':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen()));
            break;
          case 'about':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AboutScreen()));
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'settings', child: Text('Settings')),
        PopupMenuItem(value: 'help', child: Text('Help')),
        PopupMenuItem(value: 'about', child: Text('About')),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: context.responsiveSize(80),
      height: context.responsiveSize(80),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.2),
        borderRadius:
            BorderRadius.circular(context.responsiveBorderRadius(20)),
      ),
      child: const Icon(Icons.eco, size: 50, color: AppColors.accentGreen),
    );
  }

  Widget _buildApplianceCount(DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "${provider.applianceCount} Appliances",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: context.responsiveFontSize(14),
          ),
        ),
      ),
    );
  }

  Widget _buildWaveGraph(DashboardProvider provider) {
    return WaveGraph(
      dataPoints: provider.weeklyUsageData,
      labels: provider.applianceLabels,
      height: context.responsiveSize(140),
    );
  }

  Widget _buildStatCards(DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Wrap(
        spacing: context.responsiveSize(12),
        runSpacing: context.responsiveSize(12),
        alignment: WrapAlignment.center,
        children: [
          SizedBox(
            width: context.isMobile
                ? (MediaQuery.of(context).size.width -
                        context.responsiveSize(40) -
                        context.responsiveSize(12)) /
                    2
                : (MediaQuery.of(context).size.width -
                        context.responsiveSize(40) -
                        2 * context.responsiveSize(12)) /
                    3,
            child: _buildStatCard(
              '${provider.averageDailyUsage.toStringAsFixed(1)} kW',
              'Daily Usage',
            ),
          ),
          SizedBox(
            width: context.isMobile
                ? (MediaQuery.of(context).size.width -
                        context.responsiveSize(40) -
                        context.responsiveSize(12)) /
                    2
                : (MediaQuery.of(context).size.width -
                        context.responsiveSize(40) -
                        2 * context.responsiveSize(12)) /
                    3,
            child: _buildStatCard(
              '${Provider.of<SettingsProvider>(context, listen: false).currencySymbol}${provider.totalMonthlyCost.toStringAsFixed(0)}',
              'Monthly Cost',
            ),
          ),
          SizedBox(
            width: context.isMobile
                ? MediaQuery.of(context).size.width -
                    context.responsiveSize(40)
                : (MediaQuery.of(context).size.width -
                        context.responsiveSize(40) -
                        2 * context.responsiveSize(12)) /
                    3,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ElectricityRateScreen()),
                ).then((_) => provider.loadDashboardData());
              },
              child: _buildStatCard(
                provider.currentRate != null
                    ? '${Provider.of<SettingsProvider>(context, listen: false).currencySymbol}${provider.currentRate!.ratePerKwh.toStringAsFixed(2)}/kWh'
                    : 'Set Rate',
                'Electricity Rate',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: context.isMobile ? 70 : 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            isDark ? const Color.fromRGBO(255, 255, 255, 0.06) : const Color.fromRGBO(255, 255, 255, 0.1),
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
                          fontSize: context.isMobile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '/kWh',
                        style: GoogleFonts.poppins(
                          fontSize: context.isMobile ? 9 : 10,
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
                    fontSize: context.isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: context.isMobile ? 8 : 9,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- DRAWER (Option A Behavior) ----------------------

  Widget _buildDrawer(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Drawer(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.8
          : context.responsiveSize(320),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : null,
          gradient: isDark ? null : AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // PROFILE SECTION
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSize(24),
                  vertical: context.responsiveSize(32),
                ),
                child: Column(
                  children: [
                    Container(
                      width: context.responsiveSize(80),
                      height: context.responsiveSize(80),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: context.responsiveSize(3),
                        ),
                        image: DecorationImage(
                          image: _userProfile?.photoUrl != null
                              ? NetworkImage(_userProfile!.photoUrl!)
                              : const AssetImage(
                                      "assets/images/default_avatar.png")
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: context.responsiveSize(16)),
                    Text(
                      _isLoadingProfile
                          ? "Loading..."
                          : (_userProfile?.name ?? "User"),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: context.responsiveFontSize(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.responsiveSize(4)),
                    Text(
                      "Energy Saver",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                  ],
                ),
              ),

              // MENU ITEMS
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerButton(
                      icon: Icons.home,
                      text: "Dashboard",
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerButton(
                      icon: Icons.bar_chart,
                      text: "Statistics",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TrackSaveScreen()),
                        );
                      },
                    ),
                    _buildDrawerButton(
                      icon: Icons.add_circle,
                      text: "Add Appliance",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddApplianceScreen()),
                        );
                      },
                    ),
                    _buildDrawerButton(
                      icon: Icons.calendar_today,
                      text: "Planner",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PlannerScreen()),
                        );
                      },
                    ),
                    _buildDrawerButton(
                      icon: Icons.person,
                      text: "Profile",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),

                    Divider(
                      color: Colors.white30,
                      height: context.responsiveSize(32),
                    ),

                    _buildDrawerButton(
                      icon: Icons.settings,
                      text: "Settings",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                    _buildDrawerButton(
                      icon: Icons.help,
                      text: "Help & Support",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen()),
                        );
                      },
                    ),
                    _buildDrawerButton(
                      icon: Icons.info,
                      text: "About",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AboutScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // LOGOUT BUTTON — FIXED WARNING
              Padding(
                padding: EdgeInsets.all(context.responsiveSize(16)),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final loginRoute =
                        MaterialPageRoute(builder: (_) => const LoginScreen());

                    navigator.pop();

                    final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false);
                    await auth.signOut();

                    if (!mounted) return;
                    navigator.pushAndRemoveUntil(
                        loginRoute, (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    minimumSize:
                        Size(double.infinity, context.responsiveSize(48)),
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

  Widget _buildDrawerButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
