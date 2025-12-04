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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    if (_budgetController.text.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            settingsProvider
                .getLocalizedText('Please enter a monthly budget amount'),
          ),
        ),
      );
      return;
    }

    final budgetAmount = double.tryParse(_budgetController.text);
    if (budgetAmount == null || budgetAmount <= 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            settingsProvider
                .getLocalizedText('Please enter a valid budget amount'),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool success;
      if (budgetProvider.hasActiveBudget) {
        success = await budgetProvider.updateBudget(
          monthlyGoal: budgetAmount,
          alertThreshold: _alertThreshold,
          alertsEnabled: _alertsEnabled,
        );
      } else {
        success = await budgetProvider.createBudget(
          monthlyGoal: budgetAmount,
          alertThreshold: _alertThreshold,
          alertsEnabled: _alertsEnabled,
        );
      }

      if (success && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              settingsProvider.getLocalizedText('Budget saved successfully!'),
            ),
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              settingsProvider.getLocalizedText(
                'Failed to save budget. Please try again.',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "${settingsProvider.getLocalizedText('Error saving budget:')} $e",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSpacing = screenHeight * 0.05;
    final cardPadding = screenHeight * 0.02;

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Padding(
                  padding: EdgeInsets.fromLTRB(16, topSpacing, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Consumer<SettingsProvider>(
                        builder: (context, settingsProvider, child) {
                          return Expanded(
                            child: Text(
                              settingsProvider
                                  .getLocalizedText('Set Monthly Budget'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // MONTHLY BUDGET BOX
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Consumer<SettingsProvider>(
                          builder: (context, sp, child) {
                            return Text(
                              sp.getLocalizedText('Monthly Budget (PHP)'),
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
                            fontSize: screenHeight * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: screenHeight * 0.045,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer<SettingsProvider>(
                          builder: (context, sp, child) {
                            return Text(
                              sp.getLocalizedText(
                                  'Set your target monthly electricity expense'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // ALERT SETTINGS BOX
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<SettingsProvider>(
                          builder: (context, sp, child) {
                            return Text(
                              sp.getLocalizedText('Alert Settings'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        Consumer<SettingsProvider>(
                          builder: (context, sp, child) {
                            return SwitchListTile(
                              title: Text(
                                sp.getLocalizedText('Enable Budget Alerts'),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                sp.getLocalizedText(
                                  'Get notified when approaching budget limit',
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              value: _alertsEnabled,
                              onChanged: (value) =>
                                  setState(() => _alertsEnabled = value),

                              /// FIXED (deprecated activeColor → activeThumbColor)
                              activeThumbColor: AppColors.accentGreen,
                            );
                          },
                        ),

                        if (_alertsEnabled) ...[
                          const SizedBox(height: 12),
                          Consumer<SettingsProvider>(
                            builder: (context, sp, child) {
                              return Text(
                                '${sp.getLocalizedText('Alert Threshold')}: ${(_alertThreshold * 100).round()}%',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          Slider(
                            value: _alertThreshold,
                            min: 0.5,
                            max: 0.95,
                            divisions: 9,
                            label: '${(_alertThreshold * 100).round()}%',
                            onChanged: (value) =>
                                setState(() => _alertThreshold = value),
                            activeColor: AppColors.accentGreen,
                            inactiveColor:
                                Colors.white.withValues(alpha: 0.3),
                          ),
                          Consumer<SettingsProvider>(
                            builder: (context, sp, child) {
                              return Text(
                                sp.getLocalizedText(
                                  'Get alerted when you reach this percentage of your budget',
                                ),
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

                SizedBox(height: screenHeight * 0.03),

                // SAVE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryBlue,
                                ),
                              ),
                            )
                          : Consumer<SettingsProvider>(
                              builder: (context, sp, child) {
                                return Text(
                                  sp.getLocalizedText('Save Budget'),
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
