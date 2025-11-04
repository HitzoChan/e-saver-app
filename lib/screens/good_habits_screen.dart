import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/appliance_provider.dart';
import '../providers/settings_provider.dart';
import '../models/appliance.dart';
import '../models/appliance_category.dart';
import '../services/habit_tips_service.dart';

class GoodHabitsScreen extends StatelessWidget {
  const GoodHabitsScreen({super.key});

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
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          settingsProvider.getLocalizedText('Good Habits'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 50,
                      color: AppColors.accentGreen,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    settingsProvider.getLocalizedText('Good Habits'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    settingsProvider.language == 'Filipino'
                        ? 'Subaybayan at pagbutihin ang iyong mga gawi sa paggamit ng kuryente'
                        : 'Track and improve your electricity usage habits',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Consumer<ApplianceProvider>(
                        builder: (context, applianceProvider, child) {
                          if (applianceProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    settingsProvider.language == 'Filipino'
                                        ? 'Walang appliances na naka-add'
                                        : 'No appliances added yet',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    settingsProvider.language == 'Filipino'
                                        ? 'Magdagdag ng appliances upang makita ang iyong mga gawi'
                                        : 'Add appliances to see your usage habits',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: ListView.builder(
                              itemCount: appliances.length,
                              itemBuilder: (context, index) {
                                final appliance = appliances[index];
                                return _buildApplianceHabitCard(
                                  context,
                                  appliance,
                                  rate,
                                  settingsProvider,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildApplianceHabitCard(
    BuildContext context,
    Appliance appliance,
    dynamic rate,
    SettingsProvider settingsProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate daily and monthly usage
    final dailyUsage = appliance.wattage * appliance.hoursPerDay / 1000; // kWh
    final monthlyUsage = dailyUsage * 30;
    final monthlyCost = rate != null ? monthlyUsage * rate.ratePerKwh : 0.0;

    // Get habit tips based on appliance type using the new service
    final habitTipsService = HabitTipsService();
    final habitTips = habitTipsService.getHabitTips(appliance, settingsProvider.language);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appliance Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getApplianceIcon(appliance.category),
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appliance.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${appliance.hoursPerDay} ${settingsProvider.language == 'Filipino' ? 'oras kada araw' : 'hours per day'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${dailyUsage.toStringAsFixed(2)} kWh/day',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${settingsProvider.currencySymbol}${monthlyCost.toStringAsFixed(2)}/month',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Habit Tips
          Text(
            settingsProvider.language == 'Filipino' ? 'Mga Tip para sa Mabuting Ugali:' : 'Good Habit Tips:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),

          const SizedBox(height: 8),

          ...habitTips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.accentGreen)),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.textGray,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }



  IconData _getApplianceIcon(ApplianceCategory category) {
    switch (category) {
      case ApplianceCategory.cooling:
        return Icons.ac_unit;
      case ApplianceCategory.entertainment:
        return Icons.tv;
      case ApplianceCategory.kitchen:
        return Icons.kitchen;
      case ApplianceCategory.cleaning:
        return Icons.cleaning_services;
      case ApplianceCategory.personalCare:
        return Icons.spa;
      case ApplianceCategory.laundry:
        return Icons.local_laundry_service;
      case ApplianceCategory.electronics:
        return Icons.computer;
      case ApplianceCategory.lighting:
        return Icons.lightbulb;
      case ApplianceCategory.business:
        return Icons.business;
      case ApplianceCategory.dorm:
        return Icons.home;
      case ApplianceCategory.essentials:
        return Icons.home;
      case ApplianceCategory.other:
        return Icons.devices_other;
    }
  }
}
