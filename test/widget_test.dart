import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frami_mobile/main.dart';
import 'package:frami_mobile/core/providers/app_providers.dart';

void main() {
  testWidgets('Private workspace is gated by the mock owner login',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const DeveloperWorkplaceApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Owner-only workspace'), findsOneWidget);
    expect(find.text('Unlock Workspace'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Unlock Workspace'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the demo passcode 1234'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock Workspace'));
    await tester.pumpAndSettle();

    expect(find.text("Today's Workspace"), findsOneWidget);
  });
}
