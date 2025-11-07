import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/budget_provider.dart';
import '../providers/appliance_provider.dart';
import '../providers/settings_provider.dart';
import 'budget_setting_screen.dart';
import 'energy_tips_screen.dart';
import 'good_habits_screen.dart';

import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import '../models/appliance.dart';
import '../models/appliance_category.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  void initState() {
    super.initState();
    // Load budget data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BudgetProvider>().loadCurrentBudget();
      }
    });
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
                          settingsProvider.getLocalizedText('Planner'),
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

                  const SizedBox(height: 40),

                  // Budget Progress
                  Consumer<BudgetProvider>(
                    builder: (context, budgetProvider, child) {
                      if (budgetProvider.isLoading) {
                        return const SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4,
                          ),
                        );
                      }

                      final budget = budgetProvider.currentBudget;
                      if (budget == null) {
                        return SizedBox(
                          width: 200,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                settingsProvider.getLocalizedText('No Budget Set'),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final progress = budget.progressPercentage;
                      final progressText = '${(progress * 100).toStringAsFixed(0)}%';

                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  budget.isOverBudget
                                      ? Colors.red
                                      : budget.shouldAlert
                                          ? Colors.orange
                                          : AppColors.accentGreen,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  progressText,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${settingsProvider.currencySymbol}${budget.currentUsage.toStringAsFixed(0)} / ${settingsProvider.currencySymbol}${budget.monthlyGoal.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Budget Categories
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCategoryChip(settingsProvider.getLocalizedText('Keep\nGoodHabits'), true, () {
                                      // Navigate to good habits screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const GoodHabitsScreen(),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),

                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildCategoryChip(settingsProvider.getLocalizedText('Tips\nTricks'), false, () {
                                      // Navigate to energy tips screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const EnergyTipsScreen(),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Appliance Budget List
                              Consumer<ApplianceProvider>(
                                builder: (context, applianceProvider, child) {
                                  if (applianceProvider.isLoading) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  final appliances = applianceProvider.appliances;
                                  final rate = applianceProvider.currentRate;

                                  if (appliances.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.devices_other,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            settingsProvider.language == 'Filipino'
                                                ? 'Walang appliances na naidagdag pa'
                                                : 'No appliances added yet',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            settingsProvider.language == 'Filipino'
                                                ? 'Magdagdag ng appliances para makita ang budget breakdown'
                                                : 'Add appliances to see budget breakdown',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (rate == null) {
                                    return Center(
                                      child: Text(
                                        settingsProvider.language == 'Filipino'
                                            ? 'Walang electricity rate na nakatakda'
                                            : 'No electricity rate set',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }

                                  // Sort appliances by monthly cost (highest first)
                                  final sortedAppliances = List<Appliance>.from(appliances)
                                    ..sort((a, b) {
                                      final costA = a.calculateMonthlyCost(rate.ratePerKwh, a.hoursPerDay);
                                      final costB = b.calculateMonthlyCost(rate.ratePerKwh, b.hoursPerDay);
                                      return costB.compareTo(costA);
                                    });

                                  // Show top 5 appliances or all if less than 5
                                  final displayAppliances = sortedAppliances.take(5).toList();

                                  return Column(
                                    children: displayAppliances.map((appliance) {
                                      final monthlyCost = appliance.calculateMonthlyCost(rate.ratePerKwh, appliance.hoursPerDay);
                                      final categoryText = _getCategoryDisplayText(appliance.category, settingsProvider.language);

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildBudgetItem(
                                          appliance.name,
                                          categoryText,
                                          '${settingsProvider.currencySymbol}${monthlyCost.toStringAsFixed(2)}',
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Set Monthly Budget Button
                              Consumer<BudgetProvider>(
                                builder: (context, budgetProvider, child) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const BudgetSettingScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        budgetProvider.hasActiveBudget ? settingsProvider.getLocalizedText('Update Monthly Budget') : settingsProvider.getLocalizedText('Set Monthly Budget'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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
      },
    );
  }

  String _getCategoryDisplayText(ApplianceCategory category, String language) {
    final isFilipino = language == 'Filipino';

    switch (category) {
      case ApplianceCategory.cooling:
        return isFilipino ? 'Pagpapalamig' : 'Cooling';
      case ApplianceCategory.entertainment:
        return isFilipino ? 'Libangan' : 'Entertainment';
      case ApplianceCategory.kitchen:
        return isFilipino ? 'Pangunahing' : 'Essentials';
      case ApplianceCategory.cleaning:
        return isFilipino ? 'Paglilinis' : 'Cleaning';
      case ApplianceCategory.personalCare:
        return isFilipino ? 'Personal na Pangangalaga' : 'Personal Care';
      case ApplianceCategory.laundry:
        return isFilipino ? 'Labahan' : 'Laundry';
      case ApplianceCategory.electronics:
        return isFilipino ? 'Elektronika' : 'Electronics';
      case ApplianceCategory.lighting:
        return isFilipino ? 'Ilaw' : 'Lighting';
      case ApplianceCategory.business:
        return isFilipino ? 'Negosyo' : 'Business';
      case ApplianceCategory.dorm:
        return isFilipino ? 'Dormitoryo' : 'Dorm';
      case ApplianceCategory.essentials:
        return isFilipino ? 'Pangunahing' : 'Essentials';
      case ApplianceCategory.other:
        return isFilipino ? 'Iba pa' : 'Other';
    }
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60, // Fixed height for uniform size
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : (isDark ? Colors.grey[600] : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11, // Slightly smaller font for better fit
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textGray),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBudgetItem(String name, String category, String amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get appropriate icon based on appliance name
    IconData getApplianceIcon(String applianceName) {
      final lowerName = applianceName.toLowerCase();
      if (lowerName.contains('refrigerator') || lowerName.contains('fridge')) {
        return Icons.kitchen;
      } else if (lowerName.contains('air') || lowerName.contains('ac') || lowerName.contains('cooling')) {
        return Icons.ac_unit;
      } else {
        return Icons.electrical_services;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : AppColors.cardLight,
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
              getApplianceIcon(name),
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
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
