import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/electricity_rate_service.dart';
import '../models/electricity_rate.dart';
import '../models/rate_source.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ElectricityRateScreen extends StatefulWidget {
  const ElectricityRateScreen({super.key});

  @override
  State<ElectricityRateScreen> createState() => _ElectricityRateScreenState();
}

class _ElectricityRateScreenState extends State<ElectricityRateScreen> {
  final ElectricityRateService _rateService = ElectricityRateService();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();

  ElectricityRate? _currentRate;
  final bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentRate();
  }

  @override
  void dispose() {
    _rateController.dispose();
    _providerController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentRate() async {
    // Capture messenger before any async gaps
    final messenger = ScaffoldMessenger.of(context);

    try {
      final rate = await _rateService.getCurrentElectricityRate();

      if (!mounted) return; // guard against using context after await

      setState(() {
        _currentRate = rate;
        if (rate != null) {
          _rateController.text = rate.ratePerKwh.toString();
          _providerController.text = rate.provider;
        }
      });
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error loading rate: $e')),
        );
      }
    }
  }

  Future<void> _saveRate() async {
    // Capture messenger synchronously
    final messenger = ScaffoldMessenger.of(context);

    if (_rateController.text.isEmpty || _providerController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final rate = double.tryParse(_rateController.text);
    if (rate == null || rate <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a valid rate')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Capture provider before async gap
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Please sign in to save rates')),
        );
        // ensure saving flag cleared
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      final newRate = await _rateService.createElectricityRate(
        ratePerKwh: rate,
        provider: _providerController.text.trim(),
        source: RateSource.manual,
      );

      if (!mounted) return;

      setState(() => _currentRate = newRate);

      messenger.showSnackBar(
        const SnackBar(content: Text('Rate saved successfully')),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error saving rate: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _checkForUpdates() async {
    // TODO: Implement Facebook Graph API integration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook integration coming soon')),
    );
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
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
                          const Spacer(),
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

                    // Title
                    Text(
                      'Electricity Rate (₱/kWh)',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Provider Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _providerController,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter provider (e.g., Meralco)',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Rate Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _rateController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
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
                            Text(
                              'per kWh',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Current Rate Display
                    if (_currentRate != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Current: ₱${_currentRate!.ratePerKwh.toStringAsFixed(2)} (${_currentRate!.ageDescription})',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveRate,
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
                                  : Text(
                                      'Save Rate',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Check for Updates Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _checkForUpdates,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white, width: 1),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Check for Updates',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
