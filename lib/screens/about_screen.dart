import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/settings_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                          settingsProvider.getLocalizedText('About'),
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
                  Icons.eco,
                  size: 80,
                  color: AppColors.accentGreen,
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Text(
                    settingsProvider.getLocalizedText('About E-Saver'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Version
              Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
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
                              settingsProvider.getLocalizedText('About E-Saver'),
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
                            return Text(
                              settingsProvider.language == 'Filipino'
                                  ? 'Ang E-Saver ay isang smart na aplikasyon na tumutulong sa mga user na subaybayan at pamahalaan ang kanilang paggamit ng kuryente. Sa pamamagitan ng pag-track ng mga appliance at paggamit ng enerhiya, makakatulong ito sa iyo na makatipid sa iyong electricity bill.'
                                  : 'E-Saver is a smart application that helps users track and manage their electricity usage. By tracking appliances and energy consumption, it helps you save on your electricity bills.',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.getLocalizedText('Features'),
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
                            return Column(
                              children: [
                                _buildFeatureItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Subaybayan ang paggamit ng appliance'
                                      : 'Track appliance usage',
                                ),
                                _buildFeatureItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Kalkulahin ang monthly electricity cost'
                                      : 'Calculate monthly electricity costs',
                                ),
                                _buildFeatureItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Mga personalized na energy-saving tips'
                                      : 'Personalized energy-saving tips',
                                ),
                                _buildFeatureItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Budget setting at alerts'
                                      : 'Budget setting and alerts',
                                ),
                                _buildFeatureItem(
                                  context,
                                  settingsProvider.language == 'Filipino'
                                      ? 'Weekly usage reports'
                                      : 'Weekly usage reports',
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.getLocalizedText('Contact Us'),
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
                                  ? 'Para sa anumang tanong o feedback, mangyaring makipag-ugnayan sa amin sa:'
                                  : 'For any questions or feedback, please contact us at:',
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
                              settingsProvider.getLocalizedText('Privacy Policy'),
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
                                  ? 'Ang iyong privacy ay mahalagang sa amin. Basahin ang aming privacy policy para sa higit pang impormasyon tungkol sa kung paano namin hinihila at ginagamit ang iyong data.'
                                  : 'Your privacy is important to us. Read our privacy policy for more information about how we collect and use your data.',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) {
                            return Text(
                              settingsProvider.getLocalizedText('Terms of Service'),
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
                                  ? 'Sa pamamagitan ng paggamit ng E-Saver, sumasang-ayon ka sa aming terms of service. Basahin ang kumpletong terms para sa higit pang detalye.'
                                  : 'By using E-Saver, you agree to our terms of service. Read the full terms for more details.',
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

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.accentGreen,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
