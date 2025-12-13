import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import '../models/appliance.dart';
import '../providers/appliance_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

import 'add_appliance_form_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class AddApplianceScreen extends StatefulWidget {
  const AddApplianceScreen({super.key});

  @override
  State<AddApplianceScreen> createState() => _AddApplianceScreenState();
}

class _AddApplianceScreenState extends State<AddApplianceScreen> {
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplianceProvider>().loadAppliances();
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoadingProfile = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        final userProfileService = UserProfileService();

        _userProfile = await userProfileService.getUserProfile();
        _userProfile ??= await userProfileService.createDefaultProfile(
          userId: auth.user!.uid,
          name: auth.user!.displayName ?? 'User',
          email: auth.user!.email ?? '',
          photoUrl: auth.user!.photoURL,
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }

    if (mounted) setState(() => _isLoadingProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? _darkGradient() : AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),

              const SizedBox(height: 20),

              _buildUserProfile(),

              const SizedBox(height: 30),

              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // FIXED HEADER — NO MORE TEXT DISTORTION
  // ---------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // left spacer

          Expanded(
            child: Text(
              "Add Appliance",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  break;
                case 'help':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                  break;
                case 'about':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()));
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'help', child: Text('Help')),
              PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // USER PROFILE SECTION
  // ---------------------------------------------------
  Widget _buildUserProfile() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            image: DecorationImage(
              image: _userProfile?.photoUrl != null
                  ? NetworkImage(_userProfile!.photoUrl!)
                  : const AssetImage("assets/images/default_avatar.png")
                      as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isLoadingProfile ? "Loading..." : (_userProfile?.name ?? "User"),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------
  // MAIN CONTENT AREA
  // ---------------------------------------------------
  Widget _buildMainContent() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Consumer<ApplianceProvider>(
                  builder: (context, provider, child) {
                    final settings =
                        Provider.of<SettingsProvider>(context, listen: false);
                    final hasAppliances = provider.appliances.isNotEmpty;
                    final connections = hasAppliances ? provider.connectionCount : 0;
                    final avgBill = hasAppliances ? provider.averageMonthlyBill : 0;
                    final household = hasAppliances ? provider.householdAverageUsage : 0;

                    return _buildResponsiveSummaryRow(
                      [
                        _buildStatCard(
                            connections.toString(),
                            settings.getLocalizedText('Connections')),
                        _buildStatCard(
                            '${settings.currencySymbol}${avgBill.toStringAsFixed(0)}',
                            settings.getLocalizedText('Avg Bill Monthly')),
                        _buildStatCard(
                            '${household.toStringAsFixed(1)} kW',
                            settings.getLocalizedText('Household Average')),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                Expanded(child: _buildApplianceList()),
              ],
            ),
          ),
        ),

        // ADD BUTTON
        Positioned(
          right: 20,
          bottom: 20,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddApplianceFormScreen()),
              );
              if (result == true && mounted) {
                context.read<ApplianceProvider>().refresh();
              }
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------
  // APPLIANCE LIST
  // ---------------------------------------------------
  Widget _buildApplianceList() {
    return Consumer<ApplianceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              "Error loading appliances",
              style: GoogleFonts.poppins(color: AppColors.textGray),
            ),
          );
        }

        final appliances = provider.appliances;

        if (appliances.isEmpty) {
          return Center(
            child: Text(
              "No appliances added yet.\nTap the + button to add one!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textGray),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: appliances.length,
          itemBuilder: (context, index) {
            final appliance = appliances[index];
            return Column(
              children: [
                Dismissible(
                  // appliance.id is non-nullable in your model, so use it directly
                  key: ValueKey(appliance.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        final textColor = Theme.of(ctx).textTheme.titleMedium?.color;
                        final subTextColor = Theme.of(ctx).textTheme.bodyMedium?.color?.withValues(alpha: 0.75);
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.delete_outline, color: AppColors.primaryBlue, size: 28),
                                ),
                                const SizedBox(height: 14),
                                Text('Delete appliance',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700, fontSize: 18, color: textColor)),
                                const SizedBox(height: 8),
                                Text('Delete "${appliance.name}"?',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(color: subTextColor, fontSize: 13)),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryBlue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    // Capture context-derived objects before async gap
                    final provider = context.read<ApplianceProvider>();
                    final messenger = ScaffoldMessenger.of(context);

                    // Attempt delete (deleteAppliance may return void). Treat no exception as success.
                    var deleted = false;
                    try {
                      await provider.deleteAppliance(appliance.id);
                      deleted = true;
                    } catch (e) {
                      deleted = false;
                    }

                    if (!deleted) {
                      // restore / refresh list
                      provider.refresh();
                      messenger.showSnackBar(const SnackBar(content: Text('Could not delete appliance')));
                      return;
                    }

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('${appliance.name} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            try {
                              await provider.addAppliance(appliance);
                            } catch (_) {
                              provider.refresh();
                            }
                          },
                        ),
                      ),
                    );
                  },
                  child: _buildApplianceItem(
                    appliance.name,
                    appliance.category.displayName,
                    "${appliance.wattage}W",
                    appliance,
                  ),
                ),
                if (index < appliances.length - 1) const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------
  // INDIVIDUAL APPLIANCE ITEM
  // ---------------------------------------------------
  Widget _buildApplianceItem(
      String name, String category, String watt, Appliance appliance) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddApplianceFormScreen(applianceToEdit: appliance),
          ),
        );
        if (result == true && mounted) {
          context.read<ApplianceProvider>().refresh();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.electrical_services,
                  color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(category,
                      style: GoogleFonts.poppins(color: AppColors.textGray)),
                ],
              ),
            ),
            Text(watt,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // STAT CARD
  // ---------------------------------------------------
  Widget _buildStatCard(String value, String label) {
    return StatCard(value: value, label: label);
  }

  Widget _buildResponsiveSummaryRow(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            cards.length,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < cards.length - 1 ? 12 : 0,
                ),
                child: cards[index],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------
// REUSABLE STAT CARD WIDGET
// ---------------------------------------------------
class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Value text - responsive sizing
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          // Label text - never breaks mid-word
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textGray,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------
// DARK MODE GRADIENT
// ---------------------------------------------------
LinearGradient _darkGradient() {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black,
      Colors.grey[900]!,
      Colors.grey[800]!,
    ],
  );
}
