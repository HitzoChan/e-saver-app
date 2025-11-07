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
    // Load appliances when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplianceProvider>().loadAppliances();
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
                      'Add Appliance',
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
              
              // User Profile
              Column(
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
                  const SizedBox(height: 12),
                  Text(
                    _isLoadingProfile ? 'Loading...' : (_userProfile?.name ?? 'User'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Appliance List
              Expanded(
                child: Container(
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
                        // Stats Row - Responsive Wrap
                        Consumer<ApplianceProvider>(
                          builder: (context, applianceProvider, child) {
                            final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width < 600
                                      ? (MediaQuery.of(context).size.width - 48 - 16) / 2
                                      : (MediaQuery.of(context).size.width - 48 - 32) / 3,
                                  child: _buildStatCard(
                                    applianceProvider.connectionCount.toString(),
                                    settingsProvider.getLocalizedText('Connections'),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width < 600
                                      ? (MediaQuery.of(context).size.width - 48 - 16) / 2
                                      : (MediaQuery.of(context).size.width - 48 - 32) / 3,
                                  child: _buildStatCard(
                                    '${settingsProvider.currencySymbol}${applianceProvider.averageMonthlyBill.toStringAsFixed(0)}',
                                    settingsProvider.getLocalizedText('Avg Bill Monthly'),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width < 600
                                      ? MediaQuery.of(context).size.width - 48
                                      : (MediaQuery.of(context).size.width - 48 - 32) / 3,
                                  child: _buildStatCard(
                                    '${applianceProvider.householdAverageUsage.toStringAsFixed(1)} kW',
                                    settingsProvider.getLocalizedText('Household Average'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Appliance List
                        Expanded(
                          child: Consumer<ApplianceProvider>(
                            builder: (context, applianceProvider, child) {
                              if (applianceProvider.isLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (applianceProvider.error != null) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: AppColors.textGray,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading appliances',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.textGray,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: applianceProvider.refresh,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final appliances = applianceProvider.appliances;
                              return appliances.isEmpty
                                ? Center(
                                    child: Consumer<SettingsProvider>(
                                      builder: (context, settingsProvider, child) {
                                        return Text(
                                          settingsProvider.getLocalizedText('No appliances added yet.\nTap the + button to add your first appliance!'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textGray,
                                            fontSize: 16,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: appliances.length,
                                    itemBuilder: (context, index) {
                                      final appliance = appliances[index];
                                      return Column(
                                        children: [
                                          _buildApplianceItem(
                                            appliance.name,
                                            appliance.category.displayName,
                                            '${appliance.wattage}W',
                                            appliance,
                                          ),
                                          if (index < appliances.length - 1)
                                            const SizedBox(height: 12),
                                        ],
                                      );
                                    },
                                  );
                            },
                          ),
                        ),
                        
                        // Add Button
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddApplianceFormScreen(),
                              ),
                            );
                            // Refresh the list when returning from add form
                            if (result == true) {
                              if (mounted) {
                                context.read<ApplianceProvider>().refresh();
                              }
                            }
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
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
  }
  
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildApplianceItem(String name, String category, String details, Appliance appliance) {
    return Dismissible(
      key: Key(appliance.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Appliance'),
              content: Text('Are you sure you want to delete "$name"?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        // Capture messenger and provider before async gap
        final messenger = ScaffoldMessenger.of(context);
        final provider = context.read<ApplianceProvider>();

        try {
          await provider.deleteAppliance(appliance.id);
          messenger.showSnackBar(
            SnackBar(content: Text('$name deleted successfully')),
          );
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('Error deleting appliance: $e')),
          );
          // Reload the list to restore the item if deletion failed
          provider.refresh();
        }
      },
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddApplianceFormScreen(applianceToEdit: appliance),
            ),
          );
          // Refresh the list when returning from edit form
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                child: const Icon(
                  Icons.electrical_services,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                details,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
