// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oneclick2service/main.dart';

void main() {
  testWidgets('One Click 2 Service app smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OneClickApp());

    // Verify that our app title is displayed.
    expect(find.text('One Click 2 Service - Test'), findsOneWidget);
    expect(find.text('One Click 2 Service'), findsOneWidget);
    expect(
      find.text('Your trusted service provider in Vijayawada'),
      findsOneWidget,
    );

    // Verify that test form elements are present.
    expect(find.text('Test Features'), findsOneWidget);
    expect(find.text('Enter Phone Number'), findsOneWidget);
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);

    // Verify that working features list is displayed.
    expect(find.text('✅ Working Features:'), findsOneWidget);
    expect(find.text('Location Picker with Map'), findsOneWidget);
    expect(find.text('Payment Integration (Razorpay + UPI)'), findsOneWidget);
    expect(find.text('Real-time Chat System'), findsOneWidget);
    expect(find.text('Booking Management'), findsOneWidget);
    expect(find.text('Profile Management'), findsOneWidget);
    expect(find.text('Service Provider Verification'), findsOneWidget);
  });
}
