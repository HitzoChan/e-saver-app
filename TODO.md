# Dark Mode Implementation Plan

## Overview
Implement dark mode support across all screens in the E-Saver app. Currently, only dashboard and settings screens check for dark mode. All other screens use fixed gradients and colors.

## Screens to Update
- [ ] track_save_screen.dart - Update gradient, text colors, card backgrounds
- [ ] add_appliance_screen.dart - Update gradient, text colors, card backgrounds
- [ ] planner_screen.dart - Update gradient, text colors, card backgrounds
- [ ] profile_screen.dart - Update gradient, text colors, card backgrounds
- [ ] budget_setting_screen.dart - Update gradient, text colors, card backgrounds
- [ ] electricity_rate_screen.dart - Update gradient, text colors, card backgrounds
- [ ] energy_tips_screen.dart - Update gradient, text colors, card backgrounds
- [ ] add_appliance_form_screen.dart - Update gradient, text colors, card backgrounds
- [ ] onboarding_screen.dart - Update gradient, text colors, card backgrounds
- [ ] login_screen.dart - Update gradient, text colors, card backgrounds
- [ ] splash_screen.dart - Update gradient, text colors, card backgrounds

## Implementation Details
For each screen:
1. Replace fixed `AppColors.primaryGradient` with conditional gradient based on `Theme.of(context).brightness`
2. Update text colors to use theme-aware colors (white/grey for dark, black/grey for light)
3. Ensure card backgrounds and other UI elements adapt properly
4. Test contrast and readability in both themes

## Dark Theme Colors to Use
- Background: Colors.black or Colors.grey[900]
- Text: Colors.white, Colors.white70, Colors.white.withValues(alpha: 0.7)
- Cards: Colors.grey[900] or Colors.grey[800]
- Accents: Keep AppColors.primaryBlue, AppColors.accentGreen as is
