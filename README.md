# E-Saver - Energy Saving Flutter Application

A beautiful and modern Flutter application for tracking and managing energy consumption of household appliances.

## Features

### 📱 Screens Implemented

1. **Dashboard Screen**
   - Beautiful gradient background
   - Animated wave graph showing energy usage over the week
   - E-Saver logo and branding
   - Clean and modern UI

2. **Onboarding/Welcome Screen**
   - Introduction to the app
   - Current month estimate display (PHP 1245.60)
   - Track usage toggle
   - Get started button

3. **Track Your Save Smart Screen**
   - Appliance category grid (Washing, TV, Essentials, Hairdryer, Roomcooler)
   - Frequency/Day bar chart
   - Weekly usage visualization
   - Notification toggle
   - Get Started button

4. **Electricity Rate Screen**
   - Rate per kWh display
   - Appliance selector
   - Estimated rate calculation
   - Check for updates functionality

5. **Planner Screen**
   - 70% circular progress indicator
   - Budget categories (Keep Good Habits, Essentials Budget, Tips & Tricks)
   - Appliance budget list
   - Set Monthly Budget button

6. **Add Appliance Screen**
   - User profile display
   - Connection statistics
   - Average bill and household average
   - Appliance list with details
   - Add new appliance button

7. **Energy Saving Tips Screen**
   - Tips and notifications list
   - Unplug idle devices tip
   - Use natural light tip
   - SAME/C rice update notification
   - View on Facebook button

### 🎨 Design Features

- **Color Scheme**: Blue gradient theme with green accents
- **Typography**: Google Fonts (Poppins)
- **Charts**: Interactive charts using fl_chart package
- **Navigation**: Custom bottom navigation bar with 5 tabs
- **Animations**: Smooth transitions and wave animations

### 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point with navigation
├── screens/
│   ├── dashboard_screen.dart          # Main dashboard with graph
│   ├── onboarding_screen.dart         # Welcome/onboarding flow
│   ├── track_save_screen.dart         # Track your save smart
│   ├── electricity_rate_screen.dart   # Electricity rate checker
│   ├── planner_screen.dart            # Budget planner
│   ├── add_appliance_screen.dart      # Add/manage appliances
│   └── energy_tips_screen.dart        # Energy saving tips
├── widgets/
│   ├── custom_bottom_nav.dart         # Bottom navigation bar
│   ├── wave_graph.dart                # Animated wave graph
│   └── appliance_card.dart            # Appliance display cards
└── utils/
    ├── app_colors.dart                # Color constants
    └── constants.dart                 # App constants
```

### 📦 Dependencies

- `flutter`: SDK
- `google_fonts`: ^6.1.0 - Custom fonts
- `fl_chart`: ^0.68.0 - Charts and graphs
- `cupertino_icons`: ^1.0.8 - iOS style icons

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- An emulator or physical device

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd demo_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running on Different Platforms

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d chrome
```

**Windows:**
```bash
flutter run -d windows
```

## Usage

1. **Launch the app** - You'll see the Dashboard screen with the wave graph
2. **Navigate** - Use the bottom navigation bar to switch between screens:
   - Home: Dashboard with energy usage graph
   - Stats: Track Your Save Smart screen
   - Add: Add Appliance screen
   - Planner: Budget planner with circular progress
   - Profile: Energy Saving Tips screen
3. **Get Started** - Tap the floating action button on the dashboard to see the onboarding screen
4. **Explore** - Navigate through different screens to explore all features

## Color Palette

- **Primary Blue**: #4169E1
- **Dark Blue**: #1E3A8A
- **Light Blue**: #93C5FD
- **Accent Green**: #10B981
- **Mint Green**: #6EE7B7

## Screenshots

The app includes 7 main screens:
- Dashboard with animated wave graph
- Onboarding/Welcome screen
- Track Your Save Smart with appliance categories
- Electricity Rate checker
- Budget Planner with 70% progress
- Add Appliance with user profile
- Energy Saving Tips

## Future Enhancements

- [ ] Add backend integration for real-time data
- [ ] Implement user authentication
- [ ] Add data persistence with local database
- [ ] Implement push notifications
- [ ] Add more detailed analytics
- [ ] Integrate with smart home devices
- [ ] Add export functionality for reports
- [ ] Implement dark mode

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Design inspiration from modern energy management apps
- Flutter community for excellent packages and support
- Google Fonts for beautiful typography
- fl_chart for powerful charting capabilities

## Contact

For questions or support, please open an issue in the repository.

---

Built with ❤️ using Flutter
