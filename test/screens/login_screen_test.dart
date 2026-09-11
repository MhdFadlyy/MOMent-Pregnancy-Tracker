import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moment/screens/login_screen.dart';

// Renders LoginScreen directly (not through MomentApp/main()) so this test
// doesn't need a real Firebase connection — the screen only touches
// FirebaseAuth inside button callbacks, never during build.
void main() {
  testWidgets('shows email/password fields and starts in sign-in mode', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('toggling to create-account mode swaps the button label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.widgetWithText(TextButton, 'Create Account'));
    await tester.pump();

    expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsNothing);
  });
}
