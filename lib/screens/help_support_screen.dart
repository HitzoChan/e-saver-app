import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/settings_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
                          settingsProvider.getLocalizedText('Help & Support'),
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

              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.help_center,
                  size: 80,
                  color: AppColors.accentGreen,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Text(
                    settingsProvider.getLocalizedText('Help & Support'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Subtitle
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Text(
                    settingsProvider.language == 'Filipino'
                        ? 'Kumuha ng tulong at suporta para sa iyong mga tanong'
                        : 'Get help and support for your questions',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Content Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.getLocalizedText('Frequently Asked Questions'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Column(
                              children: [
                                _buildFAQItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Paano magdagdag ng appliance?'
                                      : 'How do I add an appliance?',
                                  settingsProvider.language == 'Filipino'
                                      ? 'Pumunta sa menu at piliin ang "Add Appliance" upang magdagdag ng bagong appliance sa iyong listahan.'
                                      : 'Go to the menu and select "Add Appliance" to add a new appliance to your list.',
                                ),
                                _buildFAQItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Paano itakda ang electricity rate?'
                                      : 'How do I set the electricity rate?',
                                  settingsProvider.language == 'Filipino'
                                      ? 'Tapikin ang "Electricity Rate" card sa dashboard upang itakda ang iyong rate per kWh.'
                                      : 'Tap the "Electricity Rate" card on the dashboard to set your rate per kWh.',
                                ),
                                _buildFAQItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Paano tingnan ang aking statistics?'
                                      : 'How do I view my statistics?',
                                  settingsProvider.language == 'Filipino'
                                      ? 'Pumunta sa drawer menu at piliin ang "Statistics" upang makita ang iyong usage data.'
                                      : 'Go to the drawer menu and select "Statistics" to view your usage data.',
                                ),
                                _buildFAQItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Paano mag-set ng budget?'
                                      : 'How do I set a budget?',
                                  settingsProvider.language == 'Filipino'
                                      ? 'Sa Planner screen, maaari kang mag-set ng budget para sa iyong monthly electricity consumption.'
                                      : 'In the Planner screen, you can set a budget for your monthly electricity consumption.',
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.getLocalizedText('Contact Support'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.language == 'Filipino'
                                  ? 'Kung hindi mo mahanap ang sagot sa iyong tanong, mangyaring makipag-ugnayan sa amin:'
                                  : 'If you cannot find the answer to your question, please contact us:',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'support@e-saver.com',
                          style: GoogleFonts.poppins(
                            color: AppColors.accentGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.getLocalizedText('User Guide'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.language == 'Filipino'
                                  ? 'Para sa detalyadong gabay sa paggamit ng app, bisitahin ang aming website o basahin ang in-app tutorials.'
                                  : 'For detailed guides on using the app, visit our website or read the in-app tutorials.',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Copyright
                        Center(
                          child: Text(
                            '© 2024 E-Saver. All rights reserved.',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: AppColors.accentGreen,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
