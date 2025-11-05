// This is a basic Flutter widget test for E-Saver app.

import 'package:flutter_test/flutter_test.dart';

import 'package:e_saver/main.dart';
import 'package:e_saver/providers/settings_provider.dart';

void main() {
  testWidgets('E-Saver app smoke test', (WidgetTester tester) async {
    // Create a mock settings provider
    final settingsProvider = SettingsProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(settingsProvider: settingsProvider));

    // Verify that splash screen loads
    expect(find.text('E-Saver'), findsOneWidget);
    expect(find.text('Track Your Energy Usage'), findsOneWidget);

    // Wait for splash screen animation and navigation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that onboarding screen appears
    expect(find.text('Welcome to E-Saver'), findsOneWidget);
  });
}
