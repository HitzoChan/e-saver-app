// … existing imports keep the same …
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
                  ? AppColors.darkGradient
                  : AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ================== FIXED CENTERED APP BAR ==================
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),

                        Expanded(
                          child: Text(
                            settingsProvider.getLocalizedText('Planner'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) {
                            switch (value) {
                              case 'settings':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                );
                                break;
                              case 'help':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                                );
                                break;
                              case 'about':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                                );
                                break;
                              default:
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
                  ),

                  const SizedBox(height: 24),

                  // ================== FIXED CIRCULAR BUDGET PROGRESS ==================
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
                              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 60),
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

                      // Compute the progress fraction safely and consistently
                      final double monthlyGoal = budget.monthlyGoal <= 0 ? 0.0 : budget.monthlyGoal;
                      final double fraction = monthlyGoal > 0 ? budget.currentUsage / monthlyGoal : 0.0;
                      final double value = fraction.clamp(0.0, 1.0);

                      // Build adaptive circular budget indicator
                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      // Track and ring colors based on theme and budget state
                      final Color trackColor = isDark
                          ? const Color.fromRGBO(255, 255, 255, 0.14)
                          : const Color.fromRGBO(230, 230, 230, 1.0);

                      final Color ringColor = budget.isOverBudget
                          ? Colors.redAccent
                          : (budget.shouldAlert
                              ? Colors.orangeAccent
                              : (isDark ? AppColors.accentGreen : AppColors.primaryBlue));

                      final Color centerTextColor = isDark
                          ? Colors.white
                          : Colors.black87;

                      // avoid deprecated withOpacity() by creating a dedicated subtitle color
                      final Color subtitleTextColor = isDark
                          ? const Color.fromRGBO(255, 255, 255, 0.85)
                          : const Color.fromRGBO(0, 0, 0, 0.8);

                      return Column(
                        children: [
                          SizedBox(
                            width: 230,
                            height: 230,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Subtle background disk so ring stands out
                                Container(
                                  width: 230,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? const Color.fromRGBO(0, 0, 0, 0.08) : const Color.fromRGBO(255, 255, 255, 1.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(0, 0, 0, 0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),

                                // Progress ring (explicit size)
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 14,
                                    backgroundColor: trackColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                                  ),
                                ),

                                // Center content (percentage + usage)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${(value * 100).toStringAsFixed(0)}%',
                                      style: GoogleFonts.poppins(
                                        color: centerTextColor,
                                        fontSize: 52,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${settingsProvider.currencySymbol}${budget.currentUsage.toStringAsFixed(0)} / '
                                      '${settingsProvider.currencySymbol}${budget.monthlyGoal.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        color: subtitleTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Add spacing between the circular progress and the main content
                  const SizedBox(height: 24),

                  // ================== MAIN CONTENT ==================
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
                              // ---------------- CATEGORY BUTTONS ----------------
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCategoryChip(
                                      settingsProvider.getLocalizedText('Keep\nGoodHabits'),
                                      true,
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const GoodHabitsScreen()),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildCategoryChip(
                                      settingsProvider.getLocalizedText('Tips\nTricks'),
                                      false,
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const EnergyTipsScreen()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // ---------------- APPLIANCES SECTION ----------------
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
                                        children: [
                                          const Icon(Icons.devices_other, size: 48, color: Colors.grey),
                                          const SizedBox(height: 16),
                                          Text(
                                            settingsProvider.language == 'Filipino'
                                                ? 'Walang appliances na naidagdag pa'
                                                : 'No appliances added yet',
                                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            settingsProvider.language == 'Filipino'
                                                ? 'Magdagdag ng appliances para makita ang budget breakdown'
                                                : 'Add appliances to see budget breakdown',
                                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
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
                                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                      ),
                                    );
                                  }

                                  final sortedAppliances = List<Appliance>.from(appliances)
                                    ..sort((a, b) {
                                      final costA = a.calculateMonthlyCost(rate.ratePerKwh, a.hoursPerDay);
                                      final costB = b.calculateMonthlyCost(rate.ratePerKwh, b.hoursPerDay);
                                      return costB.compareTo(costA);
                                    });

                                  final displayAppliances = sortedAppliances.take(5).toList();

                                  return Column(
                                    children: displayAppliances.map((appliance) {
                                      final monthlyCost = appliance.calculateMonthlyCost(
                                        rate.ratePerKwh,
                                        appliance.hoursPerDay,
                                      );

                                      final categoryText = _getCategoryDisplayText(
                                          appliance.category, settingsProvider.language);

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

                              // ---------------- SET/UPDATE BUDGET BUTTON ----------------
                              Consumer<BudgetProvider>(
                                builder: (context, budgetProvider, child) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const BudgetSettingScreen()),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        budgetProvider.hasActiveBudget
                                            ? settingsProvider.getLocalizedText('Update Monthly Budget')
                                            : settingsProvider.getLocalizedText('Set Monthly Budget'),
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

  // ================= CATEGORY TEXT =================
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

  // ================= CATEGORY CHIP =================
  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : (isDark ? Colors.grey[600] : const Color.fromRGBO(218, 218, 218, 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textGray),
            ),
          ),
        ),
      ),
    );
  }

  // ================= RESPONSIVE BUDGET ITEM =================
  Widget _buildBudgetItem(String name, String category, String amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double deviceWidth = MediaQuery.of(context).size.width;

    double titleFont = (deviceWidth * 0.045).clamp(12, 16);
    double subtitleFont = (deviceWidth * 0.032).clamp(10, 13);
    double priceFont = (deviceWidth * 0.045).clamp(12, 16);

    IconData getApplianceIcon(String applianceName) {
      final lower = applianceName.toLowerCase();

      if (lower.contains('refrigerator') || lower.contains('fridge')) {
        return Icons.kitchen;
      }
      if (lower.contains('air') || lower.contains('ac') || lower.contains('cool')) {
        return Icons.ac_unit;
      }
      return Icons.electrical_services;
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
              color: const Color.fromRGBO(65, 105, 225, 0.1),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: titleFont,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: subtitleFont,
                    color: isDark ? Colors.white70 : AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: priceFont,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
