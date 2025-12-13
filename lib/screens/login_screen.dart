import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_utils.dart';
import '../main.dart'; // Import MainScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

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
          child: Padding(
            padding:
                context.responsivePadding(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'E-Saver',
                  style: GoogleFonts.poppins(
                    fontSize: context.responsiveFontSize(48),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: context.responsiveSize(8)),

                Text(
                  'Track Your Energy Usage',
                  style: GoogleFonts.poppins(
                    fontSize: context.responsiveFontSize(16),
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: context.responsiveSize(80)),

                // ⭐ GOOGLE SIGN-IN BUTTON FIXED
                SizedBox(
                  width: double.infinity,
                  height: context.responsiveSize(60),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.g_mobiledata,
                            size: 24,
                            color: AppColors.primaryBlue,
                          ),
                    label: Text(
                      _isLoading ? 'Signing in...' : 'Continue with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.responsiveSize(20)),

                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ FIXED LOGIN FLOW
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        // Navigate to MainScreen (with bottom nav) instead of DashboardScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign in error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
