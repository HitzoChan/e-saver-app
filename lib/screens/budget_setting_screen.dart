import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';

class BudgetSettingScreen extends StatefulWidget {
  const BudgetSettingScreen({super.key});

  @override
  State<BudgetSettingScreen> createState() => _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends State<BudgetSettingScreen> {
  final TextEditingController _budgetController = TextEditingController();
  bool _alertsEnabled = true;
  double _alertThreshold = 0.8;

  @override
  void initState() {
    super.initState();
    // Load existing budget if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingBudget();
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _loadExistingBudget() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    if (budgetProvider.currentBudget != null) {
      final budget = budgetProvider.currentBudget!;
      _budgetController.text = budget.monthlyGoal.toStringAsFixed(0);
      _alertsEnabled = budget.alertsEnabled;
      _alertThreshold = budget.alertThreshold;
      setState(() {});
    }
  }

  Future<void> _saveBudget() async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    if (_budgetController.text.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(settingsProvider.getLocalizedText('Please enter a monthly budget amount'))),
      );
      return;
    }

    final budgetAmount = double.tryParse(_budgetController.text);
    if (budgetAmount == null || budgetAmount <= 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(settingsProvider.getLocalizedText('Please enter a valid budget amount'))),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool success;
      if (budgetProvider.hasActiveBudget) {
        // Update existing budget
        success = await budgetProvider.updateBudget(
          monthlyGoal: budgetAmount,
          alertThreshold: _alertThreshold,
          alertsEnabled: _alertsEnabled,
        );
      } else {
        // Create new budget
        success = await budgetProvider.createBudget(
          monthlyGoal: budgetAmount,
          alertThreshold: _alertThreshold,
          alertsEnabled: _alertsEnabled,
        );
      }

      if (success && mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(settingsProvider.getLocalizedText('Budget saved successfully!'))),
        );
        Navigator.pop(context);
      } else if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(settingsProvider.getLocalizedText('Failed to save budget. Please try again.'))),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${settingsProvider.getLocalizedText('Error saving budget:')} $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _isSaving = false;

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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Consumer<SettingsProvider>(
                      builder: (context, settingsProvider, child) {
                        return Text(
                          settingsProvider.getLocalizedText('Set Monthly Budget'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Budget Input Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Consumer<SettingsProvider>(
                        builder: (context, settingsProvider, child) {
                          return Text(
                            settingsProvider.getLocalizedText('Monthly Budget (PHP)'),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<SettingsProvider>(
                        builder: (context, settingsProvider, child) {
                          return Text(
                            settingsProvider.getLocalizedText('Set your target monthly electricity expense'),
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Alert Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<SettingsProvider>(
                        builder: (context, settingsProvider, child) {
                          return Text(
                            settingsProvider.getLocalizedText('Alert Settings'),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Enable Alerts Toggle
                      Consumer<SettingsProvider>(
                        builder: (context, settingsProvider, child) {
                          return SwitchListTile(
                            title: Text(
                              settingsProvider.getLocalizedText('Enable Budget Alerts'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              settingsProvider.getLocalizedText('Get notified when approaching budget limit'),
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            value: _alertsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _alertsEnabled = value;
                              });
                            },
                            activeThumbColor: AppColors.accentGreen,
                          );
                        },
                      ),

                      if (_alertsEnabled) ...[
                        const SizedBox(height: 16),
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              '${settingsProvider.getLocalizedText('Alert Threshold')}: ${(_alertThreshold * 100).toInt()}%',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _alertThreshold,
                          min: 0.5,
                          max: 0.95,
                          divisions: 9,
                          label: '${(_alertThreshold * 100).toInt()}%',
                          onChanged: (value) {
                            setState(() {
                              _alertThreshold = value;
                            });
                          },
                          activeColor: AppColors.accentGreen,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                        ),
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.getLocalizedText('Get alerted when you reach this percentage of your budget'),
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                            ),
                          )
                        : Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Text(
                                settingsProvider.getLocalizedText('Save Budget'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              );
                            },
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
}
